function  [fiberCount, voxCount, totalFiber,totalVoxel] = ...
    fatFiberIntersectRoiWholeFiber(fatDir,fgDir, sessid, runName,...
    fgName, roiName, foi, mode, radius)
% fatFiberIntersectRoi(fatDir, sessid, runName, fgName, roiName, foi, radius)
% roiName, cell array
% foi,fiber of interest, vector
% mode, string, 'endpoint' or 'wholefiber'
% radius, scalar
% fgName should be specified according to the afq dir


if nargin < 8, mode = 'endpoint'; end
if nargin < 9, radius = 5; end
minLength = 20;

nRoi = length(roiName);
nFg = length(foi);
% total number of fiber
totalFiber = nan(nFg);
% total number of voxel in roi
totalVoxel = nan(nRoi);
% the number of fibers touching the ROI
fiberCount = nan(nRoi,nFg);
% the number of ROI's voxel touching the fibers
voxCount = fiberCount;
[~,fgNameWoExt] = fileparts(fgName);

fprintf('Fiber count for (%s, %s, %s)\n',...
    sessid, runName, fgName);
runDir = fullfile(fatDir,sessid,runName,'dti96trilin');
fgFile = fullfile(fgDir,fgName);
load(fgFile);
if exist('fg','var')
    fg = fg(foi);
else
    fg = roifg(foi);
end


% remove fiber that are less than 2cm, and
% calculate total fiber for each fg
for i = 1:nFg
    L = fgGet(fg(i),'nodesperfiber');
    fg(i).fibers = fg(i).fibers(L > minLength);
    totalFiber(i) = fgGet(fg(i),'nfibers');
end

% use ref image info to convert the acpa coords to img coords
refImg = niftiRead(fullfile(runDir,'bin','b0.nii.gz'),[]);
dist = radius + nthroot(prod(refImg.pixdim),3);

for i = 1:nRoi
    roiFile = fullfile(runDir,'ROIs',roiName{i});
    if exist(roiFile)
    roi = dtiReadRoi(roiFile);
    coords = roi.coords;
    % convert vertex acpc coords to img coords
    imgCoords  = mrAnatXformCoords(refImg.qto_ijk, coords);
    % get coords for the unique voxels
    imgCoords = unique(round(imgCoords),'rows');
    % transfer back to acpc coords
    rc = mrAnatXformCoords(refImg.qto_xyz, imgCoords);
    
    totalVoxel(i)= size(rc,1);
    nvox = totalVoxel(i);
    
    % only consider endpoints of the fibers in interesecting
    if strcmp(mode,'endpoint')
        for j = 1:nFg
            nfiber = totalFiber(j);
            fc = zeros(nfiber*2,3);
            % Get fiber terminate
            for k =1:nfiber
                fc((k-1)*2+1,:) = fg(j).fibers{k}(:,1);
                fc((k-1)*2+2,:) = fg(j).fibers{k}(:,end);
            end
            
            % distance betwee a fg and a roi
            D = reshape(pdist2(fc,rc),2,nfiber,nvox);
            D = permute(D,[2,3,1])< dist;
            D = xor(D(:,:,1),D(:,:,2));
            
            voxCount(i,j) = sum(any(D,1));
            
            % fiber idx of a fg which connect a roi
            F = any(D,2);
            fiberCount(i,j)= sum(F);
            
            % create roi's fiber
            rfg = fg(j);
            rfg.name = sprintf('%s_%s',roi.name, rfg.name);
            rfg.fibers = rfg.fibers(F);
            roifg(j) = rfg;
            fidx{j}  = F;
        end
        
        % consider whole fibers in interesecting
    elseif strcmp(mode,'wholefiber')
        for j = 1:nFg
            nfiber = totalFiber(j);
            F = false(nfiber,1);
            R = false(nvox,1);
            
            % check if a fiber intersect with the roi
            for k = 1:nfiber
                fc = fg(j).fibers{k};
                D = pdist2(fc',rc) <  dist
                F(k) = any(D(:));
                R = R | any(D,1)';
            end
            
            % number of voxels intersecting with the fg
            voxCount(i,j) = nnz(R);
            
            % number of fibers intersecting with the roi
            fiberCount(i,j)= nnz(F);
            
            % create roi's fiber
            rfg = fg(j);
            rfg.name = sprintf('%s_%s',roi.name, rfg.name);
            rfg.fibers = rfg.fibers(F);
            roifg(j) = rfg;
            fidx{j}  = F;
        end
    end

    % save the fiber group intersecting with roi
    [~,roiNameWoExt] = fileparts(roiName{i});
    roifgFile = fullfile(runDir,'fibers','afq',...
        sprintf('%s_r%.2f_%s_%s.mat',roiNameWoExt,radius,fgNameWoExt,mode));
    save(roifgFile, 'roifg','fidx');
    clear roifg fidx;
    end
end


