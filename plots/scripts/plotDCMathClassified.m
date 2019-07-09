
clear all;
ExpDir=fullfile('/sni-storage/kalanit/biac2/kgs/projects','NFA_tasks','data_mrAuto');
OutDir=fullfile(ExpDir,'dti_results_new_math_ROIs');

input_ROIs={'ITG_morphing_adding.mat' 'pIPS_morphing_adding_vs_all.mat' 'ISMG_morphing_adding_vs_all.mat' 'IPCS_morphing_adding_vs_all.mat'}

t1_name=['t1.nii.gz'];
count=1

for l=1:length(input_ROIs)
        if l==1
            ROIs={'pIPS_morphing_adding_vs_all.mat' 'ISMG_morphing_adding_vs_all.mat' 'IPCS_morphing_adding_vs_all.mat'}
        elseif l==2
            ROIs={'ISMG_morphing_adding_vs_all.mat' 'IPCS_morphing_adding_vs_all.mat'}
        elseif l==3
            ROIs={'IPCS_morphing_adding_vs_all.mat'}
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
            values(2,count)=(values(1,count))*(percentage_of_interest_both(2,hem)/100)
            values(3,count)=((values(1,count))*(percentage_of_interest_both(2,hem+2)/100))+values(2,count)
            values(4,count)=((values(1,count))*(percentage_of_interest_both(2,hem+4)/100))+values(3,count)
            values(5,count)=((values(1,count))*(percentage_of_interest_both(2,hem+6)/100))+values(4,count)
            values(6,count)=((values(1,count))*(percentage_of_interest_both(2,hem+10)/100))+values(5,count)
            values(7,count)=((values(1,count))*(percentage_of_interest_both(2,hem+8)/100))+values(6,count)
            error(1,count)=DC(subjectnr(1,1)+2,2)
            count=count+1
        end
    end
end


    
    caption_x={'ITG/IPS' 'ITG/SMG' 'ITG/PCS'...
        'IPS/SMG' 'IPS/PCS'...
        'SMG/PCS'};

    caption_y='betas';
    fig=mybar(values(1,:),error, caption_x,[],[1 1 1],2,0.8);
    
    hold on
    bar(values(1,:),'FaceColor',[1 1 1]);
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
    ylim([0 0.3]);
    %t=title('allcount','FontSize',14,'FontName','Arial','FontWeight','bold','interpreter','none');
    % P = get(t,'Position');
    % set(t,'Position',[P(1) P(2)-0.05 P(3)])
    ylabel('DC','FontSize',16,'FontName','Arial','FontWeight','bold');
    pbaspect([1 1 1])
    set(gca,'FontSize',16,'FontWeight','bold'); box off; set(gca,'Linewidth',2);
        lin=refline(0,0.0282);
set(lin,'Linewidth',3);
set(lin,'Color',[0 0 0]);
set(lin,'LineStyle','--');

    outfile=fullfile(OutDir, strcat(hemname, 'allcount'));
    saveas(gcf, outfile, 'tif')
