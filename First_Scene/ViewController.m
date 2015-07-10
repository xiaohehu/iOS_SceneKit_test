//
//  ViewController.m
//  First_Scene
//
//  Created by Xiaohe Hu on 6/8/15.
//  Copyright (c) 2015 Xiaohe Hu. All rights reserved.
//

#import "ViewController.h"

typedef NS_OPTIONS(NSUInteger, CollisionCategory) {
    CollisionCategoryWall       = 0x1 << 0,
    CollisionCategoryBox        = 0x1 << 1,
    CollisionCategoryCube       = 0x1 << 2,
    CollisionCategoryCubeBlock  = 0x1 << 3,
};

@interface ViewController ()
{
    // Geometry
    SCNBox                      *box;
    SCNBox                      *cube;
    SCNBox                      *cube_block;
    SCNPlane                    *leftWall;
    SCNPlane                    *rightWall;
    SCNPlane                    *backWall;
    SCNPlane                    *frontWall;
    SCNPlane                    *floor;
    SCNText                     *boxText;
    SCNLight                    *light;
    SCNLight                    *omniLight;
    SCNLight                    *spotlight;
    SCNLight                    *ambientLight;
    
    // Nodes
    SCNNode                     *floorNode;
    SCNNode                     *boxNode;
    SCNNode                     *cubeNode;
    SCNNode                     *cube_blockNode;
    SCNNode                     *cameraNode;
    SCNNode                     *cameraOrbit;
    SCNNode                     *boxTextNode;
    SCNNode                     *leftWallNode;
    SCNNode                     *rightWallNode;
    SCNNode                     *backWallNode;
    SCNNode                     *frontWallNode;
    
    // Position Parameters
    CGFloat                     lastRotation;

    UIPanGestureRecognizer      *panGesture;
    UIPinchGestureRecognizer    *pinchGesture;
    CGFloat                     cameraY;
    CGFloat                     cameraZ;
    CGFloat                     cameraX;
    
    CGPoint                     touchPoint;
    
    float                       moveStartTime;
    float                       intervalTime;
    float                       speed;
    BOOL                        position;
    BOOL                        review;
    BOOL                        rotateCam;
    BOOL                        sizeBtn;
    BOOL                        editNode;
    NSArray                     *arr_shapes;
    NSArray                     *arr_cameraRotation;
    int                         box_shapeIndex;
    int                         cube_shapeIndex;
    int                         cameraRotationIndex;
}
// UIButtons
@property (weak, nonatomic) IBOutlet UIButton *uib_view;
@property (weak, nonatomic) IBOutlet UIButton *uib_position;
@property (weak, nonatomic) IBOutlet UIButton *uib_size;
@property (weak, nonatomic) IBOutlet UIButton *uib_color;
@property (weak, nonatomic) IBOutlet UIButton *uib_freeCam;
@property (weak, nonatomic) IBOutlet UIButton *uib_rotateCam;
@property (weak, nonatomic) IBOutlet UIButton *uib_edit;
// Color picker
@property (weak, nonatomic) IBOutlet UIView *uiv_colorContainer;
@property (weak, nonatomic) IBOutlet UIButton *uib_yellow;
@property (weak, nonatomic) IBOutlet UIButton *uib_blue;
@property (weak, nonatomic) IBOutlet UIButton *uib_green;

@end

@implementation ViewController

@synthesize myScnView;

#pragma mark - ViewController Life-cycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self buildEnvironment];
    
    [self addElementToEnvironment];
    
    [self createShapesArray];
    
    [self createCameraPositionArray];
}

