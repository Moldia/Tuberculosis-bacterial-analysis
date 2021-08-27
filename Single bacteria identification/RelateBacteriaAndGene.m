%% input
decoded_file = 'E:\ISS Bacteria project 15.01.2021\Analysis\Scene3\3_single bac\3_QT_0.35_1234_0_details_missing tile.csv';
bacteria_segmentation = 'E:\ISS Bacteria project 15.01.2021\Analysis\Scene3\3_single bac\3_merged\3_bac_merged.csv';
tile_pos = 'E:\ISS Bacteria project 15.01.2021\Analysis\Scene3\3_single bac\BactTiled_3.csv';
max_distance = 200; % pixel

%% load data
[name, pos] = getinsitudata(decoded_file);
bacteria = importdata(bacteria_segmentation);
tilepos = getcsvtilepos(tile_pos);

% calculate global bacteria position
bacteria_loc = [bacteria.data(:,strcmp(bacteria.textdata, 'ImageNumber')),...
    bacteria.data(:,strcmp(bacteria.textdata, 'Location_Center_X')),...
    bacteria.data(:,strcmp(bacteria.textdata, 'Location_Center_Y'))];

for t = 1:max(bacteria_loc(:,1))    
    bacteria_loc(bacteria_loc(:,1)==t,2:3) = bacteria_loc(bacteria_loc(:,1)==t,2:3) + tilepos(tilepos(:,1)==t,2:3);
end

%% nearest bacterion
[iNN, dNN] = knnsearch(bacteria_loc(:,2:3), pos, 'k', 1);
i_bacteria = (1:length(bacteria_loc))';
parent_bacteria = [i_bacteria(iNN), dNN];

%% write reads file with Parent Bacteria
mkdir('ParentBacteria');
data = readtable(decoded_file);
header = data.Properties.VariableNames;
data = table2cell(data);
data = [data, num2cell(parent_bacteria)];
charcolumns = false(1,numel(header));
header = [header, {'Parent_Bact', 'Parent_Dist'}];
for i = 1:numel(header)
    if ischar(data{1,i})
        charcolumns(i) = 1;
    end
end
data = data';

[~, filename] = fileparts(decoded_file);

fid = fopen(fullfile('ParentBacteria', [filename '_ParentBact.csv']), 'w');
fprintf(fid, lineformat('%s', numel(header)), header{:});
fmt = repmat({'%f'}, 1, numel(header));
fmt(charcolumns) = {'%s'};
fmt = strcat(fmt, ',');
fmt = [fmt{:}];
fmt = [fmt(1:end-1), '\n'];
fprintf(fid, fmt, data{:});
fclose(fid);

%% write parent file with counts
parent_bacteria(dNN>max_distance,1) = 0;
[uNames, ~, iName] = unique(name);
per_bacteria = hist3([parent_bacteria(:,1), iName], [{[0; i_bacteria]}, {1:length(uNames)}]);

data = readtable(bacteria_segmentation);
header = data.Properties.VariableNames;
data = table2cell(data);
data = [data, num2cell(bacteria_loc(:,2:3)), num2cell(per_bacteria(2:end,:))];
charcolumns = false(1,numel(header));
header = [header, {'Global_X', 'Global_Y'}, uNames'];
for i = 1:numel(header)
    if ischar(data{1,i})
        charcolumns(i) = 1;
    end
end
data = data';

[~, filename] = fileparts(bacteria_segmentation);

fid = fopen(fullfile('ParentBacteria', [filename '_ChildCounts.csv']), 'w');
fprintf(fid, lineformat('%s', numel(header)), header{:});
fmt = repmat({'%f'}, 1, numel(header));
fmt(charcolumns) = {'%s'};
fmt = strcat(fmt, ',');
fmt = [fmt{:}];
fmt = [fmt(1:end-1), '\n'];
fprintf(fid, fmt, data{:});
fclose(fid);
