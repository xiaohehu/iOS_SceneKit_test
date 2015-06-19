//
//  ViewController.m
//  First_Scene
//
//  Created by Xiaohe Hu on 6/8/15.
//  Copyright (c) 2015 Xiaohe Hu. All rights reserved.
//

#import "ViewController.h"

typedef NS_OPTIONS(NSUInteger, CollisionCategory) {
    CollisionCategoryWall    = 0x1 << 0,
    CollisionCategoryCube    = 0x1 << 1,
};

@interface ViewController ()
{
    SCNNode                     *floorNode;
    SCNBox                      *box;
    SCNPlane                    *leftWall;
    SCNPlane                    *rightWall;
    SCNPlane                    *backWall;
    SCNPlane                    *frontWall;
    SCNPlane                    *floor;
    SCNNode                     *boxNode;
    SCNNode                     *cameraNode;
    SCNNode                     *textNode;
    SCNNode                     *leftWallNode;
    SCNNode                     *rightWallNode;
    SCNNode                     *backWallNode;
    SCNNode                     *frontWallNode;
    CGFloat                     lastRotation;
    SCNLight                    *light;
    SCNLight                    *omniLight;
    SCNLight                    *spotlight;
    SCNLight                    *ambientLight;
    UIPanGestureRecognizer      *panGesture;
    UIPinchGestureRecognizer    *pinchGesture;
    CGFloat                     cameraY;
    CGFloat                     cameraZ;
    CGFloat                     cameraX;
    
    float   moveStartTime;
    float   intervalTime;
    
    BOOL    position;
    BOOL    review;
    BOOL    sizeBtn;
}

@property (weak, nonatomic) IBOutlet UIButton *uib_view;
@property (weak, nonatomic) IBOutlet UIButton *uib_position;
@property (weak, nonatomic) IBOutlet UIButton *uib_size;
@property (weak, nonatomic) IBOutlet UIButton *uib_color;
@property (weak, nonatomic) IBOutlet UIButton *uib_freeCam;

@property (weak, nonatomic) IBOutlet UIView *uiv_colorContainer;
@property (weak, nonatomic) IBOutlet UIButton *uib_yellow;
@property (weak, nonatomic) IBOutlet UIButton *uib_blue;
@property (weak, nonatomic) IBOutlet UIButton *uib_green;

@end

@implementation ViewController

@synthesize myScnView;

- (void)physicsWorld:(SCNPhysicsWorld *)world didEndContact:(SCNPhysicsContact *)contact
{
//    position = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    myScnView.scene.physicsWorld.gravity = SCNVector3Make(0, 0, 0);
    
    SCNScene *scene = [SCNScene scene];
    myScnView.scene = scene;
    myScnView.scene.physicsWorld.gravity = SCNVector3Make(0.0, 0.0, 0.0);
    myScnView.scene.physicsWorld.contactDelegate = self;
    myScnView.scene.physicsWorld.timeStep = 1.0/600.0;
    
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
    
    // A plane on X-Z coordinates
    // ------------------
    floor = [SCNPlane planeWithWidth:50 height:50];
    floor.firstMaterial.diffuse.contents = [UIColor colorWithRed:79.0/255.0 green:191.0/255.0 blue:76.0/255.0 alpha:1.0];
    floor.firstMaterial.lightingModelName = SCNLightingModelConstant;
    floorNode = [SCNNode nodeWithGeometry:floor];
    floorNode.position = SCNVector3Make(0, 0, 0);
//    floorNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeKinematic shape:[SCNPhysicsShape shapeWithGeometry:floor options:nil]];
    floorNode.pivot = SCNMatrix4MakeTranslation(0.0, 0.0, 0.0);
    floorNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
    floorNode.physicsBody.friction = 0.5;
    [scene.rootNode addChildNode:floorNode];

    // A plane on Y-Z coordinates left
    // ------------------
    leftWall = [SCNPlane planeWithWidth:50 height:50];
    leftWall.firstMaterial.diffuse.contents = [UIColor blackColor];
//    leftWall.firstMaterial.lightingModelName = SCNLightingModelConstant;
    leftWallNode = [SCNNode nodeWithGeometry:leftWall];
    leftWallNode.rotation = SCNVector4Make(0, 1, 0, M_PI_2);
    leftWallNode.position = SCNVector3Make(-25, 0, 0);
    leftWallNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic shape:[SCNPhysicsShape shapeWithGeometry:leftWall options:nil]];
    leftWallNode.physicsBody.physicsShape = [SCNPhysicsShape shapeWithGeometry:leftWall options:nil];
    leftWallNode.physicsBody.restitution = 0.0;
    leftWallNode.physicsBody.angularDamping = 1.0;
//    leftWallNode.pivot = SCNMatrix4MakeTranslation(0.0, 0.0, 0.0);
    [scene.rootNode addChildNode:leftWallNode];
    
    // A plane on Y-Z coordinates right
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
    
    // A plane on X-Y coordinates back
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
    
    // A plane on X-Y coordinates front
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
    
    CGFloat boxSide = 10.0;
    box = [SCNBox boxWithWidth:boxSide
                                height:boxSide
                                length:boxSide
                         chamferRadius:1.0];
    box.firstMaterial.diffuse.contents = [UIColor whiteColor];
    boxNode = [SCNNode nodeWithGeometry:box];
    boxNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic
                                                 shape:[SCNPhysicsShape shapeWithGeometry:[SCNBox boxWithWidth:20 height:20 length:20 chamferRadius:0.0] options:nil]];
    boxNode.physicsBody.restitution = 0.0;
    boxNode.physicsBody.angularDamping = 1.0;
