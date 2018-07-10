
%% Website
%https://www.mathworks.com/help/images/examples/marker-controlled-watershed-segmentation.html
%https://blogs.mathworks.com/steve/2013/11/19/watershed-transform-question-from-tech-support/
%https://www.mathworks.com/company/newsletters/articles/the-watershed-transform-strategies-for-image-segmentation.html
%https://www.mathworks.com/matlabcentral/fileexchange/25157-image-segmentation-tutorial
%

%% initialization
thresh_mask = 130; % threshold for generating the foreground mask
tolerance_mask = 20; % tolerance for threshold
black_checker = [49; 48; 51];
blue_checker = [34; 63; 147];
green_checker = [67; 149; 74];
red_checker = [180; 49; 57];
colors_checker = cat(2, black_checker, blue_checker, green_checker, red_checker);
OUTPUT = 1; % output flag for exporting result images and text file

%% read in image
img = imread('C:\Users\ycth8\Desktop\32_ecotype_Fall_2017_Round1_Rep1_CS76227_2017-11-17_10-51_top.jpg');
[rows, cols, ~] = size(img);
figure; imshow(img); title('Original Input Image');
img = double(img);

%% get sample color and correct the color of the image
[x, y] = ginput(4); % get graphical input from mouse click
x = round(x);
y = round(y);

black_corrupt = [img(y(1),x(1),1); img(y(1),x(1),2); img(y(1),x(1),3)];
blue_corrupt = [img(y(2),x(2),1); img(y(2),x(2),2); img(y(2),x(2),3)];
green_corrupt = [img(y(3),x(3),1); img(y(3),x(3),2); img(y(3),x(3),3)];
red_corrupt = [img(y(4),x(4),1); img(y(4),x(4),2); img(y(4),x(4),3)];

colors_corrupt = cat(2, black_corrupt, blue_corrupt, green_corrupt, red_corrupt);
pause(1);

correct_mat = colors_checker / colors_corrupt; % color correlation matrix

img_correct = zeros(size(img));
    for i0 = 1:rows
        for j0 = 1:cols
            rgb_out = correct_mat * [img(i0,j0,1); img(i0,j0,2); img(i0,j0,3)];
            img_correct(i0,j0,1) = rgb_out(1);
            img_correct(i0,j0,2) = rgb_out(2);
            img_correct(i0,j0,3) = rgb_out(3);
        end
    end
figure;
imshow(uint8(img_correct)); title('Color Corrected Image');

%% compute the normalized RGB image
img_r = img_correct(:,:,1); % red channel
img_g = img_correct(:,:,2); % green channel
img_b = img_correct(:,:,3); % blue channel
img_sum = img_r + img_g + img_b;
img_r_n = 255 * img_r ./ img_sum; % normalized red channel
img_g_n = 255 * img_g ./ img_sum; % normalized green channel
img_b_n = 255 * img_b ./ img_sum; % normalized blue channel
img_norm = zeros(size(img));
img_norm(:,:,1) = img_r_n;
img_norm(:,:,2) = img_g_n;
img_norm(:,:,3) = img_b_n;
figure;
imshow(uint8(img_norm));  title('Normalized RGB Image');

img_mask = img_g_n;
img_mask(abs(img_mask-thresh_mask)<tolerance_mask) = 1;
img_mask(img_mask~=1) = 0;

%% remove noise and other irrelavant green objects on the picture
se1 = strel('disk', 5);
img_mask = imopen(img_mask, se1); % remove salt-and-pepper noise
img_mask = imclose(img_mask, se1); % fill the holes in the mask

img_mask2 = bwpropfilt(logical(img_mask(50:300,:,:)),'Area',[0 12100]);
img_mask(50:300,:,:) = img_mask2;

img_mask3 = bwpropfilt(logical(img_mask(1150:end,:,:)),'Area',[0 12100]);
img_mask(1150:end,:,:) = img_mask3;

%% calculating leaf area
area_fg = sum(img_mask(:));
area_cm = area_fg / (78^2); %need to confirm this

%% generate foreground image using mask
img_r_fg = img(:,:,1);
img_g_fg = img(:,:,2);
img_b_fg = img(:,:,3);
img_r_fg(img_mask==0) = 0;
img_g_fg(img_mask==0) = 0;
img_b_fg(img_mask==0) = 0;
img_fg = zeros(size(img));
img_fg(:,:,1) = img_r_fg;
img_fg(:,:,2) = img_g_fg;
img_fg(:,:,3) = img_b_fg;
figure; imshow(uint8(img_fg)); title('Foreground Image');

bw_img_fg = rgb2gray(uint8(img_fg));
figure; imshow(bw_img_fg); title('Forground BW Image');

hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(bw_img_fg), hy, 'replicate');
Ix = imfilter(double(bw_img_fg), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);
figure;imshow(gradmag,[]), title('Gradient magnitude (gradmag)');

%% leaves cutting
D = -bwdist(~bw_img_fg);
figure; imshow(D,[]);

mask = imextendedmin(D,2);
figure; imshowpair(img_mask,mask,'blend');

D2 = imimposemin(D,mask);
Ld2 = watershed(D2);
bw3 = img_mask;
bw3(Ld2 == 0) = 0;
figure; imshow(bw3);

