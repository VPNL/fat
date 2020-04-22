
%Diffusion tool combine Vistasoft, MRtrix, LiFE and AFQ to produce functional defined fasciculus.
%It requires these toolboxs installed, and also required the fROI defined by vistasoft.
%In oder for this code to run, you will likely need to upgrade several
%software packages, specifically this code was tested using: MRtrix RC3,
%fslv6.0.1, ANTs from 2017, AFQ from 2019, cuda9.1, and freesurferv6.0.0. Please note that
%running older version will lead to subtly inoptimal results. I made a few
%suggestions which outputs to ckeck for quality assurance. You can do sou
%using mrview.
%The pipeline is orgnized as bellow and was written by Mareike Grotheer in
%2019

% The following parameters need to be adjusted to fit your system
fatDir=fullfile('/sni-storage/kalanit/biac2/kgs/projects/NFA_tasks/data_mrAuto');
anatDir_system =fullfile('/biac2/kgs/3Danat');
anatDir =('/sni-storage/kalanit/biac2/kgs/3Danat');
fsDir=('/sni-storage/kalanit/biac2/kgs/3Danat/FreesurferSegmentations');

sessid={'01_sc_dti_mrTrix3_080917' '02_at_dti_mrTrix3_080517' '03_as_dti_mrTrix3_083016'...
    '04_kg_dti_mrTrix3_101014' '05_mg_dti_mrTrix3_071217' '06_jg_dti_mrTrix3_083016'...
    '07_bj_dti_mrTrix3_081117' '08_sg_dti_mrTrix3_081417' '10_em_dti_mrTrix3_080817'...
    '12_rc_dti_mrTrix3_080717' '13_cb_dti_mrTrix3_081317' '15_mn_dti_mrTrix3_091718'...
    '16_kw_dti_mrTrix3_082117' '17_ad_dti_mrTrix3_081817' '18_nc_dti_mrTrix3_090817'...
    '19_df_dti_mrTrix3_111218' '21_ew_dti_mrTrix3_111618' '22_th_dti_mrTrix3_112718'...
    '23_ek_dti_mrTrix3_113018'  '24_gm_dti_mrTrix3_112818' '25_bl_dti_mrTrix3_120718'...
    '26_mw_dti_mrTrix3_032019' '27_jk_dti_mrTrix3_032019' '28_pe_dti_mrTrix3_040319'...
    '29_ie_dti_mrTrix3_040319' '30_pw_dti_mrTrix3_041219' '31_ks_dti_mrTrix3_041019'...
    '32_mz_dti_mrTrix3_041519' '33_mm_dti_mrTrix3_041619' '34_ans_dti_mrTrix3_041819'}

%anatid={'erica' 'th' 'ek' 'gm' 'ar'}
anatid={'siobhan' 'avt' 'anthony_new_recon_2017'...
    'kalanit_new_recon_2017' 'mareike' 'jesse_new_recon_2017'...
    'brianna' 'swaroop' 'eshed'...
    'richard' 'cody' 'marisa'...
    'kari' 'alexis' 'nathan'...
    'dawn' 'erica' 'th'...
    'ek' 'gm' 'bl'...
    'mw' 'jk' 'pe'...
    'ie' 'pw' 'ks' ...
    'mz' 'mm' 'ans'};

runName={'96dir_run1_noFW'};
t1_name=['t1.nii.gz'];

mrtrixversion=3; %going to a different version will require serious changes to the pipeline
revPhase=1; %the adult data is not using reverse phase encoding correction
doDenoise=1; % denoise the data? Enter 0 or 1
doGibbs=1; % do gibss ringing correction? Enter 0 or 1
doEddy=1; % do eddy correction? Enter 0 or 1
doBiasCorr=1; % do bias correction? Enter 0 or 1
doRicn=1; % ricn denoise is not yet implemented for revPhase data

lmax='auto'; %to date MRtrix automatically choose appropricate lmax when using dhollander
multishell=0; % we only have 1 shell
track_tool='freesurfer'; % chose between freesurfer or fsl. Fsl does not work well though.
algo='IFOD1'; % several options, IFOD2 is the most modern.
background=0; % run multible MRtrix comments at the same time. 1 will not work.
verbose=1; % print output to window
clobber=1; %overwrite existing files
seeding='seed_gmwmi'; % seeding mechanisms, this uses ACT
nSeeds=500000; % how many seeds
ET=0; % do you want to use ensemble tractography? Enter 1 or 0
runLife=0; % do you want to run life?
classifyConnectome = 1; % do you want to classify the connectome with AFQ? Enter 1 or 0
cleanConnectome = 1; % do you want to clean the connectome with AFQ? Enter 1 or 0
generatePlots =1; % do you want to generates some simple plots of fiber tracts for quality assurance? Enter 1 or 0
roi='lh_OTS_from_fsaverage_manual'; % will be used as masked for seeding. Use [] if you don't want a mask.

