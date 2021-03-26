
function [status, results, fgFileNameWithDir2] = babyFatCreateConnectomeMRtrix3ACT(tractPath, files, algo, seeding, nSeeds, background, verbose, clobber, mrtrixVersion, ET, cutoff, csdFile, roipath,roi)

if notDefined('algo'), algo = 'IFOD2'; end
if notDefined('seeding'), seeding = 'seed_gmwmi'; end
if notDefined('background'), background = 'false'; end
if notDefined('verbose'), verbose = 'true'; end
if notDefined('clobber'), clobber = 'false'; end
if notDefined('mrtrixVersion'), mrtrixVersion = 3; end
if notDefined('ET'), ET = 0; end
if notDefined('multishell'); end
if notDefined('roipath'); roipath=[]; end
if notDefined('roi'); roi=[]; end
if notDefined('cutoff'); cutoff=0.05; end
if notDefined('csdFile'); csdFile=files.wmCsd; end

if ET ==1
    voxelSize = 2;
    stepSize  = 0.1 * voxelSize;  % for iFOD1
    dfAng = (100 * stepSize)/voxelSize; % 45 default
    angleValues = [0.25*dfAng, 0.5*dfAng, ...
        dfAng, ...
        1.25*dfAng, 1.5*dfAng];
else
    angleValues = 15;
end

%if multishell==0
%    csdFile  = files.csd;
%else

%end

file5tt = files.tt5;
gmwmi =files.gmwmi;
wmMask =files.wmMask_dilated;

% Create the seed with a masked 5tt2gmwmi
% if ~isempty(roi)
%     gmwmi = fullfile(tractPath,'mrtrix', strcat('5tt_gmwmi_',roi,'.mif'));
%     mask= fullfile(roipath,strcat(roi,'.nii.gz'));
%     cmd_str   = ['5tt2gmwmi -force -mask_in  ' mask ' ' file5tt  ' ' gmwmi ];
%     AFQ_mrtrix_cmd(cmd_str, background, verbose,mrtrixVersion) 
% else
%     cmd_str   = ['5tt2gmwmi -force ' file5tt  ' ' gmwmi ];
%     AFQ_mrtrix_cmd(cmd_str, background, verbose,mrtrixVersion) 
% end

csdName=strsplit(csdFile,'/');
csdName=strsplit(csdName{size(csdName,2)},'_');
csdName=strsplit(strcat(csdName{size(csdName,2)-3:size(csdName,2)}),'.');
csdName=csdName{1};
cmd_str = ['mkdir ' (fullfile(tractPath,'fibers'))];
system(cmd_str);

numconcatenate = [];
for na=1:length(angleValues)
    if ET==1
    if isempty(roi)
    tck_file = fullfile(tractPath,'fibers',strcat('WholeBrainFG_ET_',csdName,'_',seeding,'.tck'));
    fgFileName{na}=[strcat('Fibers_ET_',csdName,'_',seeding,'_angle_') strrep(num2str(angleValues(na)),'.','p') '.tck'];
    fgFileNameWithDir{na}=fullfile(tractPath, '/fibers/', fgFileName{na});
    fgFileNameWithDir2=fullfile(tractPath,'fibers',strcat('WholeBrainFG_ET_',csdName,'_',seeding,'.mat'));
    else
    tck_file = fullfile(tractPath, '/fibers/',strcat(roi,'_FG_masked.tck'));
    fgFileName{na}=[strcat(roi,'_Fibers_angle') strrep(num2str(angleValues(na)),'.','p') '.tck'];
    fgFileNameWithDir{na}=fullfile(tractPath, '/fibers/', fgFileName{na});
    fgFileNameWithDir2=fullfile(tractPath, '/fibers/',strcat(roi,'_FG_masked.mat'));
    end   
    else
    if isempty(roi)
    tck_file = fullfile(tractPath,'fibers',strcat('WholeBrainFG.tck'));
    fgFileName{na}=[strcat('Fibers_',csdName,'_',seeding,'_angle_') strrep(num2str(angleValues(na)),'.','p') '.tck'];
    fgFileNameWithDir{na}=tck_file;
    fgFileNameWithDir2=fullfile(tractPath,'fibers',strcat('WholeBrainFG.mat'));
    else
    tck_file = fullfile(tractPath, '/fibers/',strcat(roi,'_FG_masked.tck'));
    fgFileName{na}=[strcat(roi,'_Fibers_angle') strrep(num2str(angleValues(na)),'.','p') '.tck'];
    fgFileNameWithDir{na}=tckfile;
    fgFileNameWithDir2=fullfile(tractPath, '/fibers/',strcat(roi,'_FG_masked.mat'));
    end     
    end    
        
    if strcmp(seeding,'seed_gmwmi')>0
        
        cmd_str = ['tckgen ' csdFile ' ' ...
            '-algo ' algo ' ' ...
            '-backtrack -crop_at_gmwmi -info ' ...
            '-seed_gmwmi ' gmwmi ' ' ...
            '-act ' file5tt ' ' ...
            '-angle ' num2str(angleValues(na)) ' ' ...
            '-select ' num2str(nSeeds) ' ' ...
            fgFileNameWithDir{na} ' ' ...
            '-cutoff ' num2str(cutoff) ' '...
            '-force'];
        
    elseif strcmp(seeding,'seed_wmMask')>0
        
        cmd_str = ['tckgen ' csdFile ' ' ...
            '-algo ' algo ' ' ...
            '-info ' ...
            '-seed_image ' wmMask ' ' ...
            '-angle ' num2str(angleValues(na)) ' ' ...
            '-select ' num2str(nSeeds) ' ' ...
            fgFileNameWithDir{na} ' ' ...
            '-cutoff ' num2str(cutoff) ' '...
            '-force'];
        
    elseif strcmp(seeding,'seed_grid_per_voxel')>0
        
        cmd_str = ['tckgen ' csdFile ' ' ...
            '-algo ' algo ' ' ...
            '-backtrack -crop_at_gmwmi -info ' ...
            '-seed_grid_per_voxel ' gmwmi ' ' num2str(nSeeds) ' '...
            '-act ' file5tt ' ' ...
            '-angle ' num2str(angleValues(na)) ' ' ...
            fgFileNameWithDir{na} ' ' ...
            '-cutoff ' num2str(cutoff) ' '...
            '-force'];
    end
    
    % Run it, if the file is not there (this is for debugging)
    %if ~exist(fgFileNameWithDir{na},'file') || strcmp(clobber,'true')>0;
        [status,results] = AFQ_mrtrix_cmd(cmd_str, background, verbose,mrtrixVersion);
    %end
    %   numconcatenate = [numconcatenate, nSeeds];
end

if ET==1
fg = fat_et_concatenateconnectomes(fgFileNameWithDir, tck_file, [], 'tck');
else
fg=fgRead(fgFileNameWithDir{na});
end

dtiWriteFiberGroup(fg, fgFileNameWithDir2);
end