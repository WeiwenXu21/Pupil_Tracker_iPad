//
//  FaceDetecter.m
//  EyeTracker
//
//  Created by Weiwen Xu on 15/02/2017.
//  Copyright © 2017 Weiwen Xu. All rights reserved.
//

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif

#import "FaceDetecter.h"
#import "UIImage+OpenCV.h"

#import "CameraViewController.h"
#import "ImageAnalyseResult.h"

#include "GradientHelper.h"
using namespace cv;

NSString* const faceCascadeFile = @"haarcascade_frontalface_alt2";
NSString* const leftEyeCascadeFile = @"haarcascade_lefteye_2splits";
NSString* const rightEyeCascadeFile = @"haarcascade_righteye_2splits";
NSInteger const HaarOptions = CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_DO_ROUGH_SEARCH;


@interface FaceDetectCamera()

@property (nonatomic, retain) CvVideoCamera *videocamera;

@property (nonatomic) cv::Point leftPupilHough;
@property (nonatomic) cv::Point rightPupilHough;

@property cv::Mat taken_image;
@property cv::Mat toUseimage;

@property (nonatomic) cv::Point leftEyeBoundaryPt1;
@property (nonatomic) cv::Point leftEyeBoundaryPt2;
@property (nonatomic) cv::Point rightEyeBoundaryPt1;
@property (nonatomic) cv::Point rightEyeBoundaryPt2;

@property (nonatomic) cv::Mat leftEye;
@property (nonatomic) cv::Mat rightEye;
@property (nonatomic) cv::Mat takenLeftEye;
@property (nonatomic) cv::Mat takenRightEye;

@property (nonatomic) ImageAnalyseResult* result;

@property (nonatomic) NSInteger gradientLocCount;
@property (nonatomic) cv::Point center_Gradient;

@end

@implementation FaceDetectCamera

const int kWeightBlurSize = 5;
const double kGradientThreshold = 50.0;


/**
 * Initialise the face detector within imageview
 **/
- (instancetype)initWithCameraView:(UIImageView *)view{
    
    self = [super init];
    
    if (self) {
        
        _videoCamera = [[CvVideoCamera alloc] initWithParentView:view];                     // Allocate cvVideoCamera as camera
        _videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;          // Set it to be back camera on device
        _videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;         // Set capture settings for 640x480 pixel
        _videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;  // Set video orientation to be vertical
        _videoCamera.defaultFPS = 30;                                                       // Set lowest possible FPS to allow faster process
        _videoCamera.grayscaleMode = NO;                                                    // Turn off gray scale
        _videoCamera.delegate = self;                                                       // Set delegation
        
        
        NSString *faceCascadePath = [[NSBundle mainBundle] pathForResource:faceCascadeFile ofType:@"xml"];
        faceCascade.load([faceCascadePath UTF8String]);                         // Load face cascade classifier for face detecting
        
        NSString *leftEyeCascadePath = [[NSBundle mainBundle] pathForResource:leftEyeCascadeFile ofType:@"xml"];
        leftEyeCascade.load([leftEyeCascadePath UTF8String]);                   // Load left eye cascade classifier for left eye detecting
        
        NSString *rightEyeCascadePath = [[NSBundle mainBundle] pathForResource:rightEyeCascadeFile ofType:@"xml"];
        rightEyeCascade.load([rightEyeCascadePath UTF8String]);                 // Load right eye cascade classifier for right eye detecting
        
        _gradientLocCount = 1;
        
    }
    
    return self;
}

/**
 * Method for start video capturing
 **/
- (void)startCapture {
    [_videoCamera start];
    NSLog(@"video camera running: %d", [_videoCamera running]);
    NSLog(@"capture session loaded: %d", [_videoCamera captureSessionLoaded]);
}

#ifdef __cplusplus

/**
 * Method for processing frame images
 **/
