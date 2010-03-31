#include "cv.h"
#include "cvaux.h"
#include "highgui.h"
#include "ml.h"
#include "hog.h"

/*
#ifdef __cplusplus
extern "C" {
#endif
*/
char *cvtInt( char *str, int num)
{
        sprintf( str, "%d", num );
}


/*This function takes in a the path and names of 64x128 pixel images, the size
 * of the cell to be used for calculation of hog features(which should
 * be 8x8 pixels, some modifications will have to be done in the code for a
 * different cell size, which could be easily done once the reader understands
 * how the code works), a default block size of 2x2 cells has been considered
 * and the window size parameter should be 64x128 pixels (appropriate
 * modifications can be easily done for other say 64x80 pixel window size). All
 * the training images are expected to be stored at the same location and the
 * names of all the images are expected to be in sequential order like a1.jpg,
 * a2.jpg, a3.jpg .. and so on or a(1).jpg, a(2).jpg, a(3).jpg ... The explanation
 * of all the parameters below will make
  clear the usage of the function. The synopsis of
  the function is as follows :

prefix : it should be the path of the images, along
with the prefix in the image name for
example if the present working directory is
/home/saurabh/hog/ and the images are in
/home/saurabh/hog/images/positive/ and are
named like pos1.jpg, pos2.jpg, pos3.jpg ....,
then the prefix parameter would be
"images/positive/pos" or if the images are
named like pos(1).jpg, pos(2).jpg,
pos(3).jpg ... instead, the prefix parameter
would be "images/positive/pos("

suffix : it is the part of the name of the image
files after the number for example for the
above examples it would be ".jpg" or ").jpg"

cell   : it should be CvSize(8,8), appropriate changes
need to be made for other cell sizes

window : it should be CvSize(64,128), appropriate
changes need to be made for other window sizes

number_samples : it should be equal to the number of
training images, for example if the
training images are pos1.jpg, pos2.jpg
..... pos1216.jpg, then it should be
1216

start_index : it should be the start index of the images'
names for example for the above case it
should be 1 or if the images were named
like pos1000.jpg, pos1001.jpg, pos1002.jpg
.... pos2216.jpg, then it should be 1000

end_index : it should be the end index of the images'
name for example for the above cases it
should be 1216 or 2216

savexml   : if you want to store the extracted features,
then you can pass to it the name of an xml
file to which they should be saved

normalization : the normalization scheme to be used for
computing the hog features, any of the
opencv schemes could be passed or -1
could be passed if no normalization is
to be done */

CvMat* train_64x128(char *prefix, char *suffix, CvSize cell,
        CvSize window, int number_samples, int start_index,
        int end_index, char *savexml = NULL, int canny = 0,
        int block = 1, int normalization = 4) 
{

    char filename[50] = "\0", number[8];
    int prefix_length;
    prefix_length = strlen(prefix);
    int bins = 9;

    /* A default block size of 2x2 cells is considered */

    int block_width = 2, block_height = 2;

    /* Calculation of the length of a feature vector for
       an image (64x128 pixels)*/

    int feature_vector_length;
    feature_vector_length = (((window.width -
                    cell.width * block_width)/ cell.width) + 1) *
        (((window.height - cell.height * block_height)
          / cell.height) + 1) * 36;

    /* Matrix to store the feature vectors for
       all(number_samples) the training samples */

    CvMat* training = cvCreateMat(number_samples,
            feature_vector_length, CV_32FC1);

    CvMat row;
    CvMat* img_feature_vector;
    IplImage** integrals;
    int i = 0, j = 0;

    printf("Beginning to extract HoG features from positive images\n");

    strcat(filename, prefix);

    /* Loop to calculate hog features for each
       image one by one */

    for (i = start_index; i <= end_index; i++) 
    {
        cvtInt(number, i);
        strcat(filename, number);
        strcat(filename, suffix);
        IplImage* img = cvLoadImage(filename);

        /* Calculation of the integral histogram for
           fast calculation of hog features*/

        integrals = calculateIntegralHOG(img);
        cvGetRow(training, &row, j);
        img_feature_vector = calculateHOG_window(integrals, cvRect(0, 0,
                        window.width, window.height), normalization);
        cvCopy(img_feature_vector, &row);
        j++;
        printf("%s\n", filename);
        filename[prefix_length] = '\0';
        for (int k = 0; k < 9; k++) 
        {
            cvReleaseImage(&integrals[k]);
        }
    }
    if (savexml != NULL) 
    {
        cvSave(savexml, training);
    }

    return training;
}

