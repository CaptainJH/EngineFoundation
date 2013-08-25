//
//  jhGLKitDojoingViewController.m
//  EngineFoundation
//
//  Created by JuHeQi on 13-8-25.
//  Copyright (c) 2013年 JU Heqi. All rights reserved.
//

#import "jhGLKitDojoingViewController.h"
#import "Surface.h"

@interface jhGLKitDojoingViewController () {
    float _rotation;
    
    Drawable* _drawable;
}
@end

@implementation jhGLKitDojoingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - real stuff

- (void)setupGL
{
    [super setupGL];
    //_drawable = new BoxDrawable();
    _drawable = new SphereDrawable();  
}

- (void)tearDownGL
{
    [super tearDownGL];
    
    if(_drawable)
    {
        delete _drawable;
    }
    
}

- (void)update
{
    [super update];
    
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    [super getCurrentEffect].transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
    
    // Compute the model view matrix for the object rendered with GLKit
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);
    //modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    [super getCurrentEffect].transform.modelviewMatrix = modelViewMatrix;
    
    _rotation += self.timeSinceLastUpdate * 0.5f;
    
    super.textDisplay.text = [NSString stringWithFormat:@"%d", self.framesPerSecond];
  
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [super glkView:view drawInRect:rect];
    
    _drawable->draw();
}



@end
