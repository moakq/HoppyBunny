import Foundation

class MainScene: CCNode {
    
    // connecting hero
    weak var hero : CCSprite!
    
    // keep track of time
    var sinceTouch : CCTime = 0
    
    // code connection
    func didLoadFromCCB()
    {
        userInteractionEnabled = true
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
        
        
    }
}
