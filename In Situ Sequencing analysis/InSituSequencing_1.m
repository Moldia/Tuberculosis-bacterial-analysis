% in situ sequencing pipeline
% Ideally keep one file for one experiment
% Four main functions: 1)Tiling, 2)Decoding, 3)Thresholding, 4)Plotting 
% All variables ending with _YN are yes or no (1 or 0) questions.
%
% Sequencing v3
% Xiaoyan, 2018


clear, clc; close all; drawnow;

% Choose functions to run
run_Tiling_YN = 0;
run_Decode_YN = 0;
run_Threshold_YN = 0;
run_Plotting_Global_YN = 1;
%================================================
% set parameters
%----------------------------
% Tiling
    t.folder_image = 'C:\Users\anastasia.magoulop\Desktop\TB_Processing\Bases'; % preferably full path name
    t.filename_base_prefix = 'base';  % keep single quote marks
        t.in_subfolder_YN = 1;
    t.filename_channel_prefix = '_c';
    t.filename_suffix = '_ORG.tif';
    t.base_start = 1;     t.base_end = 4;       
    t.channel_start = 1;  t.channel_end = 6;
    t.tile_size = 2000;
    t.channel_order = {'N', 'T', 'G', 'C', 'A', 'General_stain'};
    t.CSV_filename_prefix = 'Tiled_B56_1';
%----------------------------
% Decoding
    d.input_file = 'E:\ISS Bacteria project 15.01.2021\Analysis\Scene2\CPresults_full_0.0018\blobs.csv';
    d.General_Alignment_ACGT_column_number = [0,0,6,7,8,9];    % use 0 if any of them is MISSING in the file
    d.XYPosition_ParentCell_column_number = [10,11,0];
    
    d.num_hybs = 4;
    d.taglist = 'E:\ISS Bacteria project 15.01.2021\Analysis\Scene2\mouseList.csv';   % old .m taglist or .csv file with columns: code, name, symbol(optional), no header
    d.csv_file_contain_tile_position = 'E:\ISS Bacteria project 15.01.2021\Analysis\Scene2\Bases\Tiled_anastasia.csv';
    d.output_directory = '2_Decoding_full_TH0.0018_4bases_35';   
    % options
    d.check_parent_cell_YN = 0;       
    d.check_alignment_YN = 0;
        alignment_min_threshold = 1.8;
    d.abnormal_sequencing_YN = 0;
        d.sequencing_order = '1230';  % keep the quote marks, same length as
%----------------------------
% Thresholding
    q.quality_threshold = 0.35;        
    q.general_stain_threshold = 0;
%----------------------------
% Plotting
    p.background_image = 'E:\ISS Bacteria project 15.01.2021\Analysis\Scene2\2_20170629_auramine_100_aligned_c3.tif'; 
        p.scale = 1;		% image sca
    p.I_want_to_plot_on_white_backgound = 0;
    % options
    p.exclude_NNNN_YN = 0;
    p.plot_reads_beforeQT_YN = 0;
    p.plot_ref_general_stain = 0; 
%================================================


if run_Tiling_YN || run_Decode_YN || run_Threshold_YN || run_Plotting_Global_YN
else
    error('Choose at least one function.');
end

if run_Tiling_YN
    seqtiling(t);
end
if run_Decode_YN
    decoding(d);
end
if run_Threshold_YN
    qthreshold(d.output_directory, q);
end 
if run_Plotting_Global_YN
    seqplotting(d.output_directory, d.taglist, q, p);
end

clear;   
    