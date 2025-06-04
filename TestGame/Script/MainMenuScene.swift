//
//  MainMenu.swift
//  TestGame
//
//  Created by Syamsuddin Putra Riefli on 05/06/25.
//  Source: ChatGPT and edited by me
//

import SpriteKit
import GameplayKit

class MainMenuScene: SKScene {
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    
    //Unity's Awake() / Start()
    //Any variable should be init and/or any change from other should be init in here
    //Start
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//titleLabel") as? SKLabelNode
        if let label = self.label {
            label.text = "Hello, World!"
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        self.label?.position = CGPoint(x: frame.midX, y: frame.midY)
        
        
        let startButton = SKButtonNode(
                texture: nil,
                size: CGSize(width: 200, height: 50),
                title: "Start",
                fontSize: 40,
                fontColor: .white,
                horizontalAlignment: .right,
                soundName: nil,
                action: {
                    print("Button clicked")
                    if let view = self.view {
                        if let newScene = GameScene(fileNamed: "GameScene") {
                            newScene.scaleMode = .aspectFill
                            view.presentScene(newScene)
                        }
                    }
                }
        )
        let settingButton = SKButtonNode(
                texture: nil,
                size: CGSize(width: 200, height: 50),
                title: "Setting",
                fontSize: 40,
                fontColor: .white,
                horizontalAlignment: .right,
                soundName: nil,
                action: {
                    print("Button clicked")
                    // Change scene or perform action
                }
        )
        let aboutButton = SKButtonNode(
                texture: nil,
                size: CGSize(width: 200, height: 50),
                title: "About",
                fontSize: 40,
                fontColor: .white,
                horizontalAlignment: .right,
                soundName: nil,
                action: {
                    print("Button clicked")
                    // Change scene or perform action
                }
        )
        startButton.name = "startButton"
        settingButton.name = "settingButton"
        aboutButton.name = "aboutButton"
        
        [startButton, settingButton, aboutButton].forEach { addChild($0) }
        layoutNodesVertically([startButton, settingButton, aboutButton], spacing: 15, alignment: .right, padding: frame.width * 0.1)
        
    }
    //End
    
    //Unity's OnCollisionEnter() or similiar function
    //Use for, well, touch
    //Start
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)
        let touchedNode = atPoint(location)

        if let label = touchedNode as? SKLabelNode, label.name == self.label?.name {
                print("Label tapped!")
                // Perform action here, like switching scenes
            self.label?.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    //End
    
    //Unity's Update() (not FixedUpdate() i think)
    //Any logic that occurs many time should be written in here
    //Start
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
//        let dt = currentTime - self.lastUpdateTime
        
        self.lastUpdateTime = currentTime
    }
    //End
}