if(area_fg<10000)
    se = strel('disk', 5);
    Ie1 = imopen(bw_img_fg, se);
    figure; imshow(Ie1); title('Scope 5 pixels');
    
    D1 = bwdist(Ie1);
    DL1 = watershed(D1);
    bgm1 = DL1 == 0;
    figure;
    imshow(bgm1), title('Watershed ridge lines (bgm1)');
    
    bw3(bgm1~=0)=0;
    figure; imshow(bw3);
    
elseif(area_fg<110000)
    se = strel('disk', 10);
    Ie1 = imerode(bw_img_fg, se);
    figure; imshow(Ie1); title('Scope 10 pixels');
    
    se = strel('disk', 20);
    Ie2 = imerode(bw_img_fg, se);
    figure; imshow(Ie2); title('Scope 20 pixels');
    
%     se = strel('disk', 30);
%     Ie3 = imerode(bw_img_fg, se);
%     figure; imshow(Ie3); title('Scope 30 pixels');

    D1 = bwdist(Ie1);
    DL1 = watershed(D1);
    bgm1 = DL1 == 0;
    figure;
    imshow(bgm1), title('Watershed ridge lines (bgm1)');

    D2 = bwdist(Ie2);
    DL2 = watershed(D2);
    bgm2 = DL2 == 0;
    figure;
    imshow(bgm2), title('Watershed ridge lines (bgm2)');

%     D3 = bwdist(Ie3);
%     DL3 = watershed(D3);
%     bgm3 = DL3 == 0;
%     figure;
%     imshow(bgm3), title('Watershed ridge lines (bgm3)');

    bw3(bgm1~=0)=0;
    bw3(bgm2~=0)=0;
%     bw3(bgm3~=0)=0;
    figure; imshow(bw3);
    
    se = strel('disk', 10);
    bw3 = imopen(bw3, se);
    figure; imshow(bw3);
    
else
    se = strel('disk', 10);
    Ie1 = imerode(bw_img_fg, se);
    figure; imshow(Ie1); title('Scope 10 pixels');
    
    se = strel('disk', 20);
    Ie2 = imerode(bw_img_fg, se);
    figure; imshow(Ie2); title('Scope 20 pixels');
    
    se = strel('disk', 30);
    Ie3 = imerode(bw_img_fg, se);
    figure; imshow(Ie3); title('Scope 30 pixels');

    D1 = bwdist(Ie1);
    DL1 = watershed(D1);
    bgm1 = DL1 == 0;
    figure;
    imshow(bgm1), title('Watershed ridge lines (bgm1)');

    D2 = bwdist(Ie2);
    DL2 = watershed(D2);
    bgm2 = DL2 == 0;
    figure;
    imshow(bgm2), title('Watershed ridge lines (bgm2)');

    D3 = bwdist(Ie3);
    DL3 = watershed(D3);
    bgm3 = DL3 == 0;
    figure;
    imshow(bgm3), title('Watershed ridge lines (bgm3)');

    bw3(bgm1~=0)=0;
    bw3(bgm2~=0)=0;
    bw3(bgm3~=0)=0;
    figure; imshow(bw3);
    
    se = strel('disk', 10);
    bw3 = imopen(bw3, se);
    figure; imshow(bw3);
end

%% leaves labelling and counting
labeledImage = bwlabel(bw3, 8);
figure;imshow(labeledImage, []); 

coloredLabels = label2rgb (labeledImage, 'hsv', 'k', 'shuffle');
figure;imshow(coloredLabels);

blobMeasurements = regionprops(labeledImage, bw_img_fg, 'all');
numberOfBlobs = size(blobMeasurements, 1);

textFontSize = 14;	% Used to control size of "blob number" labels put atop the image.
labelShiftX = -7;

blobTotalArea=0;
blobECD = zeros(numberOfBlobs, 1);

fprintf(1,'Blob #      Mean Intensity  Area   Perimeter    Centroid       Diameter\n');
% Loop over all blobs printing their measurements to the command window.
for k = 1 : numberOfBlobs           % Loop through all blobs.
	% Find the mean of each blob.  (R2008a has a better way where you can pass the original image
	% directly into regionprops.  The way below works for all versions including earlier versions.)
	thisBlobsPixels = blobMeasurements(k).PixelIdxList;  % Get list of pixels in current blob.
	meanGL = mean(bw_img_fg(thisBlobsPixels)); % Find mean intensity (in original image!)
	meanGL2008a = blobMeasurements(k).MeanIntensity; % Mean again, but only for version >= R2008a
	
	blobArea = blobMeasurements(k).Area;		% Get area.
	blobPerimeter = blobMeasurements(k).Perimeter;		% Get perimeter.
	blobCentroid = blobMeasurements(k).Centroid;		% Get centroid one at a time
	blobECD(k) = sqrt(4 * blobArea / pi);					% Compute ECD - Equivalent Circular Diameter.
	fprintf(1,'#%2d %17.1f %11.1f %8.1f %8.1f %8.1f % 8.1f\n', k, meanGL, blobArea, blobPerimeter, blobCentroid, blobECD(k));
	% Put the "blob number" labels on the "boundaries" grayscale image.
	text(blobCentroid(1) + labelShiftX, blobCentroid(2), num2str(k), 'FontSize', textFontSize, 'FontWeight', 'Bold');
    fprintf('\n\nArea of leaves: %d\n\n' , blobArea);
end

%% display results
fprintf('\n\n');
disp(['Total leaf area is ', num2str(area_fg), ' in pixels.']);
disp(['Total leaf area is ', num2str(area_cm), ' in cm^2.']);
fprintf('\n\nNumber of leaves: %d\n\n' , numberOfBlobs);

