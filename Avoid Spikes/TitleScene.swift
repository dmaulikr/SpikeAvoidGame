//
//  TitleScene.swift
//  Avoid Spikes
//
//  Created by Greg Willis on 2/18/16.
//  Copyright © 2016 Willis Programming. All rights reserved.
//

import Foundation
import SpriteKit

class TitleScene: SKScene {
    var playButton : UIButton!
    var gameTitle : UILabel!
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor.orangeColor()
        
        setUpText()
        
    }
    
    func setUpText() {
        playButton = UIButton(frame: CGRect(x: 100, y: 100, width: 400, height: 100))
        playButton.center = CGPoint(x: view!.frame.size.width / 2, y: view!.frame.size.height * 0.7)
        playButton.titleLabel?.font = UIFont(name: "Futura", size: 50)
        playButton.setTitle("Play", forState: UIControlState.Normal)
        playButton.setTitleColor(offBlackColor, forState: UIControlState.Normal)
        playButton.addTarget(self, action: Selector("playTheGame"), forControlEvents: UIControlEvents.TouchUpInside)
        self.view?.addSubview(playButton)
        
        gameTitle = UILabel(frame: CGRect(x: 0, y: 0, width: view!.frame.width, height: 300))
        gameTitle.textColor = offWhiteColor
        gameTitle.font = UIFont(name: "Futura", size: 50)
        gameTitle.textAlignment = NSTextAlignment.Center
        gameTitle.text = "SPIKE AVOID"
        self.view?.addSubview(gameTitle)
    }
    
    func playTheGame() {
        self.view?.presentScene(GameScene(), transition: SKTransition.crossFadeWithDuration(1.0))
        playButton.removeFromSuperview()
        gameTitle.removeFromSuperview()
        
        if let scene = GameScene(fileNamed: "GameScene") {
            let skView = self.view! as SKView
            skView.ignoresSiblingOrder = true
            scene.scaleMode = .AspectFill
            skView.presentScene(scene)
        }
    }
    
    
}