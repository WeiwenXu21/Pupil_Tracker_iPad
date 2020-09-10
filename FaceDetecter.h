//
//  FaceDetectCamera.h
//  SuperCool Logo Detector
//
//  Created by Weiwen Xu on 15/02/2017.
//  Copyright © 2017 Weiwen Xu. All rights reserved.
//
/* FaceDetectCamera_h */
#import <opencv2/imgcodecs/ios.h>

#import <opencv2/videoio/cap_ios.h>
#import <opencv2/objdetect.hpp>
#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/imgproc.hpp>
#import <opencv2/core/core_c.h>
#import <opencv2/core/core.hpp>
#import <opencv2/highgui/highgui_c.h>
#import <opencv2/imgcodecs/imgcodecs_c.h>
#import <Foundation/Foundation.h>

#import "ImageAnalyseResult.h"

using namespace cv;

@interface FaceDetectCamera : NSObject <CvVideoCameraDelegate>{
    CascadeClassifier faceCascade;
    CascadeClassifier leftEyeCascade;
    CascadeClassifier rightEyeCascade;
}

@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (nonatomic) BOOL capture;
@property (nonatomic, strong) UIImage* savedImage;
@property (nonatomic) cv::Point leftPupil;
@property (nonatomic) cv::Point rightPupil;

- (instancetype)initWithCameraView:(UIImageView *)view;

- (void)startCapture;

-(cv::Point)PupilLoc:(NSString*)name;
-(cv::Mat)capturedFrame;

-(cv::Rect)leftEyeArea;
-(cv::Rect)rightEyeArea;

-(ImageAnalyseResult*)result;
@end
