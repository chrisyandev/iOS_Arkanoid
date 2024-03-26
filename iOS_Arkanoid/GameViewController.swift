import UIKit
import QuartzCore
import SceneKit
import SpriteKit

@objc public class GameViewController: UIViewController {

    var gameScene: GameScene!
    
    // UI
    var scoreLabel: SKLabelNode!
    var livesLabel: SKLabelNode!
    
    static var instance: GameViewController? = nil
    
    @objc
    var currentScore: Int = 0
    @objc
    var livesRemaining: Int = 3
    
    @objc
    static func GetInstance() -> GameViewController {
        return instance!
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        gameScene = GameScene()
        gameScene.viewController = self
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        scnView.scene = gameScene
        
        createAndLinkUI(scnView)
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.numberOfTapsRequired = 2
        scnView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target:self, action: #selector(handlePan(_:)))
        self.view.addGestureRecognizer(panGesture)
        
        GameViewController.instance = self
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        gameScene.handleTap()
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    @objc
    func handlePan(_ gesture: UIPanGestureRecognizer) {
        let scnView = self.view as! SCNView
        
        gameScene.handlePan(gesture.velocity(in: scnView))
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    private func createAndLinkUI(_ scnView: SCNView) {
        let spriteKitUIOverlayScene = SKScene(size: CGSizeMake(UIScreen.main.bounds.width, UIScreen.main.bounds.height))
        spriteKitUIOverlayScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        scoreLabel = SKLabelNode()
        scoreLabel.text = "SCORE: 0"
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: 0, y: 50)
        
        livesLabel = SKLabelNode()
        livesLabel.fontName = "AvenirNext-Bold"
        livesLabel.text = "LIVES: 3"
        livesLabel.fontColor = SKColor.white
        livesLabel.position = CGPoint(x: 0, y: -100)
        
        spriteKitUIOverlayScene.addChild(scoreLabel)
        spriteKitUIOverlayScene.addChild(livesLabel)
        scnView.overlaySKScene = spriteKitUIOverlayScene
    }
    
    @objc
    public func updateScore(newScore: Int) {
        
        currentScore = newScore
        scoreLabel.text = "SCORE: " + String(newScore)
        
        if (currentScore == 9) {
            gameScene.resetBall();
            gameScene.resetPhysics();
            
            currentScore = 0
            scoreLabel.text = "SCORE: " + String(newScore)
        }
    }
    
    @objc
    public func updateLives(newLives: Int) {
        
        livesRemaining = newLives
        livesLabel.text = "LIVES: " + String(newLives)
        
        if (livesRemaining == 0) {
            gameScene.resetBall();
            gameScene.resetPhysics();
            
            livesRemaining = 3
            livesLabel.text = "LIVES: " + String(livesRemaining)
        }
    }
    
}
