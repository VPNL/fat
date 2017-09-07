Diffusion tool combine Vistasoft, MRtrix, LiFE and AFQ  to produce functional defined fasciculus.It requires these toolboxs installed, and also required the fROI defined by vistasoft. The pipeline is orgnized as bellow.
1) Prepare dwi data and directory structure
dwiPrepare(dwiDir, sessid);

2) Correct the header info in dwi data
dwiTransform(dwiDir, sessid, runName);

3) Preprocess the dwi using vistasoft
dwiPreprocess(dwiDir,sessid,runName,force)

4) Make wm mask from freesurfer output 
dwiMakeWMmask(dwiDir, sessid, 'wm', force)

5) Run MRtrix to create candidate connectomes with different parameters
dwiCreateConnectome(dwiDir, sessid, runName);

6) Run LiFE to optimize each candidate connectomes
dwiRunLife(dwiDir, sessid, runName(r), fgName, Niter, L, force);

7) Concatenate the optimzed fg from LiFE to construct the final ET optimized connectome
dwiConcateFg(dwiDir, sessid, runName(i), fgInName,fgOutName);

8) Run AFQ to classify the fibers
dwiMakefsROI(dwiDir,sessid,force):create fsROI for fiber classification
IIdwiSegmentConnectome(dwiDir, sessid, runName, fgName, computeRoi)

9) Convert vista ROI to functional ROI 
dwiVistaRoi2DtiRoi(dwiDir, sessid, runName, roiName)
dwiDtiRoi2Nii(dwiDir, sessid, runName, roiName)

9) Define FDFs and get fiber count
dwiFiberIntersectRoi(dwiDir, sessid,runName, fgName, roiName, foi, radius) 

10) Extract fiber proprieties
dwiTractDmr(dwiDir, sessid, runName, fgName)
dwiTractQmr(dwiDir, sessid, runName, fgName, qmrDir)

11) Extract roi selectivity
dwiRoiSelectivity(dwiDir, sessid, mapName, roiName)
dwiRoiSelectivityCv(dwiDir, sessid, contrast, roiName)

%% Script to merge data
1) Normalize fiber cout
normFiberCount(afqFiberCountFile, rawFiberCountFile) 
2) Collect all data to a structure
runMetaDataCollect