- (void)viewWillAppear:(BOOL)animated {
    [self defaultMode];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Create Nessary Data
- (void)createShapesArray {
    SCNBox *boxShape = [SCNBox boxWithWidth:10.0
                                      height:10.0
                                      length:10.0
                               chamferRadius:1.0];
    
    SCNSphere *shpereShape = [SCNSphere sphereWithRadius:5.0];
    
    SCNCylinder *cylinderShape = [SCNCylinder cylinderWithRadius:5.0 height:10.0];
    
    arr_shapes = @[boxShape, shpereShape, cylinderShape];
    
    box_shapeIndex = 0;
    cube_shapeIndex = 0;
}

- (void)createCameraPositionArray {
    NSNumber *rotation1 = [NSNumber numberWithFloat:-M_PI_4];
    NSNumber *rotation2 = [NSNumber numberWithFloat:-1.0 * M_PI];
    NSNumber *rotation3 = [NSNumber numberWithFloat:-1.5 * M_PI];
    arr_cameraRotation = @[rotation1, rotation2, rotation3];
}

#pragma mark - Defaul mode

- (void)defaultMode {
    // Turn on tap and drag func
//    _uib_position.selected = YES;
//    position = YES;
    [self addLongPressToNodes];
    
    // Turn on tap change shape and 1 step rotation
    _uib_edit.selected = YES;
    editNode = YES;
    [self addEditGesutreToBox];
    
    // Trun on pan gesture to rotate camera
    _uib_rotateCam.selected = YES;
    rotateCam = YES;
}

#pragma mark - Build up environment & Add Elements
/*
 * Create floor and walls for whole scene
 */
- (void)buildEnvironment
{
    /*
     * Init the root scene
     */
    SCNScene *scene = [SCNScene scene];
    myScnView.scene = scene;
    myScnView.scene.physicsWorld.gravity = SCNVector3Make(0.0, -1.0, 0.0);
    myScnView.scene.physicsWorld.contactDelegate = self;
    myScnView.scene.physicsWorld.timeStep = 1.0/60.0;
    //Turn on antialiasing (it is off by default)
    myScnView.antialiasingMode = SCNAntialiasingModeMultisampling4X;
    
    UIColor *lightBlueColor = [UIColor colorWithRed:4.0/255.0
                                              green:120.0/255.0
                                               blue:255.0/255.0
                                              alpha:1.0];
    //    // A reflective floor
    //    // ------------------
    //    SCNFloor *floor = [SCNFloor floor];
    //    // A solid white color, not affected by light
    //    floor.firstMaterial.diffuse.contents = [UIColor colorWithRed:79.0/255.0 green:191.0/255.0 blue:76.0/255.0 alpha:1.0];
    //    floor.firstMaterial.lightingModelName = SCNLightingModelConstant;
    //    // Less reflective and decrease by distance
    //    floor.reflectivity = 0;
    //    floor.reflectionFalloffEnd = 0;
    //    floorNode = [SCNNode nodeWithGeometry:floor];
    //    floorNode.position = SCNVector3Make(0, -5, 0);
    //    floorNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeKinematic shape:[SCNPhysicsShape shapeWithGeometry:floor options:nil]];
    //    [scene.rootNode addChildNode:floorNode];
    
    // A plane on X-Z coordinates as floor
    // ------------------
    floor = [SCNPlane planeWithWidth:50 height:50];
    floor.firstMaterial.diffuse.contents = [UIColor lightGrayColor];
    floor.firstMaterial.lightingModelName = SCNLightingModelConstant;
    floorNode = [SCNNode nodeWithGeometry:floor];
    floorNode.position = SCNVector3Make(0, 0, 0);
    floorNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic shape:[SCNPhysicsShape shapeWithGeometry:floor options:nil]];
    floorNode.pivot = SCNMatrix4MakeTranslation(0.0, 0.0, 0.0);
    floorNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
    floorNode.physicsBody.friction = 0.5;
    [scene.rootNode addChildNode:floorNode];
    
    // A plane on Y-Z coordinates left as left wall
    // ------------------
    leftWall = [SCNPlane planeWithWidth:50 height:50];
    leftWall.firstMaterial.diffuse.contents = [UIColor clearColor];
    leftWall.firstMaterial.lightingModelName = SCNLightingModelConstant;
    leftWallNode = [SCNNode nodeWithGeometry:leftWall];
    leftWallNode.rotation = SCNVector4Make(0, 1, 0, M_PI_2);
    leftWallNode.position = SCNVector3Make(-25, 0, 0);
    leftWallNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic shape:[SCNPhysicsShape shapeWithGeometry:leftWall options:nil]];
    leftWallNode.physicsBody.physicsShape = [SCNPhysicsShape shapeWithGeometry:leftWall options:nil];
    leftWallNode.physicsBody.restitution = 0.0;
    leftWallNode.physicsBody.angularDamping = 1.0;
    [scene.rootNode addChildNode:leftWallNode];
    
    // A plane on Y-Z coordinates right as right wall
    // ------------------
    rightWall = [SCNPlane planeWithWidth:50 height:50];
    rightWall.firstMaterial.diffuse.contents = [UIColor clearColor];
    rightWall.firstMaterial.lightingModelName = SCNLightingModelConstant;
    rightWallNode = [SCNNode nodeWithGeometry:rightWall];
    rightWallNode.rotation = SCNVector4Make(0, 1, 0, -M_PI_2);
    rightWallNode.position = SCNVector3Make(25, 0, 0);
    rightWallNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic shape:[SCNPhysicsShape shapeWithGeometry:rightWall options:nil]];
    rightWallNode.physicsBody.physicsShape = [SCNPhysicsShape shapeWithGeometry:rightWall options:nil];
    rightWallNode.pivot = SCNMatrix4MakeTranslation(0.0, 0.0, 0.0);
    [scene.rootNode addChildNode:rightWallNode];
    
    // A plane on X-Y coordinates back as back wall
    // ------------------
    backWall = [SCNPlane planeWithWidth:50 height:50];
    backWall.firstMaterial.diffuse.contents = [UIColor clearColor];
    backWall.firstMaterial.lightingModelName = SCNLightingModelConstant;
    backWallNode = [SCNNode nodeWithGeometry:backWall];
    backWallNode.position = SCNVector3Make(0, 0, -25);
    backWallNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic shape:[SCNPhysicsShape shapeWithGeometry:backWall options:nil]];
    backWallNode.physicsBody.physicsShape = [SCNPhysicsShape shapeWithGeometry:backWall options:nil];
    backWallNode.pivot = SCNMatrix4MakeTranslation(0.0, 0.0, 0.0);
    [scene.rootNode addChildNode:backWallNode];
    
    // A plane on X-Y coordinates front as front wall
    // ------------------
    frontWall = [SCNPlane planeWithWidth:50 height:50];
    frontWall.firstMaterial.diffuse.contents = [UIColor clearColor];
    frontWall.firstMaterial.lightingModelName = SCNLightingModelConstant;
    frontWallNode = [SCNNode nodeWithGeometry:frontWall];
    frontWallNode.position = SCNVector3Make(0, 0, 25);
    frontWallNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic shape:[SCNPhysicsShape shapeWithGeometry:frontWall options:nil]];
    frontWallNode.physicsBody.physicsShape = [SCNPhysicsShape shapeWithGeometry:frontWall options:nil];
    frontWallNode.pivot = SCNMatrix4MakeTranslation(0.0, 0.0, 0.0);
    [scene.rootNode addChildNode:frontWallNode];
    
    /*
     * Omni Light
     */
    //    omniLight = [SCNLight light];
    //    omniLight.type = SCNLightTypeOmni;
    //    omniLight.color = lightBlueColor;
    //    omniLight.attenuationStartDistance = 15;
    //    omniLight.attenuationEndDistance = 20;
    //    SCNNode *omniLightNode = [SCNNode node];
    //    omniLightNode.light = omniLight;
    //    [self.myScnView.scene.rootNode addChildNode: omniLightNode];
    
    /*
     * Spot Light
     */
    //    spotlight = [SCNLight light];
    //    spotlight.type = SCNLightTypeSpot;
    //    spotlight.color = lightBlueColor;
    //    spotlight.spotInnerAngle = 10;
    //    spotlight.spotOuterAngle = 15;
    //    SCNNode *spotLightNode = [SCNNode node];
    //    spotLightNode.light = spotlight;
    //    [cameraNode addChildNode: spotLightNode];
    
    /*
     * Ambient Light
     */
    ambientLight = [SCNLight light];
    ambientLight.type = SCNLightTypeAmbient;
    ambientLight.color = lightBlueColor;
    SCNNode *ambienLightNode = [SCNNode node];
    ambienLightNode.light = ambientLight;
    [self.myScnView.scene.rootNode addChildNode: ambienLightNode];
}

