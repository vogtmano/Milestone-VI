//
//  GameScene.swift
//  Milestone VI.1
//
//  Created by Maks Vogtman on 19/01/2023.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var scoreLabel: SKLabelNode!
    var gameTimer: SKLabelNode!
    var finalScore: SKLabelNode!
    var timer: Timer?
    var createTargetTimer: Timer?
    var cursorNode: SKSpriteNode!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var secondsRemaining = 60 {
        didSet {
            gameTimer.text = "Time: \(secondsRemaining)"
        }
    }
    
    
    override func didMove(to view: SKView) {
        cursorNode = SKSpriteNode(imageNamed: "cursor")
        cursorNode.size = CGSize(width: 50, height: 50)
        cursorNode.zPosition = 1
        addChild(cursorNode)
        
        let background = SKSpriteNode(imageNamed: "wood")
        background.position = CGPoint(x: 512, y: 384)
        background.zPosition = -1
        background.size = self.view?.bounds.size ?? CGSize()
        addChild(background)
        
        let line = SKSpriteNode(imageNamed: "line")
        line.position = CGPoint(x: 400, y: 256)
        addChild(line)
        
        let secondLine = SKSpriteNode(imageNamed: "line")
        secondLine.position = CGPoint(x: 400, y: 512)
        addChild(secondLine)
        
        gameTimer = SKLabelNode(fontNamed: "Marker Felt")
        gameTimer.position = CGPoint(x: 800, y: 8)
        gameTimer.text = "Time: 60"
        gameTimer.horizontalAlignmentMode = .left
        gameTimer.zPosition = 1
        gameTimer.fontSize = 58
        gameTimer.fontColor = .black
        addChild(gameTimer)
        
        scoreLabel = SKLabelNode(fontNamed: "Marker Felt")
        scoreLabel.position = CGPoint(x: 8, y: 8)
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.zPosition = 1
        scoreLabel.fontSize = 58
        scoreLabel.fontColor = .black
        addChild(scoreLabel)
        
        startGame()
    }
    
    
    func startGame() {
        createTargetTimer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(createTarget), userInfo: nil, repeats: true)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(gameTime), userInfo: nil, repeats: true)
    }
    
    
    @objc func createTarget() {
        let sprite = target()
        sprite.physicsBody = SKPhysicsBody()
        sprite.physicsBody?.isDynamic = false
        
        let moveLeft = SKAction.move(by: CGVector(dx: -1500, dy: 0), duration: 4)
        let moveRight = SKAction.move(by: CGVector(dx: 1200, dy: 0), duration: 4)
        
        switch Int.random(in: 0...2) {
        case 0:
            sprite.zPosition = 1
            sprite.position = CGPoint(x: -50, y: Int.random(in: 532...715))
            addChild(sprite)
            sprite.run(moveRight)
        case 1:
            sprite.zPosition = 1
            sprite.position = CGPoint(x: 1150, y: Int.random(in: 276...492))
            addChild(sprite)
            sprite.run(moveLeft)
        case 2:
            sprite.zPosition = 1
            sprite.position = CGPoint(x: -50, y: Int.random(in: 40...236))
            addChild(sprite)
            sprite.run(moveRight)
        default: break }
    }
    
    
    func target() -> SKSpriteNode {
        var sprite: SKSpriteNode!
        
        switch Int.random(in: 0...13) {
        case 0...2:
            sprite = SKSpriteNode(imageNamed: "target1")
            sprite.name = "target1"
        case 3...5:
            sprite = SKSpriteNode(imageNamed: "target3")
            sprite.name = "target3"
        case 6...11:
            sprite = SKSpriteNode(imageNamed: "target2")
            sprite.xScale = 0.33
            sprite.yScale = 0.33
            sprite.name = "targetBad"
        case 12...13:
            sprite = SKSpriteNode(imageNamed: "target0")
            sprite.name = "targetGood"
        default: break }
        
        return sprite
    }
    
    
    @objc func gameTime() {
        secondsRemaining -= 1
        
        if secondsRemaining == 0 {
            let gameOver = SKSpriteNode(imageNamed: "game-over")
            gameOver.position = CGPoint(x: 512, y: 384)
            gameOver.zPosition = 1
            addChild(gameOver)
            showFinalScore()
            timer?.invalidate()
            createTargetTimer?.invalidate()
            return
        }
    }
    
    
    func showFinalScore() {
        finalScore = SKLabelNode()
        finalScore.position = CGPoint(x: 512, y: 260)
        finalScore.text = "Final score: \(score)"
        finalScore.fontName = "Marker Felt"
        finalScore.fontSize = 75
        finalScore.zPosition = 1
        addChild(finalScore)
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        cursorNode.position = location
        
        for node in tappedNodes {
            switch node.name {
            case "target1":
                score += 5
                node.run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                spriteHit(node: node)
            case "target3":
                score += 5
                node.run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                spriteHit(node: node)
            case "targetGood":
                score += 5
                node.run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                spriteHit(node: node)
            case "targetBad":
                score -= 15
                node.run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
                spriteHit(node: node)
                default: break }
        }
    }
    
    
    func spriteHit(node: SKNode) {
        let reduceSize = SKAction.scale(by: 0.7, duration: 0.05)
        let applyGravity = SKAction.run { node.physicsBody?.isDynamic = true }
        let wait = SKAction.wait(forDuration: 0.2)
        let sequence = SKAction.sequence([reduceSize, wait, applyGravity])
        
        node.run(sequence)
    }

    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        cursorNode.position = location
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        cursorNode.position = location
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x == -300 && node.position.x == 1200 {
                node.removeFromParent()
            }
        }
    }
}
