
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



ROIs={'rh_OTS_union_morphing_reading_vs_all.mat' 'rh_pSTS_MTG_union_morphing_reading_vs_all.mat' 'rh_ISMG_morphing_reading_vs_all.mat' 'rh_IFG_union_morphing_reading_vs_all.mat'}

t1_name=['t1.nii.gz'];

for r=1:1 %only use first run
       
        for n=1:length(ROIs)
            fibercount=[];
            allcount=[];
            percentage=[];
            percentage_all=[];
            subjcnt=1;
            for s=1:length(sessid)  % Ok, here we go
                ROIName=strsplit(ROIs{n},'.')
                ROIfgname=[ROIName{1} '_r7.00_run' num2str(r) '_lmax8_curvatures_concatenated_optimize_it500_new_classified.mat'];
                roifgFile = fullfile(dwiDir,sessid{s},runName{r},'dti96trilin','fibers','afq',ROIfgname);
                if exist(roifgFile,'file')
                    roifg_classified=load(roifgFile);
                    
                    for f=1:28
                        roicnt=size(roifg_classified.roifg(1,f).fibers);
                        fibercount(subjcnt,1)=s
                        fibercount(subjcnt,f+1)=roicnt(1,1);
                    end
                    
                    f=[2:23 28 29]
                    allcount(subjcnt,1)=s
                    allcount(subjcnt,2)=sum(fibercount(subjcnt,f));
                    
                                    
                for f=2:29
                    percentage(subjcnt,1)=s
                    percentage(subjcnt,f)=(fibercount(subjcnt,f)/allcount(subjcnt,2))*100
                end
                    
                    
                    subjcnt=subjcnt+1;
                end

            end
            

          
            
            for i=2:29
                fibercount(subjcnt,i)=mean(fibercount(1:subjcnt-1,i));
                fibercount(subjcnt+1,i)=(std(fibercount(1:subjcnt-2,i))/sqrt(subjcnt-1));
                
                percentage(subjcnt,i)=mean(percentage(1:subjcnt-1,i));
                percentage(subjcnt+1,i)=(std(percentage(1:subjcnt-2,i))/sqrt(subjcnt-1));
            end
            
            
            percentage_of_interest(1,:)=[11 12 13 14 15 16 19 20 21 22 27 28];
            percentage_of_interest(2,:)=percentage(subjcnt,[12 13 14 15 16 17 20 21 22 23 28 29]);
            
            cd(fullfile(dwiDir))
            outname=[ROIName{1} '_fibers_in_ROI_classified']
            save(outname,'fibercount','allcount','percentage', 'percentage_of_interest')
        end
        end