for s=6
    for r=1:length(runName)
        % %The following parameters need to be adjusted to fit your system
        anatDir_system_current=fullfile(anatDir_system, anatid{s});
        anatDir_system_output=fullfile('/biac2/kgs/projects/NFA_tasks/data_mrAuto/', sessid{s}, runName{r}, 't1');
        
        %here we go
        %1) Organize the data
        fatPrepareMRtrix3(fatDir,sessid{s}, anatDir_system_current, anatDir_system_output, r)
        cmdstr=['cp ' fullfile(fatDir, 'dwiSlSpec.txt') ' ' fullfile(fatDir, sessid{s}, runName{r}, 'dwiSlSpec.txt')];
        system(cmdstr)
        cmdstr=['cp ' fullfile(fatDir, 'run1_Xflip_corrected.bvec') ' ' fullfile(fatDir, sessid{s}, runName{r}, 'raw/run1.bvec')];
        system(cmdstr)
        
        %2) Preprocess the data using mrTrix3
        %--> After this step check that dwi_processed.nii.gz looks ok
        fatPreProcMRtrix3Nii(fatDir,sessid{s},runName{r},revPhase,doDenoise,doGibbs,doEddy,doBiasCorr,doRicn)
        
        %3) The preprocessing messes with the nifti header, we need to
        % fix this.
        nii=niftiRead(fullfile(fatDir,sessid{s},runName{r},'dwi_processed.nii.gz'));
        nii.phase_dim=2;
        niftiWrite(nii,fullfile(fatDir,sessid{s},runName{r},'dwi_processed.nii.gz'));
        
        %4) Initiate a dt.mat data structure
        % --> After this step, check that t1 and dwi were aligned properly
        [dt6folder, dt6file]=fatCreateDT6(fatDir,sessid(s),runName(r),t1_name,clobber);
        
        %5) Create a good wm mask using FreeSurfer Segmentation
        %--> After this step check that wmMask_from_FreeSurfer.nii.gz in mrtrix folder looks ok
        mkdir(fullfile(fatDir,sessid{s},runName{r},'dti96trilin','mrtrix'));
        fatMakeWMmask(fatDir, anatDir_system, anatid(s), sessid(s),runName{r},t1_name,'wm', 1)
        cmd_str=['mrconvert ' fullfile(anatDir_system, anatid{s},'wm_mask_resliced.nii.gz') ' ' fullfile(fatDir,sessid{s},runName{r},dt6folder.name,'mrtrix','wmMask_from_FreeSurfer.nii.gz')]
        AFQ_mrtrix_cmd(cmd_str,background, verbose,mrtrixversion)
        
        %6) Set up tractography for mrtrix 3
        %--> After this step check that dwi_[...]_wmCSD_lmax_auto.mif looks
        %ok. You probably also want to check the other files in the mrtrix folder, especially:
        %dwi_[...]_ev.mif, dwi_[...]_5tt.mif, dwi_[...]_ev.mif, dwi_[...]_vf.mif and dwi_[...]_voxels.mif
        anatFolder=fullfile(fsDir,anatid{s},'mri');
        files = fat_AFQ_mrtrixInit(dt6file, ...
            fullfile(fatDir,sessid{s},runName{r},dt6folder.name,'mrtrix'),...
            mrtrixversion, ...
            multishell, ... % true/false
            track_tool,... % 'fsl', 'freesurfer'
            1,...
            anatFolder);
        
        %7) Create connectomes
        %--> After this step check that connectome looks ok
        fatMakefsROI(anatDir,anatid{s},sessid{s},1) % first create the ROIs needed for AFQ using freesurfer
        roiPath=fullfile(anatDir,anatid{s},'niftiRois');
        [status, results, out_fg] = fatCreateConnectomeMRtrix3ACT(fullfile(fatDir,sessid{s},runName{r},dt6folder.name),...
            files, ...
            algo, ...
            seeding, ...
            nSeeds, ...
            background, ...
            verbose, ... %verbose
            clobber, ... %clobber
            mrtrixversion, ...
            ET, ...
            roiPath,...
            roi);
        
        %8) Optional: Run LiFE to optimize the ET connectome
        if runLife > 0
            fgname=out_fg;
            out_fg=fatRunLifeMRtrix3(fatDir, sessid{s}, runName{r},fgname,t1_name);
        end
        
        %9) Optional: Run AFQ to classify the fibers
        if classifyConnectome >0
            fatMakefsROI(anatDir,anatid{s},sessid{s},1) % first create the ROIs needed for AFQ using freesurfer
            
            fgName=out_fg;
            out_fg=fatSegmentConnectomeMRtrix3(fatDir, anatDir, anatid(s), sessid{s}, runName{r}, fgName)
        end
        
        10) Optional: Clean Connectome with AFQ
        if cleanConnectome >0
            for r=1:length(runName)
                %fgName=out_fg;
                fgName=fullfile('/share/kalanit/biac2/kgs/projects/NFA_tasks/data_mrAuto',sessid{s},'96dir_run1_noFW/dti96trilin/fibers/afq/lh_OTS_from_fsaverage_manual_FG_masked_classified.mat')
                out_fg=fatCleanConnectomeMRtrix3Prediction(fatDir, anatDir, anatid(s), sessid{s}, runName{r}, fgName)
            end
        end
        
        %11) Optional: Generate a few plots for quality assurance
        if generatePlots >0
            for hem=1
                if hem==1
                    hem='lh'
                    foi=[11 13 21 19 27 17];
                else
                    hem='rh'
                    foi=[12 14 16 20 28 22];
                end
                out_fg='lh_OTS_from_fsaverage_manual_FG_masked_classified_clean.mat'
                fatRenderFibersWholeConnectome(fatDir, sessid{s}, runName{r}, out_fg, foi,t1_name, hem)
                %close all;
            end
        end
        
    end
end

