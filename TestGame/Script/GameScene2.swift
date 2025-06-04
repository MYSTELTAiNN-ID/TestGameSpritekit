import SpriteKit
import GameplayKit
import GameController

class GameScene2: SKScene {
    
    // GameplayKit
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    private var stateMachine: GKStateMachine!

    // Dialog System
    private var dialogSystem: DialogSystem!

    // Player & Camera
    private var lastUpdateTime : TimeInterval = 0
    private var player: SKSpriteNode!
    private var cameraPlayer: SKCameraNode?
    private var spawnPoint: CGPoint?
    
    // Movement
    var joystickDirection = CGVector.zero
    private var virtualController: GCVirtualController?

    // Animation
    var runFrames1: [SKTexture] = []
    var runFrames2: [SKTexture] = []
    var idleFrames: [SKTexture] = []
    var audioFootstep: SKAction!

    override func didMove(to view: SKView) {
        lastUpdateTime = 0

        setupSpawnPoint()
        setupGround()
        setupPlayer()
        setupCameraPlayer()
        setupControllerHandlers()
        setupNpc()

        setupDialogSystem()
        setupStateMachine()

        stateMachine.enter(ExplorationState.self)
    }

    func setupDialogSystem() {
        dialogSystem = DialogSystem()
        dialogSystem.onDialogLineDisplayed = { line, portrait in
            print("[\(line.speaker) \(line.expression)] \(line.text)")
        }

        dialogSystem.onChoicesPresented = { choices in
            for (index, choice) in choices.enumerated() {
                print("\(index + 1): \(choice.text)")
            }
        }

        dialogSystem.onDialogEnded = {
            print("Dialog ended")
            self.stateMachine.enter(ExplorationState.self)
        }

        dialogSystem.registerDialogTree(npcBob)
        dialogSystem.registerDialogTree(npcMaya)
    }

    func setupStateMachine() {
        stateMachine = GKStateMachine(states: [
            ExplorationState(scene: self),
            TalkingState(scene: self)
        ])
    }

    func interactWithNpc(npcId: String, dialogTag: String = "default") {
        stateMachine.enter(TalkingState.self)
        dialogSystem.startDialog(npcId: npcId, state: dialogTag)
    }

    // MARK: - Player & Movement Setup

    func setupPlayer() {
        guard let spawn = spawnPoint else {
            print("⚠️ Spawn point not set.")
            return
        }

        let idleAtlas = SKTextureAtlas(named: "Player-Idle")
        idleFrames = (0...2).map { idleAtlas.textureNamed("adventurer-idle-0\($0)") }
        let runAtlas = SKTextureAtlas(named: "Player-Run")
        runFrames1 = (0...2).map { runAtlas.textureNamed("adventurer-run-0\($0)") }
        runFrames2 = (3...5).map { runAtlas.textureNamed("adventurer-run-0\($0)") }

        audioFootstep = SKAction.playSoundFileNamed("Player_Walk.wav", waitForCompletion: false)

        player = SKSpriteNode(texture: idleFrames.first)
        player.position = spawn
        player.size = CGSize(width: 90, height: 90)
        player.zPosition = 1
        player.name = "player"

        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.ground
        player.physicsBody?.collisionBitMask = PhysicsCategory.ground
        player.physicsBody?.allowsRotation = false

        addChild(player)
        player.run(SKAction.repeatForever(SKAction.animate(with: idleFrames, timePerFrame: 0.3)), withKey: "idle")
    }

    func setupCameraPlayer() {
        guard let cameraNode = self.childNode(withName: "//SKCameraNode") as? SKCameraNode else {
            print("⚠️ Camera node not found")
            return
        }
        cameraPlayer = cameraNode
        self.camera = cameraNode
    }

    func setupGround() {
        if let ground = self.childNode(withName: "//ground") as? SKSpriteNode {
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

    func setupNpc() {
        if let npcNode = self.childNode(withName: "//npc1") as? SKSpriteNode {
            npcNode.name = "npc_bob"
            npcNode.size = CGSize(width: 90, height: 90)
            npcNode.zPosition = 0
            npcNode.physicsBody = SKPhysicsBody(rectangleOf: npcNode.size)
            npcNode.physicsBody?.categoryBitMask = PhysicsCategory.npc
            npcNode.physicsBody?.contactTestBitMask = PhysicsCategory.player
            npcNode.physicsBody?.collisionBitMask = PhysicsCategory.ground
            npcNode.physicsBody?.isDynamic = false
        }
    }

    func setupControllerHandlers() {
        let virtualConfiguration = GCVirtualController.Configuration()
        virtualConfiguration.elements = [GCInputLeftThumbstick, GCInputButtonA, GCInputButtonB]
        virtualController = GCVirtualController(configuration: virtualConfiguration)
        virtualController?.connect()

        if let gamepad = virtualController?.controller?.extendedGamepad {
            gamepad.leftThumbstick.valueChangedHandler = { [weak self] _, x, _ in
                self?.joystickDirection = CGVector(dx: CGFloat(x), dy: 0)
                self?.handleWalking()
            }
        }
    }

    func handleWalking() {
        let isMoving = abs(joystickDirection.dx) > 0.1

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
            player.run(SKAction.repeatForever(sequence), withKey: "run")
        } else if !isMoving {
            player.removeAction(forKey: "run")
            player.run(SKAction.repeatForever(SKAction.animate(with: idleFrames, timePerFrame: 0.3)), withKey: "idle")
        }
    }

    override func update(_ currentTime: TimeInterval) {
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        let speed: CGFloat = 150
        let dx = joystickDirection.dx * speed * CGFloat(dt)
        player.position.x += dx

        if let cameraPlayer = cameraPlayer {
            cameraPlayer.position = player.position
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)

        if let npcNode = nodes.first(where: { $0.name?.starts(with: "npc_") == true }),
           let npcId = npcNode.name {
            interactWithNpc(npcId: npcId)
        }
    }
}
