
clear all;
ExpDir=fullfile('/sni-storage/kalanit/biac2/kgs/projects','NFA_tasks','data_mrAuto');

%sessions={'01_sc_morphing_112116'};
 
sessions={'01_sc_morphing_112116' '02_at_morphing_102116' '03_as_morphing_112616'...
     '04_kg_morphing_120816' '05_mg_morphing_101916' '06_jg_morphing_102316'...
     '07_bj_morphing_102516' '08_sg_morphing_102716' '10_em_morphing_1110316'... 
     '12_rc_morphing_112316' '13_cb_morphing_120916' '16_kw_morphing_081517'...
     '17_ad_morphing_082217' '18_nc_morphing_083117'};

rois={'lh_OTS_union_morphing_reading_vs_all.mat' 'lh_IFG_union_morphing_reading_vs_all.mat'... 
    'lh_pSTS_MTG_union_morphing_reading_vs_all.mat' 'lh_ISMG_morphing_reading_vs_all.mat'... 
    'lh_ITG_morphing_adding.mat' 'lh_pIPS_morphing_adding_vs_all.mat'...  
    'lh_IPCS_morphing_adding_vs_all.mat' 'lh_ISMG_morphing_adding_vs_all.mat'... 
    'lh_Ac_Cc_Pc_union_morphing_color_vs_all.mat'};


for s = 1:length(sessions)
    cd(fullfile(ExpDir,sessions{s}));
    
for r=1:length(rois) 
    roi=rois(r);       
    name=strsplit(roi{1},'.')
    hG = initHiddenGray(5,1,roi);
    if size(hG.ROIs)>0
    hG2=makeROIdiskGray(hG,2,strcat(name{1,1},'_disk_2mm'),[],[],'roi')
%  [gray,ROI] = makeROIdiskGray(gray, [radius], [name], [select], [color], [grayCoordStart],[addFlag])
    saveROI(hG2,hG2.ROIs(hG2.selectedROI),0);
    clear hG
    clear hG2
    end
end
end



rois={'lh_OTS_union_morphing_reading_vs_all_disk_2mm.mat' 'lh_IFG_union_morphing_reading_vs_all_disk_2mm.mat'... 
    'lh_pSTS_MTG_union_morphing_reading_vs_all_disk_2mm.mat' 'lh_ISMG_morphing_reading_vs_all_disk_2mm.mat'... 
    'lh_ITG_morphing_adding_disk_2mm.mat' 'lh_pIPS_morphing_adding_vs_all_disk_2mm.mat'...  
    'lh_IPCS_morphing_adding_vs_all_disk_2mm.mat' 'lh_ISMG_morphing_adding_vs_all_disk_2mm.mat'... 
    'lh_Ac_Cc_Pc_union_morphing_color_vs_all_disk_2mm.mat' 'lh_Ac_Cc_Pc_union_morphing_color_vs_all_disk_2mm.mat'};
fatDir=fullfile('/sni-storage/kalanit/biac2/kgs/projects/NFA_tasks/data_mrAuto');


 sessid={'01_sc_dti_080917' '02_at_dti_080517' '03_as_dti_083016'...
     '04_kg_dti_101014' '05_mg_dti_071217' '06_jg_dti_083016'...
     '07_bj_dti_081117' '08_sg_dti_081417' '10_em_dti_080817'...
     '12_rc_dti_080717' '13_cb_dti_081317'...
'16_kw_dti_082117' '17_ad_dti_081817' '18_nc_dti_090817'}


for s = 1:length(sessid)
    
for r=1:length(rois)
roiName = sprintf('%s',rois{r})
fatVistaRoi2DtiRoi(fatDir, sessid{s}, '96dir_run1', rois(r), 't1.nii.gz')
fatDtiRoi2Nii(fatDir, sessid{s}, '96dir_run1', rois(r)) 
dwiDilateRoi(fatDir, sessid{s}, '96dir_run1', rois{r}, 5);
end

end
 


