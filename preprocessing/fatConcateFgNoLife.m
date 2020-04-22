function fatConcateFgNoLife(fatDir, sessid, runName, fgInName,fgOutName)
% Concatenate optimized LiFE from different parameters to create
% final LiFE. In this function, we simply concatenate streamlines in each connectome
% (fg structure) to create new connectome as fg file.
% INPUT:
% fgInName: Files of connectomes generated by various type of tractography
%          algorithms and parameters (.pdb or .mat format)
% fgOutName: File name for output file. (.pdb or .mat format)
for s = 1:length(sessid)
    for r = 1:length(runName)
        fprintf('Concate Fg (%s, %s, %s)\n',sessid{s},runName{r},fgOutName);
        
        fiberDir = fullfile(fatDir,sessid{s},runName{r},'dti96trilin','fibers');
        % Load fgfile to input;
        for i = 1:length(fgInName)
            fg(i) = fgRead(fullfile(fiberDir, fgInName{i}));
        end
        
        % Create fg structure
        fgConcat = fgCreate;
        % Set name for connectome file to save
        fgConcat.name = fullfile(fiberDir,fgOutName);
        % Set fibres
        fgConcat.fibers = cat(1,fg.fg.fibers);
        
        % Write file
        fgWrite(fgConcat);
    end
end