/*
 * Add cubes and make physics body
 */
- (void)addElementToEnvironment
{
    UIColor *lightBlueColor = [UIColor colorWithRed:4.0/255.0
                                              green:120.0/255.0
                                               blue:255.0/255.0
                                              alpha:1.0];
    /*
     *  Create box and it's node, added to myScnView
     */
    CGFloat boxSize = 10.0;
    box = [SCNBox boxWithWidth:boxSize
                        height:boxSize
                        length:boxSize
                 chamferRadius:1.0];
    box.firstMaterial.diffuse.contents = [UIColor whiteColor];
    boxNode = [SCNNode nodeWithGeometry:box];
    boxNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic
                                                 shape:[SCNPhysicsShape shapeWithGeometry:box options:nil]];
    boxNode.physicsBody.restitution = 0.0;
    boxNode.physicsBody.angularDamping = 1.0;
    boxNode.position = SCNVector3Make(-10.0, box.height/2, 0.0);
    [myScnView.scene.rootNode addChildNode: boxNode];
    
    /*
     * Create No.2 cube
     */
    cube = [SCNBox boxWithWidth:boxSize
                         height:boxSize
                         length:boxSize
                  chamferRadius:1.0];
    cube.firstMaterial.diffuse.contents = [UIColor whiteColor];
    cubeNode = [SCNNode nodeWithGeometry:cube];
    cubeNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic
                                                 shape:[SCNPhysicsShape shapeWithGeometry:cube options:nil]];
    cubeNode.physicsBody.restitution = 0.0;
    cubeNode.physicsBody.angularDamping = 1.0;
    cubeNode.position = SCNVector3Make(15.0, cube.height/2, 0.0);
    [myScnView.scene.rootNode addChildNode: cubeNode];
    
    /*
     * Create Cube to block
     */
    cube_block = [SCNBox boxWithWidth:boxSize
                               height:boxSize
                               length:boxSize
                        chamferRadius:0.0];
    cube_block.firstMaterial.diffuse.contents = [UIColor orangeColor];
    cube_blockNode = [SCNNode nodeWithGeometry:cube_block];
    cube_blockNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic shape:[SCNPhysicsShape shapeWithGeometry:cube_block options:nil]];
    cube_blockNode.position = SCNVector3Make(20.0, cube.height/2, 20);
    [myScnView.scene.rootNode addChildNode: cube_blockNode];
    /*
     * Set up collision bit masks to box and all walls
     */
    leftWallNode.physicsBody.categoryBitMask = CollisionCategoryWall;
    rightWallNode.physicsBody.categoryBitMask = CollisionCategoryWall;
    backWallNode.physicsBody.categoryBitMask = CollisionCategoryWall;
    frontWallNode.physicsBody.categoryBitMask = CollisionCategoryWall;
    boxNode.physicsBody.categoryBitMask = CollisionCategoryBox;
    cubeNode.physicsBody.categoryBitMask = CollisionCategoryCube;
    cube_blockNode.physicsBody.categoryBitMask = CollisionCategoryCubeBlock;
    
    leftWallNode.physicsBody.collisionBitMask = CollisionCategoryBox | CollisionCategoryCube;
    rightWallNode.physicsBody.collisionBitMask = CollisionCategoryBox | CollisionCategoryCube;
    backWallNode.physicsBody.collisionBitMask = CollisionCategoryBox | CollisionCategoryCube;
    frontWallNode.physicsBody.collisionBitMask = CollisionCategoryBox | CollisionCategoryCube;
    boxNode.physicsBody.collisionBitMask = CollisionCategoryWall | CollisionCategoryCube | CollisionCategoryCubeBlock;
    cubeNode.physicsBody.collisionBitMask = CollisionCategoryWall| CollisionCategoryBox | CollisionCategoryCubeBlock;
    
    /*
     * Added view camera
     */
    cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.position = SCNVector3Make(0.0, 20.0, 30.0);
    cameraNode.rotation = SCNVector4Make(1, 0, 0, -atan2(10.0, 20.0));
    cameraNode.camera.zFar = 500;
    cameraNode.camera.zNear = 0.1;
    cameraX = 0.0;
    cameraY = 20.0;
    cameraZ = 30.0;
    /*
     * Add camera orbit to rotate camera node
     */
    cameraOrbit = [SCNNode node];
    [cameraOrbit addChildNode: cameraNode];
    [myScnView.scene.rootNode addChildNode: cameraOrbit];
//    [myScnView.scene.rootNode addChildNode: cameraNode];
    
    /*
     * Set text on top of the box
     */
    NSString *myText = @"HOTEL";
    SCNText *text = [SCNText textWithString:myText
                             extrusionDepth:0.2];
    text.firstMaterial.diffuse.contents =
    [UIColor colorWithWhite:.9 alpha:1.0];
    text.font = [UIFont systemFontOfSize:2.0];
    text.flatness = 0.1;
    boxTextNode = [SCNNode nodeWithGeometry:text];
    
    boxTextNode.position = SCNVector3Make(-2.5,
                                       box.height/2 + 2,
                                       0);
    
