//
//  ViewController.h
//  First_Scene
//
//  Created by Xiaohe Hu on 6/8/15.
//  Copyright (c) 2015 Xiaohe Hu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <SpriteKit/SpriteKit.h> 

@interface ViewController : UIViewController <SCNPhysicsContactDelegate>

@property (weak, nonatomic) IBOutlet SCNView *myScnView;

@end