/* This function is almost the same as
   train_64x128(...), except the fact that it can
   take as input images of bigger sizes and
   generate multiple samples out of a single
   image.

   It takes 2 more parameters than
   train_64x128(...), horizontal_scans and
   vertical_scans to determine how many samples
   are to be generated from the image. It
   generates horizontal_scans x vertical_scans
   number of samples. The meaning of rest of the
   parameters is same.

   For example for a window size of
   64x128 pixels, if a 320x240 pixel image is
   given input with horizontal_scans = 5 and
   vertical scans = 2, then it will generate to
   samples by considering windows in the image
   with (x,y,width,height) as (0,0,64,128),
   (64,0,64,128), (128,0,64,128), .....,
   (0,112,64,128), (64,112,64,128) .....
   (256,112,64,128)

   The function takes non-overlapping windows
   from the image except the last row and last
   column, which could overlap with the second
   last row or second last column. So the values
   of horizontal_scans and vertical_scans passed
   should be such that it is possible to perform
   that many scans in a non-overlapping fashion
   on the given image. For example horizontal_scans
   = 5 and vertical_scans = 3 cannot be passed for
   a 320x240 pixel image as that many vertical scans
   are not possible for an image of height 240
   pixels and window of height 128 pixels. */

CvMat* train_large(char *prefix, char *suffix,
        CvSize cell, CvSize window, int number_images,
        int horizontal_scans, int vertical_scans,
        int start_index, int end_index,
        char *savexml = NULL, int normalization = 4)
{
    char filename[50] = "\0", number[8];
    int prefix_length;
    prefix_length = strlen(prefix);
    int bins = 9;

    /* A default block size of 2x2 cells is considered */

    int block_width = 2, block_height = 2;

    /* Calculation of the length of a feature vector for
       an image (64x128 pixels)*/

    int feature_vector_length;
    feature_vector_length = (((window.width -
                    cell.width * block_width) / cell.width) + 1) *
        (((window.height - cell.height * block_height)
          / cell.height) + 1) * 36;

    /* Matrix to store the feature vectors for
       all(number_samples) the training samples */

    CvMat* training = cvCreateMat(number_images
            * horizontal_scans * vertical_scans,
            feature_vector_length, CV_32FC1);

    CvMat row;
    CvMat* img_feature_vector;
    IplImage** integrals;
    int i = 0, j = 0;
    strcat(filename, prefix);

    printf("Beginning to extract HoG features from negative images\n");

    /* Loop to calculate hog features for each
       image one by one */

    for (i = start_index; i <= end_index; i++) 
    {
        cvtInt(number, i);
        strcat(filename, number);
        strcat(filename, suffix);
        IplImage* img = cvLoadImage(filename);
        integrals = calculateIntegralHOG(img);
        for (int l = 0; l < vertical_scans - 1; l++)
        {
            for (int k = 0; k < horizontal_scans - 1; k++)
            {
                cvGetRow(training, &row, j);
                img_feature_vector = calculateHOG_window(
                        integrals, cvRect(window.width * k,
                            window.height * l, window.width,
                            window.height), normalization);

                cvCopy(img_feature_vector, &row);
                j++;
            }

            cvGetRow(training, &row, j);

            img_feature_vector = calculateHOG_window(
                    integrals, cvRect(img->width - window.width,
                        window.height * l, window.width,
                        window.height), normalization);

            cvCopy(img_feature_vector, &row);
            j++;
        }

        for (int k = 0; k < horizontal_scans - 1; k++)
        {
            cvGetRow(training, &row, j);

            img_feature_vector = calculateHOG_window(
                    integrals, cvRect(window.width * k,
                        img->height - window.height, window.width,
                        window.height), normalization);

            cvCopy(img_feature_vector, &row);
            j++;
        }
        cvGetRow(training, &row, j);

        img_feature_vector = calculateHOG_window(integrals,
                cvRect(img->width - window.width, img->height -
                    window.height, window.width, window.height),
                normalization);

        cvCopy(img_feature_vector, &row);
        j++;

        printf("%s\n", filename);
        filename[prefix_length] = '\0';
        for (int k = 0; k < 9; k++)
        {
            cvReleaseImage(&integrals[k]);
        }

        cvReleaseImage(&img);

    }

    printf("%d negative samples created \n",
            training->rows);

    if (savexml != NULL)
    {
        cvSave(savexml, training);
        printf("Negative samples saved as %s\n",
                savexml);
    }

    return training;

}


