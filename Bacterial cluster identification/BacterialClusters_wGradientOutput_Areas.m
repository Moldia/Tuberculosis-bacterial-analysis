image = 'E:\ISS Bacteria project 15.01.2021\Analysis\Scene2\Clusters\20170629\2_20170629_auramine_20_aligned_substr_ORG.tif';
output_prefix = 'E:\ISS Bacteria project 15.01.2021\Analysis\Scene2\Clusters\20170629\2_Clusters_78_300dpi\2_Clusters_78_300dpi';
blob_file = 'E:\ISS Bacteria project 15.01.2021\Analysis\Scene2\Clusters\20170629\2_QT_0.35_1234_0_details.csv';
image_scale = 0.2;
gradient_step = 300; % pixel in orignal scale

%% load and prepare image
% load image
I = double(imread(image));

% rescale intensity to 0-1, i.e. max intensity is 1
I = I/max(I(:));

% tophat-filtering to remove some very big background
% the filter is just a quick and dirty square filter, no fancy circle
% filter
% the size of the filter can be changed via filter_length
% all parameters are based on pixel size in the input image
filter_length = 5;
I_tophat = imtophat(I, ones(filter_length));

%% visualize the image with or without tophat filtering
% the images will be displayed as heatmaps
% x:y ratio of 1:1 is not preserved
figure, 
ax1 = subplot(121); imagesc(I)
ax2 = subplot(122); imagesc(I_tophat)
% synchronize zoom and view of two images
linkaxes([ax1 ax2], 'xy');

%% smooth the image
% create a guassian filter
% the shape of the guassian filter can be changed via the following two
% parameters
% it is always recommended to have filter_coverage at least three times
% bigger than filter_sigma
filter_coverage = 160;
filter_sigma = 40;
filter = fspecial('gaussian', [filter_coverage filter_coverage], filter_sigma);

% filter the image
I_smooth = imfilter(I_tophat, filter/max(filter(:)));

% visualizaiton
clf; imagesc(I_smooth)

%% threshold the smoothed image
% rescale intensity of the smoothed image
I_smooth = I_smooth/max(I_smooth(:));

% threshold the smoothed image
% threshold is determined by the percentile of all values
% a threshold of 90 means the top 10% pixels are considered as foreground
% threshold changes depending on how widespread the staining is
threshold_percentile = 78;
I_foreground = im2bw(I_smooth, prctile(I_smooth(:), threshold_percentile));

% visualizaiton
clf; imshow(I_foreground);
figure; imshow(I_foreground);
imwrite(I_foreground, [output_prefix '_BW.tiff'],'Resolution', 300);
%% some final touches
% fill the holes or not
% generally advised to fill, which will get rid of small "bubbles" in
% segmented objects
fill_holes = 1;
if fill_holes
    I_foreground = imfill(I_foreground, 'holes');
end

% identify individual objects, get position and area of each object
% the area can be a potential filtering criterion
rp = regionprops(I_foreground, 'centroid', 'area');
centroid = cat(1, rp.Centroid);
area = cat(1, rp.Area);

% get outline image
outline = I_foreground ~= imerode(I_foreground, strel('disk', 1));

% visualization
Icolor = repmat(double(outline), 1, 1, 3);
Icolor(:,:,1:2) = Icolor(:,:,1:2) + I*2;
figure,imshow(Icolor)
hold on;
text(centroid(:,1), centroid(:,2), num2str((1:size(centroid,1))'),...
    'Color', 'w', 'FontWeight', 'bold')

% output images
imwrite(uint8(Icolor*255), [output_prefix '_outline_original.tiff'],'Resolution', 300);

set(gcf, 'InvertHardcopy', 'off');
print([output_prefix '_number.tiff'], '-r300', '-dtiff');

% write cluster info
fid = fopen([output_prefix '_clusters.csv'], 'w');
fprintf(fid, 'cluster_#,centroid_x,centroid_y,area\n');
fprintf(fid, '%d,%f,%f,%d\n', [(1:length(area))', centroid, area]');
fclose(fid);

%% HERE is manual exclusion of some clusters
exclude_these_clusters = [2 4 5 8 11 17 26 28 31];
Ilabel = bwlabel(I_foreground);

for i = exclude_these_clusters
    I_foreground(Ilabel==i) = 0;
    Ilabel(Ilabel==i) = 0;
end

% get outline image
outline = I_foreground ~= imerode(I_foreground, strel('disk', 1));

% visualization
Icolor = repmat(double(outline), 1, 1, 3);
Icolor(:,:,1:2) = Icolor(:,:,1:2) + I*2;

% output images
imwrite(uint8(Icolor*255), [output_prefix '_outline_adjusted.tiff'],'Resolution', 300);

%% label image based on distance


[I_dist, idx] = bwdist(I_foreground);
map_dist = Ilabel(idx);

%% get some quantitative results
[name, pos] = getinsitudata(blob_file);
pos = correctcoord(pos, image_scale);

% crop away Ila
pos(pos(:,1)>size(Ilabel,2),1) = size(Ilabel,2);
pos(pos(:,2)>size(Ilabel,1),2) = size(Ilabel,1);
[uNames, ~, iName] = unique(name);
header = [{'cluster'}, uNames']';
fid = fopen([output_prefix '_counts.csv'], 'w');
header{end+1}='AREA';
fprintf(fid, lineformat('%s', length(header)), header{:});

gradient_step = gradient_step*image_scale;
vel=[{'ROIS'}];

for d = 0:gradient_step:gradient_step*ceil(max(I_dist(:))/gradient_step)
    mask = double(I_dist>d-gradient_step & I_dist<=d).* map_dist;
    a = unique(mask);
    out = [a,histc(mask(:),a)];
    iC = readsinroi(pos, mask);
    cMatrix = hist3([iC, iName], [{unique(Ilabel(:))}, {1:length(uNames)}]);
    tab=table(unique(Ilabel(:)));
    tab2=table();
    tab2.Var1=out(:,1);
    tab2.Var2=out(:,2);
    if d==0
    all_areas=table(unique(Ilabel(:))); 
    end
    out=table2array(outerjoin(tab,tab2));
    out(isnan(out))=0;
    cMatrix(:,end+1)=out(:,3);
    all_areas(:,end+1)=table(out(:,3));
    cMatrix = [catstrnum(['d' num2str(d) '_'], unique(Ilabel(Ilabel~=0))), num2cell(cMatrix(2:end,:))]';
    fprintf(fid, ['%s,', lineformat('%d', length(header)-1)], cMatrix{:});
    vel=[vel,{['d','_', num2str(d) ]}];
    plot(pos(iC~=0,1), pos(iC~=0,2), '.'); drawnow;
end
fclose(fid);
all_areas.Properties.VariableNames=vel;

writetable(all_areas,[output_prefix '_areas.csv']);
set(gcf, 'InvertHardcopy', 'off');
saveas(gcf, [output_prefix '_gradient.tif'],'Resolution',300);

