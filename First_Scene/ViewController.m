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
    CABasicAnimation *grow = [CABasicAnimation animationWithKeyPath:@"geometry.height"];
    grow.fromValue = @0.5;
    // ... and the position
    CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position.y"];
    move.fromValue = @10;
    
    // group both animations
    CAAnimationGroup *growGroup = [CAAnimationGroup animation];
    growGroup.animations = @[grow, move];
    growGroup.duration   = 1.0;
    growGroup.beginTime  = CACurrentMediaTime();
    growGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    growGroup.fillMode = kCAFillModeBackwards;
    
    
    // animate the rotation of the chart
    CABasicAnimation *rotateBox = [CABasicAnimation animationWithKeyPath:@"rotation.w"];
    rotateBox.fromValue = @(0);
    rotateBox.duration  = 1.0;
    rotateBox.beginTime = CACurrentMediaTime();
    rotateBox.fillMode  = kCAFillModeBackwards;
    rotateBox.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *rotateCam = [CABasicAnimation animationWithKeyPath:@"position.z"];
    rotateCam.toValue = @30;
    rotateCam.duration = 1.0;
    rotateCam.beginTime = CACurrentMediaTime();
    rotateCam.fillMode = kCAFillModeForwards;
    rotateCam.removedOnCompletion = NO;
    rotateCam.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
//    [boxNode addAnimation:growGroup forKey:@"testAnimation"];
//    [boxNode addAnimation:rotateBox forKey:@"rotation"];
//    [cameraNode addAnimation:rotateCam forKey:@"cameraRotation"];
    
    [self addGestureToBox];
    
//    self.myScnView.allowsCameraControl = YES;
}

- (void)addGestureToBox
{
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [[self view] addGestureRecognizer:recognizer];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinch];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    CGPoint translation = [gesture translationInView:self.view];
//    CGFloat positionX = boxNode.position.x;
//    CGFloat positionY = boxNode.position.y;
//    CGFloat positionZ = boxNode.position.z;
//    if(gesture.state == UIGestureRecognizerStateChanged)
//    {
//        
//        boxNode.position = SCNVector3Make(positionX + translation.x/400/sqrt(2.0), positionY - translation.y/400/sqrt(2.0), positionZ + translation.x/400/sqrt(2.0));
//    }
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        
        boxNode.rotation = SCNVector4Make(0, 1, 0, lastRotation + atan2(translation.x, self.myScnView.bounds.size.width));
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        lastRotation = lastRotation + atan2(translation.x, self.myScnView.bounds.size.width);
    }
    CGFloat cameraX = cameraNode.position.x;
    CGFloat cameraY = cameraNode.position.y;
    CGFloat cameraZ = cameraNode.position.z;
    if(gesture.state == UIGestureRecognizerStateChanged)
    {
        if (ABS(translation.y) < 60) {
            return;
        }
        
        if (cameraY+translation.y/400 <=1 || cameraY+translation.y/400 >= 50) {
            return;
        }
        cameraNode.position = SCNVector3Make(cameraX, cameraY+translation.y/400, cameraZ) ;
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
        
        NSLog(@"the value is \n\n%f", cameraZ*scale);
        
        cameraNode.position = SCNVector3Make(cameraX, cameraY*scale, cameraZ*scale);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
