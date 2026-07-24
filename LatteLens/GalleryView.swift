import SwiftUI

struct GalleryView: View {
    @EnvironmentObject var store: ArtworkStore
    @State private var selectedFilter: String = "All"
    @State private var selectedArtwork: LatteArtwork? = nil
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    // Get filter categories
    var filterCategories: [String] {
        var cats = ["All"]
        cats.append(contentsOf: LattePattern.allCases.map { $0.rawValue })
        cats.append(contentsOf: DrinkType.allCases.map { $0.rawValue })
        return cats
    }
    
    func localizedFilterName(_ name: String) -> String {
        if name == "All" { return "すべて" }
        if let pattern = LattePattern(rawValue: name) {
            return pattern.localizedName
        }
        if let drink = DrinkType(rawValue: name) {
            return drink.localizedName
        }
        return name
    }
    
    var filteredArtworks: [LatteArtwork] {
        if selectedFilter == "All" {
            return store.artworks
        }
        return store.artworks.filter { art in
            art.pattern.rawValue == selectedFilter || art.drink.rawValue == selectedFilter
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 1. Horizontal category filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filterCategories, id: \.self) { cat in
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedFilter = cat
                                }
                            } label: {
                                Text(localizedFilterName(cat))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedFilter == cat ? Color(hex: "c4a484") : Color(white: 0.12))
                                    .foregroundColor(selectedFilter == cat ? .black : .white)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color.black)
                
                // 2. Main Grid View
                ScrollView {
                    if filteredArtworks.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "cup.and.saucer.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.top, 64)
                            Text("記録されたラテアートがありません")
                                .foregroundColor(.gray)
                            Text("「記録」タブから新しく登録してください")
                                .font(.caption)
                                .foregroundColor(.gray.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredArtworks) { art in
                                Button {
                                    selectedArtwork = art
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        // Load Image
                                        if let image = store.loadImage(fileName: art.imageFileName) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(minWidth: 0, maxWidth: .infinity)
                                                .aspectRatio(1, contentMode: .fit)
                                                .cornerRadius(12)
                                                .clipped()
                                        } else {
                                            Rectangle()
                                                .fill(Color(white: 0.1))
                                                .aspectRatio(1, contentMode: .fit)
                                                .cornerRadius(12)
                                        }
                                        
                                        // Metadata Labels
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(art.pattern.localizedName)
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                            
                                            Text(art.drink.localizedName)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .lineLimit(1)
                                        }
                                        .padding(.horizontal, 4)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
                .background(Color.black)
            }
            .navigationTitle("ギャラリー")
            .background(Color.black.ignoresSafeArea())
            .fullScreenCover(item: $selectedArtwork) { artwork in
                ReviewView(artwork: artwork)
                    .environmentObject(store)
            }
        }
    }
}