- (void)processImage:(Mat&)image;
{
    
    Mat grayscaleFrame;
    cvtColor(image, grayscaleFrame, CV_BGR2GRAY);                           // Convert frame image to gray scale for later processing
    equalizeHist(grayscaleFrame, grayscaleFrame);                           // Improve contract in the image
    
    std::vector<cv::Rect> faces;
    faceCascade.detectMultiScale(grayscaleFrame, faces, 1.1, 2, HaarOptions, cv::Size(60, 60)); // Detect face with face cascade classifier
    
    
    for (int i = 0; i < faces.size(); i++){
        cv::Point pt1(faces[i].x + faces[i].width, faces[i].y + faces[i].height);
        cv::Point pt2(faces[i].x, faces[i].y);
        
        cv::Point pt3(faces[i].x + faces[i].width*0.5, faces[i].y + faces[i].height);
        cv::Point pt4(faces[i].x+faces[i].width*0.5, faces[i].y);
        
        cv::rectangle(image, pt1, pt2, cvScalar(0, 255, 0, 0), 1, 8 ,0);    // Draw face area
        
        cv::Rect newObjectRight(pt2,pt3);                                   // Get area of right half of detected face
        cv::Rect newObjectLeft(pt4,pt1);                                    // Get area of left half of detected face

        [self detectEyeWithClassifier:rightEyeCascade withFrame:grayscaleFrame withOriginalImage:image check:newObjectRight id:@"right"];
                                                                            // Detect right eye on right half side area
        
        [self detectEyeWithClassifier:leftEyeCascade withFrame:grayscaleFrame withOriginalImage:image check:newObjectLeft id:@"left"];
                                                                            // Detect left eye on left half side area
        
        _toUseimage = image;
        [self printOnScreen:image];
    }
    
    if(_capture){                               // Check if user wants to save this frame image
                                                // Yes, then
        _takenLeftEye = _leftEye;               // Save left eye (X,Y)
        _takenRightEye = _rightEye;             // Save right eye (X,Y)
        _capture = false;                       // Turn off BOOL
    }

}

/**
 * Method for printing pupil location on screen
 **/
-(void)printOnScreen:(Mat&)image{
    
    cv::Point houghLeft(_leftEyeBoundaryPt1.x,_leftEyeBoundaryPt2.y);    // Set location for printing left eye hough processed location
    cv::Point houghRight(_rightEyeBoundaryPt1.x,_rightEyeBoundaryPt2.y); // Set location for printing right eye hough processed location
    NSString *leftPupil = [NSString stringWithFormat: @"(%i,%i)",_leftPupil.x,_leftPupil.y];
    const char* leftPupilStr = [leftPupil cStringUsingEncoding: NSUTF8StringEncoding];                      // Standardize string
    cv::putText(image, leftPupilStr, houghLeft, CV_FONT_HERSHEY_PLAIN, 1.0, cv::Scalar(255, 0, 0));         // Draw string
    
    
    NSString *rightPupil = [NSString stringWithFormat: @"(%i,%i)",_rightPupil.x,_rightPupil.y];
    const char* rightPupilStr = [rightPupil cStringUsingEncoding: NSUTF8StringEncoding];                    // Standardize string
    cv::putText(image, rightPupilStr, houghRight, CV_FONT_HERSHEY_PLAIN, 1.0, cv::Scalar(255, 0, 0));       // Draw string
    
    circle( image, _leftPupil, 1, Scalar(0,0,255), 5, CV_AA);
    circle( image, _rightPupil, 1, Scalar(0,0,255), 5, CV_AA);
    
    
}

/**
 * Method for calculating the average location detected by Hough and Gradient
 * @HoughPupil: pupil location detected by Circle Hough Transform
 * @GradientPupil: pupil location detected by Means of Gradient
 * return pupilLoc: the average point being calculated
 **/
-(cv::Point)calculatePupilLocationWithHough:(cv::Point)HoughPupil andWithGradinate:(cv::Point)GradientPupil{
    cv::Point pupilLoc;
                                                            // Check the existance of the two pupil location
    if(HoughPupil.x!=0 && GradientPupil.x!=0){              // Both exist
        int x = (HoughPupil.x+GradientPupil.x)/2;           // Calcuate aver point
        int y = (HoughPupil.y+GradientPupil.y)/2;
        cv::Point tmp(x,y);
        pupilLoc = tmp;
    }else if (HoughPupil.x!=0 && GradientPupil.x==0){       // Only gradient location exists
        pupilLoc = HoughPupil;                              // Do nothing
    }else if (HoughPupil.x==0 && GradientPupil.x!=0){       // Only hough location exists
        pupilLoc = GradientPupil;                           // Do nothing
    }
    
    return pupilLoc;
}

/**
 * Method for returning pupil location
 **/
-(cv::Point)PupilLoc:(NSString*)name{
    cv::Point pupil;
    if([name isEqualToString:@"left"]){
        pupil = _leftPupil;
    }else if ([name isEqualToString:@"right"]){
        pupil = _rightPupil;
    }
    return pupil;
}

