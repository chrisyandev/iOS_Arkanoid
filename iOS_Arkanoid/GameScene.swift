import SceneKit
import QuartzCore

class GameScene: SCNScene {
    
    var cameraNode = SCNNode()
    var lastFrameTime = CFTimeInterval(floatLiteral: 0)
    private var gamePhysics: GamePhysics!
    
    override init() {
        super.init()
        
        background.contents = UIColor.black
        setupCamera()
        
        addBall()
        addBricks()
        
        gamePhysics = GamePhysics()
        
        let updater = CADisplayLink(target: self, selector: #selector(gameLoop))
        updater.preferredFrameRateRange = CAFrameRateRange(minimum: 120.0, maximum: 120.0, preferred: 120.0)
        updater.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupCamera() {
        let camera = SCNCamera()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 50, 100)
        cameraNode.eulerAngles = SCNVector3(0, 0, 0)
        rootNode.addChildNode(cameraNode)
    }
    
    
    func addBricks() {
        let theBrick = SCNNode(geometry: SCNBox(width: CGFloat(BRICK_WIDTH), height: CGFloat(BRICK_HEIGHT), length: 1, chamferRadius: 0))
        theBrick.name = "Brick"
        theBrick.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        theBrick.position = SCNVector3(Int(BRICK_POS_X), Int(BRICK_POS_Y), 0)
        rootNode.addChildNode(theBrick)
        
        let spacer = Float(5)
        
        let positions = [
            SCNVector3(Int(Float(BRICK_POS_X) - BRICK_WIDTH - spacer), Int(BRICK_POS_Y), 0),
            SCNVector3(Int(Float(BRICK_POS_X) + BRICK_WIDTH + spacer), Int(BRICK_POS_Y), 0)
        ]
        
        let colors = [
            UIColor.green,
            UIColor.blue
        ]
        
        for i in positions.indices {
            let newBrick = SCNNode(geometry: SCNBox(width: CGFloat(BRICK_WIDTH), height: CGFloat(BRICK_HEIGHT), length: 1, chamferRadius: 0))
            newBrick.name = "Brick" + String(i)
            newBrick.geometry?.firstMaterial?.diffuse.contents = colors[i]
            newBrick.position = positions[i]
            rootNode.addChildNode(newBrick)
        }
    }
    
    
    func addBall() {
        let theBall = SCNNode(geometry: SCNSphere(radius: CGFloat(BALL_RADIUS)))
        theBall.name = "Ball"
        theBall.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        theBall.position = SCNVector3(Int(BALL_POS_X), Int(BALL_POS_Y), 0)
        rootNode.addChildNode(theBall)
    }
    
    @MainActor
    @objc
    func gameLoop(displaylink: CADisplayLink) {
        if (lastFrameTime != CFTimeInterval(floatLiteral: 0)) {
            let elapsedTime = displaylink.targetTimestamp - lastFrameTime
            updateGameObjects(elapsedTime: elapsedTime)
        }
        lastFrameTime = displaylink.targetTimestamp
    }
    
    
    @MainActor
    func updateGameObjects(elapsedTime: Double) {
        gamePhysics.update(Float(elapsedTime))
        
        let ballPos = UnsafePointer(gamePhysics.getObject("Ball"))
        let theBall = rootNode.childNode(withName: "Ball", recursively: true)
        theBall?.position.x = (ballPos?.pointee.loc.x)!
        theBall?.position.y = (ballPos?.pointee.loc.y)!
        
        let brickPos = UnsafePointer(gamePhysics.getObject("Brick"))
        let theBrick = rootNode.childNode(withName: "Brick", recursively: true)
        
        if (brickPos != nil) {
            theBrick?.position.x = (brickPos?.pointee.loc.x)!
            theBrick?.position.y = (brickPos?.pointee.loc.y)!
        } else {
            theBrick?.isHidden = true
        }
    }
    
    @MainActor
    func handleTap() {
        gamePhysics.launchBall()
    }
    
    @MainActor
    func resetPhysics() {
        gamePhysics.reset()
        let theBrick = rootNode.childNode(withName: "Brick", recursively: true)
        theBrick?.isHidden = false
    }
}

