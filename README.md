# Viola-Jones Face Detection for Matlab
### A CSCi 5561 Spring 2015 Semester Project

Authors: Chee Yi Ong, Stephen Peyton

### Introduction

This is a slightly modified Viola-Jones face detection algorithm built using Matlab. Here's a quick rundown of the code flow:

* Preprocessing: variance normalization, gamma correction for ‘hard’ (under/over-exposed) images
* Train weak classifiers from Haar-like features
* Boost weak classifiers using Adaboost
* Face detection using a cascade structure

### Assumptions

 1. Frontal-facing images ONLY.
 2. Background is not cluttered. Solid-colored background works the best.
 3. Tilting of the head is at a minimum.
 4. Image size is approximately 300x400 or similar. Individual features are a minimum of 
  19x19, because that is the smallest size of a single Haar feature or classifier.
  5. One face-of-interest per image.

### Instructions

This folder contains two subfolders: `trainHaar` and `detectFaces`. `trainHaar` consists of the training algorithm which trains classifiers using Haar-like features, while `detectFaces` uses the trained classifiers to detect faces.

The `main` functions for both parts of the face detection routine are named identically to the folder containing the code, i.e., `trainHaar.m` for the training part, and `detectFaces.m` for the detection part.
 
 1. Training: simply start the training by running the script `trainHaar` on the command line. Note that this takes _approximately 21 hours_ on a 2.6GHz quad-core i7.
 2. Detection: `detectFaces('image.jpg')` or `detectFaces('someDirectory/image.jpg')`.

### Opportunities for improvements:
* Train algorithm with a larger set of images
* Better thresholding with more Adaboost training rounds
* Better cascade structuring with fewer, stronger classifiers: real-time detection possible

### Acknowledgements
* University of Minnesota, Twin Cities
* Viola, Paul, and Michael J. Jones. “Robust real-time face detection.” International journal of computer vision 57.2 (2004): 137-154.
* Freund, Yoav and Schapire, Robert E.. “A decision-theoretic generalization of on-line learning and an application to boosting.” Second European Conference, EuroCOLT ’95, pages 23–37, Springer-Verlag, 1995.
* Anila, S. and Devarajan N.. “Preprocessing Technique for Face Recognition Applications under Varying Illumination Conditions.” Global Journal of Computer Science and Technology 12.11-F (2012).
* MIT Center for Biological and Computational Learning. “CBCL Face Database 1”. N. p., 2015. Web. Accessed 16 April 2015. http://cbcl.mit.edu/software-datasets/FaceData2.html
* “AT&T Face Dataset”, http://www.cl.cam.ac.uk/research/dtg/attarchive/facedatabase.html
