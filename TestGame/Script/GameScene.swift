//
//  GameScene.swift
//  TestGame
//
//  Created by Syamsuddin Putra Riefli on 04/06/25.
//

import SpriteKit
import GameplayKit
import GameController


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var ground: SKSpriteNode?
    private var player: SKSpriteNode!
    private var spawnPoint: CGPoint?
    private var virtualController: GCVirtualController?
    private var contactedNpcId: String?
    private var dialogSystem = DialogSystem()
    private var visNovNode = SKVisNovNode()
    var runFrames1: [SKTexture] = []
    var runFrames2: [SKTexture] = []
    var idleFrames: [SKTexture] = []
    var audioFootstep: SKAction!
    var joystickDirection = CGVector.zero
    
    override func sceneDidLoad() {
        
        print("GameScene loaded")
        
        self.lastUpdateTime = 0
        
        physicsWorld.contactDelegate = self
        
        setupSpawnPoint()
        setupGround()
        setupPlayer()
        setupCameraPlayer()
        setupControllerHandlers()
        setupNpc()
    }
    
    
    override func didMove(to view: SKView) {
        visNovNode.position = CGPoint(
            x: frame.midX,
            y: frame.minY
        )
        visNovNode.scene?.size = self.size
        self.camera?.addChild(visNovNode)
        visNovNode.resizeBackgroundNode(to: self.view!)
        visNovNode.isHidden = true
        setupDialogSystem()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let names = [contact.bodyA.node?.name, contact.bodyB.node?.name]
        if let npcName = names.first(where: { $0?.starts(with: "npc_") == true }) {
            contactedNpcId = npcName
            print("Player contacted: \(npcName!)")
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        let names = [contact.bodyA.node?.name, contact.bodyB.node?.name]
        if let npcName = names.compactMap({ $0 }).first(where: { $0 == contactedNpcId }) {
            contactedNpcId = nil
            print("Player left: \(npcName)")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if visNovNode.isHidden == false {
            dialogSystem.showNextDialogLine()
            return
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        self.lastUpdateTime = currentTime
        
        let speed: CGFloat = 200

        let dx = joystickDirection.dx * speed * dt
        player.position.x += dx
        if let camera = self.camera, let player = player {
            camera.position = player.position
        }
    }
    
    func setupGround() {
        self.ground = self.childNode(withName: "//ground") as? SKSpriteNode
        if let ground = self.ground {
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody?.isDynamic = false
            ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        }
    }
    
    func setupSpawnPoint() {
        if let spawnNode = self.childNode(withName: "//spawnPoint") {
            spawnPoint = spawnNode.position
        } else {
            print("⚠️ spawnPoint not found!")
        }
    }
    
    func setupControllerHandlers() {
        
        let virtualConfiguration = GCVirtualController.Configuration()

        virtualConfiguration.elements = [GCInputLeftThumbstick,
                                         GCInputButtonA,
                                         GCInputButtonB]
        virtualController = GCVirtualController(configuration: virtualConfiguration)
        virtualController?.connect()
        if let gamepad = virtualController?.controller?.extendedGamepad {
            gamepad.leftThumbstick.valueChangedHandler = { [weak self] _, x, y in
                self?.joystickDirection = CGVector(dx: CGFloat(x), dy: 0)
                self?.handleWalking()
            }
            
            gamepad.buttonA.pressedChangedHandler = { [weak self] _,_, pressed in
                if pressed {
                    self?.tryStartNpcDialog()
                }
            }
        }
    }
    
    func handleWalking() {
        let isMoving = abs(joystickDirection.dx) > 0.1
            // Flip direction immediately based on dx
        if isMoving {
            let newScale: CGFloat = joystickDirection.dx > 0 ? 1 : -1
            if player.xScale != newScale {
                player.xScale = newScale
            }
        }
        if isMoving && player.action(forKey: "run") == nil {
            player.removeAction(forKey: "idle")
            let run1 = SKAction.animate(with: runFrames1, timePerFrame: 0.1)
            let run2 = SKAction.animate(with: runFrames2, timePerFrame: 0.1)
            let sequence = SKAction.sequence([run1, audioFootstep, run2, audioFootstep])
            let runSequence = SKAction.repeatForever(sequence)
            player.run(runSequence, withKey: "run")
            player.xScale = joystickDirection.dx > 0 ? 1 : -1
        } else if !isMoving {
            player.removeAction(forKey: "run")
            let walkAction = SKAction.repeatForever(SKAction.animate(with: idleFrames, timePerFrame: 0.3))
            player.run(walkAction, withKey: "idle")
        }
    }
    
    func setupPlayer() {
        guard let spawn = spawnPoint else {
                print("⚠️ Spawn point not set. Aborting player setup.")
                return
            }
        
        let textureAtlas = SKTextureAtlas(named: "Player-Idle")
        idleFrames = (0...2).map { textureAtlas.textureNamed("adventurer-idle-0\($0)") }
        let textureAtlas2 = SKTextureAtlas(named: "Player-Run")
        runFrames1 = (0...2).map { textureAtlas2.textureNamed("adventurer-run-0\($0)") }
        runFrames2 = (3...5).map { textureAtlas2.textureNamed("adventurer-run-0\($0)") }
        audioFootstep = SKAction.playSoundFileNamed("Player_Walk.wav", waitForCompletion: false)

        player = SKSpriteNode(texture: idleFrames[0])
        player.position = spawnPoint!
        player.zPosition = 1
        player.size = CGSize(width: Int((player.texture?.size().width)!)*3, height: Int((player.texture?.size().height)!)*3)

        // Physics
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: Int((player.texture?.size().width)!*2.7), height: Int((player.texture?.size().height)! * 2.7)))
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.ground
        player.physicsBody?.collisionBitMask = PhysicsCategory.ground
        player.physicsBody?.allowsRotation = false
        
        
        player.name = "player"
        addChild(player)
        
        let walkAction = SKAction.repeatForever(SKAction.animate(with: idleFrames, timePerFrame: 0.3))
        player.run(walkAction, withKey: "idle")
    }
    
    func setupCameraPlayer() {
        guard let cameraNode = self.childNode(withName: "//SKCameraNode") as? SKCameraNode else {
            print("⚠️ Camera node not found")
            return
        }
        
        self.camera = cameraNode // Assign camera to scene
    }
    
    func setupNpc() {
        if let npcNode = self.childNode(withName: "//npc_smith") as? SKSpriteNode {
            npcNode.name = "npc_smith"
            npcNode.size = CGSize(width: 90, height: 90)
            npcNode.zPosition = 0
            npcNode.physicsBody = SKPhysicsBody(rectangleOf: npcNode.size)
            npcNode.physicsBody?.categoryBitMask = PhysicsCategory.npc
            npcNode.physicsBody?.contactTestBitMask = PhysicsCategory.player
            npcNode.physicsBody?.collisionBitMask = PhysicsCategory.ground
            npcNode.physicsBody?.isDynamic = false
        }
    }
    
    func setupDialogSystem() {
        dialogSystem.setPlayerPortraits(playerPortrait) // Use your actual player portraits dictionary
        dialogSystem.registerDialogTree(npcSmith)          // You should already have this in DialogData.swift

        dialogSystem.onDialogLineDisplayed = { [weak self] line, portrait in
            let texture = portrait != nil ? SKTexture(imageNamed: portrait!) : nil
            self?.visNovNode.updateDialog(line: line, texture: texture)
        }

        dialogSystem.onChoicesPresented = { [weak self] choices in
            self?.visNovNode.showChoices(choices: choices) { index in
                self?.dialogSystem.selectChoice(choices[index])
            }
        }

        dialogSystem.onDialogEnded = { [weak self] in
            self?.visNovNode.clearDialog()
            self?.virtualController?.connect()
            self?.visNovNode.isHidden = true
        }
    }
    
    func tryStartNpcDialog() {
        guard let npcId = contactedNpcId else { return }
        print("Starting dialog with: \(npcId)")
        dialogSystem.startDialog(npcId: npcId, state: "quest_01")
        visNovNode.isHidden = false
        virtualController?.disconnect()
    }
}