//    boxTextNode.position = SCNVector3Make(-2.5,
//                                          12,
//                                          0);
    
//    SCNLookAtConstraint *constraint = [SCNLookAtConstraint lookAtConstraintWithTarget:cameraNode];
//    boxTextNode.constraints = @[constraint];
    
//    boxTextNode.pivot = SCNMatrix4MakeRotation(-M_PI, 1, 0, 0);
    
    
//    boxTextNode.rotation = SCNVector4Make(1, 0, 0, -M_PI);
//    boxTextNode.rotation = SCNVector4Make(0, 1, 0, M_PI);
    
    /*
     * Temp method to make text node looking at the camera by adding a node in far away position
     */
    SCNNode *tempNode = [SCNNode node];
    tempNode.position = SCNVector3Make(0, 0, -50000);
    [myScnView.scene.rootNode addChildNode: tempNode];
    SCNLookAtConstraint *constraint = [SCNLookAtConstraint lookAtConstraintWithTarget:tempNode];
    boxTextNode.constraints = @[constraint];
    [boxNode addChildNode: boxTextNode];
    
    /*
     * Added light node along with the camera
     */
    light = [SCNLight light];
    light.type = SCNLightTypeDirectional;
    light.color = lightBlueColor;
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = light;
    [cameraNode addChildNode: lightNode];
}

#pragma mark - Action of control buttons

- (IBAction)tapFreeCam:(id)sender {
    _uib_freeCam.selected = !_uib_freeCam.selected;
    /*
     * Free camera control
     */
    self.myScnView.allowsCameraControl = _uib_freeCam.selected;
}

#pragma mark Edit scene node
- (IBAction)tapEditBtn:(id)sender {
    if (!_uib_edit.selected) {
        [self resetAllBtns];
        _uib_edit.selected = YES;
        editNode = YES;
        [self addEditGesutreToBox];
    }
    else {
        [self resetAllBtns];
    }
}

#pragma mark Camera rotation
- (IBAction)tapRotateCam:(id)sender {
    if (!_uib_rotateCam.selected) {
        [self resetAllBtns];
        _uib_rotateCam.selected = YES;
        rotateCam = YES;
    }
    else {
        [self resetAllBtns];
    }
}


#pragma mark Color picker
- (IBAction)tapColorBtn:(id)sender {
    if (!_uib_color.selected) {
        [self resetAllBtns];
        _uib_color.selected = YES;
        _uiv_colorContainer.hidden = NO;
    }
    else {
        [self resetAllBtns];
    }
}

- (IBAction)changeColor:(id)sender
{
    /*
     * Button's tag is set in StoryBorad
     */
    UIColor *lightBlueColor = [UIColor colorWithRed:4.0/255.0
                                              green:120.0/255.0
                                               blue:255.0/255.0
                                              alpha:1.0];
    UIColor *lightPinkColor = [UIColor colorWithRed:255.0/255.0
                                                green:26.0/255.0
                                                 blue:245.0/255.0
                                                alpha:1.0];
    UIColor *lightGreenColor = [UIColor colorWithRed:89.0/255.0
                                               green:255.0/255.0
                                                blue:26.0/255.0
                                               alpha:1.0];
    switch ([sender tag]) {
        case 1:
            light.color = lightPinkColor;
            ambientLight.color = lightPinkColor;
            break;
        case 2:
            light.color = lightBlueColor;
            ambientLight.color = lightBlueColor;
            break;
        case 3:
            light.color = lightGreenColor;
            ambientLight.color = lightGreenColor;
            break;
        default:
            break;
    }
}

#pragma mark Change view along Y direction and rotate the cube
- (IBAction)tapViewBtn:(id)sender {
    
    if (!_uib_view.selected) {
        [self resetAllBtns];
        _uib_view.selected = YES;
        review = YES;
        [self addGestureToBox];
    }
    else {
        [self resetAllBtns];
    }
}

#pragma mark Change cube's position on floor (keep Y value)
- (IBAction)tapPositionBtn:(id)sender {

    if (!_uib_position.selected) {
        [self resetAllBtns];
        _uib_position.selected = YES;
//        position = YES;
        [self addLongPressToNodes];
    }
    else {
        [self resetAllBtns];
    }
}

#pragma mark Change width/height/length of the cube
- (IBAction)tapSizeBtn:(id)sender {

    if (!_uib_size.selected) {
        [self resetAllBtns];
        _uib_size.selected = YES;
        sizeBtn = YES;
    }
    else {
        [self resetAllBtns];
    }
}

#pragma mark Update camera's rotation around Y
- (IBAction)tapCam1:(id)sender {
    
    // Change index to load different angles
    cameraRotationIndex++;
    if (cameraRotationIndex == 3) {
        cameraRotationIndex = 0;
    }
    
    NSNumber *value = arr_cameraRotation[cameraRotationIndex];
    CGFloat rotation = [value floatValue];

    [SCNTransaction begin]; {
        
        CABasicAnimation *moveCamera =
        [CABasicAnimation animationWithKeyPath:@"rotation"];
        moveCamera.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0.0, 1.0, 0.0, rotation)];
        moveCamera.duration  = 1.0;
        moveCamera.fillMode  = kCAFillModeForwards;
        moveCamera.timingFunction =
        [CAMediaTimingFunction functionWithName:
         kCAMediaTimingFunctionEaseInEaseOut];
        // Keep the final state after animation
        moveCamera.removedOnCompletion = NO;
        [cameraOrbit addAnimation:moveCamera forKey:@"rotaion"];
        
        [SCNTransaction setCompletionBlock:^{
            /*
             * Set cameraOrbit's rotation by code and remove animation to make enable interactive
             * Record current rotation of the cameraOrbit
             */
            cameraOrbit.rotation = SCNVector4Make(0.0, 1.0, 0.0, rotation);
            [cameraOrbit removeAllAnimations];
            lastRotation = rotation;
        }];
        
    } [SCNTransaction commit];
}

