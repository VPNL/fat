
clear all;
ExpDir=fullfile('/sni-storage/kalanit/biac2/kgs/projects','NFA_tasks','data_mrAuto');
OutDir=fullfile(ExpDir,'dti_results_new_math_ROIs');

input_ROIs={'OTS_union_morphing_reading_vs_all.mat' 'pSTS_MTG_union_morphing_reading_vs_all.mat' 'ISMG_morphing_reading_vs_all.mat' 'IFG_union_morphing_reading_vs_all.mat'...
    'OTS_union_morphing_reading_vs_all.mat' 'pSTS_MTG_union_morphing_reading_vs_all.mat' 'ISMG_morphing_reading_vs_all.mat' 'IFG_union_morphing_reading_vs_all.mat'}

t1_name=['t1.nii.gz'];
count=1

for l=1:length(input_ROIs)
    if l==1
        ROIs={'pSTS_MTG_union_morphing_reading_vs_all.mat' 'ISMG_morphing_reading_vs_all.mat' 'IFG_union_morphing_reading_vs_all.mat'}
    elseif l==2
        ROIs={'ISMG_morphing_reading_vs_all.mat' 'IFG_union_morphing_reading_vs_all.mat'}
    elseif l==3
        ROIs={'IFG_union_morphing_reading_vs_all.mat'}
    elseif l==4
        ROIs={}
    end
    
    
    for n=1:length(ROIs)
        for hem=1
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
            values(2,count)=(values(1,count))*(percentage_of_interest_both(2,1)/100)
            values(3,count)=((values(1,count))*(percentage_of_interest_both(2,2)/100))+values(2,count)
            values(4,count)=((values(1,count))*(percentage_of_interest_both(2,3)/100))+values(3,count)
            values(5,count)=((values(1,count))*(percentage_of_interest_both(2,4)/100))+values(4,count)
            values(6,count)=((values(1,count))*(percentage_of_interest_both(2,5)/100))+values(5,count)
            values(7,count)=((values(1,count))*(percentage_of_interest_both(2,6)/100))+values(6,count)
            error(1,count)=DC(subjectnr(1,1)+2,2)
            count=count+1
        end
    end
end


    
    caption_x={'OTS/STS' 'OTS/SMG' 'OTS/IFG'...
        'STS/SMG' 'STS/IFG'...
        'SMG/IFG'};

    caption_y='betas';
    fig=mybar(values(1,:),error, caption_x,[],[0 0 0],2,0.8);
    
    hold on
    bar(values(1,:),'FaceColor',[0 0 0]);
    hold on
    bar(values(7,:),'FaceColor',[0 0.8 0]);
    hold on
    bar(values(6,:),'FaceColor',[0 0.8 0.8]);
    hold on
    bar(values(5,:),'FaceColor',[0 0 0.8]);
    hold on
    bar(values(4,:),'FaceColor',[0.8 0 0.8]);
    hold on
    bar(values(3,:),'FaceColor',[0.8 0 0]);
    hold on
    bar(values(2,:),'FaceColor',[0.9 0.5 0]);
    
    
    xticklabel_rotate([],45,[],'Fontsize',14,'FontWeight','bold')
    ylim([0 0.25]);
    %t=title('allcount','FontSize',14,'FontName','Arial','FontWeight','bold','interpreter','none');
    % P = get(t,'Position');
    % set(t,'Position',[P(1) P(2)-0.05 P(3)])
    ylabel('DC','FontSize',16,'FontName','Arial','FontWeight','bold');
    pbaspect([1 1 1])
    set(gca,'FontSize',16,'FontWeight','bold'); box off; set(gca,'Linewidth',2);
    
            lin=refline(0,0.0231);
set(lin,'Linewidth',3);
set(lin,'Color',[0 0 0]);
set(lin,'LineStyle','--');
    
    outfile=fullfile(OutDir, strcat(hemname, 'allcount'));
    saveas(gcf, outfile, 'tif')
