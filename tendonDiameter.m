% Script for automatic tendon-area/volume measurements.
%
% Author: Max Hess <hess.max.timo@gmail.com>
% Created: April 2018
% Modified: -
%
% Dependencies:
% - loadImageStack.m
% - imoverlay3D.m
% - writeColorStack.m
% - getLargestCc.m 
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

root = 'E:/Max_Hess/tendonDiameterFabian/'; %Specify your working diretory here
data_path = strcat(root, 'Data/Tendon2/'); %Name of the folder containing the images
results_path = strcat(root, 'Results/Tendon2/');
visualize = true; %set to true for visualization

if ~(7==exist(results_path, 'dir'))
    mkdir(results_path);
end

%Load all the images from the specified folder into a matrix and the labels
%into a string array. (converted to grayscale)
[stack, names] = loadImageStack(data_path, true);

%Calculate the histogram and Otsu threshold for the whole stack
[counts, x] = imhist(stack(:));
otsu_threshold = otsuthresh(counts);

%Apply the calculated threhsold
bw_stack = zeros(size(stack), 'logical');
for i = 1:size(stack, 3)
    bw_stack(:,:,i) = imbinarize(stack(:,:,i), otsu_threshold);
end
bw_stack = ~bw_stack;

%Select the biggest (2D-) connected component and calculate the area
clean_bw_stack = zeros(size(stack), 'logical');
areas = zeros(1, size(bw_stack, 3));
for i = 1:size(bw_stack, 3)
    bw_image = bw_stack(:,:,i);
    bw_image = imdilate(bw_image, strel('square', 3));
    clean_bw_image = getLargestCc(bw_image);
    areas(i) = sum(clean_bw_image(:));
    clean_bw_stack(:,:,i) = clean_bw_image;
    a=3;
end

%calculate the z-position from the label
labels = zeros(1, length(names));
for i = 1:length(names)
    name = names{i};
    fields = strsplit(name, ' ');
    labels(i) = str2double(fields{end});
end
zpos = labels - labels(1);
relative_zpos = mapminmax(zpos, 0, 1);

%save the results
Results = struct('name', [names], 'zpos', num2cell(zpos), 'relative_zpos', ...
                 num2cell(relative_zpos), 'area', num2cell(areas));
results_table = struct2table(Results);
writetable(results_table, strcat(results_path, 'Results.xls'));

%visualization of the segmentation
if visualize
    col_stack = imoverlay3D(stack, clean_bw_stack, [0.5 0 0]);
    writeColorStack(im2uint8(col_stack), strcat(results_path, 'Visualization.tif'));
    plot(zpos, areas);
    xlabel('Z position [um]');
    ylabel('Cross sectional area [px]');
    ylim([0, max(areas)*1.1]);
    fig = gcf;
    print(strcat(results_path, 'Plot'), '-dpng');
    
end
    