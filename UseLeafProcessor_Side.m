clc; clear all;
img = imread('C:\Users\ycth8\Desktop\32_ecotype_Fall_2017_Round1_Rep1_CS76098_2017-11-08_09-52_top.jpg');
s = LeafProcessor([], img);
figure;imshow(img);title('Original Side Image');[x, y]=ginput(4);
s = s.collectSideSampleColors(img, x, y);
s = s.generateSideColorCorelationalMatrix();
figure;imshow(s.generateSideColorCorrectedImage());title('Color Corrected Side Image');
figure;imshow(s.generateSideNormalizedImage());title('Normalized Side Image');
figure;imshow(s.generateSideGreenMask());title('Side Green Mask');
figure;imshow(s.generateSideForegroundImage());title('Side Foreground Image');
figure;imshow(s.generateSideBWForegroundImage());title('Side BW Foreground Image');
figure;imshow(s.generateSideGradientMagnitudeImage());title('Side Gradient Magnitude Image');

