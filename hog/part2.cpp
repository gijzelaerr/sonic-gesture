#include "cv.h"
#include "hog.h"
/* 
#ifdef __cplusplus
extern "C" {
#endif
 */

/* This function takes in a block as a rectangle and calculates the hog features
 * for the block by dividing it into cells of size cell(the supplied parameter),
 * calculating the hog features for each cell using the function
 * calculateHOG_rect(...), concatenating the so obtained vectors for each cell
 * and then normalizing over the concatenated vector to obtain the hog features
 * for a block */

void calculateHOG_block(CvRect block, CvMat* hog_block, 
IplImage** integrals,CvSize cell, int normalization) 
{
 int cell_start_x, cell_start_y;
 CvMat vector_cell;
 int startcol = 0;
 for (cell_start_y = block.y; cell_start_y <= 
      block.y + block.height - cell.height; 
      cell_start_y += cell.height) 
 {
    for (cell_start_x = block.x; cell_start_x <= 
         block.x + block.width - cell.width; 
         cell_start_x += cell.width) 
    {
      cvGetCols(hog_block, &vector_cell, startcol, 
                                    startcol + 9);

      calculateHOG_rect(cvRect(cell_start_x,
      cell_start_y, cell.width, cell.height), 
      &vector_cell, integrals, -1);

      startcol += 9;
    }
  }
  if (normalization != -1)
     cvNormalize(hog_block, hog_block, 1, 0, 
                              normalization);
}

/* This function takes in a window(64x128 pixels, but can be easily modified for
 * other window sizes) and calculates the hog features for the window. It can be
 * used to calculate the feature vector for a 64x128 pixel image as well. This
 * window/image is the training/detection window which is used for training or
 * on which the final detection is done. The hog features are computed by
 * dividing the window into overlapping blocks, calculating the hog vectors for
 * each block using calculateHOG_block(...) and concatenating the so obtained
 * vectors to obtain the hog feature vector for the window*/
CvMat* calculateHOG_window(IplImage** integrals,
  CvRect window, int normalization) 
{
  
  /*A cell size of 8x8 pixels is considered and each block is divided into 2x2
   * such cells (i.e. the block is 16x16 pixels). So a 64x128 pixels window
   * would be divided into 7x15 overlapping blocks*/
 
  int block_start_x, block_start_y, cell_width = 8;
  int cell_height = 8;
  int block_width = 2, block_height = 2;
   
   /* The length of the feature vector for a cell is 9(since no. of bins is 9),
    * for block it would  be 9*(no. of cells in the block) = 9*4 = 36. And the
    * length of the feature vector for a window would be 36*(no. of blocks in
    * the window */
  CvMat* window_feature_vector = cvCreateMat(1,
     ((((window.width - cell_width * block_width)
        / cell_width) + 1) * (((window.height -
        cell_height * block_height) / cell_height)
        + 1)) * 36, CV_32FC1);
  
  CvMat vector_block;
  int startcol = 0;
  for (block_start_y = window.y; block_start_y
          <= window.y + window.height - cell_height
          * block_height; block_start_y += cell_height)
  {
    for (block_start_x = window.x; block_start_x
              <= window.x + window.width - cell_width
             * block_width; block_start_x += cell_width)
    {
      cvGetCols(window_feature_vector, &vector_block,
                startcol, startcol + 36);
      
      calculateHOG_block(cvRect(block_start_x,
          block_start_y, cell_width * block_width, cell_height
          * block_height), &vector_block, integrals, cvSize(
          cell_width, cell_height), normalization);
      
      startcol += 36;
     }
   }
 return (window_feature_vector);
}

/* 
#ifdef __cplusplus
}
#endif */