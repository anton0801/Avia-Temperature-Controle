import SwiftUI

struct ConfigurationGameView: View {
    
    @Environment(\.presentationMode) var presMode
    
    @State var soundsEnabled = UserDefaults.standard.bool(forKey: "sounds")
    @State var musicEnabled = UserDefaults.standard.bool(forKey: "music")
    
    var body: some View {
        VStack {
            Text("CONFIGURATION")
                .font(.custom("ZenAntique-Regular", size: 42))
                .foregroundColor(.white)
            
            Spacer()
            
            ZStack {
                Image("config_bg")
                VStack(alignment: .leading) {
                    Button {
                        withAnimation {
                            soundsEnabled = !soundsEnabled
                        }
                    } label: {
                        HStack {
                            Image("sound")
                                .resizable()
                                .frame(width: 40, height: 40)
                            if soundsEnabled {
                                Image("config_field_full")
                            } else {
                                Image("config_field_empty")
                            }
                        }
                    }
                    
                    Button {
                        withAnimation {
                            musicEnabled = !musicEnabled
                        }
                    } label: {
                        HStack {
                            Image("music")
                                .resizable()
                                .frame(width: 40, height: 40)
                            if musicEnabled {
                                Image("config_field_full")
                            } else {
                                Image("config_field_empty")
                            }
                        }
                    }
                }
            }
            
            Button {
                saveConfigChanges()
                presMode.wrappedValue.dismiss()
            } label: {
                Image("done_btn")
            }
            .offset(y: -20)
            
            Spacer()
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
            Image("menu_back")
                .resizable()
                .frame(width: UIScreen.main.bounds.width + 10, height: UIScreen.main.bounds.height + 25)
                .edgesIgnoringSafeArea(.all)
        )
    }
    
    private func saveConfigChanges() {
        UserDefaults.standard.set(soundsEnabled, forKey: "sounds")
        UserDefaults.standard.set(musicEnabled, forKey: "music")
    }
    
}

#Preview {
    ConfigurationGameView()
}
