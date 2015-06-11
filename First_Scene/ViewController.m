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
    SCNNode *boxNode;
    SCNNode *cameraNode;
    CGFloat lastRotation;
    UIPanGestureRecognizer *panGesture;
    UIPinchGestureRecognizer *pinchGesture;
    BOOL    position;
    BOOL    review;
}
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
    floor.firstMaterial.diffuse.contents = [UIColor redColor];
    floor.firstMaterial.lightingModelName = SCNLightingModelConstant;
    // Less reflective and decrease by distance
    floor.reflectivity = 0;
    floor.reflectionFalloffEnd = 0;
    SCNNode *floorNode = [SCNNode nodeWithGeometry:floor];
    floorNode.position = SCNVector3Make(0, -5, 0);
    [scene.rootNode addChildNode:floorNode];

    CGFloat boxSide = 10.0;
    SCNBox *box = [SCNBox boxWithWidth:boxSide
                                height:boxSide
                                length:boxSide
                         chamferRadius:1.0];
    boxNode = [SCNNode nodeWithGeometry:box];
    boxNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeKinematic shape:nil];
    box.firstMaterial.specular.contents = [UIColor whiteColor];
//    boxNode.rotation = SCNVector4Make(0.0, 1.0, 0.0, M_PI/6.0);
    [scene.rootNode addChildNode: boxNode];
    
    cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.position = SCNVector3Make(0.0, 10.0, 20.0);
    cameraNode.rotation = SCNVector4Make(1, 0, 0, -atan2(10.0, 20.0));
//    SCNLookAtConstraint *constraint = [SCNLookAtConstraint lookAtConstraintWithTarget:boxNode];
//    cameraNode.constraints = @[constraint];
    [scene.rootNode addChildNode: cameraNode];
    
    SCNLight *light = [SCNLight light];
    light.type = SCNLightTypeDirectional;
    light.color = lightBlueColor;
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = light;
    [cameraNode addChildNode: lightNode];
    
    /*
     * Omni Light
     */
//    SCNLight *omniLight = [SCNLight light];
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
//    SCNLight *spotlight = [SCNLight light];
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
    SCNLight *ambientLight = [SCNLight light];
    ambientLight.type = SCNLightTypeAmbient;
    ambientLight.color = lightBlueColor;
    SCNNode *ambienLightNode = [SCNNode node];
    ambienLightNode.light = ambientLight;
    
    [self.myScnView.scene.rootNode addChildNode: ambienLightNode];
}
- (IBAction)animation:(id)sender {
    UIButton *tmpBtn = sender;
    tmpBtn.selected = !tmpBtn.selected;
    review = tmpBtn.selected;
    if (review)
    {
        [self addGestureToBox];
    }
    else
    {
        [myScnView removeGestureRecognizer:panGesture];
        [myScnView removeGestureRecognizer:pinchGesture];
        panGesture = nil;
        pinchGesture = nil;
    }
    
    /*
     * Free camera control
     */
//    self.myScnView.allowsCameraControl = YES;
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
        // Get the hit on the cube
        NSArray *hits = [myScnView hitTest:translation options:@{SCNHitTestRootNodeKey: boxNode,
                                                                 SCNHitTestIgnoreChildNodesKey: @YES}];
        SCNHitTestResult *hit = [hits firstObject];
        SCNVector3 hitPosition = hit.worldCoordinates;
        CGFloat hitPositionZ = [myScnView projectPoint: hitPosition].z;
        SCNVector3 position_3d = [myScnView unprojectPoint:SCNVector3Make(translation.x, translation.y, hitPositionZ)];
        
        position_3d.x = position_3d.x + 18;
        NSLog(@"\n\n\n %f", -atan(position_3d.x / position_3d.z));
        boxNode.rotation = SCNVector4Make(0, 1, 0,  -atan(position_3d.x / position_3d.z));
        
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
- (IBAction)tapPositionBtn:(id)sender {
    UIButton *tmpBtn = sender;
    tmpBtn.selected = !tmpBtn.selected;
    position = tmpBtn.selected;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (position) {
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
        CGFloat nodeX = hit.node.position.x;
        CGFloat nodeY = hit.node.position.y;
        CGFloat nodeZ = hit.node.position.z;
        
        CGPoint location = [touch locationInView:myScnView];
        CGPoint prevLocation = [touch previousLocationInView:myScnView];
        SCNVector3 location_3d = [myScnView unprojectPoint:SCNVector3Make(location.x, location.y, hitPositionZ)];
        SCNVector3 prevLocation_3d = [myScnView unprojectPoint:SCNVector3Make(prevLocation.x, prevLocation.y, hitPositionZ)];
        
        CGFloat x_varible = location_3d.x - prevLocation_3d.x;
        CGFloat z_varible = location_3d.z - prevLocation_3d.z;
        
        hit.node.position = SCNVector3Make(nodeX + x_varible, nodeY, nodeZ + z_varible);
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
