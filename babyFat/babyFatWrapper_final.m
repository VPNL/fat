
%Diffusion tool combine Vistasoft, MRtrix, LiFE and AFQ to produce functional defined fasciculus.
%It requires these toolboxs installed, and also required the fROI defined by vistasoft.
%In oder for this code to run, you will likely need to upgrade several
%software packages, specifically this code wa9afstys tested using: MRtrix RC3,
%fslv6.0.1, ANTs from 2017, AFQ from 2019, cuda9.1, and freesurferv6.0.0. Please note that
%running older version will lead to subtly inoptimal results. I made a few
%suggestions which outputs to ckeck for qulity assurance. You can do sou
%using mrview.
%The pipeline is orgnized as bellow and was written by Mareike Grotheer in
%2019

% The following parameters need to be adjusted to fit your system
fatDir=fullfile('/share/kalanit/biac2/kgs/projects/babybrains/mri/');

sessid={                 'bb02/mri3/dwi/' 'bb02/mri6/dwi/' ,...
        'bb04/mri0/dwi/' 'bb04/mri3/dwi/' 'bb04/mri6/dwi/' ,...
        'bb05/mri0/dwi/' 'bb05/mri3/dwi/' 'bb05/mri6/dwi/' ,...
        'bb07/mri0/dwi/' 'bb07/mri3/dwi/' 'bb07/mri6/dwi/' ,...
                         'bb08/mri3/dwi/' 'bb08/mri6/dwi/' ,...
        'bb11/mri0/dwi/' 'bb11/mri3/dwi/' 'bb11/mri5/dwi/' ,...
        'bb12/mri0/dwi/' 'bb12/mri3/dwi/' 'bb12/mri6/dwi/' ,...
        'bb14/mri0/dwi/' 'bb14/mri3/dwi/' 'bb14/mri6/dwi/' ,...
                         'bb15/mri3/dwi/' 'bb15/mri6/dwi/' ,...
        'bb17/mri0/dwi/' , ...
        'bb18/mri0/dwi/' 'bb18/mri3/dwi/' , ...
                                          'bb19/mri6/dwi/' , ...
        'bb22/mri0/dwi/'};

runName={'94dir_run1'};
t1_name=['t2_biascorr_acpc.nii.gz'];

useBabyAFQ =1;
useAdultAFQ=0;

revPhase=1; %the baby project is using reverse phase encoding correction
doDenoise=1; % denoise the data? Enter 0 or 1
doGibbs=0; % do gibss ringing correction? Enter 0 or 1
doEddy=1; % do eddy correction? Enter 0 or 1
doBiasCorr=1; % do bias correction? Enter 0 or 1
doRicn=0; % ricn denoise is not yet implemented for revPhase data

lmax='auto'; %todate MRtrix automatically choose appropricate lmax when using dhollander
mrtrixversion=3; %going back to an older version will require serious changes to the pipeline
multishell=1; % the baby project has 3 shells
track_tool='freesurfer'; % chose between freesurfer or fsl. Fsl does not work well though.
algo='IFOD1'; % several options, IFOD2 is the most modern.
background=0; % run multible MRtrix comments at the same time. 1 will not work.
verbose=1; % print output to window
clobber=1; %overwrite existing files
seeding='seed_gmwmi'; % seeding mechanisms, this uses ACT
nSeeds=2000000; % how many seeds

ET=0; % do you want to use ensemble tractography? Enter 1 or 0
runLife=0; % do you want to run life?
classifyConnectome = 1; % do you want to classify the connectome with AFQ? Enter 1 or 0
cleanConnectome = 1; % do you want to clean the connectome with AFQ? Enter 1 or 0
generatePlots =1; % do you want to generates some simple plots of fiber tracts for quality assurance? Enter 1 or 0
cutOff=0.05;

