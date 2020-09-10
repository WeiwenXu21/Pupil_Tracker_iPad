//
//  ImageAnalyseResult.h
//  EyeTracker
//
//  Created by Weiwen Xu on 29/03/2017.
//  Copyright © 2017 Weiwen Xu. All rights reserved.
//

/* ImageAnalyseResult_h */
#import <Foundation/Foundation.h>
// #import "CameraViewController.h"
#import <UIKit/UIKit.h>
@interface ImageAnalyseResult : NSObject

@property (nonatomic) UIImage *resultImage;

@property (nonatomic) NSInteger xCordinate;
@property (nonatomic) NSInteger yCordinate;

@property (nonatomic) CGRect eyeArea;

- (instancetype)initListwithImage:(UIImage*)inputImg andX:(NSInteger)x andY:(NSInteger)y andWithArea:(CGRect)eyeArea;
@end
