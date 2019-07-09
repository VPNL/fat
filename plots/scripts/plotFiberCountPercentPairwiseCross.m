
clear all;
ExpDir=fullfile('/sni-storage/kalanit/biac2/kgs/projects','NFA_tasks','data_mrAuto');
OutDir=fullfile(ExpDir,'dti_results_cross');

runName={'96dir_run1' '96dir_run2'}

input_ROIs={'lh_OTS_union_morphing_reading_vs_all.mat' 'lh_ITG_morphing_adding.mat'}

t1_name=['t1.nii.gz'];

for r=1:1 %only use first run
    
    for l=1:length(input_ROIs)
        if l==1
            ROIs={'lh_aSTS_morphing_reading_vs_all.mat' 'lh_pSTS_MTG_union_morphing_reading_vs_all.mat'...
                'lh_ISMG_morphing_reading_vs_all.mat' 'lh_IFG_union_morphing_reading_vs_all.mat' 'lh_ORS_morphing_reading_vs_all.mat'...
                'lh_aIPS_morphing_adding_vs_all.mat'  'lh_pIPS_morphing_adding_vs_all.mat' 'lh_ANG_morphing_adding_vs_all.mat'...
                'lh_LF_morphing_adding_vs_all.mat'  'lh_ISMG_morphing_adding_vs_all.mat' 'lh_IPCS_morphing_adding_vs_all.mat'}
        elseif l==2
            ROIs={'lh_aSTS_morphing_reading_vs_all.mat' 'lh_pSTS_MTG_union_morphing_reading_vs_all.mat'...
                'lh_ISMG_morphing_reading_vs_all.mat' 'lh_IFG_union_morphing_reading_vs_all.mat' 'lh_ORS_morphing_reading_vs_all.mat'...
                'lh_aIPS_morphing_adding_vs_all.mat'  'lh_pIPS_morphing_adding_vs_all.mat' 'lh_ANG_morphing_adding_vs_all.mat'...
                'lh_LF_morphing_adding_vs_all.mat'  'lh_ISMG_morphing_adding_vs_all.mat' 'lh_IPCS_morphing_adding_vs_all.mat'}
        end
        
        for n=1:length(ROIs)
            name_ending=['_pairwise_classified']
            
            
            ROIName=strsplit(ROIs{n},'.')
            inputROIName=strsplit(input_ROIs{l},'.')
            
            filename=strcat(ROIName{1}, '_', inputROIName{1}, name_ending,'.mat')
            
            load(filename)
            subjectnr=size(percentage)-2;
            
            foi=[11 12 13 14 15 16 17 18 19 20 21 22 27 28];
            values=percentage(subjectnr(1,1)+1,foi+1)
            error=percentage(subjectnr(1,1)+2,foi+1)
        
 caption_x=['IFOF';'IFOF';'ILF ';'ILF ';...
        'SLF ';'SLF ';'UCIF';'UCIF';'AF  ';'AF  ';'VOF ';'VOF ';'pAF ';'pAF '];
        caption_y='betas';
        fig=mybar(values,error, caption_x,[],[[1 0.5 0];[0.8 0.3 0];[1 1 0];[0.8 0.8 0];[1 0 1];[0.8 0 0.8];[1 0 0];[0.8 0 0];[0 0 1];[0 0 0.8];[0 1 1];[0 0.8 0.8];[0 1 0];[0 0.8 0];[1 0.5 0];[0.8 0.3 0]],2,0.8);
        ylim([0 max(values)+10]);
        t=title(strcat(ROIName{1}, '_', inputROIName{1}, name_ending),'FontSize',14,'FontName','Arial','FontWeight','bold','interpreter','none');
        % P = get(t,'Position');
        % set(t,'Position',[P(1) P(2)-0.05 P(3)])
        ylabel('[%]','FontSize',14,'FontName','Arial','FontWeight','bold');
           xlabel(' lh   rh   lh   rh   lh    rh    lh   rh    lh    rh    lh   rh    lh   rh','FontSize',16,'FontName','Arial','FontWeight','bold');
        pbaspect([2 1 2])
        set(gca,'FontSize',14,'FontWeight','bold'); box off; set(gca,'Linewidth',2);
        
        outfile=fullfile(OutDir, strcat(ROIName{1}, '_', inputROIName{1},name_ending));
        saveas(gcf, outfile, 'tif')
        end
    end
end