/* This function trains a linear support vector
   machine for object classification. The synopsis is
   as follows :

pos_mat : pointer to CvMat containing hog feature
vectors for positive samples. This may be
NULL if the feature vectors are to be read
from an xml file

neg_mat : pointer to CvMat containing hog feature
vectors for negative samples. This may be
NULL if the feature vectors are to be read
from an xml file

savexml : The name of the xml file to which the learnt
svm model should be saved

pos_file: The name of the xml file from which feature
vectors for positive samples are to be read.
It may be NULL if feature vectors are passed
as pos_mat

neg_file: The name of the xml file from which feature
vectors for negative samples are to be read.
It may be NULL if feature vectors are passed
as neg_mat*/


void trainSVM(CvMat* pos_mat, CvMat* neg_mat, char *savexml,
        char *pos_file = NULL, char *neg_file = NULL) 
{


    /* Read the feature vectors for positive samples */
    if (pos_file != NULL) 
    {
        printf("positive loading...\n");
        pos_mat = (CvMat*) cvLoad(pos_file);
        printf("positive loaded\n");
    }

    /* Read the feature vectors for negative samples */
    if (neg_file != NULL)
    {
        neg_mat = (CvMat*) cvLoad(neg_file);
        printf("negative loaded\n");
    }

    int n_positive, n_negative;
    n_positive = pos_mat->rows;
    n_negative = neg_mat->rows;
    int feature_vector_length = pos_mat->cols;
    int total_samples;
    total_samples = n_positive + n_negative;

    CvMat* trainData = cvCreateMat(total_samples,
            feature_vector_length, CV_32FC1);

    CvMat* trainClasses = cvCreateMat(total_samples,
            1, CV_32FC1 );

    CvMat trainData1, trainData2, trainClasses1,
          trainClasses2;

    printf("Number of positive Samples : %d\n",
            pos_mat->rows);

    /*Copy the positive feature vectors to training
      data*/

    cvGetRows(trainData, &trainData1, 0, n_positive);
    cvCopy(pos_mat, &trainData1);
    cvReleaseMat(&pos_mat);

    /*Copy the negative feature vectors to training
      data*/

    cvGetRows(trainData, &trainData2, n_positive,
            total_samples);

    cvCopy(neg_mat, &trainData2);
    cvReleaseMat(&neg_mat);

    printf("Number of negative Samples : %d\n",
            trainData2.rows);

    /*Form the training classes for positive and
      negative samples. Positive samples belong to class
      1 and negative samples belong to class 2 */

    cvGetRows(trainClasses, &trainClasses1, 0, n_positive);
    cvSet(&trainClasses1, cvScalar(1));

    cvGetRows(trainClasses, &trainClasses2, n_positive,
            total_samples);

    cvSet(&trainClasses2, cvScalar(2));


    /* Train a linear support vector machine to learn from
       the training data. The parameters may played and
       experimented with to see their effects*/

    CvSVM svm(trainData, trainClasses, 0, 0,
            CvSVMParams(CvSVM::C_SVC, CvSVM::LINEAR, 0, 0, 0, 2,
                0, 0, 0, cvTermCriteria(CV_TERMCRIT_EPS,0, 0.01)));

    printf("SVM Training Complete!!\n");

    /*Save the learnt model*/

    if (savexml != NULL) {
        svm.save(savexml);
    }
    cvReleaseMat(&trainClasses);
    cvReleaseMat(&trainData);

}

/*
#ifdef __cplusplus
}
#endif
*/