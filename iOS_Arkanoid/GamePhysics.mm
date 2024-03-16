#include <Box2D/Box2D.h>
#include "GamePhysics.h"
#include <stdio.h>
#include <iostream>
#include <map>
#include <string>
#include <queue>

// Some Box2D engine paremeters
const float MAX_TIMESTEP = 1.0f/60.0f;
const int NUM_VEL_ITERATIONS = 10;
const int NUM_POS_ITERATIONS = 3;

#pragma mark - Box2D contact listener class
// This C++ class is used to handle collisions
class CContactListener : public b2ContactListener {
public:
    void BeginContact(b2Contact* contact) {};
    void EndContact(b2Contact* contact) {};
    void PreSolve(b2Contact* contact, const b2Manifold* oldManifold) {
        b2WorldManifold worldManifold;
        contact->GetWorldManifold(&worldManifold);
        b2PointState state1[2], state2[2];
        b2GetPointStates(state1, state2, oldManifold, contact->GetManifold());
        
        if (state2[0] == b2_addState) {
            // Use contact->GetFixtureA()->GetBody() to get the body that was hit
            b2Body* bodyA = contact->GetFixtureA()->GetBody();
            
            // Get the PhysicsObject as the user data, and then the CBox2D object in that struct
            // This is needed because this handler may be running in a different thread and this
            //  class does not know about the CBox2D that's running the physics
            struct PhysicsObject *objData = (struct PhysicsObject *)(bodyA->GetUserData());
            GamePhysics *parentObj = (__bridge GamePhysics *)(objData->gamePhysObj);
            
            if (objData->objType == ObjTypeBrick) {
                // Call RegisterHit (assume CBox2D object is in user data)
                [parentObj RegisterHit:objData->name];    // assumes RegisterHit is a callback function to register collision
            }
        }
    }
    void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {};
};


#pragma mark - CBox2D

@interface GamePhysics () {
    // Box2D-specific objects
    b2Vec2 *gravity;
    b2World *world;
    CContactListener *contactListener;
    float totalElapsedTime;
    
    // Map to keep track of physics object to communicate with the renderer
    std::map<std::string, struct PhysicsObject *> physicsObjects;

    // Logit for this particular "game"
    bool ballHitBrick;  // register that the ball hit the break
    bool ballLaunched;  // register that the user has launched the ball
    float nextPaddlePosX; // next paddle position to set in update loop
    std::queue<std::string> bricksToDestroy;
}
@end

@implementation GamePhysics
- (instancetype)init {
    self = [super init];
    
    if (self) {
        // Initialize Box2D
        gravity = new b2Vec2(0.0f, -10.0f);
        world = new b2World(*gravity);
        
        contactListener = new CContactListener();
        world->SetContactListener(contactListener);
        
        // Set up the brick and ball objects for Box2D
        struct PhysicsObject *newObj = new struct PhysicsObject;
        newObj->objType = ObjTypeBrick;
        
        [self ResetBricks];
        
        // Create ball object
        char *objName;
        newObj = new struct PhysicsObject;
        newObj->loc.x = BALL_POS_X;
        newObj->loc.y = BALL_POS_Y;
        newObj->objType = ObjTypeBall;
        objName = strdup("Ball");
        newObj->name = objName;
        [self AddObject:objName newObject:newObj];
        
        // Create paddle object
        newObj = new struct PhysicsObject;
        newObj->loc.x = PADDLE_POS_X;
        newObj->loc.y = PADDLE_POS_Y;
        newObj->objType = ObjTypePaddle;
        objName = strdup("Paddle");
        newObj->name = objName;
        [self AddObject:objName newObject:newObj];
        
        // Create wall objects
        newObj = new struct PhysicsObject;
        newObj->loc.x = WALL_NORTH_POS_X;
        newObj->loc.y = WALL_NORTH_POS_Y;
        newObj->objType = ObjTypeWallNorth;
        objName = strdup("NorthWall");
        newObj->name = objName;
        [self AddObject:objName newObject:newObj];
        
        // Create wall objects
        newObj = new struct PhysicsObject;
        newObj->loc.x = WALL_WEST_POS_X;
        newObj->loc.y = WALL_EASTWEST_POS_Y;
        newObj->objType = ObjTypeWallSides;
        objName = strdup("WestWall");
        newObj->name = objName;
        [self AddObject:objName newObject:newObj];
        
        // Create wall objects
        newObj = new struct PhysicsObject;
        newObj->loc.x = WALL_EAST_POS_X;
        newObj->loc.y = WALL_EASTWEST_POS_Y;
        newObj->objType = ObjTypeWallSides;
        objName = strdup("EastWall");
        newObj->name = objName;
        [self AddObject:objName newObject:newObj];
        
        
        totalElapsedTime = 0;
        ballHitBrick = false;
        ballLaunched = false;
        nextPaddlePosX = PADDLE_POS_X;
    }
    return self;
}

