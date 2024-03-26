#ifndef GamePhysics_h
#define GamePhysics_h

#import <Foundation/NSObject.h>

#define BRICK_POS_X           -15.0f
#define BRICK_POS_Y           70.0f
#define BRICK_WIDTH           10.0f
#define BRICK_HEIGHT          5.0f
#define BRICK_SPACER          1.0f
#define BRICK_ROW_COUNT       3
#define BRICK_COL_COUNT       3
#define BRICK_WAIT            1000.0f
#define BALL_POS_X            0.0f
#define BALL_POS_Y            7.0f
#define BALL_RADIUS           3.0f
#define BALL_VELOCITY         2000.0f
#define PADDLE_POS_X          0.0f
#define PADDLE_POS_Y          0.0f
#define PADDLE_WIDTH          20.0f
#define PADDLE_HEIGHT         5.0f
#define WALL_NORTH_POS_X      0.0f
#define WALL_NORTH_POS_Y      100.0f
#define WALL_WEST_POS_X       -25.0f
#define WALL_EAST_POS_X       25.0f
#define WALL_EASTWEST_POS_Y   50.0f
#define WALL_NORTH_WIDTH      100.0f
#define WALL_NORTH_HEIGHT     0.1f
#define WALL_EASTWEST_WIDTH   3.0f
#define WALL_EASTWEST_HEIGHT  100.0f

// You can define other object types here
typedef enum { ObjTypeBrick=0, ObjTypeBall=1, ObjTypePaddle=2, ObjTypeWallNorth=3, ObjTypeWallSides=4 } ObjectType;

// Location of each object in our physics world
struct PhysicsLocation {
    float x, y, theta;
};

// Information about each physics object
struct PhysicsObject {
    struct PhysicsLocation loc;     // location
    ObjectType objType;             // type
    void *b2ShapePtr;               // pointer to Box2D shape definition
    void *gamePhysObj;              // pointer to the GamePhysics instance for use in callbacks
    char *name;                     // identifier
};

// Wrapper class
@interface GamePhysics : NSObject
-(void) LaunchBall;                 // Launch the ball
-(void) ResetBall;                  // Reset the ball after a life loss
-(void) MovePaddleX:(float)x;       // Move the paddle on X axis
-(void) Update:(float)elapsedTime;  // Update the Box2D engine
-(void) RegisterPaddleHit:(char* )name;
-(void) RegisterHit:(char* )name;   // Register when the ball hits the brick
-(void) AddObject:(char *)name newObject:(struct PhysicsObject *)newObj;    // Add a new physics object
-(struct PhysicsObject *) GetObject:(const char *)name; // Get a physics object by name
-(void) ResetBricks;

@end

#endif
