#ifndef INCLUDE_FINDHOG
#define INCLUDE_FINDHOG

#include "cv.h"


IplImage** calculateIntegralHOG(IplImage* in);
void calculateHOG_rect(CvRect cell, CvMat* hog_cell, IplImage** integrals, int normalization);
void calculateHOG_block(CvRect block, CvMat* hog_block, IplImage** integrals,CvSize cell, int normalization);
CvMat* calculateHOG_window(IplImage** integrals, CvRect window, int normalization);
char *cvtInt( char *str, int num);
//CvMat* train_64x128(char *prefix, char *suffix, CvSize cell, CvSize window, int number_samples, int start_index, int end_index, char *savexml = NULL, int canny = 0, int block = 1, int normalization = 4);
CvMat* train_64x128(char *prefix, char *suffix, CvSize cell, CvSize window, int number_samples, int start_index, int end_index, char *savexml , int canny , int block , int normalization );
//CvMat* train_large(char *prefix, char *suffix, CvSize cell, CvSize window, int number_images, int horizontal_scans, int vertical_scans, int start_index, int end_index, char *savexml = NULL, int normalization = 4);
CvMat* train_large(char *prefix, char *suffix, CvSize cell, CvSize window, int number_images, int horizontal_scans, int vertical_scans, int start_index, int end_index, char *savexml , int normalization );
//void trainSVM(CvMat* pos_mat, CvMat* neg_mat, char *savexml, char *pos_file = NULL, char *neg_file = NULL);
void trainSVM(CvMat* pos_mat, CvMat* neg_mat, char *savexml, char *pos_file , char *neg_file );

#endif