- (void) dealloc {
    if (gravity) delete gravity;
    if (world) delete world;
    if (contactListener) delete contactListener;
}

- (void) Update:(float)elapsedTime {
    // Get pointers to the brick and ball physics objects
    struct PhysicsObject *theBall = physicsObjects["Ball"];
    struct PhysicsObject *thePaddle = physicsObjects["Paddle"];
    
    // Update paddle position
    b2Vec2 newPaddlePos = b2Vec2(nextPaddlePosX, thePaddle->loc.y);
    ((b2Body *)thePaddle->b2ShapePtr)->SetTransform(newPaddlePos, thePaddle->loc.theta);
    
    // Check here if we need to launch the ball
    //  and if so, use ApplyLinearImpulse() and SetActive(true)
    if (ballLaunched) {
        // Apply a force (since the ball is set up not to be affected by gravity)
        ((b2Body *)theBall->b2ShapePtr)->ApplyLinearImpulse(b2Vec2(0, BALL_VELOCITY),
                                                            ((b2Body *)theBall->b2ShapePtr)->GetPosition(),
                                                            true);
        ((b2Body *)theBall->b2ShapePtr)->SetActive(true);
        ballLaunched = false;
    }
    
//    // Check if it is time yet to drop the brick, and if so call SetAwake()
//    totalElapsedTime += elapsedTime;
//    if ((totalElapsedTime > BRICK_WAIT) && theBrick && theBrick->b2ShapePtr) {
//        ((b2Body *)theBrick->b2ShapePtr)->SetAwake(true);
//    }
    
    // Use these lines for debugging the brick and ball positions
    //    if (theBrick)
    //        printf("Brick: %4.2f %4.2f\t",
    //               ((b2Body *)theBrick->b2ShapePtr)->GetPosition().x,
    //               ((b2Body *)theBrick->b2ShapePtr)->GetPosition().y);
    //    if (theBall &&  theBall->b2ShapePtr)
    //        printf("Ball: %4.2f %4.2f",
    //               ((b2Body *)theBall->b2ShapePtr)->GetPosition().x,
    //               ((b2Body *)theBall->b2ShapePtr)->GetPosition().y);
    //    printf("\n");
    
    // If the last collision test was positive, stop the ball and destroy the brick
//    if (ballHitBrick) {
        // Stop the ball and make sure it is not affected by forces
//        ((b2Body *)theBall->b2ShapePtr)->SetLinearVelocity(b2Vec2(0, 0));
//        ((b2Body *)theBall->b2ShapePtr)->SetAngularVelocity(0);
//        ((b2Body *)theBall->b2ShapePtr)->SetAwake(false);
//        ((b2Body *)theBall->b2ShapePtr)->SetActive(false);
        
        // Destroy the brick from Box2D and related objects in this class
//        world->DestroyBody(((b2Body *)theBrick->b2ShapePtr));
//        delete theBrick;
//        theBrick = nullptr;
//        physicsObjects.erase("Brick");
//        ballHitBrick = false;   // until a reset and re-launch
//    }
    
    // Destroy next brick in the queue
    while (!bricksToDestroy.empty()) {
        std::string brickName = bricksToDestroy.front();
        struct PhysicsObject *brick = physicsObjects[brickName];
        world->DestroyBody((b2Body *)brick->b2ShapePtr);
        delete brick;
        brick = nullptr;
        physicsObjects.erase(brickName);
        bricksToDestroy.pop();
    }
    
    if (world) {
        while (elapsedTime >= MAX_TIMESTEP) {
            world->Step(MAX_TIMESTEP, NUM_VEL_ITERATIONS, NUM_POS_ITERATIONS);
            elapsedTime -= MAX_TIMESTEP;
        }
        
        if (elapsedTime > 0.0f) {
            world->Step(elapsedTime, NUM_VEL_ITERATIONS, NUM_POS_ITERATIONS);
        }
    }
    
    // Update each node based on the new position from Box2D
    for (auto const &b:physicsObjects) {
        if (b.second && b.second->b2ShapePtr) {
            b.second->loc.x = ((b2Body *)b.second->b2ShapePtr)->GetPosition().x;
            b.second->loc.y = ((b2Body *)b.second->b2ShapePtr)->GetPosition().y;
        }
    }
    
}

