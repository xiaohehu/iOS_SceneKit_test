//
//  ViewController.m
//  First_Scene
//
//  Created by Xiaohe Hu on 6/8/15.
//  Copyright (c) 2015 Xiaohe Hu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

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
    
    CGFloat boxSide = 10.0;
    SCNBox *box = [SCNBox boxWithWidth:boxSide
                                height:boxSide
                                length:boxSide
                         chamferRadius:0.0];
    SCNNode *boxNode = [SCNNode nodeWithGeometry:box];
    box.firstMaterial.specular.contents = [UIColor whiteColor];
    boxNode.rotation = SCNVector4Make(0.0, 1.0, 0.0, M_PI/5.0);
    [scene.rootNode addChildNode: boxNode];
    
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.position = SCNVector3Make(0.0, 10.0, 20.0);
    cameraNode.rotation = SCNVector4Make(1, 0, 0, -atan2(10.0, 20.0));
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
//    [cameraNode addChildNode: omniLightNode];
    
    /*
     * Spot Light
     */
    SCNLight *spotlight = [SCNLight light];
    spotlight.type = SCNLightTypeSpot;
    spotlight.color = lightBlueColor;
    spotlight.spotInnerAngle = 10;
    spotlight.spotOuterAngle = 15;
    SCNNode *spotLightNode = [SCNNode node];
    spotLightNode.light = spotlight;
    [cameraNode addChildNode: spotLightNode];
    
    /*
     * Ambient Light
     */
//    SCNLight *ambientLight = [SCNLight light];
//    ambientLight.type = SCNLightTypeAmbient;
//    ambientLight.color = lightBlueColor;
//    SCNNode *ambienLightNode = [SCNNode node];
//    ambienLightNode.light = ambientLight;
//    
//    [cameraNode addChildNode: ambienLightNode];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
