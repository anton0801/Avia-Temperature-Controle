import Foundation
import SwiftUI
import SpriteKit

class GameScene: SKScene {
    
    func formatTime(seconds: Int) -> String {
        if seconds < 60 {
            return "\(seconds)"
        } else {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return String(format: "%d:%02d", minutes, remainingSeconds)
        }
    }
    
    var level: Level!
    
    private var rulesTitle: SKSpriteNode!
    private var rulesContent: SKSpriteNode!
    private var rulesNextBtn: SKSpriteNode!
    
    private var plane: SKSpriteNode!
    
    private var gamePauseBtn: SKSpriteNode!
    
    private var gameCreditsLabel: SKLabelNode!
    private var gameTimeLabel: SKLabelNode!
    
    private var gameLevelLabel: SKLabelNode!
    
    private var credits = UserDefaults.standard.integer(forKey: "credits") {
        didSet {
            gameCreditsLabel.text = "\(credits)"
            UserDefaults.standard.set(credits, forKey: "credits")
        }
    }
    
    private var gameTime = 30 {
        didSet {
            gameTimeLabel.text = formatTime(seconds: gameTime)
            if gameTime == 0 {
                isTimePaused = true
                let actionMove = SKAction.move(to: CGPoint(x: size.width + 100, y: plane.position.y), duration: 3)
                plane.run(actionMove) {
                    NotificationCenter.default.post(name: Notification.Name("win"), object: nil, userInfo: nil)
                }
            }
        }
    }
    private var isTimePaused = false
    private var gameTimer = Timer()
    private var complicationsSpawner = Timer()
    
    private var tempCold: CGFloat = 7 {
        didSet {
            setUpTempCold()
            if tempCold == 13 {
                NotificationCenter.default.post(name: Notification.Name("lose"), object: nil, userInfo: ["info": "cooled"])
            }
        }
    }
    
    private var tempHot: CGFloat = 7 {
        didSet {
            setUpHotTemp()
            if tempHot == 13 {
                NotificationCenter.default.post(name: Notification.Name("lose"), object: nil, userInfo: ["info": "hot"])
            }
        }
    }
    
    private var tempColdNodes: [SKSpriteNode] = []
    private var tempHotNodes: [SKSpriteNode] = []
    
    private var boosterTemperature: SKSpriteNode!
    private var boosterTemperatureCountLabel: SKLabelNode!
    
    private var boosterTemperatureCount = UserDefaults.standard.integer(forKey: "temperature_booster_count") {
        didSet {
            boosterTemperatureCountLabel.text = "\(boosterTemperatureCount)"
            UserDefaults.standard.set(boosterTemperatureCount, forKey: "temperature_booster_count")
        }
    }
    
    private let allComplications = ["complication_vulkan", "complication_rain", "complication_wind"]
    private let complicationSizes = ["complication_vulkan": (120, 110), "complication_rain": (100, 90), "complication_wind": (100, 90)]
    private var availableComplications = [String]()
    private var complicationNodes: [SKSpriteNode] = []
    private var spawnedComplicationsCount = 0
    
    private var allRules = ["rules_1", "rules_2", "rules_3", "rules_4", "rules_5"]
    private var currentRulesContentIndex = 0 {
        didSet {
            let newTexture = SKTexture(imageNamed: allRules[currentRulesContentIndex])
            rulesContent.texture = newTexture
        }
    }
    
    func createNewGame() -> GameScene {
        let newGameScene = GameScene()
        newGameScene.level = level
        view?.presentScene(newGameScene)
        return newGameScene
    }
    
    func continuePlayingGame() {
        isPaused = false
    }
    
