%
% ﻿Diffusion tool combine Vistasoft, MRtrix, LiFE and AFQ  to produce functional defined fasciculus.
%It requires these toolboxs installed, and also required the fROI defined by vistasoft.
%The pipeline is orgnized as bellow.
clear all;

% The following parameters need to be adjusted to fit your system
fatDir=fullfile('/sni-storage/kalanit/biac2/kgs/projects/NFA_tasks/data_mrAuto');
anatDir_system =fullfile('/biac2/kgs/3Danat');
anatDir =('/sni-storage/kalanit/biac2/kgs/3Danat');

sessid={'13_cb_dti_mrTrix3_081317'}

 runName={'96dir_run1' '96dir_run2'}
% 
% input_ROIs={'lh_OTS_union_morphing_reading_vs_all.mat' 'lh_aSTS_morphing_reading_vs_all.mat' 'lh_pSTS_MTG_union_morphing_reading_vs_all.mat'...
%     'lh_ISMG_morphing_reading_vs_all.mat' 'lh_IFG_union_morphing_reading_vs_all.mat' 'lh_ORS_morphing_reading_vs_all.mat'}
% 
 t1_name=['t1.nii.gz'];
for hemi =1
    
    for r=1:1 %only use first run
        for s=1:length(sessid)
            ROIfgname=['MoriGroups.mat']
            
            if hemi==1
                foi=[1, 3, 5, 7, 9, 10, 11, 13, 15, 17, 19]
                hems='lh'
            elseif hemi==2
                foi=[2, 4, 6, 8, 9, 10, 12, 14, 16, 18, 20, 28, 22]
                hems='rh'
                
            end
            colors=[0.9 0.9 0.9; 1 0 1; 0 0 0; 0 0 1; 0 0 0.5; 0.5 0.5 1; 0 0.8 0.8; 1 0.5 1; 0.45 0 0.45; 0.6,0.2,0.2; 1 0 0; 1 0.6 0; 0.6 1 0.05];
            
            fatRenderFibersWholeConnectome(fatDir, sessid{s}, runName{r}, ROIfgname, foi,t1_name, hems ,colors)
        end
    end
end

% for r=1:1 %only use first run
%  for s=1:length(sessid)   
% ROIfgname=['roifg_reading_for_plot.mat']
% fatRenderFibers(dwiDir, sessid{s}, runName{r}, ROIfgname, [1:36],t1_name, 'lh')
%  end
% end
%     



