 
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
%fatDir=fullfile('/share/kalanit/biac2/kgs/projects/babybrains/mri/DWI/');
%fatDir=fullfile('/home/grotheer/babybrains/pilot/testbaby_6mo_g_DTI/');
fatDir=fullfile('/home/grotheer/babybrains/pilot/Dawn_DTI_pilot/');
%fatDir=fullfile('/home/grotheer/babybrains/pilot/alex_dwi_new/');

anatDir_system =fullfile('/biac2/kgs/3Danat');
anatDir =('/sni-storage/kalanit/biac2/kgs/3Danat');
fsDir=('/sni-storage/kalanit/biac2/kgs/3Danat/FreesurferSegmentations');

sessid={'Mareike_Test6'}

anatid={'dawn'};

runName={'94dir_run1'};
t1_name=['t1.nii.gz'];

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
clobber=0; %overwrite existing files
seeding='seed_gmwmi'; % seeding mechanisms, this uses ACT
nSeeds=500000; % how many seeds
ET=0; % do you want to use ensemble tractography? Enter 1 or 0
runLife=1; % do you want to run life?
classifyConnectome = 1; % do you want to classify the connectome with AFQ? Enter 1 or 0
cleanConnectome = 1; % do you want to clean the connectome with AFQ? Enter 1 or 0
generatePlots =1; % do you want to generates some simple plots of fiber tracts for quality assurance? Enter 1 or 0


for s=1
    for r=1:length(runName)
        %Ok, here we go
        
        %1) Prepare fat data and directory structure
        
        %The following parameters need to be adjusted to fit your system
        anatDir_system_current=fullfile(anatDir_system, anatid{s});
        anatDir_system_output=fullfile('/biac2/kgs/projects/NFA_tasks/data_mrAuto/', sessid{s}, runName{r}, 't1');
        babyFatPrepareMRtrix3(fatDir,sessid{s}, anatDir_system_current, anatDir_system_output, runName{r})

        %2) Preprocess the data using mrTrix3
        %--> After this step check that dwi_processed.nii.gz looks ok
        cd(fullfile(fatDir,sessid{s},runName{r}))
        !echo '0 -1 0 0.0792' > acq_params.txt
        !echo '0 1 0 0.0792' >> acq_params.txt
        cmd_str=['cp ' fullfile(fatDir,'index.txt') ' ' fullfile(fatDir,sessid{s},runName{r},'index.txt')]
        system(cmd_str)
        
        cmd_str=['cp ' fullfile(fatDir,'dwiMultiShell_correctedByX.bvecs') ' ' fullfile(fatDir,sessid{s},runName{r},'raw','dwiMultiShell.bvec')]
        system(cmd_str)
        
        fatPreProcMRtrix3Nii(fatDir,sessid{s},runName{r},revPhase,doDenoise,doGibbs,doEddy,doBiasCorr,doRicn)
        
        %3) We need to make a few changes to the nifti for it to work with
        %the rest of the pipeline
        !mrconvert dwi_processed.nii.gz -fslgrad dwi_processed.bvec dwi_processed.bval dwi_processed.nii.gz -stride -1,2,3,4 -export_grad_fsl dwi_processed.bvec dwi_processed.bval -force
        nii=niftiRead(fullfile(fatDir,sessid{s},runName{r},'dwi_processed.nii.gz'));
        nii.phase_dim=2;
        niftiWrite(nii,fullfile(fatDir,sessid{s},runName{r},'dwi_processed.nii.gz'));
        
        %4) Initiate a dt.mat data structure
        % --> After this step, check that t1 and dwi were aligned properly
        [dt6folder, dt6file]=fatCreateDT6(fatDir,sessid(s),runName(r),t1_name,clobber);
        
        %5) Create a good wm mask using FreeSurfer Segmentation
        %--> After this step check that wmMask_from_FreeSurfer.nii.gz in mrtrix folder looks ok
        mkdir(fullfile(fatDir,sessid{s},runName{r},'dti94trilin','mrtrix'));
        fatMakeWMmask(fatDir, anatDir_system, anatid(s), sessid(s),runName{r},t1_name,'wm', 1)
        cmd_str=['mrconvert ' fullfile(anatDir_system, anatid{s},'wm_mask_resliced.nii.gz') ' ' fullfile(fatDir,sessid{s},runName{r},dt6folder.name,'mrtrix','wmMask_from_FreeSurfer.nii.gz')]
        AFQ_mrtrix_cmd(cmd_str,0,1,mrtrixversion)
        
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
            1,... %compute5tt
            anatFolder);
        %include mt normaize
        
        % create new b0 from aligned dwi data
        cmd_str = ['dwiextract ' files.dwi ' - -bzero -grad ' files.b ' -quiet | mrmath - mean ' fullfile(fatDir,sessid{s},runName{r},dt6folder.name,'mrtrix','b0.nii.gz') ' -axis 3 -quiet'];
        [status,results] = AFQ_mrtrix_cmd(cmd_str, background, verbose,mrtrixversion);
        
        %7) Create connectomes
        %--> After this step check that WholeBrainFG.tck looks ok
        [status, results, out_fg] = fatCreateConnectomeMRtrix3ACT(fullfile(fatDir,sessid{s},runName{r},dt6folder.name),...
            files, ...
            algo, ...
            seeding, ...
            nSeeds, ...
            background, ...
            verbose, ... %verbose
            clobber, ... %clobber
            mrtrixversion, ...
            ET)
        
        fgName='WholeBrainFG';
        
        %7) Optional: Run LiFE to optimize the ET connectome
        if runLife > 0
            out_fg=fatRunLifeMRtrix3(fatDir, sessid{s}, runName{r},strcat(fgName,'.mat'));
            fgName=strcat(fgName,'_LiFE');
        end
        
        %8) Optional: Run AFQ to classify the fibers
        if classifyConnectome > 0
            % fatMakefsROI(anatDir,anatid{s},sessid{s},1) % first create the ROIs needed for AFQ using freesurfer
            out_fg=fatSegmentConnectomeMRtrix3(fatDir, anatDir, anatid(s), sessid{s}, runName{r}, strcat(fgName,'.mat'))
            fgName=strcat(fgName,'_classified');
        end
        
        %9) Optional: Clean Connectome with AFQ
        if cleanConnectome > 0
            out_fg=fatCleanConnectomeMRtrix3(fatDir, anatDir, anatid(s), sessid{s}, runName{r}, strcat(fgName,'.mat'))
            fgName=strcat(fgName,'_clean');
        end
        
        %10 Optional: Generate a few plots for quality assurance
        if generatePlots >0
        for hem=1:2
            if hem==1
                hem='lh'
                foi=[11 13 15 19 27 21];
            else
                hem='rh'
                foi=[12 14 16 20 28 22];
            end

            fatRenderFibersWholeConnectome(fatDir, sessid{s}, runName{r}, strcat(fgName,'.mat'), foi,t1_name, hem)
        end
        
        for fiberNum=[1:22 27 28]
            fg=load(fullfile(fatDir,sessid{s},runName{r},'dti94trilin/fibers/afq', strcat(fgName,'.mat')))
            myfg = fg.fg(fiberNum);
            fiberName = [strcat(fgName, '_track_', num2str(fiberNum), '.tck')];
            fpn = fullfile(fatDir,sessid{s},runName{r},'dti94trilin/fibers/afq', fiberName);
            dr_fwWriteMrtrixTck(myfg, fpn)
        end
        end
    end
end

