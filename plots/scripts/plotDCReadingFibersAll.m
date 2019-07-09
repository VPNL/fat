
fascicles={'lh_pSTS_MTG_union_morphing_reading_vs_all_lh_IFG_union_morphing_reading_vs_all_r5.00_run1_lmax8_curvatures_concatenated_optimize_it500_new_classified_overlap_for_plot.mat'...
    'lh_pSTS_MTG_union_morphing_reading_vs_all_lh_ISMG_morphing_reading_vs_all_r5.00_run1_lmax8_curvatures_concatenated_optimize_it500_new_classified_overlap_for_plot.mat'...
    'lh_ISMG_morphing_reading_vs_all_lh_IFG_union_morphing_reading_vs_all_r5.00_run1_lmax8_curvatures_concatenated_optimize_it500_new_classified_overlap_for_plot.mat'...
    'lh_OTS_union_morphing_reading_vs_all_lh_ISMG_morphing_reading_vs_all_r5.00_run1_lmax8_curvatures_concatenated_optimize_it500_new_classified_overlap_for_plot.mat'...
    'lh_OTS_union_morphing_reading_vs_all_lh_IFG_union_morphing_reading_vs_all_r5.00_run1_lmax8_curvatures_concatenated_optimize_it500_new_classified_overlap_for_plot.mat'...
    'lh_OTS_union_morphing_reading_vs_all_lh_pSTS_MTG_union_morphing_reading_vs_all_r5.00_run1_lmax8_curvatures_concatenated_optimize_it500_new_classified_overlap_for_plot.mat'}

foi={11 13 15 19 27 21}

for f=1:length(fascicles)
    for i=1:6
        if f==1
            x=i;
        elseif f==2
            x=i+6
        elseif f==3
            x=i+12
        elseif f==4
            x=i+18
        elseif f==5
            x=i+24
        elseif f==6
            x=i+30
        end
    load(fascicles{f})
    fg(x)=roifg(foi{i})
    fid(x)=fidx(foi{i})
    end
end

clear roifg
clear fidx

roifg=fg
fidx=fid
save('roifg_reading_for_plot', 'roifg','fidx');

