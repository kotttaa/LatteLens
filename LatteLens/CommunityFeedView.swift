import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CommunityFeedView: View {
    @AppStorage("communityId") private var communityId = ""
    @State private var artworks: [CommunityArtwork] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if communityId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("プライベートコミュニティ")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("設定タブから「コミュニティID（合言葉）」を設定すると、そのコミュニティの投稿を閲覧・共有できるようになります。")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 80)
                } else if isLoading {
                    ProgressView()
                        .padding(.top, 50)
                } else if artworks.isEmpty {
                    Text("まだこのコミュニティには投稿がありません。")
                        .foregroundColor(.gray)
                        .padding(.top, 50)
                } else {
                    LazyVStack(spacing: 24) {
                        ForEach(artworks) { artwork in
                            CommunityCard(artwork: artwork) {
                                // Delete locally
                                if let index = artworks.firstIndex(where: { $0.id == artwork.id }) {
                                    artworks.remove(at: index)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle(communityId.isEmpty ? "コミュニティ" : "コミュニティ: \(communityId)")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if !communityId.isEmpty {
                    fetchFeed()
                }
            }
            .refreshable {
                if !communityId.isEmpty {
                    fetchFeed()
                }
            }
            .onChange(of: communityId) { _ in
                if !communityId.isEmpty {
                    fetchFeed()
                } else {
                    artworks = []
                }
            }
        }
    }
    
    func fetchFeed() {
        isLoading = true
        FirebaseManager.shared.db.collection("communities").document(communityId).collection("artworks")
            .order(by: "createdAt", descending: true)
            .limit(to: 30)
            .getDocuments { snapshot, error in
                self.isLoading = false
                guard let documents = snapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "")")
                    return
                }
                
                self.artworks = documents.map { doc in
                    CommunityArtwork(id: doc.documentID, documentData: doc.data())
                }
            }
    }
}

struct CommunityCard: View {
    @AppStorage("communityId") private var communityId = ""
    let artwork: CommunityArtwork
    let onDelete: () -> Void
    
    @State private var showingDeleteAlert = false
    @State private var isDeleting = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // User header mock
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                    )
                Text(artwork.userName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
                Text(artwork.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.gray)
                    
                if artwork.userId == Auth.auth().currentUser?.uid {
                    Button {
                        showingDeleteAlert = true
                    } label: {
                        if isDeleting {
                            ProgressView().scaleEffect(0.8)
                        } else {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    .disabled(isDeleting)
                }
            }
            .padding(.horizontal)
            
            // Image (AsyncImage)
            AsyncImage(url: URL(string: artwork.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color(white: 0.1))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure:
                    Rectangle()
                        .fill(Color(white: 0.1))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(Image(systemName: "exclamationmark.triangle").foregroundColor(.gray))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity)
            
            // Info
            HStack {
                Text(artwork.pattern)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: "c4a484"))
                    .foregroundColor(.black)
                    .cornerRadius(8)
                
                Text(artwork.drink)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 16)
        .background(Color(white: 0.05))
        .cornerRadius(16)
        .padding(.horizontal, 12)
        .alert("投稿を削除", isPresented: $showingDeleteAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("削除する", role: .destructive) {
                isDeleting = true
                FirebaseManager.shared.deleteCommunityArtwork(communityId: communityId, artworkId: artwork.id, imageUrl: artwork.imageUrl) { success, errorMsg in
                    isDeleting = false
                    if success {
                        onDelete()
                    } else {
                        print("Error deleting: \(errorMsg ?? "")")
                    }
                }
            }
        } message: {
            Text("この投稿をコミュニティから削除しますか？")
        }
    }
}
