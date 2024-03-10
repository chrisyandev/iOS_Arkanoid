#ifndef GamePhysics_h
#define GamePhysics_h

#import <Foundation/NSObject.h>

#define BRICK_POS_X         -10.0f
#define BRICK_POS_Y         70.0f
#define BRICK_WIDTH         5.0f
#define BRICK_HEIGHT        5.0f
#define BRICK_SPACER        1.0f
#define BRICK_ROW_COUNT     3
#define BRICK_COL_COUNT     4
#define BRICK_WAIT          1000.0f
#define BALL_POS_X          0.0f
#define BALL_POS_Y          7.0f
#define BALL_RADIUS         3.0f
#define BALL_VELOCITY       1000.0f
#define PADDLE_POS_X        0.0f
#define PADDLE_POS_Y        0.0f
#define PADDLE_WIDTH        20.0f
#define PADDLE_HEIGHT       5.0f

// You can define other object types here
typedef enum { ObjTypeBrick=0, ObjTypeBall=1, ObjTypePaddle=2 } ObjectType;

// Location of each object in our physics world
struct PhysicsLocation {
    float x, y, theta;
};

// Information about each physics object
struct PhysicsObject {
    struct PhysicsLocation loc;     // location
    ObjectType objType;             // type
    void *b2ShapePtr;               // pointer to Box2D shape definition
    void *box2DObj;                 // pointer to the CBox2D object for use in callbacks
};

// Wrapper class
@interface GamePhysics : NSObject
-(void) LaunchBall;                 // Launch the ball
-(void) MovePaddleX:(float)x;       // Move the paddle on X axis
-(void) Update:(float)elapsedTime;  // Update the Box2D engine
-(void) RegisterHit;                // Register when the ball hits the brick
-(void) AddObject:(char *)name newObject:(struct PhysicsObject *)newObj;    // Add a new physics object
-(struct PhysicsObject *) GetObject:(const char *)name; // Get a physics object by name
-(void) Reset;                      // Reset Box2D

@end

#endif
