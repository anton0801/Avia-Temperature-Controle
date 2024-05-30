import SwiftUI
import SpriteKit

struct SceneGameView: View {
    
    @Environment(\.presentationMode) var presMode
    
    @EnvironmentObject var userData: UserData
    let levelChecker = LevelChecker()
    
    var level: Level
    
    @State var gameScene: GameScene? = nil
    
    @State private var pauseViewNeedShow = false
    @State private var winViewNeedShow = false
    @State private var loseViewNeedShow = false
    
    var body: some View {
        ZStack {
            if gameScene != nil {
                SpriteView(scene: gameScene!)
                    .ignoresSafeArea()
                    .onReceive(NotificationCenter.default.publisher(for: Notification.Name("pause"))) { _ in
                        pauseContentShow()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: Notification.Name("win"))) { _ in
                        winGameShow()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: Notification.Name("lose"))) { _ in
                        loseGameShow()
                    }
            }
            if pauseViewNeedShow {
                pauseView
            }
            
            if winViewNeedShow {
                winView
            }
            
            if loseViewNeedShow {
                loseView
            }
        }
        .onAppear {
            gameScene = GameScene()
            gameScene!.level = level
        }
    }
    
    private func winGameShow() {
        withAnimation {
            winViewNeedShow = true
        }
        let totalPoints = userData.credits
        userData.credits = totalPoints + 10
        levelChecker.setLevelAvailable(levelNum: level.level + 1)
    }
    
    private func loseGameShow() {
        withAnimation {
            loseViewNeedShow = true
        }
    }
    
    private func pauseContentShow() {
        withAnimation {
            pauseViewNeedShow = true
        }
    }
    
    private var pauseView: some View {
        VStack {
            Text("PAUSE")
                .font(.custom("ZenAntique-Regular", size: 42))
                .foregroundColor(.white)
            
            Spacer()
            
            Image("game_on_hold")
                .zIndex(2)
            HStack {
                Button {
                    presMode.wrappedValue.dismiss()
                } label: {
                    Image("back_btn")
                }
                Button {
                    gameScene = gameScene!.createNewGame()
                    withAnimation {
                        pauseViewNeedShow = false
                    }
                } label: {
                    Image("restart_btn")
                }
                Button {
                    withAnimation {
                        pauseViewNeedShow = false
                    }
                    gameScene!.continuePlayingGame()
                } label: {
                    Image("next_btn")
                }
            }
            .offset(y: -20)
            .zIndex(1)
            
            Spacer()
        }
        .background(
            Image("result_game_bg")
                .resizable()
                .frame(width: UIScreen.main.bounds.width + 10, height: UIScreen.main.bounds.height + 25)
                .edgesIgnoringSafeArea(.all)
        )
    }
    
    private var winView: some View {
        VStack {
            Text("WIN")
                .font(.custom("ZenAntique-Regular", size: 42))
                .foregroundColor(.white)
            
            Spacer()
            
            Image("win_text")
                .zIndex(1)
            HStack {
                Button {
                    presMode.wrappedValue.dismiss()
                } label: {
                    Image("back_btn")
                }
                Button {
                    gameScene = gameScene!.createNewGame()
                    withAnimation {
                        winViewNeedShow = false
                    }
                } label: {
                    Image("restart_btn")
                }
            }
            .offset(y: -20)
            .zIndex(2)
            
            Spacer()
        }
        .background(
            Image("result_game_bg")
                .resizable()
                .frame(width: UIScreen.main.bounds.width + 10, height: UIScreen.main.bounds.height + 25)
                .edgesIgnoringSafeArea(.all)
        )
    }
    
    private var loseView: some View {
        VStack {
            Text("LOSE")
                .font(.custom("ZenAntique-Regular", size: 42))
                .foregroundColor(.white)
            
            Spacer()
            
            Image("lose_text")
                .zIndex(1)
            HStack {
                Button {
                    gameScene = gameScene!.createNewGame()
                    withAnimation {
                        loseViewNeedShow = false
                    }
                } label: {
                    Image("restart_btn")
                }
            }
            .offset(y: -20)
            .zIndex(2)
            
            Spacer()
        }
        .background(
            Image("result_game_bg")
                .resizable()
                .frame(width: UIScreen.main.bounds.width + 10, height: UIScreen.main.bounds.height + 25)
                .edgesIgnoringSafeArea(.all)
        )
    }
    
}

#Preview {
    SceneGameView(level: Level(id: "level_1", level: 1, time: 30, vulkan: false, rain: false, wind: false, complicationsCount: 0))
        .environmentObject(UserData())
}
