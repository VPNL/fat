

clear all;
ExpDir=fullfile('/sni-storage/kalanit/biac2/kgs/projects','NFA_tasks','data_mrAuto');

% sessid={'01_sc_dti_080917' '02_at_dti_080517' '03_as_dti_083016'...
%     '04_kg_dti_101014' '05_mg_dti_071217' '06_jg_dti_083016'...
%     '07_bj_dti_081117' '08_sg_dti_081417' '10_em_dti_080817'...
%     '12_rc_dti_080717' '13_cb_dti_081317' '16_kw_dti_082117'...
%     '17_ad_dti_081817' '18_nc_dti_090817'}

dtiSessid={'18_nc_dti_090817'}

volSessid={'18_nc_morphing_083117'};
 
roiFgs={'lh_ISMG_morphing_reading_vs_all_lh_IFG_union_morphing_reading_vs_all_r5.00_run1_lmax8_curvatures_concatenated_optimize_it500_new_classified_overlap_unique.mat'...
    'lh_ISMG_morphing_adding_vs_all_lh_IPCS_morphing_adding_vs_all_5.00_run1_lmax8_curvatures_concatenated_optimize_it500_new_classified_overlap_unique.mat'...
    'lh_ISMG_morphing_reading_vs_all_lh_IFG_union_morphing_reading_vs_all_lh_ISMG_morphing_adding_vs_all_lh_IPCS_morphing_adding_vs_all_r5.00_run1_lmax8_curvatures_concatenated_optimize_it500_new_classified__overlap_overlap.mat'}

outnames={'lh_IFG_ISMG_SLF_unique' 'lh_IPCS_ISMG_SLF_unique' 'lh_IFG_IPCS_ISMG_SLF_overlap'}
roiNum=1 

for s=1:length(dtiSessid)
    
    roiFolder=fullfile(ExpDir,dtiSessid{s},'96dir_run1','dti96trilin','ROIs');
    volFolder=[fullfile(ExpDir,volSessid{s})]
    
    cd(fullfile(ExpDir,dtiSessid{s},'96dir_run1','dti96trilin'))
    load dt6.mat
    
    cd(fullfile(ExpDir,dtiSessid{s},'96dir_run1','dti96trilin','fibers','afq'))
    
    for i=1:length(roiFgs)
        roiFg=roiFgs{i};
         cd(fullfile(ExpDir,dtiSessid{s},'96dir_run1','dti96trilin','fibers','afq'))
    
        if exist(roiFg)>0
            load(roiFg)
            outname=outnames{i};
            fibers2MrVistaRoi(roifg,roiFolder,volFolder,outname,roiNum,xformVAnatToAcpc)
        end
    end
end