#pragma mark Update camera's position
- (IBAction)tapCam2:(id)sender {
    
    [SCNTransaction begin]; {
        /*
         * Check the current rotation of cameraOrbit
         * If the cameraObit is changed, make it go back to original place
         */
        if (lastRotation != 0) {
            CABasicAnimation *moveCamera =
            [CABasicAnimation animationWithKeyPath:@"rotation"];
            moveCamera.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0.0, 1.0, 0.0, 0)];
            moveCamera.duration  = 1.0;
            moveCamera.fillMode  = kCAFillModeForwards;
            moveCamera.timingFunction =
            [CAMediaTimingFunction functionWithName:
             kCAMediaTimingFunctionEaseInEaseOut];
            moveCamera.removedOnCompletion = NO;
            [cameraOrbit addAnimation:moveCamera forKey:@"test"];
        }
        /*
         * Change the positon of the camera
         */
        CABasicAnimation *moveCamera =
        [CABasicAnimation animationWithKeyPath:@"position"];
        moveCamera.toValue = [NSValue valueWithSCNVector3:SCNVector3Make(10.0, 2.0, 30.0)];
        moveCamera.duration  = 1.0;
        moveCamera.fillMode  = kCAFillModeForwards;
        moveCamera.timingFunction =
        [CAMediaTimingFunction functionWithName:
         kCAMediaTimingFunctionEaseInEaseOut];
        moveCamera.removedOnCompletion = NO;
        [cameraNode addAnimation:moveCamera forKey:@"change_position"];
        /*
         * Rotate camera (NOT THE ORBIT)
         */
        CABasicAnimation *rotateCamera =
        [CABasicAnimation animationWithKeyPath:@"rotation"];
        rotateCamera.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(1, 0, 0, atan2(10.0, 20.0))];
        rotateCamera.duration  = 1.0;
        rotateCamera.fillMode  = kCAFillModeForwards;
        rotateCamera.timingFunction =
        [CAMediaTimingFunction functionWithName:
         kCAMediaTimingFunctionEaseInEaseOut];
        rotateCamera.removedOnCompletion = NO;
        [cameraNode addAnimation:rotateCamera forKey:@"rotate_camera"];
        
        [SCNTransaction setCompletionBlock:^{
            /*
             * Set camera's position and rotation by code
             * Set cameraOrbit's rotation by code
             * Remove animation effect to make whole scene view enable to interaction
             * Set cameraOrbit's rotation record to 0
             */
            cameraNode.position = SCNVector3Make(10.0, 2.0, 30.0);
            cameraNode.rotation = SCNVector4Make(1, 0, 0, atan2(10.0, 20.0));
            cameraOrbit.rotation = SCNVector4Make(0.0, 1.0, 0.0, 0.0);
            [cameraNode removeAllAnimations];
            [cameraOrbit removeAllAnimations];
            lastRotation = 0;
        }];
        
    } [SCNTransaction commit];
}

- (IBAction)resetCamera:(id)sender {
    
    [SCNTransaction begin]; {
    
    CABasicAnimation *moveCameraOrbit =
    [CABasicAnimation animationWithKeyPath:@"rotation"];
    moveCameraOrbit.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0.0, 1.0, 0.0, 0)];
    moveCameraOrbit.duration  = 1.0;
    moveCameraOrbit.fillMode  = kCAFillModeForwards;
    moveCameraOrbit.timingFunction =
    [CAMediaTimingFunction functionWithName:
     kCAMediaTimingFunctionEaseInEaseOut];
    moveCameraOrbit.removedOnCompletion = NO;
    [cameraOrbit addAnimation:moveCameraOrbit forKey:@"test"];
    /*
     * Change the positon of the camera
     */
    CABasicAnimation *moveCamera =
    [CABasicAnimation animationWithKeyPath:@"position"];
    moveCamera.toValue = [NSValue valueWithSCNVector3:SCNVector3Make(0.0, 20.0, 30.0)];
    moveCamera.duration  = 1.0;
    moveCamera.fillMode  = kCAFillModeForwards;
    moveCamera.timingFunction =
    [CAMediaTimingFunction functionWithName:
     kCAMediaTimingFunctionEaseInEaseOut];
    moveCamera.removedOnCompletion = NO;
    [cameraNode addAnimation:moveCamera forKey:@"change_position"];
    /*
     * Rotate camera (NOT THE ORBIT)
     */
    CABasicAnimation *rotateCamera =
    [CABasicAnimation animationWithKeyPath:@"rotation"];
    rotateCamera.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(1, 0, 0, -atan2(10.0, 20.0))];
    rotateCamera.duration  = 1.0;
    rotateCamera.fillMode  = kCAFillModeForwards;
    rotateCamera.timingFunction =
    [CAMediaTimingFunction functionWithName:
     kCAMediaTimingFunctionEaseInEaseOut];
    rotateCamera.removedOnCompletion = NO;
    [cameraNode addAnimation:rotateCamera forKey:@"rotate_camera"];
    
    [SCNTransaction setCompletionBlock:^{
        /*
         * Set camera's position and rotation by code
         * Set cameraOrbit's rotation by code
         * Remove animation effect to make whole scene view enable to interaction
         * Set cameraOrbit's rotation record to 0
         */
        cameraNode.position = SCNVector3Make(0.0, 20.0, 30.0);
        cameraNode.rotation = SCNVector4Make(1, 0, 0, -atan2(10.0, 20.0));
        cameraOrbit.rotation = SCNVector4Make(0.0, 1.0, 0.0, 0.0);
        [cameraNode removeAllAnimations];
        [cameraOrbit removeAllAnimations];
        lastRotation = 0;
    }];
    
} [SCNTransaction commit];

}

