//
//  Utility.h
//  EyeTracker
//
//  Created by Weiwen Xu on 17/04/2017.
//  Copyright © 2017 Weiwen Xu. All rights reserved.
//
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"

#ifndef GradientHelper_h
#define GradientHelper_h

cv::Mat computeGradient(const cv::Mat& mat);
cv::Mat matrixMagnitude(const cv::Mat& gradientX, const cv::Mat& gradientY);
double computeThreshold(const cv::Mat& magnitudes, double stdDevFactor);

#endif /* Utility_h */
