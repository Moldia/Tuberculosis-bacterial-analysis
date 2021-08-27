%% align a floating image on top of a reference image
%  need to give rotation angle and translation matrix
%  last update, 2015-2-18, Xiaoyan

clear;
close all;

%% input

ref_image = 'E:\ISS Bacteria project\Analysis\Scene2\ForMATLAB_correct\2_0703_auramine_aligned_100\2_auramine_aligned_100_c1_ORG.tif';
flo_image = 'E:\ISS Bacteria project\Analysis\Scene2\ForMATLAB_correct\2_20170629_auramine_100\2_20170629_auramine_100_c1_ORG.tif';; % give sample snapshot image (blue DAPI)

 input_image_prefix = 'E:\ISS Bacteria project\Analysis\Scene2\ForMATLAB_correct\2_20170629_auramine_100\2_20170629_auramine_100_c';
% flo_image = [input_image_prefix '1_stitched.tif']; % give sample snapshot image (blue DAPI)



%% original  
ref = imread(ref_image);
size_ref = size(ref);
flo = imread(flo_image);
ref_resized= imresize(ref, 0.1);

flo_resized = imresize(flo, 0.1);
Ifuse = imfuse(flo_resized, ref_resized);
figure;imshow(Ifuse);
% green: floating
% purple: reference

%% rotation
angle = 0.08; % positive: counter clockwise
[flo_rotate, Ifuse_rotate] = rotateimage(flo_resized, angle, ref_resized);
%figure;imshow(Ifuse_rotate*8);

%% translation
yup = 41;   % positive: move the floating image up, negative: down
xleft = 23;   % positive: move the floating image left, negative: right
Ifuse_translate = translateimage(yup, xleft, flo_rotate, ref_resized);
figure;imshow(Ifuse_translate*10);

%% transform images
mkdir('E:\ISS Bacteria project\Analysis\Scene2\ForMATLAB_correct\');
output_image_prefix = '2_20170629_auramine_100_aligned_c';
 for c = 1:5
     flo = imread([input_image_prefix num2str(c) '_ORG.tif']);
     transformimage(flo,angle,yup,xleft,10,...
         ['E:\ISS Bacteria project\Analysis\Scene2\ForMATLAB_correct\2_20170629_auramine_100_aligned\' output_image_prefix num2str(c) '.tif'],size_ref);
 end
% toc