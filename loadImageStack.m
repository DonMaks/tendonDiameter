function [imageStack, labels] = loadImageStack(folder, gray)
    files = dir(fullfile(folder, '*.tif'));
    labels = cell(1, length(files));
    for i = 1:length(files)
        label = files(i).name;
        label_fields = strsplit(label, '.');
        labels{i} = label_fields{1};
        image = imread(strcat(folder, label));
        if gray
            image = rgb2gray(image);
            image = mat2gray(image);
        else
            image = image(:,:,2);
        end
        if i == 1
            imageStack = image;
        else
            imageStack = cat(3, imageStack, image);
        end
    end
end
        