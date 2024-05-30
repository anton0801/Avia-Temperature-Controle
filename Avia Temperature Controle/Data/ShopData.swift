import Foundation

class ShopData: ObservableObject {
    
    @Published var shopItemsInStock: [ShopItem] = []
    
    var shopItems = [
        ShopItem(id: "temperature_booster", name: "TEMPERATURE", item: "", price: 15, type: .booster),
        ShopItem(id: "map_1", name: "MAP", item: "map_1", price: 25, type: .map),
        ShopItem(id: "map_2", name: "MAP", item: "map_2", price: 25, type: .map),
        ShopItem(id: "map_3", name: "MAP", item: "map_3", price: 25, type: .map),
        ShopItem(id: "map_4", name: "MAP", item: "map_4", price: 25, type: .map)
    ]
    
    func buyShopItem(userData: UserData, shopItem: ShopItem) -> Bool {
      let credits = userData.credits
      if credits >= shopItem.price {
          userData.credits = credits - shopItem.price
          if shopItem.type != .booster {
              shopItemsInStock.append(shopItem)
              UserDefaults.standard.set(shopItemsInStock.map { $0.id }.joined(separator: ","), forKey: "stocked_items")
          } else {
              UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "temperature_booster_count") + 1, forKey: "temperature_booster_count")
          }
          return true
      }
      return false
  }
    
}

struct ShopItem {
    let id: String
    let name: String
    let item: String
    let price: Int
    let type: String
}

extension String {
    static let booster = "booster"
    static let map = "map"
}
