Diffusion tool box that combines Vistasoft, MRtrix, LiFE and AFQ  to produce functional defined white matter tracts. It requires the toolboxes mentioned before to be installed, and also requires fROIs defined using vistasoft. The pipeline is orgnized as bellow.

1) Prepare fat data and directory structure
fatPrepare(fatDir, sessid);

2) Preprocess the dti data using vistasoft
fatPreprocess(fatDir,sessid,runName,force)

4) Make wm mask from freesurfer output 
fatMakeWMmask(fatDir, sessid, 'wm', force)

5) Run MRtrix to create candidate connectomes with different parameters
fatCreateEtConnectome(fatDir, sessid, runName);

6) Concatenate candidate connectomes to construct the final ET connectome
fatConcateFg(fatDir, sessid, runName(i), fgInName,fgOutName);

7) Run LiFE to optimize the connectome
fatRunLife(fatDir, sessid, runName(r), fgName, Niter, L, force);

8) Run AFQ to classify the fibers
fatMakefsROI(fatDir,sessid,force):create fsROI for fiber classification
fatSegmentConnectome(fatDir, sessid, runName, fgName, computeRoi)

9) Convert vista ROI to functional ROI 
fatVistaRoi2DtiRoi(fatDir, sessid, runName, roiName)
fatDtiRoi2Nii(fatDir, sessid, runName, roiName)

9) Define FDFs and get fiber count
fatFiberIntersectRoi(fatDir, sessid,runName, fgName, roiName, foi, radius) 

10) Extract fiber proprieties
fatTractQmr(fatDir, sessid, runName, fgName, qmrDir)
