

clear all;

% The following parameters need to be adjusted to fit your system
dwiDir=fullfile('/sni-storage/kalanit/biac2/kgs/projects/NFA_tasks/data_mrAuto');
anatDir_system =fullfile('/biac2/kgs/3Danat');
anatDir =('/sni-storage/kalanit/biac2/kgs/3Danat');



input_ROIs={'rh_OTS_union_morphing_reading_vs_all.mat' 'rh_pSTS_MTG_union_morphing_reading_vs_all.mat' 'rh_ISMG_morphing_reading_vs_all.mat' 'rh_IFG_union_morphing_reading_vs_all.mat'...
    'lh_OTS_union_morphing_reading_vs_all.mat' 'lh_pSTS_MTG_union_morphing_reading_vs_all.mat' 'lh_ISMG_morphing_reading_vs_all.mat' 'lh_IFG_union_morphing_reading_vs_all.mat'}

t1_name=['t1.nii.gz'];

for r=1:1 %only use first run
    
    for l=1:length(input_ROIs)
        if l==1
            ROIs={'rh_pSTS_MTG_union_morphing_reading_vs_all.mat' 'rh_ISMG_morphing_reading_vs_all.mat' 'rh_IFG_union_morphing_reading_vs_all.mat'}
        elseif l==2
            ROIs={'rh_ISMG_morphing_reading_vs_all.mat' 'rh_IFG_union_morphing_reading_vs_all.mat'}
        elseif l==3
            ROIs={'rh_IFG_union_morphing_reading_vs_all.mat'}
        elseif l==4
            ROIs={}
            
        elseif l==5
            ROIs={'lh_pSTS_MTG_union_morphing_reading_vs_all.mat' 'lh_ISMG_morphing_reading_vs_all.mat' 'lh_IFG_union_morphing_reading_vs_all.mat'}
        elseif l==6
            ROIs={'lh_ISMG_morphing_reading_vs_all.mat' 'lh_IFG_union_morphing_reading_vs_all.mat'}
        elseif l==7
            ROIs={'lh_IFG_union_morphing_reading_vs_all.mat'}
        elseif l==8
            ROIs={}
        end