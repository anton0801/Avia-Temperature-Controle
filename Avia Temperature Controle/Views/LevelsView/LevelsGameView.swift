import SwiftUI

struct LevelsGameView: View {
    
    @Environment(\.presentationMode) var presMode
    @EnvironmentObject var userData: UserData
    
    @State var levels: [[Level]] = []
    
    @StateObject var levelsGenerator: LevelsGenerator = LevelsGenerator()
    @State var levelChecker = LevelChecker()
    @State var levelsPage = 0
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("LEVELS")
                        .font(.custom("ZenAntique-Regular", size: 42))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                if !levels.isEmpty {
                    LazyVGrid(columns: [
                        GridItem(.fixed(85), spacing: 42),
                        GridItem(.fixed(85), spacing: 42),
                        GridItem(.fixed(85), spacing: 42),
                        GridItem(.fixed(85), spacing: 42)
                    ], spacing: 18) {
                        ForEach(levels[levelsPage], id: \.id) { level in
                            if levelChecker.isLevelAvailable(level: level.level) {
                                NavigationLink(destination: SceneGameView(level: level)
                                    .environmentObject(userData)
                                    .navigationBarBackButtonHidden(true)) {
                                    ZStack {
                                        Image("level_item_back")
                                        Text("\(level.level)")
                                            .font(.custom("ZenAntique-Regular", size: 32))
                                            .foregroundColor(.white)
                                            .padding(.bottom, 8)
                                    }
                                }
                            } else {
                                ZStack {
                                    Image("level_item_back")
                                    Text("\(level.level)")
                                        .font(.custom("ZenAntique-Regular", size: 32))
                                        .foregroundColor(.white)
                                        .padding(.bottom, 8)
                                }
                                .opacity(0.6)
                            }
                        }
                    }
                }
                
                Spacer()
                
                HStack {
                    Button {
                        withAnimation {
                            levelsPage -= 1
                        }
                    } label: {
                        Image("back_btn")
                    }
                    .opacity(levelsPage == 0 ? 0.6 : 1)
                    .disabled(levelsPage == 0 ? true : false)
                    
                    Spacer().frame(width: 12)
                    
                    Button {
                        withAnimation {
                            levelsPage += 1
                        }
                    } label: {
                        Image("next_btn")
                    }
                    .opacity(levelsPage == levels.count - 1 ? 0.6 : 1)
                    .disabled(levelsPage == levels.count - 1 ? true : false)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        presMode.wrappedValue.dismiss()
                    } label: {
                        Image("back_btn")
                    }
                    .offset(y: 30)
                }
            }
            .background(
                Image("levels_bg")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width + 10, height: UIScreen.main.bounds.height + 25)
                    .edgesIgnoringSafeArea(.all)
            )
            .onAppear {
                levels = levelsGenerator.trunckadedLevelsArray()
            }
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    LevelsGameView()
        .environmentObject(UserData())
}
