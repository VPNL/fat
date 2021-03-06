

sessid={'bb04/mri0/dwi/' 'bb05/mri0/dwi/', ...
    'bb07/mri0/dwi/' 'bb11/mri0/dwi/', ...
    'bb12/mri0/dwi/' 'bb14/mri0/dwi',...
    'bb17/mri0/dwi/' 'bb18/mri0/dwi/',...
    'bb22/mri0/dwi'}

% sessid={'bb02/mri3/dwi/',...
%         'bb04/mri3/dwi/',...
%         'bb05/mri3/dwi/',...
%         'bb07/mri3/dwi/',...
%         'bb08/mri3/dwi/',...
%         'bb11/mri3/dwi/',...
%         'bb12/mri3/dwi/',...
%         'bb14/mri3/dwi/',...
%         'bb15/mri3/dwi/',...
%         'bb18/mri3/dwi/'};

    
% sessid={'bb02/mri6/dwi/' ,...
%         'bb04/mri6/dwi/' ,...
%         'bb05/mri6/dwi/' ,...
%         'bb07/mri6/dwi/' ,...
%         'bb08/mri6/dwi/' ,...
%         'bb11/mri5/dwi/' ,...
%         'bb12/mri6/dwi/' ,...
%         'bb14/mri6/dwi/' ,...
%         'bb15/mri6/dwi/' ,...
%          'bb19/mri6/dwi/'};
     
runName={'94dir_run1'};
fatDir=fullfile('/share/kalanit/biac2/kgs/projects/babybrains/mri/');

fgNames={'WholeBrainFG_classified_clean',...
  'WholeBrainFG_classified_withBabyAFQ_clean',...
  'manual'};
%fgName='WholeBrainFG_classified_clean_withROIs';

tract_names={'TR' 'TR' 'CS' 'CS' 'CC' 'CC' 'CH' 'CH',...
    'FMa' 'FMi' 'IFOF' 'IFOF' 'ILF' 'ILF' 'SLF' 'SLF',...
    'UCI' 'UCI' 'AF' 'AF' 'MdLF' 'MdLF' 'VOF' 'VOF' 'pAF' 'pAF'}

outdir='/share/kalanit/biac2/kgs/projects/babybrains/mri/code/babyDWI/plots/montages/mri0';
mkdir(outdir)
%outname=strcat(tract_names{foi},'_',subject,'_',age,'_',fgName)
for n=2%1:length(fgNames)
for foi=21:22%:30
    if rem(foi,2)==0
        hem='rh'
    else
        hem='lh'
    end
    
    imgName=strcat(hem,'_',tract_names{foi},'_',fgNames{n},'.tiff')
    numberOfCoulumns=2;
    bigImg = babyFatMontage(fatDir, sessid, runName, imgName,numberOfCoulumns,outdir);
end
end