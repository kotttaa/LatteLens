import SwiftUI

struct ReviewView: View {
    let artwork: LatteArtwork
    @EnvironmentObject var store: ArtworkStore
    @Environment(\.dismiss) var dismiss
    
    // Image adjustment state
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var showGuidelines = false
    
    // User Settings
    @AppStorage("userName") private var userName = "Latte Artist"
    @AppStorage("communityId") private var communityId = ""
    
    // UI states
    @State private var isUploading = false
    @State private var uploadSuccess = false
    
    // Alert states
    @State private var showingPostAlert = false
    @State private var showingDeleteAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    // For drag gesture
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                // 1. Latte Art Image with gestures
                if let uiImage = store.loadImage(fileName: artwork.imageFileName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(dragGesture)
                } else {
                    ProgressView()
                }
                
                // 2. Guide Overlay Lines
                if showGuidelines {
                    SymmetryOverlay()
                }
                
                // Upload Overlay
                if isUploading {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        Text("コミュニティへ送信中...")
                            .foregroundColor(.white)
                            .padding(.top, 16)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                // Controls Panel
                VStack(spacing: 16) {
                    // Zoom Slider
                    HStack {
                        Image(systemName: "minus.magnifyingglass")
                            .foregroundColor(.gray)
                        Slider(value: $scale, in: 0.5...3.0)
                            .tint(Color(hex: "c4a484"))
                        Image(systemName: "plus.magnifyingglass")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    // Detail info
                    VStack(spacing: 4) {
                        Text("\(artwork.pattern.localizedName) • \(artwork.drink.localizedName)")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(artwork.date.formatted(date: .long, time: .shortened))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Community Share Button
                    Button {
                        showingPostAlert = true
                    } label: {
                        HStack {
                            Image(systemName: uploadSuccess ? "checkmark.icloud.fill" : "cloud.arrow.up")
                            Text(uploadSuccess ? "コミュニティに送信済み" : "コミュニティに投稿する")
                                .fontWeight(.bold)
                        }
                        .font(.headline)
                        .foregroundColor(uploadSuccess ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(uploadSuccess ? Color.green : Color(hex: "c4a484"))
                        .cornerRadius(12)
                    }
                    .disabled(isUploading || uploadSuccess)
                    
                    // Reset Button
                    Button(role: .cancel) {
                        withAnimation(.spring()) {
                            scale = 1.0
                            offset = .zero
                            lastOffset = .zero
                        }
                    } label: {
                        Text("位置をリセット")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color(hex: "c4a484"))
                    }
                }
                .padding()
                .background(Color(white: 0.1).opacity(0.85))
                .cornerRadius(24)
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // Toggle Guidelines Button
                        Button {
                            showGuidelines.toggle()
                        } label: {
                            Image(systemName: showGuidelines ? "grid.circle.fill" : "grid.circle")
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                        
                        // ShareLink
                        if let uiImage = store.loadImage(fileName: artwork.imageFileName) {
                            let shareImage = Image(uiImage: uiImage)
                            ShareLink(
                                item: shareImage,
                                preview: SharePreview(
                                    "\(artwork.pattern.localizedName) (\(artwork.drink.localizedName))",
                                    image: shareImage
                                )
                            ) {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Delete Button
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .alert("コミュニティに投稿", isPresented: $showingPostAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("投稿する") {
                    if communityId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        errorMessage = "設定タブから「コミュニティID」を設定してください。"
                        showingErrorAlert = true
                        return
                    }
                    if let uiImage = store.loadImage(fileName: artwork.imageFileName) {
                        isUploading = true
                        FirebaseManager.shared.uploadArtwork(
                            image: uiImage,
                            pattern: artwork.pattern.localizedName,
                            drink: artwork.drink.localizedName,
                            userName: userName,
                            communityId: communityId
                        ) { success, errorMsg in
                            isUploading = false
                            if success {
                                uploadSuccess = true
                            } else if let errorMsg = errorMsg {
                                errorMessage = errorMsg
                                showingErrorAlert = true
                            }
                        }
                    }
                }
            } message: {
                Text("このラテアートをコミュニティ全体に公開しますか？")
            }
            .alert("画像の削除", isPresented: $showingDeleteAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("削除する", role: .destructive) {
                    store.deleteArtwork(artwork)
                    dismiss()
                }
            } message: {
                Text("このラテアートを完全に削除しますか？この操作は取り消せません。")
            }
            .alert("エラー", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
}

// SwiftUI Symmetry Drawing
struct SymmetryOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let minDimension = min(geometry.size.width, geometry.size.height)
            
            ZStack {
                // Outer circle for cup rim
                Circle()
                    .stroke(Color.green.opacity(0.8), style: StrokeStyle(lineWidth: 1, dash: [4]))
                    .frame(width: minDimension * 0.85, height: minDimension * 0.85)
                    .position(center)
                
                // Inner circle for pattern target
                Circle()
                    .stroke(Color.green.opacity(0.4), style: StrokeStyle(lineWidth: 0.8, dash: [4]))
                    .frame(width: minDimension * 0.5, height: minDimension * 0.5)
                    .position(center)
                
                // Vertical cross line
                Path { path in
                    path.move(to: CGPoint(x: center.x, y: 0))
                    path.addLine(to: CGPoint(x: center.x, y: geometry.size.height))
                }
                .stroke(Color.green.opacity(0.8), style: StrokeStyle(lineWidth: 1, dash: [4]))
                
                // Horizontal cross line
                Path { path in
                    path.move(to: CGPoint(x: 0, y: center.y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: center.y))
                }
                .stroke(Color.green.opacity(0.8), style: StrokeStyle(lineWidth: 1, dash: [4]))
            }
        }
        .allowsHitTesting(false) // Let touches pass through to the image behind
    }
}

// Color Hex initializer helper
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 1)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
