% 
% ﻿Diffusion tool combine Vistasoft, MRtrix, LiFE and AFQ  to produce functional defined fasciculus.
%It requires these toolboxs installed, and also required the fROI defined by vistasoft. 
%The pipeline is orgnized as bellow.
clear all;

% The following parameters need to be adjusted to fit your system
dwiDir=fullfile('/sni-storage/kalanit/biac2/kgs/projects/NFA_tasks/data_mrAuto');
anatDir_system =fullfile('/biac2/kgs/3Danat');
anatDir =('/sni-storage/kalanit/biac2/kgs/3Danat');

sessid={'01_sc_dti_080917' '02_at_dti_080517' '03_as_dti_083016'...
    '04_kg_dti_101014' '05_mg_dti_071217' '06_jg_dti_083016'...
    '07_bj_dti_081117' '08_sg_dti_081417' '10_em_dti_080817'...
    '12_rc_dti_080717' '13_cb_dti_081317' '16_kw_dti_082117'...
    '17_ad_dti_081817' '18_nc_dti_090817'}
%sessid={'01_sc_dti_080917' '02_at_dti_080517' '03_as_dti_083016' '04_kg_dti_101014'...
%'10_em_dti_080817' '05_mg_dti_071217' '06_jg_dti_083016'}
%anatid={'jesse_new_recon_2017'}
runName={'96dir_run1' '96dir_run2'}
% 
ROIs={'lh_OTS_union_morphing_reading_vs_all' 'lh_ITG_morphing_adding'}




% ROIs={'rh_ITG_morphing_adding.mat' 'rh_aIPS_morphing_adding_vs_all.mat'  'rh_pIPS_morphing_adding_vs_all.mat' 'rh_ANG_morphing_adding_vs_all.mat'...
%     'rh_LF_morphing_adding_vs_all.mat'  'rh_ISMG_morphing_adding_vs_all.mat' 'rh_IPCS_morphing_adding_vs_all.mat'...
%     'lh_ITG_morphing_adding.mat' 'lh_aIPS_morphing_adding_vs_all.mat'  'lh_pIPS_morphing_adding_vs_all.mat' 'lh_ANG_morphing_adding_vs_all.mat'...
%     'lh_LF_morphing_adding_vs_all.mat'  'lh_ISMG_morphing_adding_vs_all.mat' 'lh_IPCS_morphing_adding_vs_all.mat'}

t1_name=['t1.nii.gz'];

for r=1:1 %only use first run

        for n=1:length(ROIs)
            ROIName=strsplit(ROIs{n})
            imgName=[ROIName{1} '_r5.00_run' num2str(r) '_lmax8_curvatures_concatenated_optimize_it500_new_classified.tiff'];
            fatMontage(dwiDir, sessid, runName, imgName)
        end
end