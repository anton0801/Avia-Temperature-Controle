import Foundation

class LevelChecker {
    
    func isLevelAvailable(level: Int) -> Bool {
        return UserDefaults.standard.bool(forKey: "level_\(level)")
    }
    
    func setLevelAvailable(levelNum: Int) {
        UserDefaults.standard.set(true, forKey: "level_\(levelNum)")
    }
    
}
