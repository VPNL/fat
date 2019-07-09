
clear all;
ExpDir=fullfile('/sni-storage/kalanit/biac2/kgs/projects','NFA_tasks','data_mrAuto');
OutDir=fullfile(ExpDir,'dti_results_new_math_ROIs_v2');

ROIs={'pSTS_MTG_union_morphing_reading_vs_all'}

name_ending={'_fibers_in_ROI_classified'}
cd(ExpDir)

for a=1
for r=1:length(ROIs)
    for hem=1
        if hem==1
            hemname='lh_'
        elseif hem==2
            hemname='rh_'
        end
 filename=strcat(hemname, ROIs{r},name_ending{a},'.mat')       
        
load(filename)
subjectnr=size(percentage)-2;
if hem==1
foi=[11 12 13 14 15 16 19 20 27 28 21 22 ];
xvalues_lh=percentage(subjectnr(1,1)+1,foi+1)
xerror_lh=percentage(subjectnr(1,1)+2,foi+1)
elseif hem==2
foi=[11 12 13 14 15 16 19 20 27 28 21 22 ];
xvalues_rh=percentage(subjectnr(1,1)+1,foi+1)
xerror_rh=percentage(subjectnr(1,1)+2,foi+1)
end
    end
   
    cnt=0
    
for n=1:length(foi)
    if rem(n,2)~=0
        cnt=cnt+1
        xvalues(1,cnt)=xvalues_lh(1,n);
        xerror(1,cnt)=xerror_lh(1,n);
    else
%         cnt=cnt+1
%         xvalues(1,cnt)=xvalues_rh(1,n);
%         xerror(1,cnt)=xerror_rh(1,n);
    end
end

caption_x=['  '];
caption_y='betas';
fig=mybar(xvalues,xerror, caption_x,[],[[0.9 0.5 0];[0.8 0 0];[0.8 0 0.8];[0 0 0.8];[0 0.8 0.8];[0 0.8 0]],2,0.8);
if a==1
ylim([0 100]);
elseif a==2
    ylim([0 100]);
end
%t=title(strcat(ROIs{r},name_ending{a}),'FontSize',14,'FontName','Arial','FontWeight','bold','interpreter','none');
% P = get(t,'Position');
% set(t,'Position',[P(1) P(2)-0.05 P(3)])
ylabel('% of intersecting fibers','FontSize',28,'FontName','Arial','FontWeight','bold');
%xlabel([],'FontSize',16,'FontName','Arial','FontWeight','bold');
pbaspect([1 1 1])
set(gca,'FontSize',28,'FontWeight','bold'); box off; set(gca,'Linewidth',2);  

outfile=fullfile(OutDir, strcat(ROIs{r},name_ending{a}));
saveas(gcf, outfile, 'tif')
end
end
