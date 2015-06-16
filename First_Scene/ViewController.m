//
//  ViewController.m
//  First_Scene
//
//  Created by Xiaohe Hu on 6/8/15.
//  Copyright (c) 2015 Xiaohe Hu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    SCNNode *floorNode;
    SCNBox  *box;
    SCNNode *boxNode;
    SCNNode *cameraNode;
    SCNNode *textNode;
    CGFloat lastRotation;
    SCNLight *light;
    SCNLight *omniLight;
    SCNLight *spotlight;
    SCNLight *ambientLight;
    UIPanGestureRecognizer *panGesture;
    UIPinchGestureRecognizer *pinchGesture;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    SCNScene *scene = [SCNScene scene];
    myScnView.scene = scene;
    UIColor *lightBlueColor = [UIColor colorWithRed:4.0/255.0
                                              green:120.0/255.0
                                               blue:255.0/255.0
                                              alpha:1.0];
    
    // A reflective floor
    // ------------------
    SCNFloor *floor = [SCNFloor floor];
    // A solid white color, not affected by light
    floor.firstMaterial.diffuse.contents = [UIColor colorWithRed:79.0/255.0 green:191.0/255.0 blue:76.0/255.0 alpha:1.0];
    floor.firstMaterial.lightingModelName = SCNLightingModelConstant;
    // Less reflective and decrease by distance
    floor.reflectivity = 0;
    floor.reflectionFalloffEnd = 0;
    floorNode = [SCNNode nodeWithGeometry:floor];
    floorNode.position = SCNVector3Make(0, -5, 0);
    floorNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeKinematic shape:[SCNPhysicsShape shapeWithGeometry:floor options:nil]];
    [scene.rootNode addChildNode:floorNode];

    CGFloat boxSide = 10.0;
    box = [SCNBox boxWithWidth:boxSide
                                height:boxSide
                                length:boxSide
                         chamferRadius:1.0];
    box.firstMaterial.specular.contents = [UIColor whiteColor];
    boxNode = [SCNNode nodeWithGeometry:box];
    boxNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeKinematic shape:[SCNPhysicsShape shapeWithGeometry:box options:nil]];
    boxNode.pivot = SCNMatrix4MakeTranslation(0.0, -box.height/2, 0.0);
    boxNode.position = SCNVector3Make(0.0, floorNode.position.y, 0.0);
//    boxNode.rotation = SCNVector4Make(0.0, 1.0, 0.0, M_PI/6.0);
    [scene.rootNode addChildNode: boxNode];
    
    cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.position = SCNVector3Make(0.0, 10.0, 20.0);
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
        
        /*
         * Change camera's Y position to move up & down 
         * ####  MAGIC NUM 400 #####
         * Limitation added to control camera's max height and min position to floor
         */
        CGFloat cameraX = cameraNode.position.x;
        CGFloat cameraY = cameraNode.position.y;
        CGFloat cameraZ = cameraNode.position.z;
        if (ABS(translation.y) < 60) {
            return;
        }
        
        if (cameraY+translation.y/400 <=1 || cameraY+translation.y/400 >= 50) {
            return;
        }
        cameraNode.position = SCNVector3Make(cameraX, cameraY+ translation.y/400, cameraZ);
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gesture
{
    CGFloat cameraX = cameraNode.position.x;
    CGFloat cameraY = cameraNode.position.y;
    CGFloat cameraZ = cameraNode.position.z;
    
    if (cameraZ <= 10 || cameraZ >= 80) {
        return;
    }
    
    if(gesture.state == UIGestureRecognizerStateChanged)
    {
        
        float scale = ABS(gesture.scale-2);
        if (gesture.scale > 2) {
            scale = 2.0;
        }
        
        if (cameraZ*scale >= 80 || cameraZ*scale <= 10) {
            return;
        }
        
        cameraNode.position = SCNVector3Make(cameraX, cameraY*scale, cameraZ*scale);
    }
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
    // Record the original position of the node
//    CGFloat nodeX = hit.node.position.x;
//    CGFloat nodeY = hit.node.position.y;
//    CGFloat nodeZ = hit.node.position.z;

    CGPoint location = [touch locationInView:myScnView];
    CGPoint prevLocation = [touch previousLocationInView:myScnView];
    SCNVector3 location_3d = [myScnView unprojectPoint:SCNVector3Make(location.x, location.y, hitPositionZ)];
    SCNVector3 prevLocation_3d = [myScnView unprojectPoint:SCNVector3Make(prevLocation.x, prevLocation.y, hitPositionZ)];
        
    CGFloat x_varible = location_3d.x - prevLocation_3d.x;
    CGFloat z_varible = location_3d.z - prevLocation_3d.z;
    
    /*
     * Change position of the box
     * Keep Y value (stick on floor)
     */
    if (position) {
        boxNode.position = SCNVector3Make(boxNode.position.x + x_varible, floorNode.position.y, boxNode.position.z + z_varible);
    }
    
    /*
     * Change scale of the box
     */
    if (sizeBtn) {
        /*
         * ###### Change the scale is not a good method
         * ###### Always reset the scale when begin moving #######
         */
//        boxNode.scale = SCNVector3Make(boxNode.scale.x * fabsf(location_3d.x/10),
//                                       boxNode.scale.y * fabsf(location_3d.y/10),
//                                       boxNode.scale.z * fabsf(location_3d.z/10));
        
//        boxNode.scale = SCNVector3Make(fabsf(location_3d.x/10),
//                                       fabsf(location_3d.y/10),
//                                       fabsf(location_3d.z/10));
        
        /*
         * Change box's size according to the move distance
         */
        box.height = location_3d.y+10;
        box.width = location_3d.x+10;
        box.length = location_3d.z+10;
       
        if (box.height * box.width * box.length <= 0) {
            return;
        }
        else {
            /*
             * Change pivot of the node keep it always on top of floor
             */
            boxNode.pivot = SCNMatrix4MakeTranslation(0.0, -box.height/2, 0.0);
            boxNode.position = SCNVector3Make(0.0, floorNode.position.y, 0.0);
            textNode.position = SCNVector3Make(textNode.position.x, box.height/2+2, textNode.position.z);
        }
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
