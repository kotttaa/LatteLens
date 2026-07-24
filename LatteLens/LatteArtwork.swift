import Foundation

enum LattePattern: String, Codable, CaseIterable, Identifiable {
    case heart = "Heart"
    case layeredHeart = "Layered Heart"
    case leaf = "Leaf"
    case swan = "Swan"
    case tulip = "Tulip"
    case rosetta = "Rosetta"
    case other = "Other"
    
    var id: String { self.rawValue }
    
    var localizedName: String {
        switch self {
        case .heart: return "ハート"
        case .layeredHeart: return "レイヤーハート"
        case .leaf: return "リーフ"
        case .swan: return "スワン"
        case .tulip: return "チューリップ"
        case .rosetta: return "ロゼッタ"
        case .other: return "その他"
        }
    }
}

enum DrinkType: String, Codable, CaseIterable, Identifiable {
    case latte = "Latte"
    case matchaLatte = "Matcha Latte"
    case cafeMocha = "Cafe Mocha"
    case flatWhite = "Flat White"
    case cappuccino = "Cappuccino"
    case other = "Other"
    
    var id: String { self.rawValue }
    
    var localizedName: String {
        switch self {
        case .latte: return "ラテ"
        case .matchaLatte: return "抹茶ラテ"
        case .cafeMocha: return "カフェモカ"
        case .flatWhite: return "フラットホワイト"
        case .cappuccino: return "カプチーノ"
        case .other: return "その他"
        }
    }
}

struct LatteArtwork: Identifiable, Codable {
    var id = UUID()
    var pattern: LattePattern
    var drink: DrinkType
    var date: Date
    var imageFileName: String
}
