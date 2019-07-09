
clear all;
ExpDir=fullfile('/sni-storage/kalanit/biac2/kgs/projects','NFA_tasks','data_mrAuto');
OutDir=fullfile(ExpDir,'dti_results_new_math_ROIs');


input_ROIs={'Ac_Cc_Pc_union_morphing_color_vs_all.mat'}

t1_name=['t1.nii.gz'];
count=1

for l=1:length(input_ROIs)
        if l==1
            ROIs={'OTS_union_morphing_reading_vs_all.mat' 'pSTS_MTG_union_morphing_reading_vs_all.mat' 'ISMG_morphing_reading_vs_all.mat' 'IFG_union_morphing_reading_vs_all.mat'...
                'ITG_morphing_adding.mat' 'pIPS_morphing_adding_vs_all.mat' 'ISMG_morphing_adding_vs_all.mat' 'IPCS_morphing_adding_vs_all.mat'}
        end
    
    
    for n=1:length(ROIs)
        for hem=2
            if hem==1
                hemname='lh_'
            elseif hem==2
                hemname='rh_'
            end
            name_ending=['_DC']
            
            
            ROIName=strsplit(ROIs{n},'.')
            inputROIName=strsplit(input_ROIs{l},'.')
            
            filename=strcat(hemname, inputROIName{1}, '_', hemname, ROIName{1}, name_ending,'.mat')
            
            load(filename)
            subjectnr=size(DC)-2
values(1,count)=DC(subjectnr(1,1)+1,2)
            error(1,count)=DC(subjectnr(1,1)+2,2)
            count=count+1
        end
    end
end


    
    caption_x={'Col/OTS' 'Col/STS' 'Col/SMG' 'Col/IFG'...
        'Col/ITG' 'Col/IPS' 'Col/SMG' 'Col/PCS'};
    hold on
    caption_y='betas';
    fig=mybar(values(1,:),error, caption_x,[],[1 1 1; 1 1 1; 1 1 1; 1 1 1; 0 0 0; 0 0 0; 0 0 0; 0 0 0],2,0.8);
    xticklabel_rotate([],45,[],'Fontsize',14,'FontWeight','bold')
    ylim([0 0.3]);
    %t=title('allcount','FontSize',14,'FontName','Arial','FontWeight','bold','interpreter','none');
    % P = get(t,'Position');
    % set(t,'Position',[P(1) P(2)-0.05 P(3)])
    ylabel('DC','FontSize',16,'FontName','Arial','FontWeight','bold');
    pbaspect([1 1 1])
    set(gca,'FontSize',16,'FontWeight','bold'); box off; set(gca,'Linewidth',2);
    
    outfile=fullfile(OutDir, strcat(hemname, 'allcount'));
    saveas(gcf, outfile, 'tif')
