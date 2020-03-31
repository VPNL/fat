%Combines Vistasoft, MRtrix3, LiFE and AFQ to produce whole brain connectomes.
%In order for this code to run, you will likely need to upgrade several
%software packages, specifically this code was tested using: MRtrix RC3,
%fslv6.0.1, ANTs from 2017, AFQ from 2019, cuda9.1, and freesurferv6.0.0. Please note that
%running older version will lead to subtly inoptimal results. I made a few
%suggestions which outputs to ckeck for quality assurance. You can do so
%using mrview.
%The pipeline is orgnized as bellow and was written by Mareike Grotheer in
%2019 and adapted by Emily Kubota in 2020. 


% The following parameters need to be adjusted to fit your system
%% Paths for child subjects 
fatDir=fullfile('/share/kalanit/biac2/kgs/projects/Kids_AcrossYears/dMRI/data');
anatDir_system = fullfile('/share/kalanit/biac2/kgs/anatomy/vistaVol/Kids_AcrossYears');
anatDir = fullfile('/share/kalanit/biac2/kgs/anatomy/vistaVol/Kids_AcrossYears');
fsDir =('/share/kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears');


% Get the sessions to process
[sessid, anatid, fsid] = getSubDirs;

% allocation for ianthe 
sessid = sessid(1:30);
anatid = anatid(1:30);
fsid = fsid(1:30);

%allocation for seele
%sessid = sessid(31:60);
%anatid = anatid(31:60);
%fsid=fsid(31:60);

%allocation for lev
%sessid = sessid(61:110);
%anatid = anatid(61:110);
%fsid = fsid(61:110);

runName = {'96dir_run1'};
t1_name = 't1.nii.gz';

%% parameters

mrtrixversion=3; %going to a different version will require serious changes to the pipeline
revPhase=0; %the longitudinal data is not using reverse phase encoding correction
doDenoise=1; % denoise the data? Enter 0 or 1
doGibbs=1; % do gibss ringing correction? Enter 0 or 1
doEddy=1; % do eddy correction? Enter 0 or 1
doBiasCorr=1; % do bias correction? Enter 0 or 1
doRicn=1; % ricn denoise is not yet implemented for revPhase data

%lmax=8; %to date MRtrix automatically choose appropricate lmax when using dhollander
multishell=0; % we only have 1 shell
track_tool='freesurfer'; % chose between freesurfer or fsl. Fsl does not work well though.
algo='IFOD1'; % several options, IFOD2 is the most modern.
background=0; % run multible MRtrix comments at the same time. 1 will not work.
verbose=1; % print output to window
clobber=1; %overwrite existing files
seeding='seed_gmwmi'; % seeding mechanisms, this uses ACT
nSeeds=500000; % how many seeds
ET=1; % do you want to use ensemble tractography?
runLife=1; % do you want to run life?
classifyConnectome = 1; % do you want to classify the connectome with AFQ? Enter 1 or 0
cleanConnectome =1; % do you want to clean the connectome with AFQ? Enter 1 or 0
generatePlots= 1; % do you want to generates some simple plots of fiber tracts for quality assurance? Enter 1 or 0
roi=[]; % will be used as masked for seeding. Use [] if you don't want a mask.

%% Main preprocessing routine
for s=1:length(sessid)
    tic
    for r=1:length(runName)
        % Make a softlink to the anatomy directoty 
         cd(fullfile(fatDir,sessid{s},runName{r}))
        lnsCommand = ['ln -s ',fullfile(anatDir,anatid{s}) ' t1'];
         system(lnsCommand)
         
         % organize the data
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
        fatMakeWMmask(fatDir, anatDir_system, anatid(s), sessid(s), fsid{s}, runName{r},t1_name,'wm', 1)
        cmd_str=['mrconvert ' fullfile(fatDir, sessid{s},runName{r},'wm_mask_resliced.nii.gz') ' ' fullfile(fatDir,sessid{s},runName{r},dt6folder.name,'mrtrix','wmMask_from_FreeSurfer.nii.gz')]
        AFQ_mrtrix_cmd(cmd_str,background, verbose,mrtrixversion)
        
        %6) Set up tractography for mrtrix 3
        %--> After this step check that dwi_[...]_wmCSD_lmax_auto.mif looks
        %ok. You probably also want to check the other files in the mrtrix folder, especially:
        %dwi_[...]_ev.mif, dwi_[...]_5tt.mif, dwi_[...]_ev.mif, dwi_[...]_vf.mif and dwi_[...]_voxels.mif
        anatFolder=fullfile(fsDir,fsid{s},'mri');
        files = fat_AFQ_mrtrixInit(dt6file, ...
            fullfile(fatDir,sessid{s},runName{r},dt6folder.name,'mrtrix'),...
            mrtrixversion, ...
            multishell, ... % true/false
            track_tool,... % 'fsl', 'freesurfer'
            1,...
            anatFolder);
        
        %7) Create connectomes
        %--> After this step check that connectome looks ok
        fatMakefsROI(anatDir,anatid{s},fsid{s}, sessid{s},1) % first create the ROIs needed for AFQ using freesurfer
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
        
        %8) Run LiFE to optimize the ET connectome
        if runLife > 0
            out_fg=fatRunLifeMRtrix3(fatDir, sessid{s}, runName{r},'WholeBrainFGRadSe.mat',t1_name);
        end
        
        %9) Run AFQ to classify the fibers (both WholeBrain + LiFE
        %connectomes)
        if classifyConnectome >0
            fatMakefsROI(anatDir,anatid{s},fsid{s},sessid{s},1) % first create the ROIs needed for AFQ using freesurfer
            fatSegmentConnectomeMRtrix3(fatDir, anatDir, anatid(s), sessid{s}, runName{r}, 'WholeBrainFGRadSe.mat')
            fatSegmentConnectomeMRtrix3(fatDir, anatDir, anatid(s), sessid{s}, runName{r}, 'WholeBrainFG_LiFE.mat')
        end
        
        %10) Optional: Clean Connectome with AFQ
        if cleanConnectome >0 
            for r=1:length(runName)
               fatCleanConnectomeMRtrix3(fatDir, anatDir, anatid(s), sessid{s}, runName{r}, 'WholeBrainFGRadSe_classified.mat')
               fatCleanConnectomeMRtrix3(fatDir,anatDir,anatid(s),sessid{s},runName{r},'WholeBrainFG_LiFE_classified.mat')
            end
        end
        
        
        %11) Optional: Generate a few plots for quality assurance
        if generatePlots >0
            for hem=1
                if hem==1
                    hem='lh'
                    foi=[11 13 15 19 27 21];
                else
                    hem='rh'
                    foi=[12 14 16 20 28 22];
                end
                fatRenderFibersWholeConnectome(fatDir, sessid{s}, runName{r}, 'WholeBrainFGRadSe_classified_cleaner.mat', foi,t1_name, hem,500)
                fatRenderFibersWholeConnectome(fatDir, sessid{s}, runName{r}, 'WholeBrainFG_LiFE_unclassified.mat', 1,t1_name, hem,12000)

            end
        end
        
    end
    toc
end