for s=1:length(sessid)
    close all;
    for r=1:length(runName)
        session=strsplit(sessid{s},'/')
        
        subject=session{1};
        age=session{2};
        anatid=strcat(subject,'/',age,'/preprocessed_acpc/')
        %Ok, here we go
        
        %1) Prepare fat data and directory structure
        
        %    The following parameters need to be adjusted to fit your system
        babyFatPrepareMRtrix3(fatDir,sessid{s}, anatid, runName{r})
        
        %         %2) Preprocess the data using mrTrix3
        %--> After this step check that dwi_processed.nii.gz looks ok
                cd(fullfile(fatDir,sessid{s},runName{r}))
                !echo '0 -1 0 0.0792' > acq_params.txt
                !echo '0 1 0 0.0792' >> acq_params.txt
                cmd_str=['cp ' fullfile('/home/grotheer/babyBrainsDWI/index.txt') ' ' fullfile(fatDir,sessid{s},runName{r},'index.txt')]
                system(cmd_str)
        
                cmd_str=['cp ' fullfile('/home/grotheer/babyBrainsDWI/dwiMultiShell_correctedByX.bvecs') ' ' fullfile(fatDir,sessid{s},runName{r},'raw','dwiMultiShell.bvec')]
                system(cmd_str)
        
                cmd_str=['cp ' fullfile('/home/grotheer/babyBrainsDWI/babySlspec.txt') ' ' fullfile(fatDir,sessid{s},runName{r},'dwiSlSpec.txt')]
                system(cmd_str)
        
                 fatPreProcMRtrix3Nii(fatDir,sessid{s},runName{r},revPhase,doDenoise,doGibbs,doEddy,doBiasCorr,doRicn)
        
                       %3) We need to make a few changes to the nifti for it to work with
                         %the rest of the pipeline
                !mrconvert dwi_processed.nii.gz -fslgrad dwi_processed.bvec dwi_processed.bval dwi_processed.nii.gz -stride -1,2,3,4 -export_grad_fsl dwi_processed.bvec dwi_processed.bval -force
        
                nii=niftiRead(fullfile(fatDir,sessid{s},runName{r},'dwi_processed.nii.gz'));
                nii.phase_dim=2;
                niftiWrite(nii,fullfile(fatDir,sessid{s},runName{r},'dwi_processed.nii.gz'));
        
                %4) Initiate a dt.mat data structure
               %--> After this step, check that t1 and dwi were aligned properly
               cmd_str = ['N4BiasFieldCorrection -i ',...
                   fullfile(fatDir,sessid{s},runName{r},'t1','t2.nii.gz') ' -o ',...
                   fullfile(fatDir,sessid{s},runName{r},'t1','t2_biascorr.nii.gz')]
               system(cmd_str);
        
        [dt6folder, dt6file]=fatCreateDT6(fatDir,sessid(s),runName(r),t1_name,clobber);
        
                %6) Set up tractography for mrtrix 3
                %--> After this step check that dwi_[...]_wmCSD_lmax_auto.mif looks
                %ok. You probably also want to check the other files in the mrtrix folder, especially:
                %dwi_[...]_ev.mif, dwi_[...]_5tt.mif, dwi_[...]_ev.mif, dwi_[...]_vf.mif and dwi_[...]_voxels.mif
        
        anatFolder=fullfile(fatDir,sessid{s},runName{r},'t1');
        files = babyFat_AFQ_mrtrixInit(dt6file, ...
            fullfile(fatDir,sessid{s},runName{r},dt6folder.name,'mrtrix'),...
            mrtrixversion, ...
            multishell, ... % true/false
            track_tool,... % 'fsl', 'freesurfer'
            1,... %compute5tt
            anatFolder);
        %include mt normaize
        
        
        wmCsd=files.wmCsdMSMTDhollanderNorm;
        %7) Create connectomes
        %--> After this step check that WholeBrainFG.tck looks ok
        [status, results, out_fg] = babyFatCreateConnectomeMRtrix3ACT(fullfile(fatDir,sessid{s},runName{r},dt6folder.name),...
            files, ...
            algo, ...
            seeding, ...
            nSeeds, ...
            background, ...
            verbose, ... %verbose
            clobber, ... %clobber
            mrtrixversion, ...
            ET, ...
            cutOff, ...
            wmCsd)

         fgName='WholeBrainFG';
         fgNameBaby='WholeBrainFG';
        
        %7) Optional: Run LiFE to optimize the ET connectome
        if runLife > 0
            out_fg=fatRunLifeMRtrix3(fatDir, sessid{s}, runName{r},strcat(fgName,'.mat'));
            fgName=strcat(fgName,'_LiFE');
        end
        
        % 8) Optional: Run AFQ to classify the fibers
        if classifyConnectome > 0
            
            if useBabyAFQ>0
                %prepare t2 for alignment
                cmd_str=['mri_convert ' fullfile(fatDir, sessid{s}, runName{r},'t1','t2_biascorr_acpc.nii.gz') ' ',...
                    fullfile(fatDir, sessid{s}, runName{r},'dti94trilin','mrtrix','t2_biascorr_acpc_resliced2dwi.nii.gz') ' --reslice_like ',...
                    fullfile(fatDir, sessid{s}, runName{r},'dti94trilin','mrtrix','b0.nii.gz')];
                system(cmd_str);
                
                cmd_str=['fslmaths ' fullfile(fatDir, sessid{s}, runName{r},'dti94trilin','mrtrix','t2_biascorr_acpc_resliced2dwi.nii.gz') ' -mas ',...
                    fullfile(fatDir, sessid{s}, runName{r},'dti94trilin','mrtrix','brainMask.nii.gz') ' ',...
                    fullfile(fatDir, sessid{s}, runName{r},'dti94trilin','mrtrix','t2_biascorr_acpc_resliced2dwi_masked.nii.gz')];
                system(cmd_str);
                
                 babyAFQRoiDir=fullfile(fatDir, sessid{s}, runName{r},'dti94trilin','babyAFQROIs');
                out_fg=babyFatSegmentConnectomeMRtrix3(fatDir, babyAFQRoiDir, sessid{s}, runName{r}, strcat(fgNameBaby,'.mat'))
            end
            
            if useAdultAFQ>0
                ROIdir=fullfile(fatDir, sessid{s}, runName{r},'dti94trilin','ROIs');
                mkdir(ROIdir);
                fsdir=fullfile('/biac2/kgs/anatomy/freesurferRecon/babySegmentations');
                cmd_str=['mris_ca_label -sdir ' fsdir ' -aseg ' fullfile(fatDir,subject, age, 'preprocessed_aligned','asegWithVentricles_edited.nii.gz'),...
                    ' ' strcat(subject,'_',age) ' rh rh.sphere.reg $FREESURFER_HOME/average/rh.curvature.buckner40.filled.desikan_killiany.2010-03-25.gcs rh.aparc.reinstalled.annot'];
                system(cmd_str);
                
                cmd_str=['mris_ca_label -sdir ' fsdir ' -aseg ' fullfile(fatDir,subject, age, 'preprocessed_aligned','asegWithVentricles_edited.nii.gz'),...
                    ' ' strcat(subject,'_',age) ' lh lh.sphere.reg $FREESURFER_HOME/average/lh.curvature.buckner40.filled.desikan_killiany.2010-03-25.gcs lh.aparc.reinstalled.annot'];
                system(cmd_str);
                
                cmd_str=['mri_label2vol --sd ' fsdir ' --subject ' strcat(subject,'_',age) ' --hemi rh --annot aparc.reinstalled --proj frac -1 0 .1 --fillthresh .1',...
                    ' --o ' fullfile(ROIdir,'rh.fsROIs.nii.gz') ' --identity --temp ' fullfile(fatDir, subject, age, 'preprocessed_aligned','asegWithVentricles_edited.nii.gz')];
                system(cmd_str);
                
                cmd_str=['mri_label2vol --sd ' fsdir ' --subject ' strcat(subject,'_',age) ' --hemi lh --annot aparc.reinstalled --proj frac -1 0 .1 --fillthresh .1',...
                    ' --o ' fullfile(ROIdir,'lh.fsROIs.nii.gz') ' --identity --temp ' fullfile(fatDir,subject, age, 'preprocessed_aligned','asegWithVentricles_edited.nii.gz')];
                system(cmd_str);
                
                cmd_str=['cp ' fullfile(babyAFQRoiDir, 'VOF_box_L.mat') ' ' fullfile(ROIdir, 'VOF_box_L.mat')];
                system(cmd_str);
                
                load(fullfile(fatDir, subject, age, 'preprocessed_aligned','landmarksForAcpcTransform.mat'));
                t2image=fullfile(fatDir, subject, age, 'preprocessed_aligned','t2_biascorr.nii.gz');
                roiName=fsROIs2maskACPC(ROIdir,Landmarks, t2image);
                out_fg=fatSegmentConnectomeMRtrix3(fatDir, ROIdir, sessid{s}, runName{r}, strcat(fgName,'.mat'))
                fatDtiRoi2Nii(fatDir, sessid{s}, runName{r}, [])
                cmd_str=['mv ' ROIdir ' ' fullfile(fatDir, sessid{s}, runName{r},'dti94trilin','adultAFQROIs')];
                system(cmd_str);
            end
        end
        
        %9) Optional: Clean Connectome with AFQ
        if cleanConnectome > 0
            if useBabyAFQ>0
                
                fgNameBaby=strcat(fgNameBaby,'_classified_withBabyAFQ');
                out_fg=fatCleanConnectomeMRtrix3(fatDir, sessid{s}, runName{r}, strcat(fgNameBaby,'.mat'))
                fgNameBaby=strcat(fgNameBaby,'_clean');
            end
            
            if useAdultAFQ>0
                fgName=strcat(fgName,'_classified');
                
                out_fg=fatCleanConnectomeMRtrix3(fatDir, sessid{s}, runName{r}, strcat(fgName,'.mat'))
                fgName=strcat(fgName,'_clean');
            end
            
        end
        
        
        %10 Optional: Generate a few plots for quality assurance
        fgNameBaby='WholeBrainFG_classified_withBabyAFQ_clean'
        fgName='WholeBrainFG_classified_clean'
        
       % colors=load('/home/grotheer/babybrains/mri/code/babyAFQ/colors.txt')
        colorsBaby=load('/share/kalanit/biac2/kgs/projects/babybrains/mri/code/babyAFQ/colorsBaby.txt')
        colorsAdult=load('/share/kalanit/biac2/kgs/projects/babybrains/mri/code/babyAFQ/colorsAdult.txt')
        if useBabyAFQ>0
            colors=colorsBaby;
            if generatePlots >0
                %cmd_str=['rm -r ' fullfile(fatDir, sessid{s}, runName{r}, 'dti94trilin/fibers/afq/image')]
                %system(cmd_str);
                tract_names={'TR' 'TR' 'CS' 'CS' 'CC' 'CC' 'CH' 'CH',...
                    'FMa' 'FMi' 'IFOF' 'IFOF' 'ILF' 'ILF' 'SLF' 'SLF',...
                    'UCI' 'UCI' 'AF' 'AF' 'MdLF' 'MdLF' 'VOF' 'VOF' 'pAF' 'pAF',...
                    'pAF_VOT' 'pAF_VOT' 'pAF_sum' 'pAF_sum'}
                
                for foi=[1:26]
                    if rem(foi,2)==0
                        hem='rh'
                        h=2;
                        color=colors(foi,:)
                    else
                        hem='lh'
                        h=1;
                        color=colors(foi+1,:)
                    end
                    
                    if strcmp(tract_names{foi},'TR')
                        ROIs= {'ATR_roi1_L.mat',  'ATR_roi2_L.mat', 'ATR_roi3_L.mat'; 'ATR_roi1_R.mat', 'ATR_roi2_R.mat', 'ATR_roi3_R.mat'};
                    elseif strcmp(tract_names{foi},'CS')
                        ROIs={'CST_roi1_L.mat', 'CST_roi2_L.mat'; 'CST_roi1_R.mat',  'CST_roi2_R.mat'};
                    elseif strcmp(tract_names{foi},'CC')
                        ROIs={'CGC_roi1_L.mat', 'CGC_roi2_L.mat'; 'CGC_roi1_R.mat', 'CGC_roi2_R.mat'};
                    elseif strcmp(tract_names{foi},'CH')
                        ROIs={'HCC_roi1_L.mat', 'HCC_roi2_L.mat'; 'HCC_roi1_R.mat', 'HCC_roi2_R.mat'};
                    elseif strcmp(tract_names{foi},'FMa')
                        ROIs={'FP_R.mat', 'FP_L.mat'; 'FP_R.mat', 'FP_L.mat'; };
                    elseif strcmp(tract_names{foi},'FMi')
                        ROIs={'FA_R.mat', 'FA_L.mat'; 'FA_R.mat', 'FA_L.mat'};
                    elseif strcmp(tract_names{foi},'IFOF')
                        ROIs={'IFO_roi1_L.mat', 'IFO_roi2_L.mat', 'IFO_roi3_L.mat' ; 'IFO_roi1_R.mat', 'IFO_roi2_R.mat', 'IFO_roi3_R.mat'};
                    elseif strcmp(tract_names{foi},'ILF')
                        ROIs={'ILF_roi1_L.mat', 'ILF_roi2_L.mat'; 'ILF_roi1_R.mat', 'ILF_roi2_R.mat'};
                    elseif strcmp(tract_names{foi},'SLF')
                        ROIs={'SLF_roi1_L.mat', 'SLF_roi2_L.mat'; 'SLF_roi1_R.mat', 'SLF_roi2_R.mat'};
                    elseif strcmp(tract_names{foi},'UCI')
                        ROIs={ 'UNC_roi1_L.mat', 'UNC_roi2_L.mat', 'UNC_roi3_L.mat' ; 'UNC_roi1_R.mat', 'UNC_roi2_R.mat', 'UNC_roi3_R.mat'};
                    elseif strcmp(tract_names{foi},'AF')
                        ROIs={ 'SLF_roi1_L.mat', 'SLFt_roi2_L.mat', 'SLFt_roi3_L.mat'; 'SLF_roi1_R.mat', 'SLFt_roi2_R.mat', 'SLFt_roi3_R.mat'};
                    elseif strcmp(tract_names{foi},'MdLF')
                        ROIs={ 'MdLF_roi1_L.mat', 'ILF_roi2_L.mat'; 'MdLF_roi1_R.mat','ILF_roi2_R.mat'};
                    else ROIs=[];
                    end
                    
                    %outname=strcat(tract_names{foi},'_',subject,'_',age,'_',fgName)
                    outname=strcat(hem,'_',tract_names{foi},'_',fgNameBaby,'_withROIs')
                    roiDir='babyAFQROIs';
                    if isempty(ROIs)
                        fatRenderFibersWholeConnectome(fatDir, sessid{s}, runName{r}, strcat(fgNameBaby,'.mat'), foi,t1_name, hem, outname,color)
                    else
                        fatRenderFibersWholeConnectome(fatDir, sessid{s}, runName{r}, strcat(fgNameBaby,'.mat'), foi,t1_name, hem, outname, color, roiDir, ROIs(h,:))
                    end
                end
                close all;
            end
        end
        
        
        if useAdultAFQ>0
            colors=colorsAdult;
            if generatePlots >0
                tract_names={'TR' 'TR' 'CS' 'CS' 'CC' 'CC' 'CH' 'CH',...
                    'FMa' 'FMi' 'IFOF' 'IFOF' 'ILF' 'ILF' 'SLF' 'SLF',...
                    'UCI' 'UCI' 'AF' 'AF' 'VOF' 'VOF' 'pAF' 'pAF',...
                    'pAF_VOT' 'pAF_VOT' 'pAF_sum' 'pAF_sum'}
                
                for foi=1:24%1:24
                    if rem(foi,2)==0
                        hem='rh'
                        h=2;
                        color=colors(foi-1,:)
                    else
                        hem='lh'
                        h=1;
                        color=colors(foi,:)
                    end
                    
                    if strcmp(tract_names{foi},'TR')
                        ROIs= {'ATR_roi1_L.mat',  'ATR_roi2_L.mat'; 'ATR_roi1_R.mat', 'ATR_roi2_R.mat'};
                    elseif strcmp(tract_names{foi},'CS')
                        ROIs={'CST_roi1_L.mat', 'CST_roi2_L.mat'; 'CST_roi1_R.mat',  'CST_roi2_R.mat'};
                    elseif strcmp(tract_names{foi},'CC')
                        ROIs={'CGC_roi1_L.mat', 'CGC_roi2_L.mat'; 'CGC_roi1_R.mat', 'CGC_roi2_R.mat'};
                    elseif strcmp(tract_names{foi},'CH')
                        ROIs={'HCC_roi1_L.mat', 'HCC_roi2_L.mat'; 'HCC_roi1_R.mat', 'HCC_roi2_R.mat'};
                    elseif strcmp(tract_names{foi},'FMa')
                        ROIs={'FP_R.mat', 'FP_L.mat'; 'FP_R.mat', 'FP_L.mat'; };
                    elseif strcmp(tract_names{foi},'FMi')
                        ROIs={'FA_R.mat', 'FA_L.mat'; 'FA_R.mat', 'FA_L.mat'};
                    elseif strcmp(tract_names{foi},'IFOF')
                        ROIs={'IFO_roi1_L.mat', 'IFO_roi2_L.mat'; 'IFO_roi1_R.mat', 'IFO_roi2_R.mat'};
                    elseif strcmp(tract_names{foi},'ILF')
                        ROIs={'ILF_roi1_L.mat', 'ILF_roi2_L.mat'; 'ILF_roi1_R.mat', 'ILF_roi2_R.mat'};
                    elseif strcmp(tract_names{foi},'SLF')
                        ROIs={'SLF_roi1_L.mat', 'SLF_roi2_L.mat'; 'SLF_roi1_R.mat', 'SLF_roi2_R.mat'};
                    elseif strcmp(tract_names{foi},'UCI')
                        ROIs={ 'UNC_roi1_L.mat', 'UNC_roi2_L.mat'; 'UNC_roi1_R.mat', 'UNC_roi2_R.mat'};
                    elseif strcmp(tract_names{foi},'AF')
                        ROIs={ 'SLF_roi1_L.mat', 'SLFt_roi2_L.mat'; 'SLF_roi1_R.mat','SLFt_roi2_R.mat'};
                    else ROIs=[];
                    end
                    
                    %outname=strcat(tract_names{foi},'_',subject,'_',age,'_',fgName)
                    outname=strcat(hem,'_',tract_names{foi},'_',fgName,'_withROIs')
                    roiDir='adultAFQROIs';
                    if isempty(ROIs)
                        fatRenderFibersWholeConnectome(fatDir, sessid{s}, runName{r}, strcat(fgName,'.mat'), foi,t1_name, hem, outname,color)
                    else
                        fatRenderFibersWholeConnectome(fatDir, sessid{s}, runName{r}, strcat(fgName,'.mat'), foi,t1_name, hem, outname, color,roiDir, ROIs(h,:))
                    end
                end
                close all;
            end
        end
        
        
        if useAdultAFQ>0
            colors=colorsAdult;
            if generatePlots >0
                tract_names={'TR' 'TR' 'CS' 'CS' 'CC' 'CC' 'CH' 'CH',...
                    'FMa' 'FMi' 'IFOF' 'IFOF' 'ILF' 'ILF' 'SLF' 'SLF',...
                    'UCI' 'UCI' 'AF' 'AF' 'VOF' 'VOF' 'pAF' 'pAF',...
                    'pAF_VOT' 'pAF_VOT' 'pAF_sum' 'pAF_sum'}
                
                for foi=1:24
                    if rem(foi,2)==0
                        hem='rh'
                        h=2;
                        color=colors(foi-1,:)
                    else
                        hem='lh'
                        h=1;
                        color=colors(foi,:)
                    end
                    %outname=strcat(tract_names{foi},'_',subject,'_',age,'_',fgName)
                    outname=strcat(hem,'_',tract_names{foi},'_',fgName)
                    
                    fatRenderFibersWholeConnectome(fatDir, sessid{s}, runName{r}, strcat(fgName,'.mat'), foi,t1_name, hem,outname,color)
                end
            end
        end
        
        if useBabyAFQ>0
            colors=colorsBaby;
            if generatePlots >0
                tract_names={'TR' 'TR' 'CS' 'CS' 'CC' 'CC' 'CH' 'CH',...
                    'FMa' 'FMi' 'IFOF' 'IFOF' 'ILF' 'ILF' 'SLF' 'SLF',...
                    'UCI' 'UCI' 'AF' 'AF' 'MdLF' 'MdLF' 'VOF' 'VOF' 'pAF' 'pAF',...
                    'pAF_VOT' 'pAF_VOT' 'pAF_sum' 'pAF_sum'}
                for foi=1:26
                    if rem(foi,2)==0
                        hem='rh'
                        h=2;
                        color=colors(foi,:)
                    else
                        hem='lh'
                        h=1;
                        color=colors(foi+1,:)
                    end
                    
                    %outname=strcat(tract_names{foi},'_',subject,'_',age,'_',fgName)
                    outname=strcat(hem,'_',tract_names{foi},'_',fgNameBaby)
                    
                    fatRenderFibersWholeConnectome(fatDir, sessid{s}, runName{r}, strcat(fgNameBaby,'.mat'), foi,t1_name, hem,outname,color)
                end
            end
        end
    end
end


 