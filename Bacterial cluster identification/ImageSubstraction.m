%location of bacteria (Cy3=c3) and autofluorescence (FITC=c2) images
image_1 = 'E:\ISS Bacteria project\Analysis\Scene2\ForMATLAB_correct\2_20170629_auramine_100_aligned\2_20170629_auramine_100_aligned_c3.tif';
image_2 = 'E:\ISS Bacteria project\Analysis\Scene2\ForMATLAB_correct\2_20170629_auramine_100_aligned\2_20170629_auramine_100_aligned_c2.tif';
%image substraction
image_1 = imread (image_1);
image_2 = imread (image_2);
image = image_1-image_2;
imwrite(image,'E:\ISS Bacteria project\Analysis\Scene2\ForMATLAB_correct\2_20170629_auramine_100_aligned\2_20170629_auramine_100_aligned_substr.tif');


