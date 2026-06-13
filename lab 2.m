img = imread("image/Screenshot 2026-06-02 002637.png"); 

mask = zeros(1030, 879); 

img_r = img(:, :, 1); 
img_g = img(:, :, 2); 
img_b = img(:, :, 3); 


mask(img_r - img_b >= 30  & img_g - img_b >= 30) = 1; 

se = strel("disk", 25); 


mask_erode = imerode(mask, se);
mask_dilate = imdilate(mask, se);
mask_open = imdilate(mask_erode, se);
mask_closed = imerode(mask_dilate, se); 
% imtool(mask_erode); 
% imtool(mask_dilate);
% imtool(mask_open);
% imtool(mask_closed);

temp = img; 

temp_r = temp(:, :, 1); 
img_r = img(:, :, 1); 

temp_g = temp(:, :, 2); 
img_g = img(:, :, 2); 

temp_b = temp(:, :, 3); 
img_b = img(:, :, 3); 

temp_r(mask_closed == 0) = img_r(mask_closed == 0) / 2; 
temp_g(mask_closed == 0) = img_g(mask_closed == 0) / 2; 
temp_b(mask_closed == 0) = img_b(mask_closed == 0) / 2; 

temp(:, :, 1) = temp_r; 
temp(:, :, 2) = temp_g; 
temp(:, :, 3) = temp_b; 


imtool(temp); 

