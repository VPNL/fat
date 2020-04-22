Diffusion tool box that combines Vistasoft, MRtrix3, LiFE and AFQ to produce white matter connectomes. It requires the toolboxes mentioned before to be installed. The pipeline is orgnized as below. 
 
A great place to start exploring this pipeline is the script "fat/preprocessing/scripts/fatPreprocmrTrix3WrapperLocal.m", which includes the entire pipeline from raw dti data to connetomes. Please note that this pipeline does not currently include resverse phase encoding correction, and that the mutishell code has never been tested. The pipeline is organized as follows:


1) Prepare fat data and directory structure
2) Preprocess the data using mrTrix3
3) The preprocessing flips our bvecs. We don't want that, so we copy our original bvecs from the raw folder. We also fix the nifti header.
4) Initiate a dt.mat data structure
5) Set up tractography for mrtrix 3
6) Create a better wm mask with FreeSurfer
7) Create connectomes with MRtrix3
8) Optional: Run LiFE to optimize the connectome
9) Optional: Run AFQ to classify the connectome
10) Optional: Clean Connectome with AFQ

In addition to this preprocessing pipeline, what include an assortment of analysis and plotting function that might come in handy.

