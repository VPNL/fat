%
% ﻿Diffusion tool combine Vistasoft, MRtrix, LiFE and AFQ  to produce functional defined fasciculus.
%It requires these toolboxs installed, and also required the fROI defined by vistasoft.
%The pipeline is orgnized as bellow.
% clear all;

% The following parameters need to be adjusted to fit your system
fatDir=fullfile('/sni-storage/kalanit/biac2/kgs/projects/NFA_tasks/data_mrAuto');


sessid={'01_sc_dti_mrTrix3_080917' '02_at_dti_mrTrix3_080517' '03_as_dti_mrTrix3_083016'...
    '04_kg_dti_mrTrix3_101014' '05_mg_dti_mrTrix3_071217' '06_jg_dti_mrTrix3_083016'...
    '07_bj_dti_mrTrix3_081117' '08_sg_dti_mrTrix3_081417' '10_em_dti_mrTrix3_080817'...
    '12_rc_dti_mrTrix3_080717' '13_cb_dti_mrTrix3_081317' '15_mn_dti_mrTrix3_091718'...
    '16_kw_dti_mrTrix3_082117' '17_ad_dti_mrTrix3_081817' '18_nc_dti_mrTrix3_090817'...
    '19_df_dti_mrTrix3_111218' '21_ew_dti_mrTrix3_111618' '22_th_dti_mrTrix3_112718'...
    '23_ek_dti_mrTrix3_113018'  '24_gm_dti_mrTrix3_112818'}

runName={'96dir_run1/fw_afq_ET_ACT_LiFE_3.0.2_lmax8'};


for r=1:length(runName)
    %
    % fgName='run1_lmax8_curvatures_concatenated_optimize_it500_new_classified'
    % roiName={'lh_IFG_union_morphing_reading_vs_all' 'lh_OTS_union_morphing_reading_vs_all'}
    % foi=19
    % fiberCount = fatRoiFiberOverlap(fatDir, sessid, runName(r), fgName, roiName, foi, '5.00')
    %
    % fgName='run1_lmax8_curvatures_concatenated_optimize_it500_new_classified'
    % roiName={'lh_IFG_union_morphing_reading_vs_all' 'lh_pSTS_MTG_union_morphing_reading_vs_all'}
    % foi=19
    % fiberCount = fatRoiFiberOverlap(fatDir, sessid, runName(r), fgName, roiName, foi, '5.00')
    %
    % fgName='run1_lmax8_curvatures_concatenated_optimize_it500_new_classified'
    % roiName={'lh_IPCS_morphing_adding_vs_all' 'lh_ITG_morphing_adding'}
    % foi=19
    % fiberCount = fatRoiFiberOverlap(fatDir, sessid, runName(r), fgName, roiName, foi, '5.00')
    
    
    % fgName='run1_lmax8_curvatures_concatenated_optimize_it500_new_classified_AF_overlap'
    % roiName={'lh_IFG_union_morphing_reading_vs_all_lh_OTS_union_morphing_reading_vs_all' 'lh_IPCS_morphing_adding_vs_all_lh_ITG_morphing_adding'}
    % foi=19
    %
    % fiberCount = fatRoiFiberOverlap(fatDir, sessid, runName(r), fgName, roiName, foi, '5.00')
    % fiberCount = fatRoiFiberUnique(fatDir, sessid, runName(r), fgName, roiName, foi, '5.00')
    %
%     roiName={'lh_ISMG_morphing_reading_vs_all_projed_lh_IFG_union_morphing_reading_vs_all_projed' 'lh_ISMG_morphing_adding_vs_all_projed_lh_IPCS_morphing_adding_vs_all_projed'}
%  fgName='WholeBrainFG_classified_overlap'

    foi=15;
    for s=1:20
        cd(fullfile(fatDir,sessid{s},runName{r},'dti96trilin','fibers','afq'));
        
        ROIfgname1=['lh_IFG2ISMGread_lmax8_select100_iFOD1_min10max250_ang13_classified.mat']
        roifgFile1 = fullfile(fatDir,sessid{s},runName{r},'dti96trilin','fibers','afq',ROIfgname1);
        
        ROIfgname2=['lh_IPCS2ISMGmath_lmax8_select100_iFOD1_min10max250_ang13_classified.mat']
        roifgFile2 = fullfile(fatDir,sessid{s},runName{r},'dti96trilin','fibers','afq',ROIfgname2);
        
        if (exist(roifgFile1,'file')>0 && exist(roifgFile2,'file')>0)
        fgName={'lh_IFG2ISMGread_lmax8_select100_iFOD1_min10max250_ang13_classified_clean_inter.mat' 'lh_IPCS2ISMGmath_lmax8_select100_iFOD1_min10max250_ang13_classified_clean_inter_inter.mat'}
            
            fiberCount = fatRoiFiberOverlapR2R(fatDir, sessid(s), runName(r), fgName, foi, '1.00')
            fiberCount = fatRoiFiberUnique(fatDir, sessid(s), runName(r), fgName, roiName, foi, '1.00')
            
            fib(s,:)=fiberCount;
            
               roiName={'lh_ISMG_morphing_adding_vs_all_projed_lh_IPCS_morphing_adding_vs_all_projed' 'lh_ISMG_morphing_reading_vs_all_projed_lh_IFG_union_morphing_reading_vs_all_projed'}
            fiberCount = fatRoiFiberUnique(fatDir, sessid(s), runName(r), fgName, roiName, foi, '1.00')
        end
    end
end

