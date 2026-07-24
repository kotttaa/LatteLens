import Foundation
import FirebaseFirestore

struct CommunityArtwork: Identifiable {
    var id: String
    var imageUrl: String
    var pattern: String
    var drink: String
    var userId: String
    var userName: String
    var createdAt: Date
    
    init(id: String, documentData: [String: Any]) {
        self.id = id
        self.imageUrl = documentData["imageUrl"] as? String ?? ""
        self.pattern = documentData["pattern"] as? String ?? ""
        self.drink = documentData["drink"] as? String ?? ""
        self.userId = documentData["userId"] as? String ?? ""
        self.userName = documentData["userName"] as? String ?? "Latte Artist"
        if let timestamp = documentData["createdAt"] as? Timestamp {
            self.createdAt = timestamp.dateValue()
        } else {
            self.createdAt = Date()
        }
    }
}
