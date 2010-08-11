#include <cmath>
#include "mex.h"
void mexFunction(int nlhs, mxArray *out[], int nrhs, const mxArray *input[])
{
    // Checking number of arguments
    if (nlhs > 1){
        mexErrMsgTxt("Error: function has only one output parameter");
        return;
    }

    if (nrhs == 0){
        mexErrMsgTxt("Error: Too few input parameters");
        return;
    }

    if (nrhs > 3){
        mexErrMsgTxt("Error: Too many input parameters");
        return;
    }

    int isSparse = 1; // By default, matrix is considered sparse
    if (nrhs > 2)
        isSparse = (int) mxGetScalar(input[2]);

    // Load in arrays
    double* a = mxGetPr( input[0] );
    double* b = mxGetPr( input[1] );
    int* aSize = (int*) mxGetDimensions(input[0]);
    int* bSize = (int*) mxGetDimensions(input[1]);

    // Check if sizes are correct
    if(aSize[1] != bSize[1]){
        mexErrMsgTxt("Error: number of columns for a and b do not match");
        return;
    }

    // Get dimensionality of the vectors
    int nFeats = aSize[1];

    // Create new array
    out[0] = mxCreateDoubleMatrix(aSize[0], bSize[0], mxREAL);
    double* distances = mxGetPr(out[0]);

    double aEntry,bEntry,dist,denominator;

    // Now do the chi square distance
    if(isSparse){
        for(int i=0; i < bSize[0]; i++){
            for(int j=0; j < bSize[1]; j++){
                double* pDist = &distances[i * aSize[0]];
                double bElem = b[bSize[0] * j + i];
                double* aElem = &a[j * aSize[0]];
                if(bElem){ // if bElem > 0
                    for(int k=0; k < aSize[0]; k++){
                        (*pDist)+= ((*aElem - bElem) * (*aElem - bElem)) / (*aElem + bElem);
                        pDist++;
                        aElem++;
                    }
                }
                else{
                    for(int k=0; k < aSize[0]; k++){
                        (*pDist)+= *aElem;
                        pDist++;
                        aElem++;
                    }
                }
            }
        }
    }
    else{
        for(int i=0; i < bSize[0]; i++){
            for(int j=0; j < bSize[1]; j++){
                double* pDist = &distances[i * aSize[0]];
                double bElem = b[bSize[0] * j + i];
                double* aElem = &a[j * aSize[0]];
                for(int k=0; k < aSize[0]; k++){
                    double denominator = (*aElem + bElem);
                    if(denominator)
                        (*pDist)+= ((*aElem - bElem) * (*aElem - bElem)) / denominator;

                    pDist++;
                    aElem++;
                }
            }
        }
    }

    double* pDist = distances;
    double normalizeFactor = 2 * aSize[1];
    for(int i=0; i < bSize[0] * aSize[0]; i++){
        *pDist = *pDist / normalizeFactor;
        pDist++;
    }

    return;
}
