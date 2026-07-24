import Foundation
import SwiftUI
import Combine

class ArtworkStore: ObservableObject {
    @Published var artworks: [LatteArtwork] = []
    
    private let saveKey = "saved_latte_artworks"
    
    init() {
        loadArtworks()
    }
    
    func loadArtworks() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            do {
                let decoded = try JSONDecoder().decode([LatteArtwork].self, from: data)
                self.artworks = decoded.sorted(by: { $0.date > $1.date })
            } catch {
                print("Failed to decode artworks: \(error.localizedDescription)")
            }
        }
    }
    
    func saveArtworks() {
        do {
            let encoded = try JSONEncoder().encode(artworks)
            UserDefaults.standard.set(encoded, forKey: saveKey)
        } catch {
            print("Failed to encode artworks: \(error.localizedDescription)")
        }
    }
    
    func addArtwork(pattern: LattePattern, drink: DrinkType, image: UIImage) {
        let fileName = "\(UUID().uuidString).jpg"
        
        // Save image to documents directory
        if let data = image.jpegData(compressionQuality: 0.8) {
            let url = getDocumentsDirectory().appendingPathComponent(fileName)
            try? data.write(to: url)
        }
        
        let newArt = LatteArtwork(pattern: pattern, drink: drink, date: Date(), imageFileName: fileName)
        DispatchQueue.main.async {
            self.artworks.insert(newArt, at: 0)
            self.saveArtworks()
        }
    }
    
    func deleteArtwork(at offsets: IndexSet) {
        for index in offsets {
            let art = artworks[index]
            let url = getDocumentsDirectory().appendingPathComponent(art.imageFileName)
            try? FileManager.default.removeItem(at: url)
        }
        artworks.remove(atOffsets: offsets)
        saveArtworks()
    }
    
    func deleteArtwork(_ artwork: LatteArtwork) {
        if let index = artworks.firstIndex(where: { $0.id == artwork.id }) {
            let url = getDocumentsDirectory().appendingPathComponent(artwork.imageFileName)
            try? FileManager.default.removeItem(at: url)
            artworks.remove(at: index)
            saveArtworks()
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func loadImage(fileName: String) -> UIImage? {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        return UIImage(contentsOfFile: url.path)
    }
}
