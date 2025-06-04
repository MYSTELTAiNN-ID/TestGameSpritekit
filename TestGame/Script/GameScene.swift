//
//  GameScene.swift
//  TestGame
//
//  Created by Syamsuddin Putra Riefli on 04/06/25.
//

import SpriteKit
import GameplayKit
import GameController


class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var ground: SKSpriteNode?
    private var player: SKSpriteNode!
    private var spawnPoint: CGPoint?
    private var cameraPlayer: SKCameraNode?
    private var virtualController: GCVirtualController?
    var runFrames1: [SKTexture] = []
    var runFrames2: [SKTexture] = []
    var idleFrames: [SKTexture] = []
    var audioFootstep: SKAction!
    var joystickDirection = CGVector.zero
    
    override func sceneDidLoad() {
        
        print("GameScene loaded")
        
        self.lastUpdateTime = 0
        
        setupSpawnPoint()
        setupGround()
        setupPlayer()
        setupCameraPlayer()
        setupControllerHandlers()
        setupNpc()
    }
    
    
    override func didMove(to view: SKView) {
        
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
        
        let speed: CGFloat = 150

        let dx = joystickDirection.dx * speed * dt
        player.position.x += dx
        if let cameraPlayer = cameraPlayer, let player = player {
            cameraPlayer.position = player.position
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
        player.size = CGSize(width: 90, height: 90)

        // Physics
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
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
        cameraPlayer = cameraNode
        self.camera = cameraNode // Assign camera to scene
    }
    
    func setupNpc() {
        if let npcNode = self.childNode(withName: "//npc1") as? SKSpriteNode {
            npcNode.name = "npc1"
            npcNode.size = CGSize(width: 90, height: 90)
            npcNode.zPosition = 0
            npcNode.physicsBody = SKPhysicsBody(rectangleOf: npcNode.size)
            npcNode.physicsBody?.categoryBitMask = PhysicsCategory.npc
            npcNode.physicsBody?.contactTestBitMask = PhysicsCategory.player
            npcNode.physicsBody?.collisionBitMask = PhysicsCategory.ground
            npcNode.physicsBody?.isDynamic = false
        }
    }
}
