//
//  jhViewController.h
//  EngineFoundation
//
//  Created by JuHeQi on 13-8-25.
//  Copyright (c) 2013年 JU Heqi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface jhViewController : GLKViewController

- (void)update;
- (void)setupGL;
- (void)tearDownGL;
- (GLKBaseEffect*)getCurrentEffect;

@property (weak, nonatomic) IBOutlet UILabel *textDisplay;

@end
