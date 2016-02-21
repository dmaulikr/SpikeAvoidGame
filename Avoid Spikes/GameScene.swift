//
//  GameScene.swift
//  Avoid Spikes
//
//  Created by Greg Willis on 2/18/16.
//  Copyright (c) 2016 Willis Programming. All rights reserved.
//

import SpriteKit

var player = SKSpriteNode?()
var spike = SKSpriteNode?()
var ground = SKSpriteNode?()

var mainLabel = SKLabelNode?()
var scoreLabel = SKLabelNode?()

var spikeSpeed = 2.0
var spikeSpawnTimerSpeed = 0.4

var isAlive = true
var score = 0
var scoreReference = 10
var offWhiteColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
var offBlackColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)

struct physicsCategory {
    static let player : UInt32 = 1
    static let spike : UInt32 = 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    override func didMoveToView(view: SKView) {
        physicsWorld.contactDelegate = self
        self.backgroundColor = UIColor.orangeColor()
        spawnPlayer()
        spawnGround()
        spawnMainLabel()
        spawnScoreLabel()
        spikeSpawnTimer()
        hideMainLabel()
        resetVariablesOnStart()
        addToScore()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
     
        for touch in touches {
            let location = touch.locationInNode(self)
            if isAlive == true {
                player?.position.x = location.x
            }
            if isAlive == false {
                player?.position.x = -200
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        if isAlive == false {
            player?.position.x = -200
        }
    }
    
    func resetVariablesOnStart() {
        isAlive = true
        score = 0
        spikeSpeed = 2.0
        scoreReference = 10
        spikeSpawnTimerSpeed = 0.4
    }
    
    func spawnPlayer() {
        player = SKSpriteNode(imageNamed: "whiteFace")
        player?.size = CGSize(width: 50, height: 50)
        player?.position = CGPoint(x: CGRectGetMidX(self.frame), y: 120)
        player?.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        player?.physicsBody?.affectedByGravity = false
        player?.physicsBody?.allowsRotation = false
        player?.physicsBody?.dynamic = false
        player?.physicsBody?.categoryBitMask = physicsCategory.player
        player?.physicsBody?.contactTestBitMask = physicsCategory.spike
        
        self.addChild(player!)
    }
    
    func spawnSpike() {
        spike = SKSpriteNode(imageNamed: "spike")
        spike?.size = CGSize(width: 15, height: 100)
        spike?.position.x = CGFloat(arc4random_uniform(700) + 200)
        spike?.position.y = 900
        spike?.physicsBody = SKPhysicsBody(rectangleOfSize: spike!.size)
        spike?.physicsBody?.affectedByGravity = false
        spike?.physicsBody?.allowsRotation = false
        spike?.physicsBody?.dynamic = true
        spike?.physicsBody?.categoryBitMask = physicsCategory.spike
        spike?.physicsBody?.contactTestBitMask = physicsCategory.player
        var moveDown = SKAction.moveToY(-200, duration: spikeSpeed)
        
        if isAlive == true {
            moveDown = SKAction.moveToY(-200, duration: spikeSpeed)
        }
        if isAlive == false {
            moveDown = SKAction.moveToY(2000, duration: spikeSpeed)
        }
        spike?.runAction(moveDown)
        self.addChild(spike!)
    }
    
    func spawnGround() {
        ground = SKSpriteNode(color: offBlackColor, size: CGSize(width: CGRectGetWidth(self.frame), height: 200))
        ground?.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMinY(self.frame))
        self.addChild(ground!)
    }
    
    func spawnMainLabel() {
        mainLabel = SKLabelNode(fontNamed: "Futura")
        mainLabel?.fontSize = 80
        mainLabel?.fontColor = offWhiteColor
        mainLabel?.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        mainLabel?.text = "Start"
        self.addChild(mainLabel!)
    }
    
    func spawnScoreLabel() {
            scoreLabel = SKLabelNode(fontNamed: "Futura")
            scoreLabel?.fontSize = 50
            scoreLabel?.fontColor = offWhiteColor
            scoreLabel?.position = CGPoint(x: CGRectGetMidX(self.frame), y: 30)
            scoreLabel?.text = "Score: \(score)"
            self.addChild(scoreLabel!)
    }
    
    func spikeSpawnTimer() {
        let spikeTimer = SKAction.waitForDuration(spikeSpawnTimerSpeed)
        let spawn = SKAction.runBlock {
            self.spawnSpike()
        }
        let sequence = SKAction.sequence([spikeTimer, spawn])
        self.runAction(SKAction.repeatActionForever(sequence))
    }
    
    func hideMainLabel() {
        let wait = SKAction.waitForDuration(2.0)
        let fadeOut = SKAction.fadeOutWithDuration(1.0)
        
        mainLabel!.runAction(SKAction.sequence([wait, fadeOut]))
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let firstBody : SKPhysicsBody = contact.bodyA
        let secondBody : SKPhysicsBody = contact.bodyB
        
        if ((firstBody.categoryBitMask == physicsCategory.player) && (secondBody.categoryBitMask == physicsCategory.spike) || (firstBody.categoryBitMask == physicsCategory.spike) && (secondBody.categoryBitMask == physicsCategory.player)) {
            
            spikeCollision(firstBody.node as! SKSpriteNode, spikeTemp: secondBody.node as! SKSpriteNode)
        }
    }
    
    func spikeCollision(playerTemp: SKSpriteNode, spikeTemp: SKSpriteNode) {
        spikeTemp.removeFromParent()
        mainLabel?.alpha = 1.0
        mainLabel?.fontSize = 50
        mainLabel?.text = "Game Over"
        
        isAlive = false
        waitThenMoveToTitleScene()
    }
    
    func updateScore() {
        scoreLabel?.text = "Score: \(score)"
        increaseDifficulty()
    }
    
    func waitThenMoveToTitleScene() {
        let wait = SKAction.waitForDuration(1.5)
        let transition = SKAction.runBlock {
            self.view?.presentScene(TitleScene(), transition: SKTransition.fadeWithDuration(1.5))
        }
        let sequence = SKAction.sequence([wait, transition])
        self.runAction(SKAction.repeatAction(sequence, count: 1))
    }
    
    func addToScore() {
        let timeInterval = SKAction.waitForDuration(1.0)
        let increaseScore = SKAction.runBlock {
            score++
            self.updateScore()
        }
        let sequence = SKAction.sequence([timeInterval, increaseScore])
        self.runAction(SKAction.repeatActionForever(sequence))
    }
    func increaseDifficulty() {
        if score == scoreReference {
            spikeSpeed -= 0.25
            spikeSpawnTimerSpeed -= 0.025
            scoreReference += 10
            mainLabel?.alpha = 1.0
            mainLabel?.text = "FASTER!"
            let wait = SKAction.waitForDuration(0.5)
            let fadeOut = SKAction.fadeOutWithDuration(0.5)
            mainLabel?.runAction(SKAction.sequence([wait, fadeOut]))
        }
    }
}