/**
 * Method for returning frame image
 **/
-(cv::Mat)capturedFrame{
    _taken_image = _toUseimage;
    [self printOnScreen:_taken_image];
    return _taken_image;
}

/**
 * Method for returning the boundary for detected left eye area
 **/
-(cv::Rect)leftEyeArea{
    cv::Rect leftEyeArea(_leftEyeBoundaryPt1,_leftEyeBoundaryPt2);
    return leftEyeArea;
}

/**
 * Method for returning the boundary for detected right eye area
 **/
-(cv::Rect)rightEyeArea{
    cv::Rect rightEyeArea(_rightEyeBoundaryPt1,_rightEyeBoundaryPt2);
    return rightEyeArea;
}

/**
 * Method for detecting eye(s)
 * @classifier: choose which classifier to use (left eye/right eye cascade classifier)
 * @grayscaleFrame: frame image that is being processed
 * @image: original image
 * @face: detected face area, for checking whether detected eye is valid (if it is within face area, then valid)
 * @name: name of eye that is looking for (left eye/right eye)
 **/
- (void)detectEyeWithClassifier: (CascadeClassifier) classifier withFrame:(Mat&) grayscaleFrame withOriginalImage:(Mat&)image check:(cv::Rect)face id:(NSString*)name;{
    
    std::vector<cv::Rect> object;
    classifier.detectMultiScale(grayscaleFrame, object, 1.1, 2, HaarOptions, cv::Size(60,60));// Detect new eye with cascade classifier
    
    
    for (int i = 0; i < object.size(); i++){
        cv::Point pt1(object[i].x + object[i].width, object[i].y + object[i].height);
        cv::Point pt2(object[i].x, (object[i].y+30));                                       // Crop new eye area to eliminate brow
        cv::Rect newEye(pt1,pt2);                                                           // Set up new eye area
        
        
        if([self checkObjectEye:newEye onFace:face]){                                       // Check whether new eye area is on face
                                                                                            // Yes, then
            cv::rectangle(image, pt1, pt2, cvScalar(0, 255, 0, 0), 1, 8 ,0);                // Draw eye area
            
            if([name isEqualToString:@"left"]){                                             // Check which eye is being processed
                _leftEyeBoundaryPt1 = pt2;                                                  // Save left eye boundary
                _leftEyeBoundaryPt2 = pt1;
                
            }else if([name isEqualToString:@"right"]){
                _rightEyeBoundaryPt1 = pt2;                                                 // Save right eye boundary
                _rightEyeBoundaryPt2 = pt1;
            }
            
            cv::Mat croppedNewEye = image(newEye);                                          // Reset area of interest to be detected eye area

            [self detectPupilwithHough:croppedNewEye onFace:newEye id:name];                // Call method for detecting pupil
            
        }
    }
}

/**
 * Method for checking whether detected eye is on face
 **/
- (BOOL)checkObjectEye:(cv::Rect)newEye onFace:(cv::Rect)face;{
    BOOL eye = false;
    int eyePt1X = newEye.x;
    int eyePt1Y = newEye.y;
    int eyePt2X = eyePt1X + newEye.width;
    int eyePt2Y = eyePt1Y + newEye.height;
    
    int facePt1X = face.x;
    int facePt1Y = face.y;
    int facePt2X = facePt1X + face.width;
    int facePt2Y = facePt1Y + face.height;
    
    if(eyePt1X>=facePt1X && eyePt1Y>=facePt1Y && eyePt2X<=facePt2X && eyePt2Y<=facePt2Y){
        eye = true;
    }
    
    return eye;
}

/**
 * Method for detecting pupil location using Circle Hough Transform (centre of detected circle will be desired pupil location)
 * @image: image being processed
 * @eye: detected eye area
 * @id: determining which eye is being processed (left eye/right eye)
 * return circle_center: pupil location
 * Reference: http://docs.opencv.org/2.4/doc/tutorials/imgproc/imgtrans/hough_circle/hough_circle.html
 **/
