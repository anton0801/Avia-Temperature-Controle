import SwiftUI

struct ShopView: View {
    
    @Environment(\.presentationMode) var preseMode
    
    @EnvironmentObject var userData: UserData
    @StateObject var shopData: ShopData = ShopData()
    
    @State var currentShopItem: ShopItem?
    @State var currentShopItemIndex = 0 {
        didSet {
            currentShopItem = shopData.shopItems[currentShopItemIndex]
            if currentShopItem!.type == .map {
                background = currentShopItem!.item
            } else {
                background = userData.map
            }
        }
    }
    @State var background = "map_base"
    
    @State var buyItemStatus = false
    
    var body: some View {
        VStack {
            if let currentShopItem = currentShopItem {
                HStack {
                    Spacer()
                    Text(currentShopItem.name)
                       .font(.custom("ZenAntique-Regular", size: 42))
                       .foregroundColor(.white)
                       .offset(x: 75)
                    Spacer()
                    ZStack {
                        Image("value_bg")
                            .resizable()
                            .frame(width: 150, height: 70)
                        HStack {
                            Text("\(userData.credits)")
                                .font(.custom("ZenAntique-Regular", size: 32))
                                .foregroundColor(.white)
                            Image("coin")
                                .resizable()
                                .frame(width: 26, height: 26)
                        }
                        .padding(.bottom, 4)
                    }
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button {
                        withAnimation {
                            currentShopItemIndex -= 1
                        }
                    } label: {
                        Image("back_btn")
                    }
                    .opacity(currentShopItemIndex == 0 ? 0.6 : 1)
                    .disabled(currentShopItemIndex == 0 ? true : false)
                    
                    Spacer()
                    
                    ZStack {
                        Image("price_item")
                        HStack {
                            if currentShopItem.type == .booster {
                                Text("15")
                                    .font(.custom("ZenAntique-Regular", size: 42))
                                    .foregroundColor(.white)
                                Image("coin")
                                    .resizable()
                                    .frame(width: 38, height: 38)
                                Image("celcius")
                            } else {
                                Text("25")
                                    .font(.custom("ZenAntique-Regular", size: 42))
                                    .foregroundColor(.white)
                                Image("coin")
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            currentShopItemIndex += 1
                        }
                    } label: {
                        Image("next_btn")
                    }
                    .opacity(currentShopItemIndex == shopData.shopItems.count - 1 ? 0.6 : 1)
                    .disabled(currentShopItemIndex == shopData.shopItems.count - 1 ? true : false)
                    
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    if !shopData.shopItemsInStock.contains(where: { $0.id == currentShopItem.id }) {
                        Button {
                            preseMode.wrappedValue.dismiss()
                        } label: {
                            Image("close_btn")
                                .resizable()
                                .frame(width: 85, height: 60)
                        }
                        
                        Spacer().frame(width: 60)
                        
                        Button {
                            buyItemStatus = !shopData.buyShopItem(userData: userData, shopItem: currentShopItem)
                        } label: {
                            Image("done_btn")
                                .resizable()
                                .frame(width: 85, height: 60)
                        }
                    } else {
                        if currentShopItem.item == userData.map {
                            VStack {
                                Image("done_btn")
                                    .resizable()
                                    .frame(width: 85, height: 60)
                                Text("SELECTED")
                                    .font(.custom("ZenAntique-Regular", size: 32))
                                    .foregroundColor(.white)
                            }
                        } else {
                            Button {
                                userData.map = currentShopItem.item
                            } label: {
                                Image("done_btn")
                                    .resizable()
                                    .frame(width: 85, height: 60)
                            }
                        }
                    }
                }
            }
        }
        .background(
            Image(background)
                .resizable()
                .frame(width: UIScreen.main.bounds.width + 10, height: UIScreen.main.bounds.height + 25)
                .edgesIgnoringSafeArea(.all)
        )
        .onAppear {
            background = userData.map
            currentShopItem = shopData.shopItems[0]
        }
        .alert(isPresented: $buyItemStatus) {
            Alert(
                title: Text("Shop Error"),
                message: Text("Looks like you don't have enough credits to buy this item, go through more levels to buy this item!"),
                dismissButton: .cancel(Text("OK!"))
            )
        }
    }
}

#Preview {
    ShopView()
        .environmentObject(UserData())
}
