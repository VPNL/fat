
fascicles={'lh_pSTS_MTG_union_morphing_reading_vs_all_lh_IFG_union_morphing_reading_vs_all_r5.00_run1_lmax8_curvatures_concatenated_optimize_it500_new_classified_overlap_for_plot.mat'...
    'lh_pSTS_MTG_union_morphing_reading_vs_all_lh_ISMG_morphing_reading_vs_all_r5.00_run1_lmax8_curvatures_concatenated_optimize_it500_new_classified_overlap_for_plot.mat'...
    'lh_ISMG_morphing_reading_vs_all_lh_IFG_union_morphing_reading_vs_all_r5.00_run1_lmax8_curvatures_concatenated_optimize_it500_new_classified_overlap_for_plot.mat'...
    'lh_OTS_union_morphing_reading_vs_all_lh_ISMG_morphing_reading_vs_all_r5.00_run1_lmax8_curvatures_concatenated_optimize_it500_new_classified_overlap_for_plot.mat'...
    'lh_OTS_union_morphing_reading_vs_all_lh_IFG_union_morphing_reading_vs_all_r5.00_run1_lmax8_curvatures_concatenated_optimize_it500_new_classified_overlap_for_plot.mat'...
    'lh_OTS_union_morphing_reading_vs_all_lh_pSTS_MTG_union_morphing_reading_vs_all_r5.00_run1_lmax8_curvatures_concatenated_optimize_it500_new_classified_overlap_for_plot.mat'...
    'lh_OTS_union_morphing_reading_vs_all_lh_pSTS_MTG_union_morphing_reading_vs_all_r5.00_run1_lmax8_curvatures_concatenated_optimize_it500_new_classified_overlap_for_plot.mat'}

foi={19 21 15 21 19 19 21}

for f=1:length(fascicles)
    load(fascicles{f})
    fg(f)=roifg(foi{f})
    fid(f)=fidx(foi{f})
end

clear roifg
clear fidx

roifg=fg
fidx=fid
save('roifg_reading_for_plot', 'roifg','fidx');

