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
        addPaddle()
        
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
        for row in 0..<BRICK_ROW_COUNT {
            for col in 0..<BRICK_COL_COUNT {
                let theBrick = SCNNode(geometry: SCNBox(width: CGFloat(BRICK_WIDTH), height: CGFloat(BRICK_HEIGHT), length: 1, chamferRadius: 0))
                theBrick.name = "Brick" + String(row) + String(col)
                theBrick.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                
                // Set the rendering position of the brick
                var posX = BRICK_POS_X + Float(col) * (BRICK_WIDTH + BRICK_SPACER)
                var posY = BRICK_POS_Y + Float(row) * (BRICK_HEIGHT + BRICK_SPACER)
                // Add variation to column positions
                if (row % 2 == 0) {
                    posX += BRICK_WIDTH/2
                }
                theBrick.position = SCNVector3(posX, posY, 0)
                
                rootNode.addChildNode(theBrick)
            }
        }
    }
    
    
    func addBall() {
        let theBall = SCNNode(geometry: SCNSphere(radius: CGFloat(BALL_RADIUS)))
        theBall.name = "Ball"
        theBall.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        theBall.position = SCNVector3(Int(BALL_POS_X), Int(BALL_POS_Y), 0)
        rootNode.addChildNode(theBall)
    }
    
    func addPaddle() {
        let thePaddle = SCNNode(geometry: SCNBox(width: CGFloat(PADDLE_WIDTH), height: CGFloat(PADDLE_HEIGHT), length: 1, chamferRadius: 0))
        thePaddle.name = "Paddle"
        thePaddle.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        thePaddle.position = SCNVector3(Int(PADDLE_POS_X), Int(PADDLE_POS_Y), 0)
        rootNode.addChildNode(thePaddle)
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
        
        let ballPhysObj = UnsafePointer(gamePhysics.getObject("Ball"))
        let theBall = rootNode.childNode(withName: "Ball", recursively: true)
        theBall?.position.x = (ballPhysObj?.pointee.loc.x)!
        theBall?.position.y = (ballPhysObj?.pointee.loc.y)!
        
        // If the physics object for the brick was destroyed, de-render the brick
        for row in 0..<BRICK_ROW_COUNT {
            for col in 0..<BRICK_COL_COUNT {
                let brickName = "Brick" + String(row) + String(col)
                let brickPhysObj = UnsafePointer(gamePhysics.getObject(brickName))
                if (brickPhysObj == nil) {
                    let theBrick = rootNode.childNode(withName: brickName, recursively: true)
                    theBrick?.isHidden = true
                }
            }
        }
        
        let paddlePhysObj = UnsafePointer(gamePhysics.getObject("Paddle"))
        let thePaddle = rootNode.childNode(withName: "Paddle", recursively: true)
        thePaddle?.position.x = (paddlePhysObj?.pointee.loc.x)!
        thePaddle?.position.y = (paddlePhysObj?.pointee.loc.y)!
    }
    
    @MainActor
    func handleTap() {
        gamePhysics.launchBall()
    }
    
    @MainActor
    func handlePan(_ velocity: CGPoint) {
        let sensitivityModifier = 0.01
        let panX = Float(velocity.x * sensitivityModifier)
        gamePhysics.movePaddleX(panX)
    }
    
    @MainActor
    func resetPhysics() {
        gamePhysics.reset()
        let theBrick = rootNode.childNode(withName: "Brick", recursively: true)
        theBrick?.isHidden = false
    }
}