- (void) RegisterHit:(char *)name {
    // add bricks to destroy for processing later...
    bricksToDestroy.push(name);
}

- (void) LaunchBall {
    // Set some flag here for processing later...
    ballLaunched = true;
}

- (void) ResetBall {
    ballLaunched = false;
    struct PhysicsObject *theBall = physicsObjects["Ball"];
    theBall->loc.x = BALL_POS_X;
    theBall->loc.y = BALL_POS_Y;
    ((b2Body *)theBall->b2ShapePtr)->SetTransform(b2Vec2(BALL_POS_X, BALL_POS_Y), 0);
    ((b2Body *)theBall->b2ShapePtr)->SetLinearVelocity(b2Vec2(0, 0));
    ((b2Body *)theBall->b2ShapePtr)->SetAngularVelocity(0);
    ((b2Body *)theBall->b2ShapePtr)->SetAwake(false);
    ((b2Body *)theBall->b2ShapePtr)->SetActive(true);
}

- (void) ResetBricks {
    // Set up the brick and ball objects for Box2D
    struct PhysicsObject *newObj = new struct PhysicsObject;
    newObj->objType = ObjTypeBrick;
    
    for (int row = 0; row < BRICK_ROW_COUNT; row++) {
        for (int col = 0; col < BRICK_COL_COUNT; col++) {
            newObj = new struct PhysicsObject;
            
            // Set the identifier of the brick
            char *objName;
            std::string nameConcat = "Brick" + std::to_string(row) + std::to_string(col);
            const char *nameConcatCStr = nameConcat.c_str();
            objName = strdup(nameConcatCStr);
            newObj->name = objName;
            
            // Set the physics location of the brick
            newObj->loc.x = BRICK_POS_X + col * BRICK_WIDTH + BRICK_SPACER;
            newObj->loc.y = BRICK_POS_Y + row * BRICK_HEIGHT + BRICK_SPACER;
            // Add variation to column positions
            if (row % 2 == 0) {
                newObj->loc.x += BRICK_WIDTH/2;
            }
            
            [self AddObject:objName newObject:newObj];
        }
    }
}

- (void) MovePaddleX:(float)x {
    nextPaddlePosX += x;
    
    if (nextPaddlePosX > 20) {
        nextPaddlePosX = 20;
    }
    
    if (nextPaddlePosX < -20) {
        nextPaddlePosX = -20;
    }
}

