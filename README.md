# iOS_Arkanoid

## Implementation Notes

For our final assignment, we decided to pick option 3, which is implementation of a 2D iOS game that mimics Breakout (Arkanoid), using the Box2D library. For this project build, the game should be run in Portrait Mode. 

Our Targeted Device for this assignment is an iPhone 15 Pro.

## Assignment 3 Instructions

Implement a 2D iOS game that mimics Breakout (Arkanoid), using the Box2D library. You do not need to worry about a 100% faithful reproduction in terms of content, colours, levels, etc. Only the core game essence is required. Use your own drawing functions instead of the drawing systems or debug drawing of Box2D.

1. [25 marks] The game should work as expected. For the paddles, use dynamic objects that are manipulated by the player(s) or AI. They have collision, but not too much in the way of dynamics because they must be responsive. For the blocks, use static objects that are turned off after the ball hits them. For this part, you should have the ability to move the user’s paddle in a responsive, predictable way.
2. [25 marks] You will need to implement a play surface and ball dynamics. You will find dynamics for spheres in the “Polygon Shapes” and “Varying Restitution” Box2D demos. Additionally, the “Apply Force” Box2D demo has an illustration of a contained environment with a dynamic object that may be of interest. For this part, you should have a basic environment where an animated sphere or cube serves as the ball and bounces around the environment.
3. [25 marks] The “Collision Processing” demo in Box2D shows an example of detecting and responding to collision events. You will need to build a similar system for disabling blocks when they are hit by the ball on screen. When the ball leaves the play area (bottom of the screen), you will need to detect this and reset, or otherwise trigger a game event. This does not need to be elaborate and can be math-based (position of the ball) or use a Sensor Shape (consult Box2D manual) for detection.
4. [25 marks] Display the score and the number of balls left as a HUD.

Total marks: 100

### Information
Submit your entire project, including documentation (at least a README file with any notes and a description of the user controls for each part) to the D2L dropbox.

Be sure to include in your README which question you are answering, and any special instructions for building and running the solution.

The code must be written in some combination of Objective-C or Swift and Objective-C++ and/or C++, and all files required to build and deploy the app must be provided.

Submit your entire project, including documentation (at least a README file with any notes and a description of the user controls for each part) to the D2L dropbox.

You are to work in groups of two or three and all will receive the same mark. Your submission should be in a single ZIP file using the naming convention A00ABC_A00DEF_Asst3.zip or A00ABC_A00DEF_GHI_Asst3.zip, where ABC, DEF and GHI are your student numbers.
