function  fatRenderFibersWholeConnectome(fatDir, sessid, runName, fgName,foi,t1name,hemi,numfibers,colorMap)
%  fatRenderFibers(fatDir, sessid, runName, fgName, hemi)
% fgName: full name of fg including path and postfix
% foi, a vector to indicate fiber of interest
% hemi, 'rh' or 'lh'
if nargin < 9
    colorMap = [0 0.8 0.8; 1 0.5 1; 0.45 0 0.45; 1 0 0; 1 0.6 0; 0.6 1 0.05]; 
end

[~,fName] = fileparts(fgName);

if strcmp(hemi,'lh')
    cameraView = [-60,10];
    xplane =  [-15, 0, 0];
else strcmp(hemi,'rh')
    cameraView = [60,10];
    xplane =  [15,0,0];
end
zplane = [0, 0, -10];

if nargin < 8 
     numfibers = 50;
end 


% colorMap  = linspecer(length(foi));
% colorMap= jet(length(foi));

% set criteria
maxDist = 4; maxLen = 4;numNodes = 100;M = 'mean';maxIter = 200;count = false;
%numfibers = 50;
        fprintf('Plot fiber %s-%s:%s\n',sessid,runName,fgName);
        
        cd(fullfile(fatDir,sessid,runName))
        subdir=dir('*trilin');
        runDir = fullfile(fatDir,sessid,runName,subdir.name);
        afqDir = fullfile(runDir, 'fibers','afq');
        if ~exist(afqDir, 'dir')
            mkdir(afqDir);
        end
        
        imgDir = fullfile(afqDir,'image');
        if ~exist(imgDir,'dir')
            mkdir(imgDir);
        end
        
        %% Load fg
        fgFile = fullfile(afqDir,fgName);
        if exist(fgFile,'file')
            load(fgFile);
            if exist('fg')
            fg = fg(foi);
            else
            fg = bothfg(foi); 
 
            end
                          for i = 1:length(foi)
                fg(i) = AFQ_removeFiberOutliers(fg(i),maxDist,maxLen,numNodes,M,count,maxIter);
            end
            
         
            % b0 = readFileNifti(fullfile(runDir,'bin','b0.nii.gz'));
            b0 = readFileNifti(fullfile(fatDir,sessid,runName,'t1',t1name));
            fibers = extractfield(fg, 'fibers');
            I =  find(~cellfun(@isempty,fibers));
            
            if isempty(I)==0
            AFQ_RenderFibers(fg(I(1)),'numfibers',numfibers,...
                'color',colorMap(I(1),:),'camera',cameraView);
            
            for j = 2:length(I)
                AFQ_RenderFibers(fg(I(j)),'numfibers',numfibers,...
                    'color',colorMap(I(j),:),'newfig',false)
            end
            
            AFQ_AddImageTo3dPlot(b0,zplane);
            AFQ_AddImageTo3dPlot(b0,xplane);
            axis off
            axis square
            clear fg roifg
            
       %     print('-depsc',fullfile(imgDir,sprintf('%s.eps',fName)));
            print('-dtiff','-r300',fullfile(imgDir,sprintf('%s.tiff',strcat(hemi,'_',fName))));
            end
           % close all;
end