- (void)resetAllBtns
{
    // Unselected all buttons
    _uiv_colorContainer.hidden = YES;
    _uib_view.selected = NO;
    _uib_size.selected = NO;
    _uib_color.selected = NO;
    _uib_position.selected = NO;
    _uib_rotateCam.selected = NO;
    _uib_edit.selected = NO;
    // Set all BOOL parameter to NO
    rotateCam = NO;
    review = NO;
    sizeBtn = NO;
    position = NO;
    editNode = NO;
    // Remove gestures
//    [myScnView removeGestureRecognizer:panGesture];
//    [myScnView removeGestureRecognizer:pinchGesture];
    for (UIGestureRecognizer *recognizer in myScnView.gestureRecognizers) {
        [myScnView removeGestureRecognizer:recognizer];
    }
    panGesture = nil;
    pinchGesture = nil;
}

#pragma mark - Gestures and handlers to scene view

#pragma mark Long press on target node (tap & drag)
- (void)addLongPressToNodes {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnTarget:)];
    longPress.minimumPressDuration = 0.3;
    [myScnView addGestureRecognizer:longPress];
}

- (void)longPressOnTarget:(UIGestureRecognizer *)gesture {
    
    CGPoint point = [gesture locationInView: myScnView];
    NSArray *hits = [myScnView hitTest:point
                               options:nil];
    [self resetCubeAndWallsBody];
        for (SCNHitTestResult *hit in hits) {
            
            if ([hit.node isEqual:boxNode] && gesture.state == UIGestureRecognizerStateBegan) {
                boxNode.opacity = 0.6;
            }
            
            if ([hit.node isEqual:boxNode] && gesture.state == UIGestureRecognizerStateChanged) {
                
                SCNVector3 hitPosition = hit.worldCoordinates;
                CGFloat hitPositionZ = [myScnView projectPoint: hitPosition].z;
                SCNVector3 location_3d = [myScnView unprojectPoint:SCNVector3Make(point.x, point.y, hitPositionZ)];
                SCNVector3 prevLocation_3d = [myScnView unprojectPoint:SCNVector3Make(boxNode.position.x, boxNode.position.y, hitPositionZ)];
                CGFloat x_varible = location_3d.x - prevLocation_3d.x;
                CGFloat z_varible = location_3d.z - prevLocation_3d.z;
                NSLog(@"The x varible is %f", x_varible);
                if (ABS(x_varible) > 5) {
                    boxNode.position = SCNVector3Make(prevLocation_3d.x + x_varible, boxNode.position.y, prevLocation_3d.z+z_varible);
                }
//                NSLog(@"The point is %@", NSStringFromCGPoint(point));
            }
        }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        boxNode.opacity = 1.0;
    }
}

#pragma mark Edit cube gesutres
- (void)addEditGesutreToBox {
    UITapGestureRecognizer *tapBox = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnBox:)];
    tapBox.numberOfTapsRequired = 2;
    [myScnView addGestureRecognizer: tapBox];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToLeft:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeft.numberOfTouchesRequired = 1;
    [myScnView addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeLeft.numberOfTouchesRequired = 1;
    [myScnView addGestureRecognizer:swipeRight];
    
}

- (void)tapOnBox:(UITapGestureRecognizer *)gesture {
    
    CGPoint point = [gesture locationInView: myScnView];
    NSArray *hits = [myScnView hitTest:point
                               options:nil];
    
    /*
     * Loop through hits array, get targets and change the geometry
     */
    for (SCNHitTestResult *hit in hits) {
        
        if ([hit.node isEqual: boxNode]) {
            box_shapeIndex++;
            if (box_shapeIndex == 3) {
                box_shapeIndex = 0;
            }
            hit.node.geometry = arr_shapes[box_shapeIndex];
            boxNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic
                                                          shape:[SCNPhysicsShape shapeWithGeometry:arr_shapes[box_shapeIndex]
                                                          options:nil]];
        } else if ([hit.node isEqual: cubeNode]) {
            cube_shapeIndex++;
            if (cube_shapeIndex == 3) {
                cube_shapeIndex = 0;
            }
            hit.node.geometry = arr_shapes[cube_shapeIndex];
            cubeNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic
                                                          shape:[SCNPhysicsShape shapeWithGeometry:arr_shapes[cube_shapeIndex]
                                                          options:nil]];
        } else {
            continue;
        }
    }
    
}

- (void)swipeToLeft:(UIGestureRecognizer *)swipeLeft {
    /*
     * Get the start point location of swipe gesture
     */
    CGPoint startPoint;
    startPoint = [swipeLeft locationOfTouch:0 inView:myScnView];
    /*
     * Swipe to left, direction is -1
     */
    [self oneStepRotationOn:startPoint andDirecton:-1];
}

- (void)swipeToRight:(UISwipeGestureRecognizer *)swipeRight {
    /*
     * Get the start point location of swipe gesture
     */
    CGPoint startPoint;
    startPoint = [swipeRight locationOfTouch:0 inView:myScnView];
    /*
     * Swipe to right, direction is +1
     */
    [self oneStepRotationOn:startPoint andDirecton:1];
}

- (void)oneStepRotationOn:(CGPoint)point andDirecton:(int)direction {
    /*
     * If swipe gesture is on target scene node, rotate the target
     */
    float   rotateAngle = M_PI_4 * direction;
    NSArray *hits = [myScnView hitTest:point
                               options:nil];
    for (SCNHitTestResult *hit in hits) {
        
        if ([hit.node isEqual: boxNode]) {
            boxNode.rotation = SCNVector4Make(0, 1, 0, boxNode.rotation.w+rotateAngle);
        } else if ([hit.node isEqual: cubeNode]) {
            cubeNode.rotation = SCNVector4Make(0, 1, 0, cubeNode.rotation.w+rotateAngle);
            hit.node.geometry = arr_shapes[cube_shapeIndex];
        } else {
            continue;
        }
    }
}

