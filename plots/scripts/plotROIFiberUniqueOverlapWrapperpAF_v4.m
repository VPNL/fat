%
% ﻿Diffusion tool combine Vistasoft, MRtrix, LiFE and AFQ  to produce functional defined fasciculus.
%It requires these toolboxs installed, and also required the fROI defined by vistasoft.
%The pipeline is orgnized as bellow.
clear all;

% The following parameters need to be adjusted to fit your system
dwiDir=fullfile('/sni-storage/kalanit/biac2/kgs/projects/NFA_tasks/data_mrAuto');
t1_name=['t1.nii.gz'];

sessid={'03_as_dti_mrTrix3_083016'}

runName={'96dir_run1'}

for s=1:length(sessid)
    for r=1:length(runName)
        radius = '1.00';
        runDir = fullfile(dwiDir,sessid{s},runName{r},'dti96trilin');
        fiberUnique1=fullfile(runDir,'fibers','afq','lh_pSTS_MTG_union_morphing_reading_vs_all_lh_ISMG_morphing_reading_vs_all_r1.00_WholeBrainFG_ACT_ET_LiFE_classified_overlap_unique.mat');
        
        fiberUnique2=fullfile(runDir,'fibers','afq','lh_ITG_morphing_adding_lh_ISMG_morphing_adding_vs_all__r1.00_WholeBrainFG_ACT_ET_LiFE_classified_overlap_unique.mat');
        
        fiberOverlap=fullfile(runDir,'fibers','afq','lh_pSTS_MTG_union_morphing_reading_vs_all_lh_ISMG_morphing_reading_vs_all_lh_ITG_morphing_adding_lh_ISMG_morphing_adding_vs_all__r1.00_WholeBrainFG_ACT_ET_LiFE_classified_overlap_overlap.mat');
        
        if exist(fiberOverlap)>0
            load(fiberUnique1);
            output_roifg(1)=roifg(1);
            
            load(fiberUnique2);
            output_roifg(2)=roifg(1);
            
            load(fiberOverlap);
            output_roifg(3)=roifg(1);
            
            
            roifg=output_roifg;
            save(fullfile(runDir,'fibers','afq','lh_OTS_ITG_SMG_pAF_overlap.mat'),'roifg');
            clear('roifg');
            clear('output_roifg');
            ROIfg=['lh_OTS_ITG_SMG_pAF_overlap.mat'];
            fatRenderFibers(dwiDir, sessid{s}, runName{r}, ROIfg, [1:2],t1_name, 'lh');
        end
        
    end
end

imgName=['lh_OTS_ITG_SMG_pAF_overlap.tiff'];
fatMontage(dwiDir, sessid, runName, imgName);

