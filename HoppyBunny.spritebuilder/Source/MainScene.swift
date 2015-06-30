import Foundation

class MainScene: CCNode, CCPhysicsCollisionDelegate
{
    
    // connecting hero
    weak var hero : CCSprite!
    
    // code connection for physics node
    weak var gamePhysicsNode : CCPhysicsNode!
    
    // keep track of time
    var sinceTouch : CCTime = 0
    
    // scroll speed of bunny
    var scrollSpeed : CGFloat = 80
    
    // code connection for ground1
    weak var ground1 : CCSprite!
    
    // code connection for ground2
    weak var ground2: CCSprite!
    
    // code connection to obstacles layer
     weak var obstaclesLayer : CCNode!
    
    // code connection for button
    weak var restartButton : CCNode!
    
    // initializing an empty array to store the grounds
    var grounds = [CCSprite] ()
    
    // code connection to obstacles
    var obstacles : [CCNode] = []
    
    // first obstacle position
    let firstObstaclePosition : CGFloat = 280
    
    // distance between obstacles
    let distanceBetweenObstacles : CGFloat = 160
    
    // gameOver properity
    var gameOver = false
    
    // code connection
    func didLoadFromCCB()
    {
        userInteractionEnabled = true
        grounds.append(ground1)
        grounds.append(ground2)
        
        // spawn 3 obstacles initially
        for i in 0...2
        {
            spawnNewObstacle()
        }
        
        gamePhysicsNode.collisionDelegate = self
    }
    
    // enable touch events
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if (gameOver == false)
        {
            hero.physicsBody.applyImpulse(ccp(0, 400))
            hero.physicsBody.applyAngularImpulse(10000)
            sinceTouch = 0
        }
    }
    
    // function controlling obstacles
    func spawnNewObstacle()
    {
        var prevObstaclePos = firstObstaclePosition
        if obstacles.count > 0
        {
            prevObstaclePos = obstacles.last!.position.x
        }
        
        // create and add a new obstacle
        let obstacle = CCBReader.load("Obstacle") as! Obstacle
        obstacle.position = ccp(prevObstaclePos + distanceBetweenObstacles, 0)
        obstacle.setupRandomPosition() 
        obstaclesLayer.addChild(obstacle)
        obstacles.append(obstacle)
    }
    
    // collision
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, level: CCNode!) -> Bool {
        triggerGameOver()
        return true
    }
    
    
    // restart method
    func restart()
    {
        let scene = CCBReader.loadAsScene("MainScene")
        CCDirector.sharedDirector().presentScene(scene)
    }

    // triggering game over
    func triggerGameOver()
    {
        if (gameOver == false)
        {
            gameOver = true
            restartButton.visible = true
            scrollSpeed = 0
            hero.rotation = 90
            hero.physicsBody.allowsRotation = false
            
            // just in case
            hero.stopAllActions()
            
            let move = CCActionEaseBounceOut(action: CCActionMoveBy(duration: 0.2, position: ccp(0, 4)))
            let moveBack = CCActionEaseBounceOut(action: move.reverse())
            let shakeSequence = CCActionSequence(array: [move, moveBack])
            runAction(shakeSequence)
        }
    }
    
    // update method, called every frame in Cocos2D
    override func update(delta: CCTime) {
        
        // limit the bunny's vertical velocity
        // clamping means testing 
        // and optionally changing a given value so that it never exceeds the specified value range.
        let velocityY = clampf(Float(hero.physicsBody.velocity.y), -Float(CGFloat.max), 200)
        hero.physicsBody.velocity = ccp(0, CGFloat(velocityY))
        
        // update sinceTouch by adding the change in time
        sinceTouch += delta
        
        // clamp rotation(limiting the rotation of the bunny)
        hero.rotation = clampf(hero.rotation, -30, 90)
        
        // check rotation, disable upon death
        if (hero.physicsBody.allowsRotation)
        {
            let angularVelocity = clampf(Float(hero.physicsBody.angularVelocity), -2, 1)
            hero.physicsBody.angularVelocity = CGFloat(angularVelocity)
        }
        
        // more than 3 tenths of a second since the last touch
        // strong downward rotation is applied
        if (sinceTouch > 0.3)
        {
            let impulse = -18000.0 * delta
            hero.physicsBody.applyAngularImpulse(CGFloat(impulse))
        }
        
        // updating the position of bunny using scroll speed
        hero.position = ccp(hero.position.x + scrollSpeed * CGFloat(delta), hero.position.y)
        
        // updating the physics node
        gamePhysicsNode.position = ccp(gamePhysicsNode.position.x - scrollSpeed * CGFloat(delta), gamePhysicsNode.position.y)
        
        // loop the ground whenever a ground image was moved entirely outside the screen
        for ground in grounds
        {
            // getting the position of each ground on the screen
            let groundWorldPosition = gamePhysicsNode.convertToWorldSpace(ground.position)
            let groundScreenPosition = convertToNodeSpace(groundWorldPosition)
            
            // if groundScreenPosition is less than covering the screen then move
            if groundScreenPosition.x <= (-ground.contentSize.width)
            {
                ground.position = ccp(ground.position.x + ground.contentSize.width * 2, ground.position.y)
            }
        }
        
        // add endless obstacles
        for obstacle in obstacles.reverse()
        {
            let obstacleWorldPosition = gamePhysicsNode.convertToWorldSpace(obstacle.position)
            let obstacleScreenPosition = convertToNodeSpace(obstacleWorldPosition)
            
            // obstacle moved past left side of screen?
            if obstacleScreenPosition.x < (-obstacle.contentSize.width)
            {
                obstacle.removeFromParent()
                obstacles.removeAtIndex(find(obstacles, obstacle)!)
                
                // for each removed obstacle, add a new one
                spawnNewObstacle()
            }
            
        }
    }
}
