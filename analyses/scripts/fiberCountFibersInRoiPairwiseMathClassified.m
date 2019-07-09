
clear all;

% The following parameters need to be adjusted to fit your system
dwiDir=fullfile('/sni-storage/kalanit/biac2/kgs/projects/NFA_tasks/data_mrAuto');
anatDir_system =fullfile('/biac2/kgs/3Danat');
anatDir =('/sni-storage/kalanit/biac2/kgs/3Danat');

sessid={'01_sc_dti_080917' '02_at_dti_080517' '03_as_dti_083016'...
    '04_kg_dti_101014' '05_mg_dti_071217' '06_jg_dti_083016'...
    '07_bj_dti_081117' '08_sg_dti_081417' '10_em_dti_080817'...
    '12_rc_dti_080717' '13_cb_dti_081317' '16_kw_dti_082117'...
    '17_ad_dti_081817' '18_nc_dti_090817'}

runName={'96dir_run1' '96dir_run2'}


input_ROIs={'lh_ITG_morphing_adding.mat' 'lh_pIPS_morphing_adding_vs_all.mat' 'lh_ISMG_morphing_adding_vs_all.mat' 'lh_IPCS_morphing_adding_vs_all.mat'}

t1_name=['t1.nii.gz'];

for r=1:1 %only use first run
    
    for l=1:length(input_ROIs)
        if l==1
            ROIs={'lh_pIPS_morphing_adding_vs_all.mat' 'lh_ISMG_morphing_adding_vs_all.mat' 'lh_IPCS_morphing_adding_vs_all.mat'}
        elseif l==2
            ROIs={'lh_ISMG_morphing_adding_vs_all.mat' 'lh_IPCS_morphing_adding_vs_all.mat'}
        elseif l==3
            ROIs={'lh_IPCS_morphing_adding_vs_all.mat'}
        elseif l==4
            ROIs={}
        end
        
        
        for n=1:length(ROIs)
            fibercount=[];
            allcount=[];
            percentage=[];
            percentage_all=[];
            subjcnt=1;
            for s=1:length(sessid)  % Ok, here we go
                inputROIName=strsplit(input_ROIs{l},'.')
                ROIName=strsplit(ROIs{n},'.')
                ROIfgname=[inputROIName{1} '_' ROIName{1} '_r7.00_run' num2str(r) '_lmax8_curvatures_concatenated_optimize_it500_new_classified_overlap.mat'];
                roifgFile = fullfile(dwiDir,sessid{s},runName{r},'dti96trilin','fibers','afq',ROIfgname);
                if exist(roifgFile,'file')
                    roifg_classified=load(roifgFile);
                    
                    for f=1:28
                        roicnt=size(roifg_classified.roifg(1,f).fibers);
                        fibercount(subjcnt,1)=s
                        fibercount(subjcnt,f+1)=roicnt(1,1);
                    end
                    subjcnt=subjcnt+1;
                end
            end
            
            cnt=0
            for f=[2:23 28 29]   
                cnt=cnt+1
            fibercount_all(1,cnt)=sum(fibercount(:,f));
            end
            fibercount_sum=sum(fibercount_all)
            
            for i=1:24
            percentage(1,i)=(fibercount_all(1,i)/fibercount_sum)*100
            end
            
            for i=2:29
                fibercount(subjcnt,i)=mean(fibercount(1:subjcnt-1,i));
                fibercount(subjcnt+1,i)=(std(fibercount(1:subjcnt-2,i))/sqrt(subjcnt-1));
            end
            
            
            percentage_of_interest(1,:)=[11 12 13 14 15 16 19 20 21 22 27 28];
            percentage_of_interest(2,:)=percentage(1,[11 12 13 14 15 16 19 20 21 22 23 24]);
            
            cd(fullfile(dwiDir))
            outname=[inputROIName{1} '_' ROIName{1} '_pairwise_classified']
            save(outname,'fibercount','fibercount_all','percentage', 'percentage_of_interest')
        end
    end
end