- (cv::Point)detectPupilwithHough:(Mat&)image onFace:(cv::Rect)eye id:(NSString*)name;{
    
    Mat cimg;
    
    if (image.type()==CV_8UC1) {                // Convert image to grayscale
        cvtColor(image, cimg, CV_GRAY2RGB);
    } else {
        cimg = image;
        cvtColor(image, image, CV_RGB2GRAY);
    }
    
    medianBlur(image, image, 5);                // Smooth the image with median filter
    
    std::vector<Vec3f> circles;                 // Detect iris circle with Circle Hough Transform
    cv::HoughCircles(  image                    // InputArray (image being processed)
                     , circles                  // OutputArray (array of circles being detected)
                     , CV_HOUGH_GRADIENT        // Method being used here
                     , 1                        // Set inverse ratio of resolution
                     , 8                        // Set minimum distance between detected centers
                     , 100                      // Set upper threshold for the internal Canny edge detector
                     , 30                       // Set threshold for center detection
                     , 5                        // Set minimum radio to be detected
                     , 30                       // Set maximum radio to be detected
                     );
    
    
    int circle_x = 0;
    int circle_y = 0;
    cv::Point circle_center;
    int circle_radius = 0;
    int index = 0;
    
    for( size_t i = 0; i < circles.size(); i++ )
    {
        Vec3i c = circles[i];
        int x = c[0];
        int y = c[1];
        cv::Point center(x, y);
        int radius = c[2];
        
                                                                            // Calculate average location of detected circles
        if(i==0){                                                           // If only one circle is detected, then
            circle_x = x;                                                   // do nothing
            circle_y = y;
            circle_center = center;
            circle_radius = radius;
            index++;
        }else{                                                              // If more than one circle is detected, then
                index++;
                circle_x = (circle_x + x)/ index;                           // calculate average X
                circle_y = (circle_y + y)/ index;                           // calculate average Y
                cv::Point tmp(circle_x, circle_y);                          // get average point
                circle_center = tmp;
                circle_radius = (circle_radius+radius)/index;               // calculate average radius
        }
    }
    
    
    circle( cimg, circle_center, circle_radius, Scalar(255,0,0), 1, CV_AA); // Draw detected circle
    circle( cimg, circle_center, 1, Scalar(0,255,0), 1, CV_AA);             // Draw circle center
    
    
    cv::Point circleGradient = [self detectPupilwithGradient:image withRect:eye]; // Process image with pixel intense method
    
    if(_gradientLocCount == 1 &&circleGradient.x!=0){                     // Calculate average pupil location detected by gradient
        _center_Gradient.x = circleGradient.x;
        _center_Gradient.y = circleGradient.y;
        _gradientLocCount++;
    }else if(_gradientLocCount != 1 && circleGradient.x!=0){
        _center_Gradient.x = (_center_Gradient.x + circleGradient.x)/_gradientLocCount;
        _center_Gradient.y = (_center_Gradient.y + circleGradient.y)/_gradientLocCount;
    }
    
    circle( cimg, _center_Gradient, 1, Scalar(0,0,255), 5, CV_AA);      // Draw detected pupil on screen
    
    if([name isEqualToString:@"left"]){
        if(circle_center.x!=0){
            _leftPupilHough = circle_center;
        }
        _leftPupil = [self calculatePupilLocationWithHough:_leftPupilHough andWithGradinate:_center_Gradient];
    }else if([name isEqualToString:@"right"]){
        if(circle_center.x!=0){
            _rightPupilHough = circle_center;
        }
        _rightPupil = [self calculatePupilLocationWithHough:_rightPupilHough andWithGradinate:_center_Gradient];
    }
    
    return circle_center;
}


/**
 * Method for testing gradient vector and displacement vector for every possible gradient location
 * @x: X
 * @y: Y
 * @weight: array being processed
 * @gx: gradient X
 * @gy: gradient Y
 * @output: Output array
 * Reference: [1] F.Timm and etc, "ACCURATE EYE CENTRE LOCALISATION BY MEANS OF GRADIENTS"
 *            [2] http://thume.ca/projects/2012/11/04/simple-accurate-eye-center-tracking-in-opencv/
 **/
