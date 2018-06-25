function coloredImage = imoverlay2D(image, mask, color)
    if size(image, 3)==1
        colImage(:,:,1) = image;
        colImage(:,:,2) = image;
        colImage(:,:,3) = image;
    end

    coloredImage = zeros(size(colImage));
    coloredImage(:,:,1) = colImage(:,:,1) + color(1) * mask;
    coloredImage(:,:,2) = colImage(:,:,2) + color(2) * mask;
    coloredImage(:,:,3) = colImage(:,:,3) + color(3) * mask;
    coloredImage(coloredImage>1) = 1;
end
        