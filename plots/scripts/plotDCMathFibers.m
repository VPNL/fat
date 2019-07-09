
fascicles={'lh_ITG_morphing_adding_lh_pIPS_morphing_adding_vs_all_r7.00_run1_lmax8_curvatures_concatenated_optimize_it500_new_classified_overlap.mat'...
    'lh_ITG_morphing_adding_lh_ISMG_morphing_adding_vs_all_r7.00_run1_lmax8_curvatures_concatenated_optimize_it500_new_classified_overlap.mat'...
    'lh_ITG_morphing_adding_lh_IPCS_morphing_adding_vs_all_r7.00_run1_lmax8_curvatures_concatenated_optimize_it500_new_classified_overlap.mat'...
    'lh_pIPS_morphing_adding_vs_all_lh_ISMG_morphing_adding_vs_all_r7.00_run1_lmax8_curvatures_concatenated_optimize_it500_new_classified_overlap.mat'...
    'lh_pIPS_morphing_adding_vs_all_lh_IPCS_morphing_adding_vs_all_r7.00_run1_lmax8_curvatures_concatenated_optimize_it500_new_classified_overlap.mat'...
    'lh_ISMG_morphing_adding_vs_all_lh_IPCS_morphing_adding_vs_all_r7.00_run1_lmax8_curvatures_concatenated_optimize_it500_new_classified_overlap.mat'}

foi={27 21 19 15 15 15}

for f=1:length(fascicles)
    load(fascicles{f})
    fg(f)=roifg(foi{f})
    fid(f)=fidx(foi{f})
end

clear roifg
clear fidx

roifg=fg
fidx=fid
save('roifg_math_for_plot', 'roifg','fidx');

