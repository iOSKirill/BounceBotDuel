import SpriteKit
import GameplayKit
import SwiftUI

class LevelsScene: SKScene {

    var levelMap: SKSpriteNode!
    var initialMapPosition: CGPoint! // Сохраняем начальное положение карты
    var level10: SKSpriteNode!
    var background: SKSpriteNode!  // Используем существующий background из SKS
    var levelSelectedCallback: ((Int) -> Void)?

    var lastTouchPosition: CGPoint?

    var dismissCallback: (() -> Void)?
    var shopViewModel: ShopViewModel!  // Связь с вашим ViewModel для доступа к выбранному фону

    override func didMove(to view: SKView) {
        // Устанавливаем фон
        setupBackground()
        
        if let button = self.childNode(withName: "BackButton") as? SKSpriteNode {
            button.position = CGPoint(x: 140, y: size.height * 0.4)
        }

        // Получаем levelMap из SKS файла
        if let map = self.childNode(withName: "levelMap") as? SKSpriteNode {
            levelMap = map

            // Устанавливаем позицию levelMap в зависимости от высоты экрана
            let yPos = size.height < 760 ? size.height - 900 : size.height - 1050
            levelMap.position = CGPoint(x: levelMap.position.x, y: yPos)
            
            // Сохраняем начальное положение карты
            initialMapPosition = levelMap.position
        } else {
            print("levelMap не найден в SKS")
        }

        // Получаем уровни по их именам (всего 10 уровней)
        for i in 1...10 {
            if let level = levelMap.childNode(withName: "level\(i)") as? SKSpriteNode {
                level.name = "level\(i)"

                // Сохраняем ссылку на level10
                if i == 10 {
                    level10 = level
                }
            }
        }
    }

    
    func setupBackground() {
        // Проверяем, что shopViewModel не равен nil
        guard let selectedBackgroundImage = shopViewModel?.selectedBackgroundImageName else {
            print("shopViewModel не инициализирован или selectedBackgroundImageName отсутствует")
            return
        }

        // Получаем существующий background узел из SKS файла
        if let backgroundNode = self.childNode(withName: "background") as? SKSpriteNode {
            self.background = backgroundNode

            // Обновляем текстуру фона
            background.texture = SKTexture(imageNamed: selectedBackgroundImage)
            background.size = self.size
            background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        } else {
            print("background не найден в SKS")
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         if let touch = touches.first {
             let touchLocation = touch.location(in: self)
             lastTouchPosition = touchLocation
             if let node = atPoint(touchLocation) as? SKSpriteNode {
                 if node.name == "BackButton" {
                     dismissCallback?()
                 } else if let levelName = node.name, levelName.starts(with: "level") {
                     if let levelNumberString = levelName.components(separatedBy: "level").last,
                        let levelNumber = Int(levelNumberString) {
                         let reversedLevelNumber = 11 - levelNumber // Переворачиваем последовательность
                         print("Level \(reversedLevelNumber) pressed")
                         
                         // Вызываем коллбек для передачи уровня
                         levelSelectedCallback?(reversedLevelNumber)
                     }
                 }
             }
         }
     }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let lastTouch = lastTouchPosition {
            let touchLocation = touch.location(in: self)
            
            // Используем прямой расчет dy
            let dy = touchLocation.y - lastTouch.y

            // Рассчитываем новую позицию карты
            let newYPosition = levelMap.position.y + dy

            // Ограничиваем перемещение карты
            if canMoveMap(newYPosition: newYPosition) {
                levelMap.position = CGPoint(x: levelMap.position.x, y: newYPosition)
            }

            lastTouchPosition = touchLocation
        }
    }


    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }

    func canMoveMap(newYPosition: CGFloat) -> Bool {
        // Получаем позицию level10 относительно сцены
        let level10PositionInScene = levelMap.convert(level10.position, to: self)
        let topOfLevel10InScene = level10PositionInScene.y + level10.size.height / 2

        // Проверяем позицию нижнего уровня (level1) относительно сцены
        if let level1 = levelMap.childNode(withName: "level1") as? SKSpriteNode {
            let level1PositionInScene = levelMap.convert(level1.position, to: self)
            let bottomOfLevel1InScene = level1PositionInScene.y - level1.size.height / 2
            
            // Проверяем, чтобы карта не опускалась слишком низко, оставляя level1 видимым
            let canMoveDown = bottomOfLevel1InScene < frame.maxY
            
            // Проверяем, чтобы карта не поднималась выше начальной позиции
            let canMoveUp = topOfLevel10InScene > frame.minY

            return canMoveUp && canMoveDown
        }
        
        return false
    }
}
