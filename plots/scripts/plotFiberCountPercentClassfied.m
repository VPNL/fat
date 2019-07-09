
function [fig] = plotFiberCountPercentClassfied(percentage)

subjectnr=size(percentage)-2;
foi=[11 12 13 14 15 16 17 18 19 20 21 22 27 28];
xvalues_lh=percentage(subjectnr(1,1)+1,foi+1)
xerror_lh=percentage(subjectnr(1,1)+2,foi+1)

cnt=0
for n=1:length(foi)
    if rem(n,2)~=0
        cnt=cnt+1
        xvalues(1,cnt)=xvalues_lh(1,n);
        xerror(1,cnt)=xerror_lh(1,n);
    end
end

caption_x=['IFOF';'ILF ';'SLF ';'UCIF';'AF  ';'VOF ';'pAF '];
caption_y='betas';
fig=mybar(xvalues,xerror, caption_x,[],[[1 0.5 0];[1 1 0];[1 0 1];[1 0 0];[0 0 1];[0 1 1];[0 1 0]],2,0.8);
    ylim([0 100]);
%t=title(strcat(ROIs{r},name_ending{a}),'FontSize',14,'FontName','Arial','FontWeight','bold','interpreter','none');
% P = get(t,'Position');
% set(t,'Position',[P(1) P(2)-0.05 P(3)])
%ylabel('[%]','FontSize',14,'FontName','Arial','FontWeight','bold');
%xlabel(' lh   rh   lh   rh   lh    rh    lh   rh    lh    rh    lh   rh    lh   rh','FontSize',16,'FontName','Arial','FontWeight','bold');
pbaspect([2 1 2])
set(gca,'FontSize',18,'FontWeight','bold'); box off; set(gca,'Linewidth',2);  

end