void testPossiblePoints(int x, int y, const cv::Mat& weight,double gx, double gy, cv::Mat& output) {

    for (int cy = 0; cy < output.rows; ++cy) {
        double *Or = output.ptr<double>(cy);
        const unsigned char *Wr = weight.ptr<unsigned char>(cy);
        for (int cx = 0; cx < output.cols; ++cx) {
            if (x == cx && y == cy) {
                continue;
            }
            double dx = x - cx;                                         // Create a vector from the possible center to the gradient origin
            double dy = y - cy;                                         // di in the paper
            double magnitude = sqrt((dx * dx) + (dy * dy));
            dx = dx / magnitude;                                        // Normalize dx
            dy = dy / magnitude;                                        // Normalize dy
                                                                        // Normalised displacement vector di to unit length
            
            double dotProduct = dx*gx + dy*gy;                          // Compute dot product of di and gi
            if(dotProduct<0){                                           // Turn negative value into zero
                dotProduct = 0;                                         // Avoid opposite direction
            }
            
            Or[cx] += pow(dotProduct,2) * Wr[cx];                        // compute 1/N*∑(di*gi)ˆ2
        }
    }
}

/**
 * Method for detecting pupil location with gradient (find darkest point within eye area)
 * @eyeROI: image being processed
 * @eye: eye area being processed
 * return: detected pupil location
 * Reference: [1] F.Timm and etc, "ACCURATE EYE CENTRE LOCALISATION BY MEANS OF GRADIENTS"
 *            [2] http://thume.ca/projects/2012/11/04/simple-accurate-eye-center-tracking-in-opencv/
 **/
- (cv::Point)detectPupilwithGradient:(Mat&)eyeImage withRect:(cv::Rect)eye{
    cv::Mat gradientX = computeGradient(eyeImage);                                    // Get gradient in horizontal
    cv::Mat gradientY = computeGradient(eyeImage.t()).t();                            // Get gradient in vertical
    
    cv::Mat magnitudes = matrixMagnitude(gradientX, gradientY);                       // Compute the magnitudes
    double gradientThreshold = computeThreshold(magnitudes, kGradientThreshold);      // Compute the threshold
    
    for (int i = 0; i < eyeImage.rows; ++i) {                                         // Normalize the gradient with threshold
        double *Xr = gradientX.ptr<double>(i);
        double *Yr = gradientY.ptr<double>(i);
        const double *Mr = magnitudes.ptr<double>(i);
        for (int x = 0; x < eyeImage.cols; ++x) {
            double gX = Xr[x];
            double gY = Yr[x];
            double magni = Mr[x];
            if (magni <= gradientThreshold) {                            // Remove gradient when magnitude is lower than threshold
                Xr[x] = 0.0;
                Yr[x] = 0.0;
            } else {
                Xr[x] = gX/magni;
                Yr[x] = gY/magni;
            }
        }
    }

    cv::Mat weight;
    GaussianBlur( eyeImage, weight, cv::Size( kWeightBlurSize, kWeightBlurSize ), 0, 0 ); // Create a blurred image to get a smoother image
    for (int y = 0; y < weight.rows; ++y) {                                               // Invert the image
        unsigned char *row = weight.ptr<unsigned char>(y);
        for (int x = 0; x < weight.cols; ++x) {
            row[x] = (255 - row[x]);
        }
    }

    cv::Mat outSum = cv::Mat::zeros(eyeImage.rows,eyeImage.cols,CV_64F);        // Initialise array with zeros()
                                                                                // Evaluates every possible center for each gradient location
    for (int j = 0; j < weight.rows; ++j) {                                     // For every possible gradient location (non-zero)
        const double *Xr = gradientX.ptr<double>(j);
        const double *Yr = gradientY.ptr<double>(j);
        for (int i = 0; i < weight.cols; ++i) {
            double gX = Xr[i];
            double gY = Yr[i];
            if (gX == 0.0 && gY == 0.0) {
                continue;
            }
            testPossiblePoints(i, j, weight, gX, gY, outSum);                   // Test gradient vector and displacement vector
        }
    }
    
    double numGradients = weight.rows*weight.cols;
    cv::Mat outarray;
    outSum.convertTo(outarray, CV_32F,1.0/numGradients);                        // Scale all the values down

                                                                                // Find the maximum point among all the possible points
                                                                                // c* = arg max{1/N*∑(di*gi)ˆ2}
    cv::Point maxP;                                                             // Maximum point
    double maxVal;                                                              // Maximum value
    cv::minMaxLoc(outarray, NULL, &maxVal, NULL, &maxP);                        // Finds the global maximum point and value in outarray
    
    return unscalePoint(maxP);
}

/**
 * Normalise detected point to integers
 **/
cv::Point unscalePoint(cv::Point p) {
    int x = round(p.x);
    int y = round(p.y);
    return cv::Point(x,y);
}

#endif

@end