//    boxNode.pivot = SCNMatrix4MakeTranslation(0.0, -box.height/2, 0.0);
    boxNode.position = SCNVector3Make(0.0, box.height/2, 0.0);
    [scene.rootNode addChildNode: boxNode];
    
    leftWallNode.physicsBody.categoryBitMask = CollisionCategoryWall;
    rightWallNode.physicsBody.categoryBitMask = CollisionCategoryWall;
    backWallNode.physicsBody.categoryBitMask = CollisionCategoryWall;
    frontWallNode.physicsBody.categoryBitMask = CollisionCategoryWall;
    boxNode.physicsBody.categoryBitMask = CollisionCategoryCube;
    
    leftWallNode.physicsBody.collisionBitMask = CollisionCategoryCube;
    rightWallNode.physicsBody.collisionBitMask = CollisionCategoryCube;
    backWallNode.physicsBody.collisionBitMask = CollisionCategoryCube;
    frontWallNode.physicsBody.collisionBitMask = CollisionCategoryCube;
    boxNode.physicsBody.collisionBitMask = CollisionCategoryWall;
    
    cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.position = SCNVector3Make(0.0, 20.0, 30.0);
    cameraNode.camera.zFar = 500;
    cameraX = 0.0;
    cameraY = 20.0;
    cameraZ = 30.0;
    cameraNode.rotation = SCNVector4Make(1, 0, 0, -atan2(10.0, 20.0));
//    SCNLookAtConstraint *constraint = [SCNLookAtConstraint lookAtConstraintWithTarget:boxNode];
//    cameraNode.constraints = @[constraint];
    [scene.rootNode addChildNode: cameraNode];
    
    NSString *myText = @"HOTEL";
    SCNText *text = [SCNText textWithString:myText
                             extrusionDepth:0.2];
    text.firstMaterial.diffuse.contents =
    [UIColor colorWithWhite:.9 alpha:1.0];
    text.font = [UIFont systemFontOfSize:2.0];
    text.flatness = 0.1;
    textNode = [SCNNode nodeWithGeometry:text];
    textNode.position = SCNVector3Make(-2.5,
                                       box.height/2 + 2,
                                       0);
    SCNNode *tempNode = [SCNNode node];
    tempNode.position = SCNVector3Make(0, 0, -50000);
    [scene.rootNode addChildNode: tempNode];
    SCNLookAtConstraint *constraint = [SCNLookAtConstraint lookAtConstraintWithTarget:tempNode];
    textNode.constraints = @[constraint];
    [boxNode addChildNode: textNode];
    
    light = [SCNLight light];
    light.type = SCNLightTypeDirectional;
    light.color = lightBlueColor;
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = light;
    [cameraNode addChildNode: lightNode];
    
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

- (IBAction)tapFreeCam:(id)sender {
    _uib_freeCam.selected = !_uib_freeCam.selected;
    /*
     * Free camera control
     */
    self.myScnView.allowsCameraControl = _uib_freeCam.selected;
}

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

- (IBAction)tapPositionBtn:(id)sender {

    if (!_uib_position.selected) {
        [self resetAllBtns];
        _uib_position.selected = YES;
        position = YES;
    }
    else {
        [self resetAllBtns];
    }
}

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

- (void)resetAllBtns
{
    _uiv_colorContainer.hidden = YES;
    _uib_view.selected = NO;
    _uib_size.selected = NO;
    _uib_color.selected = NO;
    _uib_position.selected = NO;
    review = NO;
    sizeBtn = NO;
    position = NO;
    [myScnView removeGestureRecognizer:panGesture];
    [myScnView removeGestureRecognizer:pinchGesture];
    panGesture = nil;
    pinchGesture = nil;
}

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
        
        
        BOOL isVisible = [myScnView isNodeInsideFrustum:boxNode withPointOfView:myScnView.pointOfView];
        if (!isVisible) {
            NSLog(@"\n\n Off the screen \n\n");
        }

        BOOL isInCamera = [myScnView isNodeInsideFrustum:boxNode
                                               withPointOfView:myScnView.pointOfView];
        if (!isInCamera) {
            NSLog(@"\n\n Off the camera");
        }
        
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    moveStartTime = event.timestamp;
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
    
    if (ABS(x_varible/intervalTime) >= 400) {
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
            
            
            boxNode.physicsBody.velocity = SCNVector3Make(x_varible*80, 0.0, z_varible*80);
            
            
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
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self resetCubeAndWallsBody];
}

- (void)resetCubeAndWallsBody
{
    boxNode.physicsBody = nil;
    leftWallNode.physicsBody = nil;
    rightWallNode.physicsBody = nil;
    backWallNode.physicsBody = nil;
    frontWallNode.physicsBody = nil;
    floorNode.physicsBody = nil;
    boxNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic shape:[SCNPhysicsShape shapeWithGeometry:box options:nil]];
    leftWallNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic shape:[SCNPhysicsShape shapeWithGeometry:leftWall options:nil]];
    rightWallNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic shape:[SCNPhysicsShape shapeWithGeometry:rightWall options:nil]];
    backWallNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic shape:[SCNPhysicsShape shapeWithGeometry:backWall options:nil]];
    frontWallNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic shape:[SCNPhysicsShape shapeWithGeometry:frontWall options:nil]];
    floorNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic shape:[SCNPhysicsShape shapeWithGeometry:floor options:nil]];
    
    boxNode.physicsBody.restitution = 1.0;
    boxNode.physicsBody.angularDamping = 1.0;
    boxNode.physicsBody.angularVelocityFactor = SCNVector3Make(0.0, 1.0, 0.0);
    boxNode.physicsBody.friction = 1.8;
    floorNode.physicsBody.friction = 1.8;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
