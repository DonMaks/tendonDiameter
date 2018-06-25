% Script for semi-automatic tendon-area/volume measurements.
%
% Author: Max Hess <hess.max.timo@gmail.com>
% Created: April 2018
% Modified: -
%
% Dependencies:
% - loadImageStack.m
% - imoverlay2D.m
% - writeColorStack.m
%   - saveastiff.m
% - getLargestCc.m
% - roiGUI.m
% - roiGUI.fig
% 
% Instructions:
% Put your images in a single folder labeled 'Data' the same directory as
% the .m files and run the script. A new folder Results containing an
% Excel-sheet with the results, a tiff-visualization of the thresholding
% and a plot of the results will be generated.
%


clear all;
mfilepath = fileparts(which(mfilename));
addpath(fullfile(mfilepath, 'functions'));


root = 'E:/Max_Hess/tendonDiameterFabian'; %Specify your working directory here
data_path = fullfile(root, 'Data'); %Name of the folder containing the images
results_path = fullfile(root, 'Results');
manual_threshold = false; % [false; 0-1] if set to false otsu thresholding is applied, otherwise the specified threshold is used.

if ~(7==exist(results_path, 'dir'))
    mkdir(results_path);
end

%Load all the images from the specified folder into a matrix and the labels
%into a string array. (converted to grayscale)
[stack, names] = loadImageStack(data_path, true);


%Apply the calculated threhsold
bw_stack = zeros(size(stack), 'logical');
if ~manual_threshold
    for i = 1:size(stack, 3)
        bw_stack(:,:,i) = imbinarize(stack(:,:,i));
    end
else
    for i = 1:size(stack, 3)
        bw_stack(:,:,i) = imbinarize(stack(:,:,i), manual_threshold);
    end
end
bw_stack = ~bw_stack;

%calculate the z-position from the label
labels = zeros(1, length(names));
for i = 1:length(names)
    name = names{i};
    fields = strsplit(name, ' ');
    labels(i) = str2double(fields{end});
end
zpos = labels - labels(1);
relative_zpos = mapminmax(zpos, 0, 1);

%Correct the segmentation manually
manual_bw_stack = zeros(size(bw_stack));
discard_image = zeros(size(bw_stack, 3), 1);
for i = 1:size(stack, 3)
    image = stack(:, :, i);
    mask = bw_stack(:, :, i);
    [~, discard_image(i), manual_bw_stack(:, :, i)] = roiGUI(image, mask);
end
    



%visualization of the segmentation
discard_mask = ones(size(stack(:, :, 1)));
visualization_stack = zeros([size(stack), 3]);
areas = zeros(sum(~discard_image), 1);
final_zpos = zeros(size(areas));
final_rel_zpos = zeros(size(areas));
final_names = cell(size(areas));
j = 1;
for i = 1:size(stack, 3);
    image = stack(:, :, i);
    if discard_image(i)
        visualization_stack(:, :, i, :) = imoverlay2D(image, discard_mask, [0.5, 0, 0]);
    else
        mask = manual_bw_stack(:, :, i);
        visualization_stack(:, :, i, :) = imoverlay2D(image, mask, [0, 0.5, 0]);
        areas(j) = sum(mask(:));
        final_zpos(j) = zpos(i);
        final_rel_zpos(j) = relative_zpos(i);
        final_names{j} = names{i};
        j = j+1;
    end
end

writeColorStack(im2uint8(visualization_stack), strcat(results_path, 'Visualization.tif'));
plot(final_zpos, areas);
xlabel('Z position [um]');
ylabel('Cross sectional area [px]');
ylim([0, max(areas)*1.1]);
fig = gcf;
print(fullfile(results_path, 'Plot'), '-dpng');

%save the results
Results = struct('name', final_names, 'zpos', num2cell(final_zpos), 'relative_zpos', ...
                 num2cell(final_rel_zpos), 'area', num2cell(areas));
results_table = struct2table(Results);
writetable(results_table, strcat(results_path, 'Results.xls'));