//
//  ImageAnalyseResult.m
//  EyeTracker
//
//  Created by Weiwen Xu on 29/03/2017.
//  Copyright © 2017 Weiwen Xu. All rights reserved.
//

#import "ImageAnalyseResult.h"

@interface ImageAnalyseResult()

@end

@implementation ImageAnalyseResult

- (instancetype)initListwithImage:(UIImage*)inputImg andX:(NSInteger)x andY:(NSInteger)y andWithArea:(CGRect)eyeArea{
    self = [super init];
    
    self.resultImage = inputImg;        // Eye image to be saved
    self.xCordinate = x;                // Pupil location in X
    self.yCordinate = y;                // Pupil location in Y
    self.eyeArea = eyeArea;             // Area of the eye image
    
    return self;
}

@end
