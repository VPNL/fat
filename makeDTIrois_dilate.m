function [] = makeDTIrois_dilate(sessions,roilist,rad)
% this function tranforms ROIs to dTI ROIs (ACPC cordinates). and then Dilate them with
% specified radius
% vn march 2017
%% basic info
runName = {'96dir_run1','96dir_run2'};
%hemi = {'lh','rh'};
radius = rad;
%% sesson info
dwiDir = '/sni-storage/kalanit/biac2/kgs/projects/Longitudinal/Diffusion/'


%% Number info
nSubj = length(sessions);
nRoi = length(roilist);
nRun = length(runName);

%%% make ROI into ACPC coordinate %% i am only doing this for place and
%%% body rois because Zonglei has done the rest.

for i=1:nSubj
  for j=1:nRun
      cd([dwiDir, sessions{i},'/', runName{j}, '/dti96trilin/'])
      [dwiDir, sessions{i},'/', runName{j}, '/dti96trilin/']
    for k=1:nRoi
       
        dtiXformMrVistaVolROIs('dt6.mat',{['/sni-storage/kalanit/biac2/kgs/projects/Longitudinal/Anatomy/', sessions{i}, '/T1/ROIs/', roilist{k}]}, ['/sni-storage/kalanit/biac2/kgs/projects/Longitudinal/Anatomy/', sessions{i}, '/T1/T1_QMR_1mm.nii.gz'], 'ROIs/.')
        
    end
  end  
end

%% Dilated a ROI with a specificed radius
% It will produce some dialated ROI in dti96trilin/ROIs dirs
    for i = 1:nRoi

         roiName = sprintf('%s',roilist{i})
     
         dwiDilateRoi(dwiDir, sessions, runName, roiName, radius);
     end



end

