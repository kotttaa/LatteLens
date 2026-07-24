import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UIKit
import Combine

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    @Published var isAuthenticated = false
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    init() {
        _ = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            self?.isAuthenticated = (user != nil)
            if user == nil {
                self?.signInAnonymously()
            }
        }
    }
    
    func signInAnonymously() {
        Auth.auth().signInAnonymously { authResult, error in
            if let error = error {
                print("Error signing in anonymously: \(error.localizedDescription)")
            } else {
                print("Signed in anonymously!")
            }
        }
    }
    
    func uploadArtwork(image: UIImage, pattern: String, drink: String, userName: String, communityId: String, completion: @escaping (Bool, String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(false, "Failed to compress image")
            return
        }
        
        let filename = UUID().uuidString + ".jpg"
        let storageRef = storage.reference().child("community_artworks").child(filename)
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(false, "Storage Error: \(error.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    completion(false, "Failed to get download URL")
                    return
                }
                
                let dbData: [String: Any] = [
                    "imageUrl": downloadURL.absoluteString,
                    "pattern": pattern,
                    "drink": drink,
                    "userId": Auth.auth().currentUser?.uid ?? "unknown",
                    "userName": userName,
                    "createdAt": FieldValue.serverTimestamp()
                ]
                
                self.db.collection("communities").document(communityId).collection("artworks").addDocument(data: dbData) { error in
                    if let error = error {
                        print("Error saving document: \(error.localizedDescription)")
                        completion(false, "Firestore Error: \(error.localizedDescription)")
                    } else {
                        completion(true, nil)
                    }
                }
            }
        }
    }
    
    func deleteCommunityArtwork(communityId: String, artworkId: String, imageUrl: String, completion: @escaping (Bool, String?) -> Void) {
        db.collection("communities").document(communityId).collection("artworks").document(artworkId).delete { error in
            if let error = error {
                completion(false, "Firestore Error: \(error.localizedDescription)")
                return
            }
            
            let storageRef = self.storage.reference(forURL: imageUrl)
            storageRef.delete { error in
                if let error = error {
                    print("Storage deletion error (ignoring): \(error.localizedDescription)")
                }
                completion(true, nil)
            }
        }
    }
}