#pragma mark View gestures
- (void)addGestureToBox
{
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [myScnView addGestureRecognizer:panGesture];
    
    pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [myScnView addGestureRecognizer:pinchGesture];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    CGPoint translation = [gesture translationInView:myScnView];

    if (gesture.state == UIGestureRecognizerStateChanged) {
        /*
         * Pan gesture distance convert to rotation radian
         */
        boxNode.rotation = SCNVector4Make(0, 1, 0, translation.x/180 * M_PI);
        
        /*
         * Change camera's Y position to move up & down
         * Limitation added to control camera's max height and min position to floor
         */
        
        if (cameraY+translation.y/cameraY <=1 || cameraY+translation.y/cameraY >= 50) {
            return;
        }
        cameraNode.position = SCNVector3Make(cameraX, cameraY + translation.y/cameraY, cameraZ);
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        cameraY = cameraNode.position.y;
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gesture
{
    
    if(gesture.state == UIGestureRecognizerStateChanged)
    {
        /*
         * According to the pinch scale change camera's Z position
         */
        float scale = gesture.scale;
        float maxDistance = 90;
        float minDistance = 10;
        if (cameraZ*scale >= maxDistance || cameraZ*scale <= minDistance) {
            return;
        }
        cameraNode.position = SCNVector3Make(cameraX, cameraY*(1/scale), cameraZ*(1/scale));
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        cameraY = cameraNode.position.y;
        cameraZ = cameraNode.position.z;
    }
}

#pragma mark General touch methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    moveStartTime = event.timestamp;
    touchPoint = [[touches anyObject] locationInView: myScnView];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    // Get the location of the click
    CGPoint point = [touch locationInView: myScnView];
    // Get the hit on the cube
    NSArray *hits = [myScnView hitTest:point options:@{SCNHitTestRootNodeKey: boxNode,
                                                           SCNHitTestIgnoreChildNodesKey: @YES}];
    SCNHitTestResult *hit = [hits firstObject];
    SCNVector3 hitPosition = hit.worldCoordinates;
    CGFloat hitPositionZ = [myScnView projectPoint: hitPosition].z;

    CGPoint location = [touch locationInView:myScnView];
    CGPoint prevLocation = [touch previousLocationInView:myScnView];
    SCNVector3 location_3d = [myScnView unprojectPoint:SCNVector3Make(location.x, location.y, hitPositionZ)];
    SCNVector3 prevLocation_3d = [myScnView unprojectPoint:SCNVector3Make(prevLocation.x, prevLocation.y, hitPositionZ)];
        
    CGFloat x_varible = location_3d.x - prevLocation_3d.x;
    CGFloat z_varible = location_3d.z - prevLocation_3d.z;
    
    intervalTime = event.timestamp - moveStartTime;
    speed = (point.x - touchPoint.x)/intervalTime;
    if (rotateCam) {
        CGFloat moveDistance = (point.x - touchPoint.x);
//        CGFloat raidus = cameraNode.position.z;
//        cameraOrbit.eulerAngles.y = float(-2.0 * M_PI * (moveDistance/raidus));
//        cameraOrbit.eulerAngles.x = float(-M_PI * (moveDistance/raidus));
        
//        NSLog(@"\n\n the original is %f\n\n", lastRotation);
//        NSLog(@"\n\n the angle is %f\n\n", -2.0 * M_PI * (moveDistance/myScnView.frame.size.width));
        if (touches.count == 2) {
            cameraOrbit.eulerAngles = SCNVector3Make(0.0, lastRotation-2.0 * M_PI * (moveDistance/myScnView.frame.size.width),0.0);
        }
        
    }
    
    if (ABS(x_varible/intervalTime) >= 200) {
        return;
    }
    else
    {
        /*
         * Change position of the box
         * Keep Y value (stick on floor)
         */
        if (position) {
            //        if (ABS(boxNode.position.x + x_varible) >= 20 || ABS(boxNode.position.z + z_varible) >= 20) {
            //            return;
            //        }
            [self resetCubeAndWallsBody];
            
            /*
             * ############# POSITION
             */
            
//            boxNode.position = SCNVector3Make(boxNode.position.x + x_varible, box.height/2, boxNode.position.z + z_varible);
            
            
            /*
             * #############VELOCITY
             */
            
//            if (x_varible > 0) {
//                boxNode.physicsBody.velocity = SCNVector3Make(100.0, 0.0, 0.0);
//            }
//            if (x_varible < 0) {
//                boxNode.physicsBody.velocity = SCNVector3Make(-100.0, 0.0, 0.0);
//            }
//            if (z_varible > 0) {
//                boxNode.physicsBody.velocity = SCNVector3Make(0.0, 0.0, 100.0);
//            }
//            if (z_varible < 0) {
//                boxNode.physicsBody.velocity = SCNVector3Make(0.0, 0.0, -100.0);
//            }
            
            
//            boxNode.physicsBody.velocity = SCNVector3Make(x_varible*80, 0.0, z_varible*80);
            
            /*
             * !!!!TEMP!!!!
             * IF POSITION IS TURNED ON BY DEFAULT:
             * AVOID CONFILICTION WITH PAN GESTURE TO ROTATE THE CAMERA
             */
            CGPoint point = [touch locationInView: myScnView];
            // Get the hit on the cube
            NSArray *hits = [myScnView hitTest:point options:nil];
            for (SCNHitTestResult *hit in hits) {
                if ([hit.node isEqual:boxNode]) {
                    boxNode.physicsBody.velocity = SCNVector3Make(x_varible*80, 0.0, z_varible*80);
                }
            }
        }
    }
    
    /*
     * Change scale of the box
     */
    if (sizeBtn) {
        /*
         * ###### Change the scale is not a good method
         * ###### Always reset the scale when begin moving #######
         */
        boxNode.pivot = SCNMatrix4MakeTranslation(0.0, -box.height/2, 0.0);
        boxNode.position = SCNVector3Make(0.0, 0, 0.0);

        boxNode.scale = SCNVector3Make(boxNode.scale.x * fabsf(location_3d.x/10),
                                       boxNode.scale.y * fabsf(location_3d.y/10),
                                       boxNode.scale.z * fabsf(location_3d.z/10));
        
        boxNode.scale = SCNVector3Make(fabsf(location_3d.x/10),
                                       fabsf(location_3d.y/10),
                                       fabsf(location_3d.z/10));
        
        /*
         * Change box's size according to the move distance
         */
//        box.height = location_3d.y+10;
//        box.width = location_3d.x+10;
//        box.length = location_3d.z+10;
//       
//        if (box.height * box.width * box.length <= 0) {
//            return;
//        }
//        else {
//            /*
//             * Change pivot of the node keep it always on top of floor
//             */
//            boxNode.pivot = SCNMatrix4MakeTranslation(0.0, -box.height/2, 0.0);
//            boxNode.position = SCNVector3Make(0.0, box.height/2, 0.0);
//            textNode.position = SCNVector3Make(textNode.position.x, box.height/2, textNode.position.z);
//        }
        
    }
    
    if (editNode) {
        return;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self resetCubeAndWallsBody];
    
    if (rotateCam) {
        
//          ######## Do Transaction to simulate #############
        
//        CGPoint point = [[touches anyObject] locationInView:myScnView];
//        intervalTime = event.timestamp - moveStartTime;
//        float speed = (point.x - touchPoint.x)/intervalTime;
        NSLog(@"\n\nThe speed is %f\n\n", speed);
//        [SCNTransaction begin];
//        [SCNTransaction setAnimationDuration:ABS(speed/1000)];
//        [SCNTransaction setAnimationTimingFunction: [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
//        cameraOrbit.eulerAngles = SCNVector3Make(0.0, cameraOrbit.eulerAngles.y-2.0 * M_PI *(ABS(speed/100)*ABS(speed/100)/4/myScnView.frame.size.width), 0.0);
//        [SCNTransaction commit];
        
        
        // If a = 15
//        float n = (speed/1000)*(speed/1000)/40/2*M_PI*5*sqrtf(2.0);
//        NSLog(@"\n\n Num of rounds %f", n);
//        [SCNTransaction begin];
//        [SCNTransaction setAnimationDuration:ABS(speed/1000)/20];
//        [SCNTransaction setAnimationTimingFunction: [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
//        cameraOrbit.eulerAngles = SCNVector3Make(0.0, cameraOrbit.eulerAngles.y-2.0 * M_PI *n*speed/ABS(speed), 0.0);
//        [SCNTransaction commit];
        
        
        
//        [cameraOrbit runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:1.0 z:0 duration:1]]];
        
//        cameraOrbit.rotation = cameraOrbit.presentationNode.rotation;
        
//        NSLog(@"\n\n Presentation:\n %f \n %f \n %f \n %f \n\n Normal:\n %f \n %f \n %f \n %f \n", cameraOrbit.presentationNode.rotation.x, cameraOrbit.presentationNode.rotation.y, cameraOrbit.presentationNode.rotation.z, cameraOrbit.presentationNode.rotation.w, cameraOrbit.rotation.x, cameraOrbit.rotation.y, cameraOrbit.rotation.z, cameraOrbit.rotation.w);
        
        if (cameraOrbit.rotation.y < 0) {
            lastRotation =  -cameraOrbit.rotation.w ;
        }
        else {
            lastRotation = cameraOrbit.rotation.w;
        }
        if (lastRotation > 6.28) {
            lastRotation = 0;
        }
    }
}

- (void)resetCubeAndWallsBody
{
    /*
     * Reset all physics body
     */
    boxNode.physicsBody = nil;
    cubeNode.physicsBody = nil;
    leftWallNode.physicsBody = nil;
    rightWallNode.physicsBody = nil;
    backWallNode.physicsBody = nil;
    frontWallNode.physicsBody = nil;
    floorNode.physicsBody = nil;
    boxNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic
                                                 shape:[SCNPhysicsShape shapeWithGeometry:box options:nil]];
    
    cubeNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic
                                                  shape:[SCNPhysicsShape shapeWithGeometry:cube options:nil]];
    
    leftWallNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic
                                                      shape:[SCNPhysicsShape shapeWithGeometry:leftWall options:nil]];
    
    rightWallNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic
                                                       shape:[SCNPhysicsShape shapeWithGeometry:rightWall options:nil]];
    
    backWallNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic
                                                      shape:[SCNPhysicsShape shapeWithGeometry:backWall options:nil]];
    
    frontWallNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic
                                                       shape:[SCNPhysicsShape shapeWithGeometry:frontWall options:nil]];
    
    floorNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic
                                                   shape:[SCNPhysicsShape shapeWithGeometry:floor options:nil]];
    
    boxNode.physicsBody.restitution = 1.0;
    boxNode.physicsBody.angularDamping = 1.0;
    boxNode.physicsBody.angularVelocityFactor = SCNVector3Make(0.0, 1.0, 0.0);
    boxNode.physicsBody.friction = 1.0;
    cubeNode.physicsBody.restitution = 1.0;
    cubeNode.physicsBody.angularDamping = 1.0;
    cubeNode.physicsBody.angularVelocityFactor = SCNVector3Make(0.0, 1.0, 0.0);
    cubeNode.physicsBody.friction = 1.0;
    floorNode.physicsBody.friction = 1.0;
}

@end
