% Data Description Toolbox
% Version 1.6.0 19-Jul-2007
%
%Dataset construction
%--------------------
%isocset        true if dataset is one-class dataset
%gendatoc       generate a one-class dataset from two data matrices
%oc_set         change normal classif. problem to one-class problem
%target_class   extracts the target class from an one-class dataset
%make_outliers  create outlier data in a box around target class
%gendatgrid     create a grid dataset around a 2D dataset
%gendatout      create outlier data in a hypersphere around the
%               target data
%gendatoutg     create outlier data normally distributed around the
%               target data
%gendatouts     create outlier data in the data PCA subspace in a
%               hypersphere around the target data
%dd_crossval    cross-validation dataset creation
%dd_label       put the classification labels in the same dataset
%
%Data preprocessing
%------------------
%myproxm        replacement for proxm.m
%kwhiten        rescale data to unit variance in kernel space
%gower          compute the Gower similarities
%
%One-class classifiers
%---------------------
%random_dd      description which randomly assigns labels
%stump_dd       threshold the first feature
%gauss_dd       data description using normal density
%rob_gauss_dd   robustified gaussian distribution
%mcd_gauss_dd   Minimum Covariance Determinant gaussian
%mog_dd         mixture of Gaussians data description
%mog_extend     extend a Mixture of Gaussians data description
%parzen_dd      Parzen density data description
%nparzen_dd     Naive Parzen density data description
%
%autoenc_dd     auto-encoder neural network data description
%kcenter_dd     k-center data description
%kmeans_dd      k-means data description
%pca_dd         principal component data description
%som_dd         Self-Organizing Map data description
%mst_dd         minimum spanning tree data description
%
%nndd           nearest neighbor based data description
%knndd          K-nearest neighbor data description
%ball_dd        L_p-ball data description
%lpball_dd      extended L_p-ball data description
%svdd           Support vector data description
%incsvdd        Incremental Support vector data description
%ksvdd          SVDD on general kernel matrices
%lpdd           linear programming data description
%mpm_dd         minimax probability machine data description
%
%dkcenter_dd    distance k-center data description
%dnndd          distance nearest neighbor based data description
%dknndd         distance K-nearest neighbor data description
%dlpdd          distance-linear programming data description
%
%isocc          true if classifier is one-class classifier
%
%AUC optimizers
%--------------
%rankboostc     Rank-boosting algorithm
%auclpm         AUC linear programming mapping
%
%Classifier postprocessing/optimization/combining.
%--------------------------------------
%consistent_occ optimize the hyperparameter using consistency
%optim_auc      optimize the hyperparameter by maximizing AUC
%dd_normc       normalize oc-classifier output
%multic         construct a multi-class classifier from OCC's
%
%Error computation.
%-----------------
%dd_error       false positive and negative fraction of classifier
%dd_f1          F1 score computation
%dd_eer         equal error rate
%dd_roc         computation of the Receiver-Operating Characterisic curve 
%dd_auc         error under the ROC curve
%dd_costc       cost curve
%dd_delta_aic   AIC error for density estimators
%dd_fp          compute false positives for given false negative
%               fraction
%simpleroc      basic ROC curve computation
%dd_setfn       set the threshold for a false negative rate
%
%Plot functions.
%--------------
%plotroc        plot an ROC curve
%plotcostc      plot the cost curve
%plotg          plot a 2D grid of function values
%plotw          plot a 2D real-valued output of classifier w
%askerplot      plot the FP and FN fraction wrt the thresholds
%plot_mst       plot the minimum spanning tree
%
%Support functions.
%-----------------
%istarget       true if an object is target
%find_target    gives the indices of target and outlier objs from a dataset
%getoclab       returns numeric labels (+1/-1)
%dist2dens      map distance to posterior probabilities
%dd_threshold   give percentiles for a sample
%randsph        create outlier data uniformly in a unit hypersphere
%makegriddat    auxiliary function for constructing grid data
%relabel        relabel a dataset
%dd_kernel      general kernel definitions
%center         center the kernel matrix in kernel space
%gausspdf       multi-variate Gaussian prob.dens.function
%mahaldist      Mahalanobis distance
%sqeucldistm    square Euclidean distance
%mog_init       initialize a Mixture of Gaussians
%mog_P          probability density of Mixture of Gaussians
%mog_update     update a MoG using EM
%mogEMupdate    EM procedure to optimize Mixture of Gaussians
%mogEMextend    smartly extend a MoG and apply EM
%mykmeans       own implementation of the k-means clustering algorithm
%getfeattype    find the nominal and continuous features
%knn_optk       optimization of k for the knndd using leave-one-out
%volsphere      compute the volume of a hypersphere
%scale_range    compute a reasonable range of scales for a dataset
%nndist_range   compute the average nearest neighbor distance
%inckernel      kernel definitions for the incsvdd
%Wstartup       startup function incsvdd
%Wadd/Wremove   add/remove one object to an incsvdd
%Wstore         store the structure in an incsvdd
%plotroc_update support function for plotroc
%roc_hull       convex hull over a ROC curve
%lpball_dist    lp-distance to a center
%lpball_vol     volume of a lpball
%lpdist         fast lp-distance between two datasets
%
%Examples
%--------
%dd_ex1         show performance of nndd and svdd
%dd_ex2         show the performances of a list of classifiers
%dd_ex3         shows the use of the svdd and ksvdd
%dd_ex4         optimizes a hyperparameter using consistent_occ
%dd_ex5         shows the construction of lpdd from dlpdd
%dd_ex6         shows the different Mixture of Gaussians classifiers
%dd_ex7         shows the combination of one-class classifiers
%dd_ex8         shows the interactive adjustment of the operating point
%dd_ex9         shows the use of dd_crossval
%dd_ex10        shows the use of the incremental SVDD
%dd_ex11        the construction of a multi-class classifier using OCCs
%
% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
