% in situ sequencing pipeline
% Ideally keep one file for one experiment
% Four main functions: 1)Tiling, 2)Decoding, 3)Thresholding, 4)Plotting 
% All variables ending with _YN are yes or no (1 or 0) questions.
%
% Sequencing v3
% Xiaoyan, 2018


clear, clc; close all; drawnow;

% Choose functions to run
run_Tiling_YN = 1;
run_Decode_YN = 0;
run_Threshold_YN = 0;
run_Plotting_Global_YN = 0;
%================================================
% set parameters
%----------------------------
% Tiling
    t.folder_image = 'C:\Users\anastasia.magoulop\Desktop\ForTBGithub\Tuberculosis-bacterial-analysis\Single bacteria identification'; % preferably full path name
    t.filename_base_prefix = 'base';  % keep single quote marks
        t.in_subfolder_YN = 1;
    t.filename_channel_prefix = '_c';
    t.filename_suffix = '_ORG.tif';
    t.base_start = 1;     t.base_end = 1;       
    t.channel_start = 1;  t.channel_end = 1;
    t.tile_size = 2000;
    t.channel_order = {'Bact'};
    t.CSV_filename_prefix = '3_TEST';
%----------------------------
% Decoding
    d.input_file = 'D:\Exp 17\2020\Scene1\CPresults\blobs\blobs.csv';
    d.General_Alignment_ACGT_column_number = [0,0,6,7,8,9];    % use 0 if any of them is MISSING in the file
    d.XYPosition_ParentCell_column_number = [10,11,0];
    
    d.num_hybs = 4;
    d.taglist = 'D:\Exp 17\2020\mouseList.csv';   % old .m taglist or .csv file with columns: code, name, symbol(optional), no header
    d.csv_file_contain_tile_position = 'D:\Exp 17\2020\Scene1\tiled.csv';
    d.output_directory = 'Decoding_scene1_newlist';   
    % options
    d.check_parent_cell_YN = 0;       
    d.check_alignment_YN = 0;
        alignment_min_threshold = 1.8;
    d.abnormal_sequencing_YN = 1;
        d.sequencing_order = '1230';  % keep the quote marks, same length as
%----------------------------
% Thresholding
    q.quality_threshold = 0.40;        
    q.general_stain_threshold = 0;
%----------------------------
% Plotting
    p.background_image = 'D:\Exp 17\2020\Scene1\DAPI_50.jpg'; 
        p.scale = 0.5;		% image sca
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
    