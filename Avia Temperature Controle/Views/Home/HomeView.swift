import SwiftUI

struct HomeView: View {
    
    @State var userData: UserData = UserData()
    @State var levelChecker = LevelChecker()
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                NavigationLink(destination: ConfigurationGameView()
                    .navigationBarBackButtonHidden(true)) {
                        Image("settings_main_btn")
                            .resizable()
                            .frame(width: 115, height: 80)
                    }
                Spacer()
                NavigationLink(destination: LevelsGameView()
                    .environmentObject(userData)
                    .navigationBarBackButtonHidden(true)) {
                        Image("play_main_btn")
                    }
                Spacer()
                NavigationLink(destination: ShopView()
                    .environmentObject(userData)
                    .navigationBarBackButtonHidden(true)) {
                        Image("shop_btn")
                            .resizable()
                            .frame(width: 115, height: 80)
                    }
                Spacer()
            }
            .background(
                Image("menu_back")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width + 10, height: UIScreen.main.bounds.height + 25)
                    .edgesIgnoringSafeArea(.all)
            )
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        exit(0)
                    } label: {
                        Image("exit_btn")
                            .resizable()
                            .frame(width: 80, height: 55)
                    }
                    .offset(y: 30)
                }
            }
            .onAppear {
                if !levelChecker.isLevelAvailable(level: 1) {
                    levelChecker.setLevelAvailable(levelNum: 1)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    HomeView()
}
