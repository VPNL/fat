%
% ﻿Diffusion tool combine Vistasoft, MRtrix, LiFE and AFQ  to produce functional defined fasciculus.
%It requires these toolboxs installed, and also required the fROI defined by vistasoft.
%The pipeline is orgnized as bellow.
clear all;

% The following param2Mers need to be adjusted to fit your system
dwiDir=fullfile('/sni-storage/kalanit/biac2/kgs/projects/NFA_tasks/data_mrAuto');
t1_name=['t1.nii.gz'];


sessid={'01_sc_dti_mrTrix3_080917' '02_at_dti_mrTrix3_080517' '03_as_dti_mrTrix3_083016'...
    '04_kg_dti_mrTrix3_101014' '05_mg_dti_mrTrix3_071217' '06_jg_dti_mrTrix3_083016'...
    '07_bj_dti_mrTrix3_081117' '08_sg_dti_mrTrix3_081417' '10_em_dti_mrTrix3_080817'...
    '12_rc_dti_mrTrix3_080717' '13_cb_dti_mrTrix3_081317' '15_mn_dti_mrTrix3_091718'...
    '16_kw_dti_mrTrix3_082117' '17_ad_dti_mrTrix3_081817' '18_nc_dti_mrTrix3_090817'...
    '19_df_dti_mrTrix3_111218' '21_ew_dti_mrTrix3_111618' '22_th_dti_mrTrix3_112718'...
    '23_ek_dti_mrTrix3_113018'  '24_gm_dti_mrTrix3_112818'}

runName={'96dir_run1/fw_afq_ET_ACT_LiFE_3.0.2_lmax8'};

for s=1:6
    for r=1:length(runName)
        radius = '1.00';
        runDir = fullfile(dwiDir,sessid{s},runName{r},'dti96trilin');
        fiberUnique1=fullfile(runDir,'fibers','afq','lh_pSTS_MTG_union_morphing_reading_vs_all_projed_gmwmi_lh_IFG_union_morphing_reading_vs_all_projed_gmwmi_r1.00_WholeBrainFGRoiSeeds_classified_clean_overlap_unique.mat');
        
        fiberUnique2=fullfile(runDir,'fibers','afq','lh_ITG_morphing_adding_projed_gmwmi_lh_IPCS_morphing_adding_vs_all_projed_gmwmi_r1.00_WholeBrainFGRoiSeeds_classified_clean_overlap_unique.mat');
        
        fiberOverlap=fullfile(runDir,'fibers','afq','lh_pSTS_MTG_union_morphing_reading_vs_all_projed_gmwmi_lh_IFG_union_morphing_reading_vs_all_projed_gmwmi_lh_ITG_morphing_adding_projed_gmwmi_lh_IPCS_morphing_adding_vs_all_projed_gmwmi_r1.00_WholeBrainFGRoiSeeds_classified_clean_overlap_overlap.mat');
        
      if (exist(fiberUnique1) && exist(fiberUnique2))
            load(fiberUnique1);
            output_roifg(1)=roifg(1);
            
            load(fiberUnique2);
            output_roifg(2)=roifg(1);
            
            load(fiberOverlap);
            output_roifg(3)=roifg(1);
            
            
            roifg=output_roifg;
            save(fullfile(runDir,'fibers','afq','lh_STS_ITG_IPCS_IFG_AF_overlap_IFOD2.mat'),'roifg');
            clear('roifg');
            clear('output_roifg');
            ROIfg=['lh_STS_ITG_IPCS_IFG_AF_overlap_IFOD2.mat'];
            fatRenderFibers(dwiDir, sessid{s}, runName{r}, ROIfg, [1:2],t1_name, 'lh');
        end
        
    end
end

 imgName=['lh_STS_ITG_IPCS_IFG_AF_overlap_IFOD2.tiff'];
 fatMontage(dwiDir, sessid, runName, imgName);