- (void) AddObject:(char *)name newObject:(struct PhysicsObject *)newObj {
    // Set up the body definition and create the body from it
    b2BodyDef bodyDef;
    b2Body *theObject;
    
    // paddle, brick, and walls are kinematic
    if (newObj->objType == ObjTypePaddle || newObj->objType == ObjTypeBrick
        || newObj->objType == ObjTypeWallNorth || newObj->objType == ObjTypeWallSides)
    {
        bodyDef.type = b2_kinematicBody;
    } else {
        bodyDef.type = b2_dynamicBody;
    }

    bodyDef.position.Set(newObj->loc.x, newObj->loc.y);
    theObject = world->CreateBody(&bodyDef);
    if (!theObject) return;
    
    // Setup our physics object and store this object and the shape
    newObj->b2ShapePtr = (void *)theObject;
    newObj->gamePhysObj = (__bridge void *)self;
    
    // Set the user data to be this object and keep it asleep initially
    theObject->SetUserData(newObj);
    theObject->SetAwake(false);
    
    // Based on the objType passed in, create a box or circle
    b2PolygonShape dynamicBox;
    b2CircleShape circle;
    b2FixtureDef fixtureDef;
    
    switch (newObj->objType) {
        case ObjTypeBrick:
            dynamicBox.SetAsBox(BRICK_WIDTH/2, BRICK_HEIGHT/2);
            fixtureDef.shape = &dynamicBox;
            fixtureDef.density = 1.0f;
            fixtureDef.friction = 0.0f;
            fixtureDef.restitution = 1.0f;
            break;
        case ObjTypeBall:
            circle.m_radius = BALL_RADIUS;
            fixtureDef.shape = &circle;
            fixtureDef.density = 1.0f;
            fixtureDef.friction = 0.0f;
            fixtureDef.restitution = 1.0f;
            theObject->SetGravityScale(0.0f);
            break;
        case ObjTypePaddle:
            dynamicBox.SetAsBox(PADDLE_WIDTH/2, PADDLE_HEIGHT/2);
            fixtureDef.shape = &dynamicBox;
            fixtureDef.density = 1.0f;
            fixtureDef.friction = 0.0f;
            fixtureDef.restitution = 1.0f;
            break;
        case ObjTypeWallNorth:
            dynamicBox.SetAsBox(WALL_NORTH_WIDTH/2, WALL_NORTH_HEIGHT/2);
            fixtureDef.shape = &dynamicBox;
            fixtureDef.density = 1.0f;
            fixtureDef.friction = 0.0f;
            fixtureDef.restitution = 1.0f;
            break;
        case ObjTypeWallSides:
            dynamicBox.SetAsBox(WALL_EASTWEST_WIDTH/2, WALL_EASTWEST_HEIGHT/2);
            fixtureDef.shape = &dynamicBox;
            fixtureDef.density = 1.0f;
            fixtureDef.friction = 0.0f;
            fixtureDef.restitution = 1.0f;
            break;
        default:
            break;
    }
    // Add the new fixture to the Box2D object and add our physics object to our map
    theObject->CreateFixture(&fixtureDef);
    physicsObjects[name] = newObj;
}

- (struct PhysicsObject *) GetObject:(const char *)name {
    return physicsObjects[name];
}

- (void) Reset {
    // Look up the brick, and if it exists, destroy it and delete it
    struct PhysicsObject *theBrick = physicsObjects["Brick"];
    if (theBrick) {
        world->DestroyBody(((b2Body *)theBrick->b2ShapePtr));
        delete theBrick;
        theBrick = nullptr;
        physicsObjects.erase("Brick");
    }
    
    // Create a new brick object
    theBrick = new struct PhysicsObject;
    theBrick->loc.x = BRICK_POS_X;
    theBrick->loc.y = BRICK_POS_Y;
    theBrick->objType = ObjTypeBrick;
    char *objName = strdup("Brick");
    [self AddObject:objName newObject:theBrick];
    
    [self ResetBricks];
    
    // Look up the ball object and re-initialize the position, etc.
    struct PhysicsObject *theBall = physicsObjects["Ball"];
    theBall->loc.x = BALL_POS_X;
    theBall->loc.y = BALL_POS_Y;
    ((b2Body *)theBall->b2ShapePtr)->SetTransform(b2Vec2(BALL_POS_X, BALL_POS_Y), 0);
    ((b2Body *)theBall->b2ShapePtr)->SetLinearVelocity(b2Vec2(0, 0));
    ((b2Body *)theBall->b2ShapePtr)->SetAngularVelocity(0);
    ((b2Body *)theBall->b2ShapePtr)->SetAwake(false);
    ((b2Body *)theBall->b2ShapePtr)->SetActive(true);
    
    // Look up the paddle object and re-initialize the position, etc.
    struct PhysicsObject *thePaddle = physicsObjects["Paddle"];
    thePaddle->loc.x = PADDLE_POS_X;
    thePaddle->loc.y = PADDLE_POS_Y;
    ((b2Body *)thePaddle->b2ShapePtr)->SetTransform(b2Vec2(PADDLE_POS_X, PADDLE_POS_Y), 0);
    ((b2Body *)thePaddle->b2ShapePtr)->SetLinearVelocity(b2Vec2(0, 0));
    ((b2Body *)thePaddle->b2ShapePtr)->SetAngularVelocity(0);
    ((b2Body *)thePaddle->b2ShapePtr)->SetAwake(false);
    ((b2Body *)thePaddle->b2ShapePtr)->SetActive(true);
    
    totalElapsedTime = 0;
    ballHitBrick = false;
    ballLaunched = false;
    nextPaddlePosX = PADDLE_POS_X;
}

@end
