import Foundation

class MainScene: CCNode {
    
    // connecting hero
    weak var hero : CCSprite!
    
    // code connection for physics node
    weak var gamePhysicsNode : CCPhysicsNode!
    
    // code connection for ground1
    weak var ground1 : CCSprite!
    
    // code connection for ground2
    weak var ground2: CCSprite!
    
    // initializing an empty array to store the grounds
    var grounds = [CCSprite] ()
    
    // keep track of time
    var sinceTouch : CCTime = 0
    
    // scroll speed of bunny
    var scrollSpeed : CGFloat = 80
    
    // code connection
    func didLoadFromCCB()
    {
        userInteractionEnabled = true
        grounds.append(ground1)
        grounds.append(ground2)
    }
    
    // enable touch events
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        hero.physicsBody.applyImpulse(ccp(0, 400))
        hero.physicsBody.applyAngularImpulse(10000)
        sinceTouch = 0
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
    }
}
