#include "cv.h"
#include "highgui.h"

    
/*Function to calculate the integral histogram*/
IplImage** calculateIntegralHOG(IplImage* in)
{

    /*Convert the input image to grayscale*/
    IplImage* img_gray = cvCreateImage(cvGetSize(in), IPL_DEPTH_8U,1);
    cvCvtColor(in, img_gray, CV_BGR2GRAY);
    cvEqualizeHist(img_gray,img_gray);
	
    /* Calculate the derivates of the grayscale image in the x and y directions
     * using a sobel operator and obtain 2 gradient images for the x and y
     * directions*/
    IplImage *xsobel, *ysobel;
    cvSobel(img_gray, &xsobel, 1, 0, 3);
    cvSobel(img_gray, &ysobel, 0, 1, 3);
    cvReleaseImage(&img_gray);


    /* Create an array of 9 images (9 because I assume bin size 20 degrees and
     * unsigned gradient ( 180/20 = 9), one for each bin which will have zeroes
     * for all pixels, except for the pixels in the original image for which the
     * gradient values correspond to the particular bin. These will be referred
     * to as bin images. These bin images will be then used to calculate the
     * integral histogram, which will quicken the calculation of HOG descriptors */

    IplImage** bins = (IplImage**) malloc(9 * sizeof(IplImage*));
    for (int i = 0; i < 9 ; i++) {
        bins[i] = cvCreateImage(cvGetSize(in), IPL_DEPTH_32F,1);
        cvSetZero(bins[i]);
    }


    /* Create an array of 9 images ( note the dimensions of the image, the
     * cvIntegral() function requires the size to be that), to store the
     * integral images calculated from the above bin images. These 9 integral
     * images together constitute the integral histogram */

    IplImage** integrals = (IplImage**) malloc(9 * sizeof(IplImage*)); for (int i = 0; i < 9 ; i++) {
        integrals[i] = cvCreateImage(cvSize(in->width + 1, in->height + 1),
                IPL_DEPTH_64F,1);
    }

    /* Calculate the bin images. The magnitude and orientation of the gradient
     * at each pixel is calculated using the xsobel and ysobel images.
     * {Magnitude = sqrt(sq(xsobel) + sq(ysobel) ), gradient = itan (ysobel/xsobel) }.
     * Then according to the orientation of the gradient, the value of the
     * corresponding pixel in the corresponding image is set */


    int x, y;
    float temp_gradient, temp_magnitude;
    for (y = 0; y <in->height; y++) {

        /* ptr1 and ptr2 point to beginning of the current row in the xsobel and
         * ysobel images respectively. ptrs[i] point to the beginning of the
         * current rows in the bin images */

        float* ptr1 = (float*) (xsobel->imageData + y * (xsobel->widthStep));
        float* ptr2 = (float*) (ysobel->imageData + y * (ysobel->widthStep));
        float** ptrs = (float**) malloc(9 * sizeof(float*));
        for (int i = 0; i < 9 ;i++){
            ptrs[i] = (float*) (bins[i]->imageData + y * (bins[i]->widthStep));
        }

        /*For every pixel in a row gradient orientation and magnitude are
         * calculated and corresponding values set for the bin images. */

        for (x = 0; x <in->width; x++) {

            /* if the xsobel derivative is zero for a pixel, a small value is
             * added to it, to avoid division by zero. atan returns values in
             * radians, which on being converted to degrees, correspond to
             * values between -90 and 90 degrees. 90 is added to each
             * orientation, to shift the orientation values range from {-90-90}
             * to {0-180}. This is just a matter of convention. {-90-90} values
             * can also be used for the calculation. */

            if (ptr1[x] == 0){
                temp_gradient = ((atan(ptr2[x] / (ptr1[x] + 0.00001))) * (180/ M_PI)) + 90;
            }
            else{
                temp_gradient = ((atan(ptr2[x] / ptr1[x])) * (180 / M_PI)) + 90;
            }
            temp_magnitude = sqrt((ptr1[x] * ptr1[x]) + (ptr2[x] * ptr2[x]));

            /*The bin image is selected according to the gradient values. The
             * corresponding pixel value is made equal to the gradient magnitude
             * at that pixel in the corresponding bin image */

            if (temp_gradient <= 20) {
                ptrs[0][x] = temp_magnitude;
            }
            else if (temp_gradient <= 40) {
                ptrs[1][x] = temp_magnitude;
            }
            else if (temp_gradient <= 60) {
                ptrs[2][x] = temp_magnitude;
            }
            else if (temp_gradient <= 80) {
                ptrs[3][x] = temp_magnitude;
            }
            else if (temp_gradient <= 100) {
                ptrs[4][x] = temp_magnitude;
            }
            else if (temp_gradient <= 120) {
                ptrs[5][x] = temp_magnitude;
            }
            else if (temp_gradient <= 140) {
                ptrs[6][x] = temp_magnitude;
            }
            else if (temp_gradient <= 160) {
                ptrs[7][x] = temp_magnitude;
            }
            else {
                ptrs[8][x] = temp_magnitude;
            }
        }
    }

    cvReleaseImage(&xsobel);
    cvReleaseImage(&ysobel);

    /*Integral images for each of the bin images are calculated*/

    for (int i = 0; i <9 ; i++){
        cvIntegral(bins[i], integrals[i]);
    }

    for (int i = 0; i <9 ; i++){
        cvReleaseImage(&bins[i]);
    }

    /*The function returns an array of 9 images which consitute the integral
     * histogram*/

    return (integrals);

}

/* The following function takes as input the rectangular cell for which the
 * histogramof oriented gradients has to be calculated, a matrix hog_cell of
 * dimensions 1x9 to store the bin values for the histogram, the integral
 * histogram, and the normalization scheme to be used. No normalization is
 * done if normalization = -1 */


void calculateHOG_rect(CvRect cell, CvMat* hog_cell,
        IplImage** integrals, int normalization) {


    /* Calculate the bin values for each of the bin of the histogram one by one */

    for (int i = 0; i < 9 ; i++){

        float a =((double*)(integrals[i]->imageData + (cell.y)
                    * (integrals[i]->widthStep)))[cell.x];
        float b = ((double*) (integrals[i]->imageData + (cell.y + cell.height)
                    * (integrals[i]->widthStep)))[cell.x + cell.width];
        float c = ((double*) (integrals[i]->imageData + (cell.y)
                    * (integrals[i]->widthStep)))[cell.x + cell.width];
        float d = ((double*) (integrals[i]->imageData + (cell.y + cell.height)
                    * (integrals[i]->widthStep)))[cell.x];

        ((float*) hog_cell->data.fl)[i] = (a + b) - (c + d);

    }


    /*Normalize the matrix*/
    if (normalization != -1){
        cvNormalize(hog_cell, hog_cell, 1, 0, normalization);
    }

}

/*
#ifdef __cplusplus
}
#endif
*/