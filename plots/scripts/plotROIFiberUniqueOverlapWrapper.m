% 
% ﻿Diffusion tool combine Vistasoft, MRtrix, LiFE and AFQ  to produce functional defined fasciculus.
%It requires these toolboxs installed, and also required the fROI defined by vistasoft. 
%The pipeline is orgnized as bellow.
clear all;

% The following parameters need to be adjusted to fit your system
dwiDir=fullfile('/sni-storage/kalanit/biac2/kgs/projects/NFA_tasks/data_mrAuto');
t1_name=['t1.nii.gz'];

sessid={'02_at_dti_080517' '03_as_dti_083016'...
    '05_mg_dti_071217' '06_jg_dti_083016'...
    '13_cb_dti_081317' '16_kw_dti_082117'}

runName={'96dir_run1'}

for s=1:length(sessid)
    for r=1:length(runName)
            radius = '5.00';
            runDir = fullfile(dwiDir,sessid{s},runName{r},'dti96trilin');
            fiberUnique1=fullfile(runDir,'fibers','afq','lh_IFG_union_morphing_reading_vs_all_lh_ISMG_morphing_reading_vs_all_lh_IPCS_morphing_adding_vs_all_lh_ISMG_morphing_adding_vs_all_r5.00_run1_lmax8_curvatures_concatenated_optimize_it500_new_classified_SLF_overlap_SLF_unique.mat');
            fiberUnique2=fullfile(runDir,'fibers','afq','lh_IPCS_morphing_adding_vs_all_lh_ISMG_morphing_adding_vs_all_lh_IFG_union_morphing_reading_vs_all_lh_ISMG_morphing_reading_vs_all_r5.00_run1_lmax8_curvatures_concatenated_optimize_it500_new_classified_SLF_overlap_SLF_unique.mat');
            fiberOverlap=fullfile(runDir,'fibers','afq','lh_IFG_union_morphing_reading_vs_all_lh_ISMG_morphing_reading_vs_all_lh_IPCS_morphing_adding_vs_all_lh_ISMG_morphing_adding_vs_all_r5.00_run1_lmax8_curvatures_concatenated_optimize_it500_new_classified_SLF_overlap_SLF_overlap.mat');
            
            if exist(fiberUnique1)>0 && exist(fiberOverlap)>0 && exist(fiberUnique2)>0
            load(fiberUnique1);
            output_roifg(1)=roifg;

            load(fiberUnique2);
            output_roifg(2)=roifg;
            
            load(fiberOverlap);
            output_roifg(3)=roifg;
        end
roifg=output_roifg;
save(fullfile(runDir,'fibers','afq','lh_ISMG_IPCS_IFG_SLF_overlap.mat'),'roifg');
clear('roifg');
ROIfg=['lh_ISMG_IPCS_IFG_SLF_overlap.mat'];
fatRenderFibers(dwiDir, sessid{s}, runName{r}, ROIfg, [1:3],t1_name, 'lh');
    end
end

imgName=['lh_ISMG_IPCS_IFG_SLF_overlap.tiff'];
fatMontage(dwiDir, sessid, runName, imgName);

