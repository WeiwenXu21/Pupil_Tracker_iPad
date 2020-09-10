//
//  Utility.m
//  EyeTracker
//
//  Created by Weiwen Xu on 17/04/2017.
//  Copyright © 2017 Weiwen Xu. All rights reserved.
//

#include "GradientHelper.h"

/**
 * Method for computing gradient from mat
 * @mat: mat being processed
 * Reference: [1] F.Timm and etc, "ACCURATE EYE CENTRE LOCALISATION BY MEANS OF GRADIENTS"
 *            [2] http://thume.ca/projects/2012/11/04/simple-accurate-eye-center-tracking-in-opencv/
 **/
cv::Mat computeGradient(const cv::Mat& mat) {
    cv::Mat output(mat.rows,mat.cols,CV_64F);

    for (int y = 0; y < mat.rows; ++y) {
        const uchar *Mr = mat.ptr<uchar>(y);
        double *Or = output.ptr<double>(y);

        Or[0] = Mr[1] - Mr[0];
        for (int x = 1; x < mat.cols - 1; ++x) {
            Or[x] = (Mr[x+1] - Mr[x-1])/2.0;
        }
        Or[mat.cols-1] = Mr[mat.cols-1] - Mr[mat.cols-2];
    }

    return output;
}

/**
 * Method for computing the magnitudes from provided gradients
 * @gradientX: Provided gradient in X cordinate
 * @gradientY: Provided gradient in Y cordinate
 * Return: Computed magnitudes
 * Reference: [1] F.Timm and etc, "ACCURATE EYE CENTRE LOCALISATION BY MEANS OF GRADIENTS"
 *            [2] http://thume.ca/projects/2012/11/04/simple-accurate-eye-center-tracking-in-opencv/
 **/
cv::Mat matrixMagnitude(const cv::Mat& gradientX, const cv::Mat& gradientY) {
    cv::Mat mags(gradientX.rows,gradientX.cols,CV_64F);
    for (int j = 0; j < gradientX.rows; ++j) {
        const double *Xr = gradientX.ptr<double>(j);
        const double *Yr = gradientY.ptr<double>(j);
        double *Mr = mags.ptr<double>(j);
        for (int i = 0; i < gradientX.cols; ++i) {
            double gX = Xr[i];
            double gY = Yr[i];
            double magnitude = sqrt((gX * gX) + (gY * gY));
            Mr[i] = magnitude;
        }
    }
    return mags;
}

/**
 * Method for computing the threshold with provided magnitudes
 * @magnitudes: provided magnitudes
 * Return: Computed threshold
 * Reference: [1] F.Timm and etc, "ACCURATE EYE CENTRE LOCALISATION BY MEANS OF GRADIENTS"
 *            [2] http://thume.ca/projects/2012/11/04/simple-accurate-eye-center-tracking-in-opencv/
 **/
double computeThreshold(const cv::Mat& magnitudes, double stdDevFactor) {
    cv::Scalar stdMagnGrad;
    cv::Scalar meanMagnGrad;
    cv::meanStdDev(magnitudes, meanMagnGrad, stdMagnGrad);                          // Calculates a mean deviation of an array
    double stdDev = stdMagnGrad[0] / sqrt(magnitudes.rows*magnitudes.cols);
    return stdDevFactor * stdDev + meanMagnGrad[0];
}