    override func didMove(to view: SKView) {
        size = CGSize(width: 1335, height: 750)
        makeBackScene()
        makeUI()
        
        if level == nil {
            level = Level(id: "level_1", level: 1, time: 50, vulkan: true, rain: true, wind: true, complicationsCount: 6)
        }
        
        setUpLevel()
        
        gameTimer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeGame), userInfo: nil, repeats: true)
        
        if !UserDefaults.standard.bool(forKey: "is_not_first_launch") {
            makeRules()
            UserDefaults.standard.set(true, forKey: "is_not_first_launch")
        }
    }
    
    @objc private func timeGame() {
        if !isPaused && !isTimePaused {
            gameTime -= 1
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        checkForComplications()
        
        if plane.position.y >= 0 {
            plane.position.y -= 0.7
        }
        
        let screenMidY = self.frame.midY
        let airplaneY = plane.position.y
                
        if airplaneY < screenMidY {
            let coolingAdjustment = (screenMidY - airplaneY) / screenMidY / 20
            adjustCoolingEngine(by: coolingAdjustment)
        } else {
            let heatingAdjustment = (airplaneY - screenMidY) / screenMidY / 20
            adjustHeatingEngine(by: heatingAdjustment)
        }
    }
    
    func checkForComplications() {
        for complication in complicationNodes {
            if plane.frame.intersects(complication.frame) {
                switch complication.name {
                case "complication_vulkan":
                    increaseEngineHeating()
                case "complication_rain":
                    increaseEngineCooling()
                case "complication_wind":
                    applyWindEffect()
                default:
                    break
                }
            }
        }
    }
    
    private var isWindEffectApplyied = false
    
    private func applyWindEffect() {
        if !isWindEffectApplyied {
            let moveOne = SKAction.move(to: CGPoint(x: plane.position.x, y: plane.position.y - 15), duration: 0.1)
            let moveTwo = SKAction.move(to: CGPoint(x: plane.position.x, y: plane.position.y + 15), duration: 0.1)
            let moveThree = SKAction.move(to: CGPoint(x: plane.position.x, y: plane.position.y - 25), duration: 0.1)
            let moveFour = SKAction.move(to: CGPoint(x: plane.position.x, y: plane.position.y + 25), duration: 0.1)
            let sequence = SKAction.sequence([moveOne, moveTwo, moveThree, moveFour])
            plane.run(sequence) {
                self.isWindEffectApplyied = false
            }
            isWindEffectApplyied = true
        }
    }
    
    private func increaseEngineHeating() {
        tempCold -= 0.05
        tempHot += 0.05
    }
    
    private func increaseEngineCooling() {
        tempCold += 0.05
        tempHot -= 0.05
    }
    
    private func adjustCoolingEngine(by amount: CGFloat) {
        tempCold += amount
        tempHot -= amount
    }
    
    private func adjustHeatingEngine(by amount: CGFloat) {
        tempCold -= amount
        tempHot += amount
    }
    
    private func setUpLevel() {
        gameTime = level.time
        let levelBg = SKSpriteNode(imageNamed: "value_bg")
        levelBg.size = CGSize(width: 300, height: 160)
        levelBg.position = CGPoint(x: size.width / 2, y: size.height - 80)
        addChild(levelBg)

        gameLevelLabel = SKLabelNode(text: "LEVEL \(level.level)")
        gameLevelLabel.fontName = "ZenAntique-Regular"
        gameLevelLabel.fontSize = 36
        gameLevelLabel.fontColor = .white
        gameLevelLabel.position = CGPoint(x: size.width / 2, y: size.height - 90)
        addChild(gameLevelLabel)
        
        makePlane()
        checkComplicationsForAvailable()
    }
    
    private func checkComplicationsForAvailable() {
        if level.vulkan {
            availableComplications.append(allComplications[0])
        }
        if level.rain {
            availableComplications.append(allComplications[1])
        }
        if level.wind {
            availableComplications.append(allComplications[2])
        }
        if !availableComplications.isEmpty {
            complicationsSpawner = .scheduledTimer(timeInterval: 5, target: self, selector: #selector(complicationSpawn), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func complicationSpawn() {
        if !isPaused && spawnedComplicationsCount < level.complicationsCount {
            let complication = availableComplications.randomElement() ?? allComplications[0]
            let node = SKSpriteNode(imageNamed: complication)
            let y = Int.random(in: 200...500)
            let nodeSize = complicationSizes[complication]!
            node.position = CGPoint(x: size.width, y: CGFloat(y))
            node.size = CGSize(width: nodeSize.0, height: nodeSize.1)
            node.name = complication
            complicationNodes.append(node)
            addChild(node)
            spawnedComplicationsCount += 1
            
            let move = SKAction.move(to: CGPoint(x: 0, y: y), duration: 8)
            let fadeOut = SKAction.fadeOut(withDuration: 0.1)
            let sequence = SKAction.sequence([move, fadeOut])
            node.run(sequence) {
                node.removeFromParent()
                if let index = self.complicationNodes.firstIndex(of: node) {
                    self.complicationNodes.remove(at: index)
                }
            }
       }
    }
    
    private func makePlane() {
        plane = SKSpriteNode(imageNamed: "plane")
        plane.position = CGPoint(x: 250, y: size.height / 2)
        plane.size = CGSize(width: 190, height: 140)
        addChild(plane)
    }
    
    private func makeBackScene() {
        let backScene = SKSpriteNode(imageNamed: UserDefaults.standard.string(forKey: "map") ?? "map_base")
        backScene.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backScene.size = size
        addChild(backScene)
    }
    
    private func makeRules() {
        rulesTitle = SKSpriteNode(imageNamed: "rules_title")
        rulesTitle.position = CGPoint(x: size.width / 2, y: size.height - 75)
        rulesTitle.size = CGSize(width: 230, height: 150)
        addChild(rulesTitle)
        
        rulesContent = SKSpriteNode(imageNamed: allRules[0])
        rulesContent.position = CGPoint(x: size.width / 2, y: size.height / 2)
        rulesContent.size = CGSize(width: 450, height: 310)
        addChild(rulesContent)
        
        rulesNextBtn = SKSpriteNode(imageNamed: "next_btn")
        rulesNextBtn.position = CGPoint(x: size.width / 2, y: size.height / 2 - 155)
        rulesNextBtn.size = CGSize(width: 125, height: 95)
        addChild(rulesNextBtn)
    }
    
    private func makeUI() {
        gamePauseBtn = SKSpriteNode(imageNamed: "pause_btn")
        gamePauseBtn.position = CGPoint(x: size.width / 2, y: 50)
        gamePauseBtn.size = CGSize(width: 125, height: 100)
        addChild(gamePauseBtn)
        
        let timeBack = SKSpriteNode(imageNamed: "value_bg")
        timeBack.size = CGSize(width: 240, height: 130)
        timeBack.position = CGPoint(x: size.width / 4, y: 50)
        addChild(timeBack)
        
        let timeIcon = SKSpriteNode(imageNamed: "time")
        timeIcon.position = CGPoint(x: size.width / 4 - 50, y: 50)
        timeIcon.size = CGSize(width: 38, height: 40)
        addChild(timeIcon)
        
        gameTimeLabel = SKLabelNode(text: ":30")
        gameTimeLabel.fontName = "ZenAntique-Regular"
        gameTimeLabel.fontSize = 36
        gameTimeLabel.fontColor = .white
        gameTimeLabel.position = CGPoint(x: size.width / 4 + 20, y: 35)
        addChild(gameTimeLabel)
        
        let creditsBack = SKSpriteNode(imageNamed: "value_bg")
        creditsBack.size = CGSize(width: 200, height: 130)
        creditsBack.position = CGPoint(x: (size.width / 2) + (size.width / 4), y: 50)
        addChild(creditsBack)
        
        let creditsIcon = SKSpriteNode(imageNamed: "coin")
        creditsIcon.position = CGPoint(x: (size.width / 2) + (size.width / 4) + 30, y: 50)
        creditsIcon.size = CGSize(width: 42, height: 40)
        addChild(creditsIcon)
        
        gameCreditsLabel = SKLabelNode(text: "\(credits)")
        gameCreditsLabel.fontName = "ZenAntique-Regular"
        gameCreditsLabel.fontSize = 36
        gameCreditsLabel.fontColor = .white
        gameCreditsLabel.position = CGPoint(x: (size.width / 2) + (size.width / 4) - 30, y: 35)
        addChild(gameCreditsLabel)
        
        boosterTemperature = SKSpriteNode(imageNamed: "temperature_booster")
        boosterTemperature.position = CGPoint(x: size.width - 90, y: size.height - 50)
        boosterTemperature.size = CGSize(width: 140, height: 100)
        addChild(boosterTemperature)
        
        let boosterCountBack = SKSpriteNode(imageNamed: "value_small_bg")
        boosterCountBack.position = CGPoint(x: size.width - 140, y: size.height - 80)
        boosterCountBack.size = CGSize(width: 50, height: 50)
        addChild(boosterCountBack)
        
        boosterTemperatureCountLabel = SKLabelNode(text: "\(boosterTemperatureCount)")
        boosterTemperatureCountLabel.fontName = "ZenAntique-Regular"
        boosterTemperatureCountLabel.fontSize = 32
        boosterTemperatureCountLabel.fontColor = .white
        boosterTemperatureCountLabel.position = CGPoint(x: size.width - 140, y: size.height - 93)
        addChild(boosterTemperatureCountLabel)
        
        let cold = SKSpriteNode(imageNamed: "cold")
        cold.position = CGPoint(x: 20, y: size.height / 2 - 150)
        cold.size = CGSize(width: 40, height: 60)
        addChild(cold)
        
        let coldTempBg = SKSpriteNode(imageNamed: "temp_bg")
        coldTempBg.position = CGPoint(x: 20, y: size.height / 2 + 15)
        coldTempBg.size = CGSize(width: 40, height: 250)
        addChild(coldTempBg)
        
        let hot = SKSpriteNode(imageNamed: "hot")
        hot.position = CGPoint(x: size.width - 120, y: size.height / 2 - 150)
        hot.size = CGSize(width: 40, height: 60)
        addChild(hot)
        
        let hotTempBg = SKSpriteNode(imageNamed: "temp_bg")
        hotTempBg.position = CGPoint(x: size.width - 120, y: size.height / 2 + 15)
        hotTempBg.size = CGSize(width: 40, height: 250)
        addChild(hotTempBg)
        
        setUpTempCold()
        setUpHotTemp()
    }
    
    private func setUpTempCold() {
        for node in tempColdNodes {
            node.removeFromParent()
        }
        tempColdNodes = []
        for i in 1...13 {
            var item = "temp_empty"
            if CGFloat(i) <= tempCold {
                item = "temp_filled"
            }
            let node = SKSpriteNode(imageNamed: item)
            let a: CGFloat = (size.height / 2 - 75)
            let b: CGFloat = (CGFloat(i) * 10)
            node.position = CGPoint(x: 19, y: a + b)
            node.size = CGSize(width: 10, height: 10)
            tempColdNodes.append(node)
            addChild(node)
        }
    }
    
    private func setUpHotTemp() {
        for node in tempHotNodes {
            node.removeFromParent()
        }
        tempHotNodes = []
        for i in 1...13 {
            var item = "temp_empty"
            if CGFloat(i) <= tempHot {
                item = "temp_filled"
            }
            let node = SKSpriteNode(imageNamed: item)
            let a: CGFloat = (size.height / 2 - 75)
            let b: CGFloat = (CGFloat(i) * 10)
            node.position = CGPoint(x: size.width - 121, y: a + b)
            node.size = CGSize(width: 10, height: 10)
            tempHotNodes.append(node)
            addChild(node)
        }
    }
    
    private func hideRulesContent() {
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        rulesTitle.run(fadeOutAction) {
            self.rulesTitle.removeFromParent()
        }
        rulesContent.run(fadeOutAction) {
            self.rulesContent.removeFromParent()
        }
        rulesNextBtn.run(fadeOutAction) {
            self.rulesNextBtn.removeFromParent()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        plane.position.y += 15
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesOnLocationTouch = nodes(at: location)
        
        if rulesNextBtn != nil {
            if nodesOnLocationTouch.contains(rulesNextBtn) {
                if currentRulesContentIndex < allRules.count - 1 {
                    currentRulesContentIndex += 1
                } else {
                    hideRulesContent()
                }
            }
        }
        
        if nodesOnLocationTouch.contains(gamePauseBtn) {
            isPaused = true
            NotificationCenter.default.post(name: Notification.Name("pause"), object: nil, userInfo: nil)
        }
        
        if nodesOnLocationTouch.contains(boosterTemperature) {
            if boosterTemperatureCount > 0 {
                boosterTemperatureCount -= 1
                tempHot = 7
                tempCold = 7
            }
        }
    }
    
}

#Preview {
    VStack {
        SpriteView(scene: GameScene())
            .ignoresSafeArea()
    }
}
