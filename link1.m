imageDir = 'C:\Users\user\Desktop\Cs484_Hw3';  
superpixelDir = 'C:\Users\user\Desktop\datfiles';
gaborSaveDir = 'C:\Users\user\Desktop\gabor';
wavelength = 4;
orientation = 90;
gaborArray = gabor([2 4 8 16],[0 45 90 135]);

all_features = []; % Store all feature vectors

% Loop through all images.
for i = 1:10
    image_path = fullfile(imageDir, [num2str(i) '.jpg']);
    superpixel_path = fullfile(superpixelDir, [num2str(i) '.dat']);
    
    gray_img = processImage(image_path);
    
    [mag, phase] = getGaborFilters(gray_img, wavelength, orientation);
    gaborMag = imgaborfilt(gray_img,gaborArray);
    
    saveGaborMagnitude(gaborMag, gaborSaveDir, i);
    
    fileID = fopen(superpixel_path, 'r'); % open the file
    superpixels = fread(fileID, [10, 50], 'int'); % replace num_rows and num_cols with the actual size
    fclose(fileID); % close the file
    
    feature_matrix = getSuperpixelFeatures(superpixels, gaborMag);
    all_features = [all_features; feature_matrix];  % append feature vectors to all_features
    
    % Now you have a feature_matrix for each image, do something with it...
    % For example, save it to a file:
    save(fullfile(gaborSaveDir, ['feature_matrix_', num2str(i), '.mat']), 'feature_matrix');
    
    showImages(gray_img, mag, phase);
    
    showGaborFilters(gaborMag, gaborArray);
end

% Now that you've processed all images and accumulated all feature vectors,
% you can perform clustering on all_features.

% number of clusters
k = 5; % you should choose a suitable number

% perform k-means clustering
[cluster_idx, cluster_centroid] = kmeans(all_features, k);

% ... the rest of your code ...

function img = processImage(image_path)
    img = imread(image_path);
    img = im2gray(img);
end

function [mag, phase] = getGaborFilters(img, wavelength, orientation)
    [mag, phase] = imgaborfilt(img, wavelength, orientation);
end

function saveGaborMagnitude(gaborMag, saveDir, index)
    save(fullfile(saveDir, ['gaborMag_', num2str(index), '.mat']), 'gaborMag');
end

function feature_matrix = getSuperpixelFeatures(superpixels, gaborMag)
    num_superpixels = max(superpixels(:));
    num_filters = size(gaborMag, 3);

    % Initialize feature matrix
    feature_matrix = zeros(num_superpixels, num_filters);

    % For each superpixel, average Gabor features of all pixels within it
    for i = 1:num_superpixels
        for j = 1:num_filters
            feature_matrix(i, j) = mean(gaborMag(superpixels == i, j));
        end
    end
end

function showImages(img, mag, phase)
    figure
    tiledlayout(1,3)
    nexttile
    imshow(img)
    title('Original Image')
    nexttile
    imshow(mag,[])
    title('Gabor Magnitude')
    nexttile
    imshow(phase,[])
    title('Gabor Phase')
end

function showGaborFilters(gaborMag, gaborArray)
    figure
    for p = 1:16
        subplot(4,4,p)
        imshow(gaborMag(:,:,p),[]);
        theta = gaborArray(p).Orientation;
        lambda = gaborArray(p).Wavelength;
        title(sprintf('Orientation=%d, Wavelength=%d',theta,lambda));
    end
end

