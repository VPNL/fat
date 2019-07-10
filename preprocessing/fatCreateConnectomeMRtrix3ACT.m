
function [status, results, fgFileNameWithDir2] = fatCreateConnectomeMRtrix3ACT(tractPath, files, roi, algo, seeding, nSeeds, background, verbose, clobber, mrtrixVersion, ET)

if notDefined('algo'), algo = 'IFOD2'; end
if notDefined('seeding'), seeding = 'seed_gmwmi'; end
if notDefined('background'), background = 'false'; end
if notDefined('verbose'), verbose = 'true'; end
if notDefined('clobber'), clobber = 'false'; end
if notDefined('mrtrixVersion'), mrtrixVersion = 3; end
if notDefined('ET'), ET = 0; end

if ET ==1
    voxelSize = 2;
    stepSize  = 0.1 * voxelSize;  % for iFOD1
    dfAng = (90 * stepSize)/voxelSize; % 45 default
    angleValues = [0.25*dfAng, 0.5*dfAng, ...
                      dfAng, ...
                      1.25*dfAng, 1.5*dfAng];
else
    angleValues = 13.5;
end
                  
    csdFile  = files.csd;
    file5tt = files.tt5;
    gmwmi =files.gmwmi;
    
    cmd_str = ['mkdir ' (fullfile(tractPath,'fibers'))];
    system(cmd_str);
    
    tck_file = fullfile(tractPath, '/fibers/WholeBrainFG.tck');

    numconcatenate = [];
     for na=1:length(angleValues)
        fgFileName{na}=['Fibers_angle' strrep(num2str(angleValues(na)),'.','p') '.tck'];
        fgFileNameWithDir{na}=fullfile(tractPath, '/fibers/', fgFileName{na});
        fgFileNameWithDir2=fullfile(tractPath, '/fibers/WholeBrainFG.mat');
        
        if strcmp(seeding,'seed_gmwmi')>0
            
        cmd_str = ['tckgen ' csdFile ' ' ...
            '-algo ' algo ' ' ...
            '-backtrack -crop_at_gmwmi -info ' ...
            '-seed_gmwmi ' gmwmi ' ' ...
            '-act ' file5tt ' ' ...
            '-angle ' num2str(ET_angleValues(na)) ' ' ...
            '-select ' nSeeeds ' ' ...
            fgFileNameWithDir{na} ' ' ...
            '-force'];
        
        elseif strcmp(seeding,'seed_grid_per_voxel')>0
            
        cmd_str = ['tckgen ' csdFile ' ' ...
            '-algo ' algo ' ' ...
            '-backtrack -crop_at_gmwmi -info ' ...
            '-seed_grid_per_voxel ' gmwmi ' ' num2str(nSeeds) ' '...
            '-act ' file5tt ' ' ...
            '-angle ' num2str(angleValues) ' ' ...
            fgFileNameWithDir{na} ' ' ...
            '-force'];
        end
   
        % Run it, if the file is not there (this is for debugging)
        if ~exist(fgFileNameWithDir{na},'file') || strcmp(clobber,'true')>0;
            [status,results] = AFQ_mrtrix_cmd(cmd_str, background, verbose,mrtrixVersion);
        end
        numconcatenate = [numconcatenate, nSeeds];
     end
    fg = et_concatenateconnectomes(fgFileNameWithDir, tck_file, numconcatenate, 'tck'); 
    dtiWriteFiberGroup(fg, fgFileNameWithDir2);

end