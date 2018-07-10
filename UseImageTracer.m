clc; clear all;
s1 = ImageTracer('C:\Users\ycth8\Desktop\HTP_Analysis\Image_data');
file_list1 = s1.traceAllTopImages(s1.getDirectory());


s2 = ImageTracer('C:\Users\ycth8\Desktop\HTP_Analysis\Image_data');
file_list2 = s2.traceIncompletedTopImages(s2.getDirectory());


s3 = ImageTracer('C:\Users\ycth8\Desktop\hello');
file_list3 = s3.traceAllSideImages(s3.getDirectory());


s4 = ImageTracer('C:\Users\ycth8\Desktop\hello');
file_list4 = s4.traceIncompletedSideImages(s4.getDirectory());