# Pupil_Tracker_iPad
This is an old archive of my undergrad thesis project. This is meant to be an IOS application on iPad that helps initial screening of abnormal eye movement caused by stroke. The essential algorithm is for dealing with tracking pupil in real time with iPad back camera.

The full project files is too large so only the core algorithm code files related to the real-time image analysis are uploaded here.

# OpenCV in IOS Application
This project was done around 5 years ago before I got into ML/DL. Therefore, only traditional methods are used with OpenCV. The IOS development was conducted with Objective C and C++ was embedded to work with OpenCV.


# Breakdown of Algorithm
1) Face detection with Haar Cascade features
2) Eye detection with Haar Cascade features inside the detected face area
3) Pupil detection with calculation of gradient and Circle Hough Transform
