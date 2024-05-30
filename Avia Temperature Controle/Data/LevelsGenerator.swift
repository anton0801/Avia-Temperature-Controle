import Foundation

class LevelsGenerator: ObservableObject {
    
    @Published var allLevels: [Level] = []
    
    init() {
        allLevels = generateAllLevels()
    }
    
    func generateAllLevels() -> [Level] {
        var result: [Level] = []
        for levelNumber in 1...24 {
            let level = Level(id: "level_\(levelNumber)", level: levelNumber, time: 30 + (5 * levelNumber), vulkan: levelNumber >= 2, rain: levelNumber >= 4, wind: levelNumber >= 6, complicationsCount: levelNumber >= 2 ? 5 + (levelNumber - 2) : 0)
            result.append(level)
        }
        return result
    }
    
    func trunckadedLevelsArray() -> [[Level]] {
        var result: [[Level]] = []
        var temp: [Level] = []
        for (index, tempLevel) in allLevels.enumerated() {
            temp.append(tempLevel)
            if (index + 1) % 8 == 0 {
                result.append(temp)
                temp = []
            }
        }
        return result
    }
    
}
