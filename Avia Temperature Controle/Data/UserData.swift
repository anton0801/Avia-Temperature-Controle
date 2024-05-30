import Foundation

class UserData: ObservableObject {
    
    @Published var map = UserDefaults.standard.string(forKey: "map") ?? "map_base" {
        didSet {
            UserDefaults.standard.set(map, forKey: "map")
        }
    }
    
    @Published var credits = UserDefaults.standard.integer(forKey: "credits") {
        didSet {
            UserDefaults.standard.set(credits, forKey: "credits")
        }
    }
    
}
