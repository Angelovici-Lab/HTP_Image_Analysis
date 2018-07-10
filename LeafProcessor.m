% This leaf processor can be used to parse any Arabidopsis plants.
% Author: Ke Gao, Najwa Nurhidayatun, Yen On Chan
% Use at your own risk.

classdef LeafProcessor < handle
    properties(Access=private)
        
        seperator
        
        topImage = [];
        topImageInDouble = [];
        topImageRows = 0;
        topImageColumns = 0;
        topImageChannels = 0;
        
        sideImage = [];
        sideImageInDouble = [];
        sideImageRows = 0;
        sideImageColumns = 0;
        sideImageChannels = 0;
        
        thresh_mask = 130; % threshold for generating the foreground mask
        tolerance_mask = 20; % tolerance for threshold
        black_checker = [49; 48; 51];
        blue_checker = [34; 63; 147];
        green_checker = [67; 149; 74];
        red_checker = [180; 49; 57];
        colorsChecker = [];
        
        topColorsCorrupt = [];
        sideColorsCorrupt = [];
        
        topCorrectMatrix = [];
        sideCorrectMatrix = [];
        
        topColorCorrectedImage = [];
        sideColorCorrectedImage = [];
        
        topNormalizedImage = [];
        sideNormalizedImage = [];
        
        topImgMaskGreen = [];
        sideImgMaskGreen = [];
        
        topForegroundImage = [];
        sideForegroundImage = [];
        
        topAverageColor = [0,0,0];
        sideAverageColor = [0,0,0];
        
        topForegroundImageWithCC = [];
        sideForegroundImageWithCC = [];
        
        topBWForegroundImage = [];
        sideBWForegroundImage = [];
        
        topBWForegroundImageWithCC = [];
        sideBWForegroundImageWithCC = [];
        
        topGradientMagnitudeImage = [];
        sideGradientMagnitudeImage = [];
        
        topLeavesCutImage = [];
        sideLeavesCutImage = [];
        
        topNumberOfLeaves = 0;
        topLeavesDetails = {};
        topLeavesLabeledImage = [];
        topLeavesTextLabeledImage = [];
        
        topTextFontSize = 30;	% Text size for text on topLeavesLabeledImage
        topLabelShiftX = -15;   % Shift to text position on topLeavesLabeledImage
        topLabelShiftY = -15;
        
        pixelPerCM = 0;
        areaPerPixel = 0;
        lengthPerPixelSide = 0;
        
        topForegroundArea = 0;
        
        csReference_Area = [];
        xArray_Area = [];
        yArray_Area = [];
        xCell_Area = [];
        yCell_Area = [];
        
        csReference_LeafNum = [];
        xArray_LeafNum = [];
        yArray_LeafNum = [];
        xCell_LeafNum = [];
        yCell_LeafNum = [];
        
    end
    properties(Constant, Hidden=true)
        extList={'jpg'};
    end
    methods(Access=private)
        function obj = calculateColorsChecker(obj)
            obj.colorsChecker = cat(2, obj.black_checker, obj.blue_checker, obj.green_checker, obj.red_checker);
        end
        function img_name = getImageNameFromFilePath(obj, filePath)
            dirComponents = strsplit(filePath, '\');
            img_name = dirComponents(size(dirComponents,2));
            img_name = img_name{1};
            img_name = img_name(1:end-4);
        end
    end
    methods
        %% Constructor and Destructor
        % constructor
        function obj = LeafProcessor(topImage, sideImage)
            if(strcmpi(computer,'PCWIN') || strcmpi(computer,'PCWIN64'))
                obj.seperator='\';
            elseif(strcmpi(computer,'GLNX86') || strcmpi(computer,'GLNXA86'))
                obj.seperator='/';
            elseif(strcmpi(computer,'MACI64')) 
                obj.seperator='/';
            end
            if(isempty(topImage) == 0)
                obj.topImage = topImage;
                obj.topImageInDouble = double(topImage);
                [obj.topImageRows, obj.topImageColumns, obj.topImageChannels] = size(topImage);
            end
            if(isempty(sideImage) == 0)
                obj.sideImage = sideImage;
                obj.sideImageInDouble = double(sideImage);
                [obj.sideImageRows, obj.sideImageColumns, obj.sideImageChannels] = size(sideImage);
            end
        end
        % destructor
        function delete(obj)
        end
        %% Get and Set Functions
        % set top image
        function obj = setTopImage(obj, img)
            obj.topImage = [];
            obj.topImage = img;
            obj.topImageInDouble = double(img);
            [obj.topImageRows, obj.topImageColumns, obj.topImageChannels] = size(img);
        end
        % get top image
        function top_image = getTopImage(obj)
            top_image = obj.topImage;
        end
        % set side image
        function obj = setSideImage(obj, img)
            obj.sideImage = [];
            obj.sideImage = img;
            obj.sideImageInDouble = double(img);
            [obj.sideImageRows, obj.sideImageColumns, obj.sideImageChannels] = size(img);
        end
        % get side image
        function side_image = getSideImage(obj)
            side_image = obj.sideImage;
        end
        % set mask threshold
        function obj = setMaskThreshold(obj, threshMask)
            obj.thresh_mask = threshMask;
        end
        % get mask threshold
        function threshold_mask = getMaskThreshold(obj)
            threshold_mask = obj.thresh_mask;
        end
        % set tolerance mask
        function obj = setMaskTolerance(obj, toleranceMask)
            obj.tolerance_mask = toleranceMask;
        end
        % get tolerance mask
        function tolerance_mask = getMaskTolerance(obj)
            tolerance_mask = obj.tolerance_mask;
        end
        % set black checker
        function obj = setBlackChecker(obj, blackChecker)
            obj.black_checker = blackChecker;
        end
        % get black Checker
        function black_checker = getBlackChecker(obj)
            black_checker = obj.black_checker;
        end
        % set blue checker
        function obj = setBlueChecker(obj, blueChecker)
            obj.blue_checker = blueChecker;
        end
        % get blue Checker
        function blue_checker = getBlueChecker(obj)
            blue_checker = obj.blue_checker;
        end
        % set green checker
        function obj = setGreenChecker(obj, greenChecker)
            obj.green_checker = greenChecker;
        end
        % get green Checker
        function green_checker = getGreenChecker(obj)
            green_checker = obj.green_checker;
        end
        % set red checker
        function obj = setRedChecker(obj, redChecker)
            obj.red_checker = redChecker;
        end
        % get red Checker
        function red_checker = getRedChecker(obj)
            red_checker = obj.red_checker;
        end
        % set top image mask (green)
        function obj = setTopImgMaskGreen(obj, topImgMaskGreen)
            obj.topImgMaskGreen = topImgMaskGreen;
        end
        % get top image mask (green)
        function top_img_mask_green = getTopImgMaskGreen(obj)
            top_img_mask_green = obj.topImgMaskGreen;
        end
        % set side image mask (green)
        function obj = setSideImgMaskGreen(obj, sideImgMaskGreen)
            obj.sideImgMaskGreen = sideImgMaskGreen;
        end
        % get side image mask (green)
        function side_img_mask_green = getSideImgMaskGreen(obj)
            side_img_mask_green = obj.sideImgMaskGreen;
        end
        % set Pixel per cm and calculate cm per pixel and cm2 per pixel
        function obj = setPixelPerCM(obj, pixelPerCM)
            obj.pixelPerCM = pixelPerCM;
            obj.lengthPerPixelSide = 1/obj.pixelPerCM;
            obj.areaPerPixel = obj.lengthPerPixelSide ^ 2;
        end
        % get colors checker matrix
        function colors_checker = getColorsChecker(obj)
            colors_checker = obj.colorsChecker;
        end
        % get top colors corrupt matrix
        function top_colors_corrupt = getTopColorsCorrupt(obj)
            top_colors_corrupt = obj.topColorsCorrupt;
        end
        % get side colors corrupt matrix
        function side_colors_corrupt = getSideColorsCorrupt(obj)
            side_colors_corrupt = obj.sideColorsCorrupt;
        end
        %% Generate mask without color correction
        % generate top normalized RGB Image without color correction
        function top_img_norm = generateTopNormalizedImageWithoutCC(obj)
            obj.topColorCorrectedImage = obj.topImageInDouble;
            top_img_norm = obj.generateTopNormalizedImage();
        end
        % generate top green mask without color correction
        function top_img_mask_green = generateTopGreenMaskWithoutCC(obj)
            obj.topImgMaskGreen = obj.topNormalizedImage(:,:,2);
            obj.topImgMaskGreen(abs(obj.topImgMaskGreen-obj.thresh_mask)<obj.tolerance_mask) = 0;
            obj.topImgMaskGreen(obj.topImgMaskGreen~=0) = 1;
            se1 = strel('disk', 5);
            obj.topImgMaskGreen = imopen(obj.topImgMaskGreen, se1); % remove salt-and-pepper noise
            obj.topImgMaskGreen = imclose(obj.topImgMaskGreen, se1); % fill the holes in the mask
            img_mask2 = bwpropfilt(logical(obj.topImgMaskGreen(50:300,:,:)),'Area',[0 12100]);
            obj.topImgMaskGreen(50:300,:,:) = img_mask2;
            img_mask3 = bwpropfilt(logical(obj.topImgMaskGreen(1150:end,:,:)),'Area',[0 12100]);
            obj.topImgMaskGreen(1150:end,:,:) = img_mask3;
            for i=300:-1:1
                if(sum(obj.topImgMaskGreen(:,i,:))==0)  % left
                    obj.topImgMaskGreen(:,1:i,:)=0;
                    break;
                end
            end
            for i=300:-1:1
                if(sum(obj.topImgMaskGreen(i,:,:))==0)  % top
                    obj.topImgMaskGreen(1:i,:,:)=0;
                    break;
                end
            end
            for i=900:size(obj.topImgMaskGreen,1)
                if(sum(obj.topImgMaskGreen(i,:,:))==0)  % bottom
                    obj.topImgMaskGreen(i:end,:,:)=0;
                    break;
                end
            end
            for i=700:size(obj.topImgMaskGreen,2)
                if(sum(obj.topImgMaskGreen(:,i,:))==0)  % right
                    obj.topImgMaskGreen(:,i:end,:)=0;
                    break;
                end
            end
            top_img_mask_green = logical(obj.topImgMaskGreen);
        end
        %% Generate mask after doing color correction
        % get sample colors from top image
        function obj = collectTopSampleColors(obj, img, x, y)
            tempImage = double(img);
            x = round(x);
            y = round(y);
            black_corrupt = [tempImage(y(1),x(1),1); tempImage(y(1),x(1),2); tempImage(y(1),x(1),3)];
            blue_corrupt = [tempImage(y(2),x(2),1); tempImage(y(2),x(2),2); tempImage(y(2),x(2),3)];
            green_corrupt = [tempImage(y(3),x(3),1); tempImage(y(3),x(3),2); tempImage(y(3),x(3),3)];
            red_corrupt = [tempImage(y(4),x(4),1); tempImage(y(4),x(4),2); tempImage(y(4),x(4),3)];
            if(isempty(obj.topColorsCorrupt)==1)
                obj.topColorsCorrupt = cat(2, black_corrupt, blue_corrupt, green_corrupt, red_corrupt);
            else
                obj.topColorsCorrupt = (obj.topColorsCorrupt + cat(2, black_corrupt, blue_corrupt, green_corrupt, red_corrupt))./2;
            end
        end
        % get sample colors from side image
        function obj = collectSideSampleColors(obj, img, x, y)
            tempImage = double(img);
            x = round(x);
            y = round(y);
            black_corrupt = [tempImage(y(1),x(1),1); tempImage(y(1),x(1),2); tempImage(y(1),x(1),3)];
            blue_corrupt = [tempImage(y(2),x(2),1); tempImage(y(2),x(2),2); tempImage(y(2),x(2),3)];
            green_corrupt = [tempImage(y(3),x(3),1); tempImage(y(3),x(3),2); tempImage(y(3),x(3),3)];
            red_corrupt = [tempImage(y(4),x(4),1); tempImage(y(4),x(4),2); tempImage(y(4),x(4),3)];
            if(isempty(obj.sideColorsCorrupt)==1)
                obj.sideColorsCorrupt = cat(2, black_corrupt, blue_corrupt, green_corrupt, red_corrupt);
            else
                obj.sideColorsCorrupt = (obj.sideColorsCorrupt + cat(2, black_corrupt, blue_corrupt, green_corrupt, red_corrupt))./2;
            end
        end
        % generate top correction matrix
        function obj = generateTopColorCorelationalMatrix(obj)
            obj.colorsChecker = [];
            obj = obj.calculateColorsChecker();
            obj.topCorrectMatrix = obj.colorsChecker / obj.topColorsCorrupt; % color corelation matrix
        end
        % generate side correction matrix
        function obj = generateSideColorCorelationalMatrix(obj)
            obj.colorsChecker = [];
            obj = obj.calculateColorsChecker();
            obj.sideCorrectMatrix = obj.colorsChecker / obj.sideColorsCorrupt; % color corelation matrix
        end
        % generate top color corrected image
        function top_color_corrected_image = generateTopColorCorrectedImage(obj)
            obj.topColorCorrectedImage = zeros(size(obj.topImageInDouble));
            for i0 = 1:obj.topImageRows
                for j0 = 1:obj.topImageColumns
                    rgb_out = obj.topCorrectMatrix * [obj.topImageInDouble(i0,j0,1); obj.topImageInDouble(i0,j0,2); obj.topImageInDouble(i0,j0,3)];
                    obj.topColorCorrectedImage(i0,j0,1) = rgb_out(1);
                    obj.topColorCorrectedImage(i0,j0,2) = rgb_out(2);
                    obj.topColorCorrectedImage(i0,j0,3) = rgb_out(3);
                end
            end
            top_color_corrected_image = uint8(obj.topColorCorrectedImage);
        end
        % generate side color corrected image
        function side_color_corrected_image = generateSideColorCorrectedImage(obj)
            obj.sideColorCorrectedImage = zeros(size(obj.sideImageInDouble));
            for i0 = 1:obj.sideImageRows
                for j0 = 1:obj.sideImageColumns
                    rgb_out = obj.sideCorrectMatrix * [obj.sideImageInDouble(i0,j0,1); obj.sideImageInDouble(i0,j0,2); obj.sideImageInDouble(i0,j0,3)];
                    obj.sideColorCorrectedImage(i0,j0,1) = rgb_out(1);
                    obj.sideColorCorrectedImage(i0,j0,2) = rgb_out(2);
                    obj.sideColorCorrectedImage(i0,j0,3) = rgb_out(3);
                end
            end
            side_color_corrected_image = uint8(obj.sideColorCorrectedImage);
        end
        % generate top normalized RGB image
        function top_img_norm = generateTopNormalizedImage(obj)
            img_r = obj.topColorCorrectedImage(:,:,1); % red channel
            img_g = obj.topColorCorrectedImage(:,:,2); % green channel
            img_b = obj.topColorCorrectedImage(:,:,3); % blue channel
            img_sum = img_r + img_g + img_b;
            img_r_n = 255 * img_r ./ img_sum; % normalized red channel
            img_g_n = 255 * img_g ./ img_sum; % normalized green channel
            img_b_n = 255 * img_b ./ img_sum; % normalized blue channel
            obj.topNormalizedImage = zeros(size(obj.topImage));
            obj.topNormalizedImage(:,:,1) = img_r_n;
            obj.topNormalizedImage(:,:,2) = img_g_n;
            obj.topNormalizedImage(:,:,3) = img_b_n;
            top_img_norm = uint8(obj.topNormalizedImage);
        end
        % generate side normalized RGB image
        function side_img_norm = generateSideNormalizedImage(obj)
            img_r = obj.sideColorCorrectedImage(:,:,1); % red channel
            img_g = obj.sideColorCorrectedImage(:,:,2); % green channel
            img_b = obj.sideColorCorrectedImage(:,:,3); % blue channel
            img_sum = img_r + img_g + img_b;
            img_r_n = 255 * img_r ./ img_sum; % normalized red channel
            img_g_n = 255 * img_g ./ img_sum; % normalized green channel
            img_b_n = 255 * img_b ./ img_sum; % normalized blue channel
            obj.sideNormalizedImage = zeros(size(obj.sideImage));
            obj.sideNormalizedImage(:,:,1) = img_r_n;
            obj.sideNormalizedImage(:,:,2) = img_g_n;
            obj.sideNormalizedImage(:,:,3) = img_b_n;
            side_img_norm = uint8(obj.sideNormalizedImage);
        end
        % generate top green mask
        function top_img_mask_green = generateTopGreenMask(obj)
            obj.topImgMaskGreen = obj.topNormalizedImage(:,:,2);
            obj.topImgMaskGreen(abs(obj.topImgMaskGreen-obj.thresh_mask)<obj.tolerance_mask) = 1;
            obj.topImgMaskGreen(obj.topImgMaskGreen~=1) = 0;
            se1 = strel('disk', 5);
            obj.topImgMaskGreen = imopen(obj.topImgMaskGreen, se1); % remove salt-and-pepper noise
            obj.topImgMaskGreen = imclose(obj.topImgMaskGreen, se1); % fill the holes in the mask
%             img_mask2 = bwpropfilt(logical(obj.topImgMaskGreen(50:300,:,:)),'Area',[0 12100]);
%             obj.topImgMaskGreen(50:300,:,:) = img_mask2;
%             img_mask3 = bwpropfilt(logical(obj.topImgMaskGreen(1150:end,:,:)),'Area',[0 12100]);
%             obj.topImgMaskGreen(1150:end,:,:) = img_mask3;
            for i=300:-1:1
                if(sum(obj.topImgMaskGreen(:,i,:))==0)  % left
                    obj.topImgMaskGreen(:,1:i,:)=0;
                    break;
                end
            end
            for i=300:-1:1
                if(sum(obj.topImgMaskGreen(i,:,:))==0)  % top
                    obj.topImgMaskGreen(1:i,:,:)=0;
                    break;
                end
            end
            for i=900:size(obj.topImgMaskGreen,1)
                if(sum(obj.topImgMaskGreen(i,:,:))==0)  % bottom
                    obj.topImgMaskGreen(i:end,:,:)=0;
                    break;
                end
            end
            for i=700:size(obj.topImgMaskGreen,2)
                if(sum(obj.topImgMaskGreen(:,i,:))==0)  % right
                    obj.topImgMaskGreen(:,i:end,:)=0;
                    break;
                end
            end
            top_img_mask_green = logical(obj.topImgMaskGreen);
        end
        % generate side green mask
        function side_img_mask_green = generateSideGreenMask(obj)
            obj.sideImgMaskGreen = obj.sideNormalizedImage(:,:,2);
            obj.sideImgMaskGreen(abs(obj.sideImgMaskGreen-obj.thresh_mask)<obj.tolerance_mask) = 1;
            obj.sideImgMaskGreen(obj.sideImgMaskGreen~=1) = 0;
            se1 = strel('disk', 5);
            obj.sideImgMaskGreen = imopen(obj.sideImgMaskGreen, se1); % remove salt-and-pepper noise
            obj.sideImgMaskGreen = imclose(obj.sideImgMaskGreen, se1); % fill the holes in the mask
            img_mask2 = bwpropfilt(logical(obj.sideImgMaskGreen(50:300,:,:)),'Area',[0 12100]);
            obj.sideImgMaskGreen(50:300,:,:) = img_mask2;
            img_mask3 = bwpropfilt(logical(obj.sideImgMaskGreen(1150:end,:,:)),'Area',[0 12100]);
            obj.sideImgMaskGreen(1150:end,:,:) = img_mask3;
            for i=300:-1:1
                if(sum(obj.sideImgMaskGreen(:,i,:))==0)  % left
                    obj.sideImgMaskGreen(:,1:i,:)=0;
                    break;
                end
            end
            for i=300:-1:1
                if(sum(obj.sideImgMaskGreen(i,:,:))==0)  % top
                    obj.sideImgMaskGreen(1:i,:,:)=0;
                    break;
                end
            end
            for i=900:size(obj.sideImgMaskGreen,1)
                if(sum(obj.sideImgMaskGreen(i,:,:))==0)  % bottom
                    obj.sideImgMaskGreen(i:end,:,:)=0;
                    break;
                end
            end
            for i=700:size(obj.sideImgMaskGreen,2)
                if(sum(obj.sideImgMaskGreen(:,i,:))==0)  % right
                    obj.sideImgMaskGreen(:,i:end,:)=0;
                    break;
                end
            end
            side_img_mask_green = logical(obj.sideImgMaskGreen);
        end
        %% Generate foreground images
        % generate top foreground image and calculate average RGB value
        function [top_foreground_image, top_foreground_image_with_cc, top_average_color] = generateTopForegroundImage(obj)
            area_fg = sum(obj.topImgMaskGreen(:));
            
            img_r_fg = obj.topImageInDouble(:,:,1);
            img_g_fg = obj.topImageInDouble(:,:,2);
            img_b_fg = obj.topImageInDouble(:,:,3);
            img_r_fg(obj.topImgMaskGreen==0) = 0;
            img_g_fg(obj.topImgMaskGreen==0) = 0;
            img_b_fg(obj.topImgMaskGreen==0) = 0;
            obj.topForegroundImage = zeros(size(obj.topImage));
            obj.topForegroundImage(:,:,1) = img_r_fg;
            obj.topForegroundImage(:,:,2) = img_g_fg;
            obj.topForegroundImage(:,:,3) = img_b_fg;
            if(area_fg == 0)
                obj.topAverageColor(1) = 0;
                obj.topAverageColor(2) = 0;
                obj.topAverageColor(3) = 0;
            else
                obj.topAverageColor(1) = sum(img_r_fg(:))/area_fg;
                obj.topAverageColor(2) = sum(img_g_fg(:))/area_fg;
                obj.topAverageColor(3) = sum(img_b_fg(:))/area_fg;
            end
            top_average_color = obj.topAverageColor;
            top_foreground_image = uint8(obj.topForegroundImage);
            
            img_r_fg = obj.topNormalizedImage(:,:,1);
            img_g_fg = obj.topNormalizedImage(:,:,2);
            img_b_fg = obj.topNormalizedImage(:,:,3);
            img_r_fg(obj.topImgMaskGreen==0) = 0;
            img_g_fg(obj.topImgMaskGreen==0) = 0;
            img_b_fg(obj.topImgMaskGreen==0) = 0;
            obj.topForegroundImageWithCC = zeros(size(obj.topImage));
            obj.topForegroundImageWithCC(:,:,1) = img_r_fg;
            obj.topForegroundImageWithCC(:,:,2) = img_g_fg;
            obj.topForegroundImageWithCC(:,:,3) = img_b_fg;
            top_foreground_image_with_cc = uint8(obj.topForegroundImageWithCC);
        end
        % generate side foreground image
        function [side_foreground_image, side_foreground_image_with_cc, side_average_color] = generateSideForegroundImage(obj)
            area_fg = sum(obj.topImgMaskGreen(:));
            
            img_r_fg = obj.sideImageInDouble(:,:,1);
            img_g_fg = obj.sideImageInDouble(:,:,2);
            img_b_fg = obj.sideImageInDouble(:,:,3);
            img_r_fg(obj.sideImgMaskGreen==0) = 0;
            img_g_fg(obj.sideImgMaskGreen==0) = 0;
            img_b_fg(obj.sideImgMaskGreen==0) = 0;
            obj.sideForegroundImage = zeros(size(obj.sideImage));
            obj.sideForegroundImage(:,:,1) = img_r_fg;
            obj.sideForegroundImage(:,:,2) = img_g_fg;
            obj.sideForegroundImage(:,:,3) = img_b_fg;
            if(area_fg == 0)
                obj.sideAverageColor(1) = 0;
                obj.sideAverageColor(2) = 0;
                obj.sideAverageColor(3) = 0;
            else
                obj.sideAverageColor(1) = sum(img_r_fg(:))/area_fg;
                obj.sideAverageColor(2) = sum(img_g_fg(:))/area_fg;
                obj.sideAverageColor(3) = sum(img_b_fg(:))/area_fg;
            end
            side_average_color = obj.sideAverageColor;
            side_foreground_image = uint8(obj.sideForegroundImage);
            
            img_r_fg = obj.sideNormalizedImage(:,:,1);
            img_g_fg = obj.sideNormalizedImage(:,:,2);
            img_b_fg = obj.sideNormalizedImage(:,:,3);
            img_r_fg(obj.sideImgMaskGreen==0) = 0;
            img_g_fg(obj.sideImgMaskGreen==0) = 0;
            img_b_fg(obj.sideImgMaskGreen==0) = 0;
            obj.sideForegroundImageWithCC = zeros(size(obj.sideImage));
            obj.sideForegroundImageWithCC(:,:,1) = img_r_fg;
            obj.sideForegroundImageWithCC(:,:,2) = img_g_fg;
            obj.sideForegroundImageWithCC(:,:,3) = img_b_fg;
            side_foreground_image_with_cc = uint8(obj.sideForegroundImageWithCC);
        end
        % generate top black and white foreground image
        function top_BW_foreground_image = generateTopBWForegroundImage(obj)
            obj.topBWForegroundImage = rgb2gray(uint8(obj.topForegroundImage));
            top_BW_foreground_image = obj.topBWForegroundImage;
        end
        % generate side black and white foreground image
        function side_BW_foreground_image = generateSideBWForegroundImage(obj)
            obj.sideBWForegroundImage = rgb2gray(uint8(obj.sideForegroundImage));
            side_BW_foreground_image = obj.sideBWForegroundImage;
        end
        %% Generate gradient magnitude image
        % generate top gradient magnitude image
        function top_gradient_magnitude_image = generateTopGradientMagnitudeImage(obj)
            hy = fspecial('sobel');
            hx = hy';
            Iy = imfilter(double(obj.topBWForegroundImage), hy, 'replicate');
            Ix = imfilter(double(obj.topBWForegroundImage), hx, 'replicate');
            obj.topGradientMagnitudeImage = sqrt(Ix.^2 + Iy.^2);
            top_gradient_magnitude_image = uint8(obj.topGradientMagnitudeImage);
        end
        % generate side gradient magnitude image
        function side_gradient_magnitude_image = generateSideGradientMagnitudeImage(obj)
            hy = fspecial('sobel');
            hx = hy';
            Iy = imfilter(double(obj.sideBWForegroundImage), hy, 'replicate');
            Ix = imfilter(double(obj.sideBWForegroundImage), hx, 'replicate');
            obj.sideGradientMagnitudeImage = sqrt(Ix.^2 + Iy.^2);
            side_gradient_magnitude_image = uint8(obj.sideGradientMagnitudeImage);
        end
        %% Leaves cutting
        % generate top leaves cut image
        function top_leaves_cut_image = generateTopLeavesCutImage(obj)
            area_fg = sum(obj.topImgMaskGreen(:));
            D = -bwdist(~obj.topBWForegroundImage);
            mask = imextendedmin(D,2);
            D = imimposemin(D,mask);
            D = watershed(D);
            obj.topLeavesCutImage = obj.topImgMaskGreen;
            obj.topLeavesCutImage(D == 0) = 0;

%             if(area_fg<10000)
%                 se = strel('disk', 5);
%                 Ie1 = imopen(obj.topBWForegroundImage, se);
% 
%                 D1 = bwdist(Ie1);
%                 DL1 = watershed(D1);
%                 bgm1 = DL1 == 0;
% 
%                 obj.topLeavesCutImage(bgm1~=0)=0;
% 
%             elseif(area_fg<110000)
%                 se = strel('disk', 10);
%                 Ie1 = imerode(obj.topBWForegroundImage, se);
% 
%                 se = strel('disk', 20);
%                 Ie2 = imerode(obj.topBWForegroundImage, se);
% 
%                 D1 = bwdist(Ie1);
%                 DL1 = watershed(D1);
%                 bgm1 = DL1 == 0;
% 
%                 D2 = bwdist(Ie2);
%                 DL2 = watershed(D2);
%                 bgm2 = DL2 == 0;
% 
%                 obj.topLeavesCutImage(bgm1~=0)=0;
%                 obj.topLeavesCutImage(bgm2~=0)=0;
% 
%                 se = strel('disk', 8);
%                 obj.topLeavesCutImage = imopen(obj.topLeavesCutImage, se);
%             else
%                 se = strel('disk', 10);
%                 Ie1 = imerode(obj.topBWForegroundImage, se);
% 
%                 se = strel('disk', 20);
%                 Ie2 = imerode(obj.topBWForegroundImage, se);
% 
%                 se = strel('disk', 30);
%                 Ie3 = imerode(obj.topBWForegroundImage, se);
% 
%                 D1 = bwdist(Ie1);
%                 DL1 = watershed(D1);
%                 bgm1 = DL1 == 0;
% 
%                 D2 = bwdist(Ie2);
%                 DL2 = watershed(D2);
%                 bgm2 = DL2 == 0;
% 
%                 D3 = bwdist(Ie3);
%                 DL3 = watershed(D3);
%                 bgm3 = DL3 == 0;
% 
%                 obj.topLeavesCutImage(bgm1~=0)=0;
%                 obj.topLeavesCutImage(bgm2~=0)=0;
%                 obj.topLeavesCutImage(bgm3~=0)=0;
%                 
%                 se = strel('disk', 8);
%                 obj.topLeavesCutImage = imopen(obj.topLeavesCutImage, se);
%             end
            top_leaves_cut_image = logical(obj.topLeavesCutImage);
        end
        %% Leaves counting
        % generate top leaves counted image
        function [foreground_area, number_of_leaves, top_average_color, leaves_details, top_leaves_labeled_image, top_leaves_text_labeled_image] = generateTopLeavesCountedImage(obj)
            foreground_area = sum(obj.topImgMaskGreen(:)) * obj.areaPerPixel;
            labeledImage = bwlabel(obj.topLeavesCutImage, 8);

            obj.topLeavesLabeledImage = label2rgb (labeledImage, 'hsv', 'k', 'shuffle');
            obj.topLeavesTextLabeledImage = obj.topLeavesLabeledImage;
            
            blobMeasurements = regionprops(labeledImage, obj.topBWForegroundImage, 'all');
            obj.topNumberOfLeaves = size(blobMeasurements, 1);
            
            obj.topLeavesDetails = {'Leaf_Number', 'Mean_Intensity', 'Area_(cm2)', 'Perimeter_(cm)', 'Centroid_X', 'Centroid_Y', 'Diameter_(cm)'};
            
            for k = 1 : obj.topNumberOfLeaves
                thisBlobsPixels = blobMeasurements(k).PixelIdxList;         % Get list of pixels in current blob.
                meanGL = mean(obj.topBWForegroundImage(thisBlobsPixels));   % Find mean intensity (in original image!)
                blobArea = blobMeasurements(k).Area;                        % Get area.
                blobPerimeter = blobMeasurements(k).Perimeter;              % Get perimeter.
                blobCentroid = blobMeasurements(k).Centroid;                % Get centroid one at a time
                blobECD = sqrt(4 * blobArea / pi);                          % Compute ECD - Equivalent Circular Diameter.
                obj.topLeavesDetails = [obj.topLeavesDetails; {k, meanGL, blobArea*obj.areaPerPixel, blobPerimeter*obj.lengthPerPixelSide, blobCentroid(1), blobCentroid(2), blobECD*obj.lengthPerPixelSide}];
                obj.topLeavesTextLabeledImage = insertText(obj.topLeavesTextLabeledImage,[blobCentroid(1)+obj.topLabelShiftX, blobCentroid(2)+obj.topLabelShiftY],...
                                                            num2str(k),'FontSize',obj.topTextFontSize,'BoxOpacity',0);
            end
            number_of_leaves = obj.topNumberOfLeaves;
            top_average_color = obj.topAverageColor;
            leaves_details = obj.topLeavesDetails;
            top_leaves_labeled_image = uint8(obj.topLeavesLabeledImage);
            top_leaves_text_labeled_image = uint8(obj.topLeavesTextLabeledImage);
        end
        %% Export images
        % export top color corrected image
        function exportTopColorCorrectedImage(obj, filePath)
            img_name = obj.getImageNameFromFilePath(filePath);
            if(numel(find(strcmpi(filePath(end-2:end), obj.extList)))==1)
                out_path = filePath(1:end-4);
                if(exist(out_path, 'dir')==0)
                    mkdir(out_path);
                end
                save_path = strcat(out_path, obj.seperator, img_name, '_Correct.png');
                imwrite(uint8(obj.topColorCorrectedImage), save_path);
            end
        end
        % export top green mask
        function exportTopGreenMask(obj, filePath)
            img_name = obj.getImageNameFromFilePath(filePath);
            if(numel(find(strcmpi(filePath(end-2:end), obj.extList)))==1)
                out_path = filePath(1:end-4);
                if(exist(out_path, 'dir')==0)
                    mkdir(out_path);
                end
                save_path = strcat(out_path, obj.seperator, img_name, '_FGMask.png');
                imwrite(obj.topImgMaskGreen, save_path);
            end
        end
        % export top foreground image
        function exportTopForegroundImage(obj, filePath)
            img_name = obj.getImageNameFromFilePath(filePath);
            if(numel(find(strcmpi(filePath(end-2:end), obj.extList)))==1)
                out_path = filePath(1:end-4);
                if(exist(out_path, 'dir')==0)
                    mkdir(out_path);
                end
                save_path = strcat(out_path, obj.seperator, img_name, '_ImgFG.png');
                imwrite(uint8(obj.topForegroundImage), save_path);
            end
        end
        % export top leaves cut image
        function exportTopLeavesCutImage(obj, filePath)
            img_name = obj.getImageNameFromFilePath(filePath);
            if(numel(find(strcmpi(filePath(end-2:end), obj.extList)))==1)
                out_path = filePath(1:end-4);
                if(exist(out_path, 'dir')==0)
                    mkdir(out_path);
                end
                save_path = strcat(out_path, obj.seperator, img_name, '_line.png');
                imwrite(obj.topLeavesCutImage, save_path);
            end
        end
        % export top leaves text labeled image
        function exportTopLeavesTextLabeledImage(obj, filePath)
            img_name = obj.getImageNameFromFilePath(filePath);
            if(numel(find(strcmpi(filePath(end-2:end), obj.extList)))==1)
                out_path = filePath(1:end-4);
                if(exist(out_path, 'dir')==0)
                    mkdir(out_path);
                end
                save_path = strcat(out_path, obj.seperator, img_name, '_Tpseudo.png');
                imwrite(obj.topLeavesTextLabeledImage, save_path);
            end
        end
        %% Export excel files
        % Export leaves number
        function exportLeavesData(obj, filePath, foreground_area, number_of_leaves, top_average_color, leaves_details)
            img_name = obj.getImageNameFromFilePath(filePath);
            if(numel(find(strcmpi(filePath(end-2:end), obj.extList)))==1)
                out_path = filePath(1:end-4);
                if(exist(out_path, 'dir')==0)
                    mkdir(out_path);
                end
                save_path = strcat(out_path, '_Info.xlsx');
                xlswrite(save_path,cell(100, 100));
                sheet = 1;
                xlRange = 'A1';
                xlswrite(save_path,{'Foreground_Area'},sheet,xlRange);
                xlRange = 'A2';
                xlswrite(save_path,foreground_area,sheet,xlRange);
                xlRange = 'C1';
                xlswrite(save_path,{'Number_of_Leaves'},sheet,xlRange);
                xlRange = 'C2';
                xlswrite(save_path,number_of_leaves,sheet,xlRange);
                xlRange = 'E1';
                xlswrite(save_path,{'Plant_Average_Color_(Red)', 'Plant_Average_Color_(Green)', 'Plant_Average_Color_(Blue)'},sheet,xlRange);
                xlRange = 'E2';
                xlswrite(save_path,top_average_color,sheet,xlRange);
                xlRange = 'A5';
                xlswrite(save_path,leaves_details,sheet,xlRange);
            end
        end
        % Export Experiment Name, CS Number, Rep Number, Leaves Number and
        % Foreground Area in one Excel Sheet
        function exportLeavesTable(obj, filePath, rowNumber, foreground_area, number_of_leaves, top_average_color)
            savePath = [];
            expName = [];
            roundNum = [];
            rep = [];
            csNum = [];
            date = [];
            dirComponents = strsplit(filePath, '\');
            for i = 1:size(dirComponents, 2)
                dirComp = dirComponents(i);
                dirComp = dirComp{1};
                if(isempty(rep) == 1 && length(dirComp) > 3)
                    if(strcmp(dirComp(1:3), "Rep")==1)
                        rep = dirComp;
                        dirCompTemp = dirComponents(i-1);
                        roundNum = dirCompTemp{1};
                        dirCompTemp = dirComponents(i-2);
                        expName = dirCompTemp{1};
                        savePath = strsplit(filePath, rep);
                        savePath = savePath(1);
                        savePath = savePath{1};
                    end
                end
                if(isempty(csNum) == 1 && length(dirComp) > 2)
                    if(strcmp(dirComp(1:2), "CS")==1)
                        csNum = dirComp;
                        dirCompTemp = dirComponents(i+1);
                        date = dirCompTemp{1};
                    end
                end
            end
            save_path = strcat(savePath, 'LeavesTable_Info.xlsx');
            title = {'Experiment_Name', 'Round_Number', 'Rep_Number', 'CS_Number', ...
                        'Date', 'Number_of_Leaves', 'Foreground_Area_(cm2)', ...
                        'Plant_Average_Color_(Red)', 'Plant_Average_Color_(Green)', 'Plant_Average_Color_(Blue)'};
            content = {expName, roundNum, rep, csNum, date, number_of_leaves, foreground_area, top_average_color(1), top_average_color(2), top_average_color(3)};
            sheet = 1;
            xlswrite(save_path,title,sheet,'A1');
            xlRange = strcat('A', num2str(rowNumber+1));
            xlswrite(save_path,content,sheet,xlRange);
            xlRange = strcat('A', num2str(rowNumber+2));
            xlswrite(save_path,cell(100, 100), sheet, xlRange);
        end
        %% Plot graphs
        % Plot area graph for each CS number
        function plotAreaGraph(obj, filePath, foreground_area)
            rep = [];
            date = [];
            csNum = [];
            dirComponents = strsplit(filePath, '\');
            for i = 1:size(dirComponents, 2)
                dirComp = dirComponents(i);
                dirComp = dirComp{1};
                if(isempty(rep) == 1 && length(dirComp) > 3)
                    if(strcmp(dirComp(1:3), "Rep")==1)
                        rep = dirComp;
                        savePath = strsplit(filePath, rep);
                        savePath = savePath(1);
                        savePath = savePath{1};
                    end
                end
                if(isempty(csNum) == 1 && length(dirComp) > 2)
                    if(strcmp(dirComp(1:2), "CS")==1)
                        csNum = dirComp;
                        dirCompTemp = dirComponents(i+1);
                        date = dirCompTemp{1};
                    end
                end
            end
            savePath = strcat(savePath, 'Area_Graphs', obj.seperator);
            graphTitle = strcat('Graph of Plant Total Area Versus Time - (', csNum, ')');
            if(exist(savePath, 'dir') == 0)
                mkdir(savePath);
            end
            savePath = strcat(savePath, csNum, '.png');
            if(isempty(obj.csReference_Area)==1)
                obj.csReference_Area = csNum;
                obj.xArray_Area = [obj.xArray_Area, datetime(date,'InputFormat','yyyy-MM-dd')];
                obj.yArray_Area = [obj.yArray_Area, foreground_area];
            elseif(strcmpi(obj.csReference_Area, csNum)==0)
                obj.csReference_Area = csNum;
                obj.xArray_Area = [];
                obj.yArray_Area = [];
                obj.xCell_Area = [];
                obj.yCell_Area = [];
                obj.xArray_Area = [obj.xArray_Area, datetime(date,'InputFormat','yyyy-MM-dd')];
                obj.yArray_Area = [obj.yArray_Area, foreground_area];
            else
                if(strcmpi(rep, "Rep1") == 1)
                    obj.xArray_Area = [obj.xArray_Area, datetime(date,'InputFormat','yyyy-MM-dd')];
                    obj.yArray_Area = [obj.yArray_Area, foreground_area];
%                     fig = figure('visible','off'); hold on;
%                     plot(obj.xArray_Area, obj.yArray_Area, '-r'); hold off;
%                     title(graphTitle);
%                     ylabel('Plant Total Area in cm2')
%                     xlabel('Time');
%                     legend('Rep 1', 'Location', 'best');
%                     saveas(fig, savePath);
%                     pause(1);
                elseif(strcmpi(rep, "Rep2") == 1)
                    if(isempty(obj.xCell_Area)==1)
                        obj.xCell_Area = {obj.xArray_Area};
                        obj.xArray_Area = [];
                    end
                    if(isempty(obj.yCell_Area)==1)
                        obj.yCell_Area = {obj.yArray_Area};
                        obj.yArray_Area = [];
                    end
                    obj.xArray_Area = [obj.xArray_Area, datetime(date,'InputFormat','yyyy-MM-dd')];
                    obj.yArray_Area = [obj.yArray_Area, foreground_area];
                    fig = figure('visible','off');
                    plot(obj.xCell_Area{1}, obj.yCell_Area{1}, '-ro'); hold on;
                    plot(obj.xArray_Area, obj.yArray_Area, '--b+'); hold off;
                    title(graphTitle);
                    ylabel('Plant Total Area in cm2');
                    xlabel('Time');
                    legend('Rep 1','Rep 2', 'Location', 'best');
                    saveas(fig, savePath);
                elseif(strcmpi(rep, "Rep3") == 1)
                    if(size(obj.xCell_Area, 1)==1)
                        tempCell = {obj.xArray_Area};
                        obj.xCell_Area = [obj.xCell_Area; tempCell];
                        obj.xArray_Area = [];
                    end
                    if(size(obj.yCell_Area, 1)==1)
                        tempCell = {obj.yArray_Area};
                        obj.yCell_Area = [obj.yCell_Area; tempCell];
                        obj.yArray_Area = [];
                    end
                    obj.xArray_Area = [obj.xArray_Area, datetime(date,'InputFormat','yyyy-MM-dd')];
                    obj.yArray_Area = [obj.yArray_Area, foreground_area];
                    fig = figure('visible','off');
                    plot(obj.xCell_Area{1}, obj.yCell_Area{1}, '-ro'); hold on;
                    plot(obj.xCell_Area{2}, obj.yCell_Area{2}, '--b+');
                    plot(obj.xArray_Area, obj.yArray_Area, ':g*'); hold off;
                    title(graphTitle);
                    ylabel('Plant Total Area in cm2');
                    xlabel('Time');
                    legend('Rep 1','Rep 2', 'Rep 3', 'Location', 'best');
                    saveas(fig, savePath);
                elseif(strcmpi(rep, "Rep4") == 1)
                    if(size(obj.xCell_Area, 1)==2)
                        tempCell = {obj.xArray_Area};
                        obj.xCell_Area = [obj.xCell_Area; tempCell];
                        obj.xArray_Area = [];
                    end
                    if(size(obj.yCell_Area, 1)==2)
                        tempCell = {obj.yArray_Area};
                        obj.yCell_Area = [obj.yCell_Area; tempCell];
                        obj.yArray_Area = [];
                    end
                    obj.xArray_Area = [obj.xArray_Area, datetime(date,'InputFormat','yyyy-MM-dd')];
                    obj.yArray_Area = [obj.yArray_Area, foreground_area];
                    fig = figure('visible','off');
                    plot(obj.xCell_Area{1}, obj.yCell_Area{1}, '-ro'); hold on;
                    plot(obj.xCell_Area{2}, obj.yCell_Area{2}, '--b+');
                    plot(obj.xCell_Area{3}, obj.yCell_Area{3}, ':g*');
                    plot(obj.xArray_Area, obj.yArray_Area, '-.m.'); hold off;
                    title(graphTitle);
                    ylabel('Plant Total Area in cm2');
                    xlabel('Time');
                    legend('Rep 1','Rep 2', 'Rep 3', 'Rep 4', 'Location', 'best');
                    saveas(fig, savePath);
                else
                    if(size(obj.xCell_Area, 1)==3)
                        tempCell = {obj.xArray_Area};
                        obj.xCell_Area = [obj.xCell_Area; tempCell];
                        obj.xArray_Area = [];
                    end
                    if(size(obj.yCell_Area, 1)==3)
                        tempCell = {obj.yArray_Area};
                        obj.yCell_Area = [obj.yCell_Area; tempCell];
                        obj.yArray_Area = [];
                    end
                    obj.xArray_Area = [obj.xArray_Area, datetime(date,'InputFormat','yyyy-MM-dd')];
                    obj.yArray_Area = [obj.yArray_Area, foreground_area];
                    fig = figure('visible','off');
                    plot(obj.xCell_Area{1}, obj.yCell_Area{1}, '-ro'); hold on;
                    plot(obj.xCell_Area{2}, obj.yCell_Area{2}, '--b+');
                    plot(obj.xCell_Area{3}, obj.yCell_Area{3}, ':g*');
                    plot(obj.xCell_Area{4}, obj.yCell_Area{4}, '-.m.');
                    plot(obj.xArray_Area, obj.yArray_Area, '-cx'); hold off;
                    title(graphTitle);
                    ylabel('Plant Total Area in cm2');
                    xlabel('Time');
                    legend('Rep 1','Rep 2', 'Rep 3', 'Rep 4', 'Rep5', 'Location', 'best');
                    saveas(fig, savePath);
                end
            end
        end
        % Plot leaf number graph for each cs number
        function plotLeafCountGraph(obj, filePath, number_of_leaves)
            rep = [];
            date = [];
            csNum = [];
            dirComponents = strsplit(filePath, '\');
            for i = 1:size(dirComponents, 2)
                dirComp = dirComponents(i);
                dirComp = dirComp{1};
                if(isempty(rep) == 1 && length(dirComp) > 3)
                    if(strcmp(dirComp(1:3), "Rep")==1)
                        rep = dirComp;
                        savePath = strsplit(filePath, rep);
                        savePath = savePath(1);
                        savePath = savePath{1};
                    end
                end
                if(isempty(csNum) == 1 && length(dirComp) > 2)
                    if(strcmp(dirComp(1:2), "CS")==1)
                        csNum = dirComp;
                        dirCompTemp = dirComponents(i+1);
                        date = dirCompTemp{1};
                    end
                end
            end
            savePath = strcat(savePath, 'Leaf_Count_Graphs', obj.seperator);
            graphTitle = strcat('Graph of Leaf Count Versus Time - (', csNum, ')');
            if(exist(savePath, 'dir') == 0)
                mkdir(savePath);
            end
            savePath = strcat(savePath, csNum, '.png');
            if(isempty(obj.csReference_LeafNum)==1)
                obj.csReference_LeafNum = csNum;
                obj.xArray_LeafNum = [obj.xArray_LeafNum, datetime(date,'InputFormat','yyyy-MM-dd')];
                obj.yArray_LeafNum = [obj.yArray_LeafNum, number_of_leaves];
            elseif(strcmpi(obj.csReference_LeafNum, csNum)==0)
                obj.csReference_LeafNum = csNum;
                obj.xArray_LeafNum = [];
                obj.yArray_LeafNum = [];
                obj.xCell_LeafNum = [];
                obj.yCell_LeafNum = [];
                obj.xArray_LeafNum = [obj.xArray_LeafNum, datetime(date,'InputFormat','yyyy-MM-dd')];
                obj.yArray_LeafNum = [obj.yArray_LeafNum, number_of_leaves];
            else
                if(strcmpi(rep, "Rep1") == 1)
                    obj.xArray_LeafNum = [obj.xArray_LeafNum, datetime(date,'InputFormat','yyyy-MM-dd')];
                    obj.yArray_LeafNum = [obj.yArray_LeafNum, number_of_leaves];
%                     fig = figure('visible','off'); hold on;
%                     plot(obj.xArray_LeafNum, obj.yArray_LeafNum, '-r'); hold off;
%                     title(graphTitle);
%                     ylabel('Leaf Count');
%                     xlabel('Time');
%                     legend('Rep 1', 'Location', 'best');
%                     saveas(fig, savePath);
                elseif(strcmpi(rep, "Rep2") == 1)
                    if(isempty(obj.xCell_LeafNum)==1)
                        obj.xCell_LeafNum = {obj.xArray_LeafNum};
                        obj.xArray_LeafNum = [];
                    end
                    if(isempty(obj.yCell_LeafNum)==1)
                        obj.yCell_LeafNum = {obj.yArray_LeafNum};
                        obj.yArray_LeafNum = [];
                    end
                    obj.xArray_LeafNum = [obj.xArray_LeafNum, datetime(date,'InputFormat','yyyy-MM-dd')];
                    obj.yArray_LeafNum = [obj.yArray_LeafNum, number_of_leaves];
                    fig = figure('visible','off');
                    plot(obj.xCell_LeafNum{1}, obj.yCell_LeafNum{1}, '-ro'); hold on;
                    plot(obj.xArray_LeafNum, obj.yArray_LeafNum, '--b+'); hold off;
                    title(graphTitle);
                    ylabel('Leaf Count');
                    xlabel('Time');
                    legend('Rep 1','Rep 2', 'Location', 'best');
                    saveas(fig, savePath);
                elseif(strcmpi(rep, "Rep3") == 1)
                    if(size(obj.xCell_LeafNum, 1)==1)
                        tempCell = {obj.xArray_LeafNum};
                        obj.xCell_LeafNum = [obj.xCell_LeafNum; tempCell];
                        obj.xArray_LeafNum = [];
                    end
                    if(size(obj.yCell_LeafNum, 1)==1)
                        tempCell = {obj.yArray_LeafNum};
                        obj.yCell_LeafNum = [obj.yCell_LeafNum; tempCell];
                        obj.yArray_LeafNum = [];
                    end
                    obj.xArray_LeafNum = [obj.xArray_LeafNum, datetime(date,'InputFormat','yyyy-MM-dd')];
                    obj.yArray_LeafNum = [obj.yArray_LeafNum, number_of_leaves];
                    fig = figure('visible','off');
                    plot(obj.xCell_LeafNum{1}, obj.yCell_LeafNum{1}, '-ro'); hold on;
                    plot(obj.xCell_LeafNum{2}, obj.yCell_LeafNum{2}, '--b+');
                    plot(obj.xArray_LeafNum, obj.yArray_LeafNum, ':g*'); hold off;
                    title(graphTitle);
                    ylabel('Leaf Count');
                    xlabel('Time');
                    legend('Rep 1','Rep 2', 'Rep 3', 'Location', 'best');
                    saveas(fig, savePath);
                elseif(strcmpi(rep, "Rep4") == 1)
                    if(size(obj.xCell_LeafNum, 1)==2)
                        tempCell = {obj.xArray_LeafNum};
                        obj.xCell_LeafNum = [obj.xCell_LeafNum; tempCell];
                        obj.xArray_LeafNum = [];
                    end
                    if(size(obj.yCell_LeafNum, 1)==2)
                        tempCell = {obj.yArray_LeafNum};
                        obj.yCell_LeafNum = [obj.yCell_LeafNum; tempCell];
                        obj.yArray_LeafNum = [];
                    end
                    obj.xArray_LeafNum = [obj.xArray_LeafNum, datetime(date,'InputFormat','yyyy-MM-dd')];
                    obj.yArray_LeafNum = [obj.yArray_LeafNum, number_of_leaves];
                    fig = figure('visible','off');
                    plot(obj.xCell_LeafNum{1}, obj.yCell_LeafNum{1}, '-ro'); hold on;
                    plot(obj.xCell_LeafNum{2}, obj.yCell_LeafNum{2}, '--b+');
                    plot(obj.xCell_LeafNum{3}, obj.yCell_LeafNum{3}, ':g*');
                    plot(obj.xArray_LeafNum, obj.yArray_LeafNum, '-.m.'); hold off;
                    title(graphTitle);
                    ylabel('Leaf Count');
                    xlabel('Time');
                    legend('Rep 1','Rep 2', 'Rep 3', 'Rep 4', 'Location', 'best');
                    saveas(fig, savePath);
                else
                    if(size(obj.xCell_LeafNum, 1)==3)
                        tempCell = {obj.xArray_LeafNum};
                        obj.xCell_LeafNum = [obj.xCell_LeafNum; tempCell];
                        obj.xArray_LeafNum = [];
                    end
                    if(size(obj.yCell_LeafNum, 1)==3)
                        tempCell = {obj.yArray_LeafNum};
                        obj.yCell_LeafNum = [obj.yCell_LeafNum; tempCell];
                        obj.yArray_LeafNum = [];
                    end
                    obj.xArray_LeafNum = [obj.xArray_LeafNum, datetime(date,'InputFormat','yyyy-MM-dd')];
                    obj.yArray_LeafNum = [obj.yArray_LeafNum, number_of_leaves];
                    fig = figure('visible','off');
                    plot(obj.xCell_LeafNum{1}, obj.yCell_LeafNum{1}, '-ro'); hold on;
                    plot(obj.xCell_LeafNum{2}, obj.yCell_LeafNum{2}, '--b+');
                    plot(obj.xCell_LeafNum{3}, obj.yCell_LeafNum{3}, ':g*');
                    plot(obj.xCell_LeafNum{4}, obj.yCell_LeafNum{4}, '-.m.');
                    plot(obj.xArray_LeafNum, obj.yArray_LeafNum, '-cx'); hold off;
                    title(graphTitle);
                    ylabel('Leaf Count');
                    xlabel('Time');
                    legend('Rep 1','Rep 2', 'Rep 3', 'Rep 4', 'Rep5', 'Location', 'best');
                    saveas(fig, savePath);
                end
            end
        end
    end
end