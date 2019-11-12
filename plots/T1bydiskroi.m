%close all
clear all

sessions={'01_sc_morphing_112116' '02_at_morphing_102116' '03_as_morphing_112616'...
     '05_mg_morphing_101916' '06_jg_morphing_102316'...
     '08_sg_morphing_102716' '10_em_morphing_1110316'... 
     '12_rc_morphing_112316' '13_cb_morphing_120916' '16_kw_morphing_081517'...
     '17_ad_morphing_082217' '18_nc_morphing_083117'};
     

 qMRI_sessions={'01_sc_qMRI_080917' '02_at_qMRI_080517' '03_as_qMRI_083016'...
    '05_mg_qMRI_071217' '06_jg_qMRI_083016'...
    '08_sg_qMRI_081417' '10_em_qMRI_080817'...
    '12_rc_qMRI_080717' '13_cb_qMRI_081317' '16_kw_qMRI_082117'...
    '17_ad_qMRI_081817' '18_nc_qMRI_090817'}
 
 subs=1 
%  sessions={'01_sc_morphing_112116' '02_at_morphing_102116' '03_as_morphing_112616'...
%      '04_kg_morphing_120816' '05_mg_morphing_101916' '06_jg_morphing_102316'...
%      '07_bj_morphing_102516' '08_sg_morphing_102716' '10_em_morphing_1110316'... 
%      '12_rc_morphing_112316' '13_cb_morphing_120916' '16_kw_morphing_081517'...
%      '17_ad_morphing_082217' '18_nc_morphing_083117'};
% 
%  qMRI_sessions={'01_sc_qMRI_080917' '02_at_qMRI_080517' '03_as_qMRI_083016'...
%     '04_kg_qMRI_101014' '05_mg_qMRI_071217' '06_jg_qMRI_083016'...
%     '07_bj_qMRI_081117' '08_sg_qMRI_081417' '10_em_qMRI_080817'...
%     '12_rc_qMRI_080717' '13_cb_qMRI_081317' '16_kw_qMRI_082117'...
%     '17_ad_qMRI_081817' '18_nc_qMRI_090817'}
% % get ROI
roiList = {'dti_lh_IFG_ISMG_SLF_unique_no_gray.mat' 'dti_lh_IPCS_ISMG_SLF_unique_no_gray.mat'...
    'lh_IFG_union_morphing_reading_vs_all' 'lh_IPCS_morphing_adding_vs_all'...
    'lh_ISMG_morphing_reading_vs_all' 'lh_ISMG_morphing_adding_vs_all'};

mriDir = '/sni-storage/kalanit/biac2/kgs/projects/NFA_tasks/data_mrAuto/';

for s=1:length(sessions)
funcDir = ['/sni-storage/kalanit/biac2/kgs/projects/NFA_tasks/data_mrAuto/' sessions{s}];

tEdge = [0.5:0.05:2.3]; % This value splits both MTV and T1 into bin sizes that are 1/10th of their respective unit ranges (.1s or .01 tissue volume fraction)
vEdge = [0.05:0.01:0.4];
T1valsVox  = zeros(length(subs),length(tEdge)-1);
MTVvalsVox = zeros(length(subs),length(vEdge)-1);
 
%% Initialize a hidden gray for motionComp_refscan1 and
cd(fullfile(mriDir,sessions{s}))
view = initHiddenGray(4,1);
fprintf('\n\nProcessing %s\n\n',sessions{s})

% Now load these ROIs into the hiddenGray
view = loadROI(view,roiList); 
view = loadAnat(view);
%roiSaveAsNifti(view)
%% load T1 values for each ROI
anatDir = ['/sni-storage/kalanit/biac2/kgs/projects/NFA_tasks/data_mrAuto/' qMRI_sessions{s}];
T1ni = readFileNifti(fullfile(anatDir,'mrQnew_processed','OutPutFiles_1','BrainMaps','T1_map_Wlin_rescliced.nii.gz'));
MTVni= readFileNifti(fullfile(anatDir,'mrQnew_processed','OutPutFiles_1','BrainMaps','TV_map_rescliced.nii.gz'));

for i = 1:length(roiList)
    coords1 = view.ROIs(i).coords; 
    len1 = size(coords1, 2);

    roiColor = 1;
    %view.viewType = 'Gray';
    roiData1 = zeros(viewGet(view, 'anatomy size'));
    for ii = 1:len1
        roiData1(coords1(1,ii), coords1(2,ii), coords1(3,ii)) = roiColor;
    end

    % 
    mmPerVox = viewGet(view, 'mmPerVox');
    [data1, xform, ni] = mrLoadRet2nifti(roiData1, mmPerVox);


    % Now let's get the qmri map means from independent voxels in each run
    T1 = nanmean(T1ni.data(data1==1)); 
    TV = nanmean(MTVni.data(data1==1));

    T1vox = [T1ni.data(data1==1)];
    TVvox = [MTVni.data(data1==1)];

    % Store these values in our vector and finally move on to next subject
    T1vals(s,i) = T1;
    MTVvals(s,i) = TV;
    allT1vox{s,i} = T1vox; 
    
end
end

T1MeanRead=mean(T1vals(1:s,1))
T1MeanMath=mean(T1vals(1:s,2))

plot(T1vals)
figure; violin([allT1vox])
t=title('T1 in SLF','FontSize',18,'FontName','Arial','FontWeight','bold');
%set(gca,'XTick',[1:3])
ylabel('Probability density [%]')
%xlim([0 2])
pbaspect([2 1 1])   
xlabel('reading and math')
ylim([0.7 1.2])


t1valsMean=mean(T1vals)
t1valsStd=std(T1vals)
t1valsSe=t1valsStd/(sqrt(11))
caption_x=[];
caption_y='betas';
fig=mybar(t1valsMean,t1valsSe,caption_x,[],[0 1 0; 0 0 1; 0 .6 1; 0 0.5 0; 0 1 0; 0.6 1 0; 0 0 0],2,0.65);
ylim([0.85 1.6]);
% t=title('E1 pOTS split-half (lh,N=12)','FontSize',18,'FontName','Arial','FontWeight','bold');
% P = get(t,'Position');
% set(t,'Position',[P(1) P(2)-0.3 P(3)])
ylabel('t1','FontSize',22,'FontName','Arial','FontWeight','bold');
pbaspect([1 1 1])
set(gca,'FontSize',22,'FontWeight','bold'); box off; set(gca,'Linewidth',2);   




