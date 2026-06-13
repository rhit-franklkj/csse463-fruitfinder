function mask = extract_apples(img)
  %% Takes an HSV image and attempts to filter for the apple pixels %% 
    RED_LOW = .90;
    RED_HIGH = .04; 
    SATURATION_LOW = .1;     
    img_h = img(:, :, 1);
    img_s = img(:, :, 2); 
    mask = zeros(size(img, 1), size(img, 2)); 
    mask(( img_h > RED_LOW | img_h < RED_HIGH) & ...
        img_s > SATURATION_LOW) = 1; 
end

function mask = extract_oranges(img)
%% Takes an HSV image and attempts to filter for the orange pixels %% 
%% TODO: the color is just a rough estimate %% 
    ORANGE_LOW = .05;
    ORANGE_HIGH = .10;
    img_h = img(:, :, 1);
    mask = zeros(size(img, 1), size(img, 2)); 
    mask(ORANGE_LOW < img_h & img_h < ORANGE_HIGH) = 1; 
end

function mask = extract_bananas(img)
%% Takes an HSV image and attempts to filter for the banana pixels %% 
%% TODO: the color is just a rough estimate %% 
    YELLOW_LOW = .10;
    YELLOW_HIGH = .18; 
    SATURATION = .9; 
    img_h = img(:, :, 1);
    img_s = img(:, :, 2); 
    mask = zeros(size(img, 1), size(img, 2)); 
    mask(YELLOW_LOW < img_h & img_h < YELLOW_HIGH & img_s < SATURATION) = 1; 
end

function avg_area = calculate_avg_area(mask)
   %% Given a mask, calculate the average size of the regions in it %% 
    cc = bwlabel(mask); 
        
    area = zeros(max(max(cc)), 1); 
    for k = 1:max(max(cc))
        area(k) = sum(sum(cc == k)); 
    end
    
    avg_area = mean(area); 
end

function mask = transform_apples(mask)
    %% Given a mask, perform transformations to remove noise and catch all apple pixels %% 
    se = strel("disk", 2); % get rid of some light noise 
    mask = imerode(mask, se); 

    avg_area = calculate_avg_area(mask); 

    % After fiddling with hyperparameters: 
    % img 1: 
    % 10, 12, 6 Area = 26

    % img 2: 
    % 20, 25, 13. Area = 785

    % img 3: 
    % 20, 35, 14 area = 998
    % 

    % Everyone say thank you desmos for linear regression
    dilate_radius = floor((0.011052 * avg_area) + 10.0232); 
    erode_radius = floor((0.0219335 * avg_area) + 10.7741); 
    dilate_radius_2 = floor((0.00849298 * avg_area) + 5.87873); 

    % close the holes
    % since the erosion is larger than dilation, this also removes some
    % noise
    se = strel("disk", dilate_radius); 
    mask = imdilate(mask, se);
    se = strel("disk", erode_radius); 
    mask = imerode(mask, se); 

    % I know apples are generally round so redilate to get a round shape
    % back
    se = strel("disk", dilate_radius_2); 
    mask = imdilate(mask, se); 

end

function mask = transform_oranges(mask)
    %% Given a mask, perform transformations to remove noise and catch all orange pixels %% 
    %% TODO: this is a copy of an earlier version of apple, so it needs tuning %% 
    se = strel("disk", 1); % get rid of some light noise 
    mask = imerode(mask, se); 
    
    avg_area = calculate_avg_area(mask); 
    
    dilate_radius = 10; 
    erode_radius = 15; 
    
    se = strel("disk", dilate_radius); 
    mask = imdilate(mask, se);
    se = strel("disk", erode_radius); 
    mask = imerode(mask, se); 
    se = strel("disk", 5); 
    mask = imdilate(mask, se); 

end

function mask = transform_bananas(mask)
    %% Given a mask, perform transformations to remove noise and catch all banana pixels %% 
    %% TODO: this is a copy of an earlier version of apple, so it needs tuning %% 
    
    se = strel("disk", 1); % get rid of some light noise 
    mask = imerode(mask, se); 
    
    avg_area = calculate_avg_area(mask); 
    
    dilate_radius = 10; 
    erode_radius = 15; 
    
    se = strel("disk", dilate_radius); 
    mask = imdilate(mask, se);
    se = strel("disk", erode_radius); 
    mask = imerode(mask, se); 
    se = strel("disk", 5); 
    mask = imdilate(mask, se); 

end

function overlay(img, mask)
    %% Layers the mask pixels back onto the original image. Background is dimmed to 1/4 lightness %% 
    temp = img; 
    
    temp_h = temp(:, :, 1); 
    img_h = img(:, :, 1); 
    
    temp_s = temp(:, :, 2); 
    img_s = img(:, :, 2); 
    
    temp_v = temp(:, :, 3); 
    img_v = img(:, :, 3); 
    
    temp_h(mask == 0) = img_h(mask == 0) / 4; 
    temp_s(mask == 0) = img_s(mask == 0) / 4; 
    temp_v(mask == 0) = img_v(mask == 0) / 4; 
    
    temp(:, :, 1) = temp_h; 
    temp(:, :, 2) = temp_s; 
    temp(:, :, 3) = temp_v; 
   
    subplot(2, 2, 4); 
    imshow(temp); 
end

function  [apples, oranges, bananas] = extract(img)
%% Wrapper function that calls all 3 fruit-specific extraction methods %% 
    apples = extract_apples(img); 
    oranges = extract_oranges(img); 
    bananas = extract_bananas(img); 
end

function [apples, oranges, bananas] = transform(mask_apple, mask_orange, mask_banana)
%% Wrapper function that calls all 3 fruit-specific transformation methods %% 
    apples = transform_apples(mask_apple); 
    oranges = transform_oranges(mask_orange); 
    bananas = transform_bananas(mask_banana); 
end

function display(img, mask)
%% I had too many imtool windows and remembered this from videos 3c.%% 
%% The image will reload when the program is run which is really nice %% 
%% TODO: probably add orange and banana filters. 
    subplot(2, 2, 1); 
    imshow(hsv2rgb(img)); % original image
    subplot(2, 2, 2); 
    imshow(img); % the hsv version
    subplot(2, 2, 3); 
    imshow(mask); % just the mask
    overlay(hsv2rgb(img), mask); % mask overlaid on original rgb image
end


function process_image(path)
   %% Given a path to an image, run it through extraction and transformation %% 
    img = imread(path); 
    img = rgb2hsv(img); 

    [mask_apples, mask_oranges, mask_bananas] = extract(img); 
    [mask_apples, mask_oranges, mask_bananas] = transform(mask_apples, mask_oranges, mask_bananas); 

    display(img, mask_apples)

end

process_image("fruit_png\mixed_fruit1.png"); 
process_image("fruit_png\mixed_fruit2.png"); 
process_image("fruit_png\mixed_fruit3.png"); 
process_image("fruit_png\fruit_tray.png");



% TODO: 
% 1. count fruits (it's just bwlabel(mask) and then find mask
% 2. centroids (for loop over the components found by bwlabel then average.
% Not sure how to plot that just yet but that sounds like a tomorrow
% problem.) 
% hopefully my apple transform isn't against the rules  
