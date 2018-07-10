function varargout = HTP_Image_Analysis(varargin)
% HTP_IMAGE_ANALYSIS MATLAB code for HTP_Image_Analysis.fig
%      HTP_IMAGE_ANALYSIS, by itself, creates a new HTP_IMAGE_ANALYSIS or raises the existing
%      singleton*.
%
%      H = HTP_IMAGE_ANALYSIS returns the handle to a new HTP_IMAGE_ANALYSIS or the handle to
%      the existing singleton*.
%
%      HTP_IMAGE_ANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HTP_IMAGE_ANALYSIS.M with the given input arguments.
%
%      HTP_IMAGE_ANALYSIS('Property','Value',...) creates a new HTP_IMAGE_ANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HTP_Image_Analysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HTP_Image_Analysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HTP_Image_Analysis

% Last Modified by GUIDE v2.5 25-Jan-2018 11:46:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HTP_Image_Analysis_OpeningFcn, ...
                   'gui_OutputFcn',  @HTP_Image_Analysis_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before HTP_Image_Analysis is made visible.
function HTP_Image_Analysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HTP_Image_Analysis (see VARARGIN)

% Choose default command line output for HTP_Image_Analysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes HTP_Image_Analysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = HTP_Image_Analysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function directoryText_Callback(hObject, eventdata, handles)
% hObject    handle to directoryText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of directoryText as text
%        str2double(get(hObject,'String')) returns contents of directoryText as a double


% --- Executes during object creation, after setting all properties.
function directoryText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to directoryText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in startAllButton.
function startAllButton_Callback(hObject, eventdata, handles)
% hObject    handle to startAllButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);
set(handles.startButton, 'visible', 'Off');
set(handles.startAllButton, 'visible', 'Off');
set(handles.stopButton, 'visible', 'On');
handles.RUN = 1;
guidata(hObject, handles);

file_path = get(handles.directoryText, 'string');
s1 = ImageTracer(file_path);
file_list1 = s1.traceAllTopImages(s1.getDirectory());
if (~isempty(file_list1))
    file_list1 = s1.sortImages(file_list1);
else
    handles = guidata(hObject);
    set(handles.startButton, 'visible', 'On');
    set(handles.startAllButton, 'visible', 'On');
    set(handles.stopButton, 'visible', 'Off');
    handles.RUN = 0;
    guidata(hObject, handles);
    statusPercentage = 0;
    set(handles.statusNumberLabel, 'String', statusPercentage);
    s1.delete();
end
s11 = LeafProcessor([], []);
s11 = s11.setPixelPerCM(75);

for i=1:size(file_list1, 1)
    handles = guidata(hObject);
    if(handles.RUN==0)
        statusPercentage = 0;
        set(handles.statusNumberLabel, 'String', statusPercentage);
        s1.delete();
        s11.delete();
        break;
    end
    statusPercentage = i*100/size(file_list1, 1);
    set(handles.statusNumberLabel, 'String', statusPercentage);
    img = imread(file_list1{i});
    s11 = s11.setTopImage(img);
    imshow(img, 'Parent', handles.originalImageAxes);pause(1);
    if(i<4)
        [x, y]=ginput(4);
        s11 = s11.collectTopSampleColors(img, x, y);
        s11 = s11.generateTopColorCorelationalMatrix();
    end
    s11.generateTopColorCorrectedImage();
    s11.generateTopNormalizedImage();
    imshow(s11.generateTopGreenMask(), 'Parent', handles.colorCorrectedImageAxes);pause(1);
    imshow(s11.generateTopForegroundImage(), 'Parent', handles.normalizedRGBImageAxes);pause(1);
    s11.generateTopBWForegroundImage();
    s11.generateTopLeavesCutImage();
    [foreground_area, number_of_leaves, top_average_color, leaves_details, top_leaves_labeled_image, top_leaves_text_labeled_image] = s11.generateTopLeavesCountedImage();
    imshow(top_leaves_text_labeled_image, 'Parent', handles.maskedImageAxes);pause(1);
    fprintf('\n\nNumber of leaves: %d\n\n' , number_of_leaves);
    
    s11.exportTopColorCorrectedImage(file_list1{i});
    s11.exportTopGreenMask(file_list1{i});
    s11.exportTopForegroundImage(file_list1{i});
    s11.exportTopLeavesCutImage(file_list1{i});
    s11.exportTopLeavesTextLabeledImage(file_list1{i});
    s11.exportLeavesData(file_list1{i}, foreground_area, number_of_leaves, top_average_color, leaves_details);
    s11.exportLeavesTable(file_list1{i}, i, foreground_area, number_of_leaves, top_average_color);
    s11.plotAreaGraph(file_list1{i}, foreground_area);
    s11.plotLeafCountGraph(file_list1{i}, number_of_leaves);
end


% --- Executes on button press in startButton.
function startButton_Callback(hObject, eventdata, handles)
% hObject    handle to startButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);
set(handles.startButton, 'visible', 'Off');
set(handles.startAllButton, 'visible', 'Off');
set(handles.stopButton, 'visible', 'On');
handles.RUN = 1;
guidata(hObject, handles);

file_path = get(handles.directoryText, 'string');
s2 = ImageTracer(file_path);
file_list2 = s2.traceIncompletedTopImages(s2.getDirectory());
if (~isempty(file_list2))
    file_list2 = s2.sortImages(file_list2);
else
    handles = guidata(hObject);
    set(handles.startButton, 'visible', 'On');
    set(handles.startAllButton, 'visible', 'On');
    set(handles.stopButton, 'visible', 'Off');
    handles.RUN = 0;
    guidata(hObject, handles);
    statusPercentage = 0;
    set(handles.statusNumberLabel, 'String', statusPercentage);
    s2.delete();
end
s22 = LeafProcessor([], []);
s22 = s22.setPixelPerCM(75);

for i=1:size(file_list2, 1)
    handles = guidata(hObject);
    if(handles.RUN==0)
        statusPercentage = 0;
        set(handles.statusNumberLabel, 'String', statusPercentage);
        s2.delete();
        s22.delete();
        break;
    end
    statusPercentage = i*100/size(file_list2, 1);
    set(handles.statusNumberLabel, 'String', statusPercentage);
    img = imread(file_list2{i});
    s22 = s22.setTopImage(img);
    imshow(img, 'Parent', handles.originalImageAxes);pause(1);
    if(i<4)
        [x, y]=ginput(4);
        s22 = s22.collectTopSampleColors(img, x, y);
        s22 = s22.generateTopColorCorelationalMatrix();
    end
    s22.generateTopColorCorrectedImage();
    s22.generateTopNormalizedImage();
    imshow(s22.generateTopGreenMask(), 'Parent', handles.colorCorrectedImageAxes);pause(1);
    imshow(s22.generateTopForegroundImage(), 'Parent', handles.normalizedRGBImageAxes);pause(1);
    s22.generateTopBWForegroundImage();
    s22.generateTopLeavesCutImage();
    [foreground_area, number_of_leaves, top_average_color, leaves_details, top_leaves_labeled_image, top_leaves_text_labeled_image] = s22.generateTopLeavesCountedImage();
    imshow(top_leaves_text_labeled_image, 'Parent', handles.maskedImageAxes);pause(1);
    fprintf('\n\nNumber of leaves: %d\n\n' , number_of_leaves);
    
    s22.exportTopColorCorrectedImage(file_list2{i});
    s22.exportTopGreenMask(file_list2{i});
    s22.exportTopForegroundImage(file_list2{i});
    s22.exportTopLeavesCutImage(file_list2{i});
    s22.exportTopLeavesTextLabeledImage(file_list2{i});
    s22.exportLeavesData(file_list2{i}, foreground_area, number_of_leaves, top_average_color, leaves_details);
end


% --- Executes on button press in stopButton.
function stopButton_Callback(hObject, eventdata, handles)
% hObject    handle to stopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);
set(handles.startButton, 'visible', 'On');
set(handles.startAllButton, 'visible', 'On');
set(handles.stopButton, 'visible', 'Off');
handles.RUN = 0;
guidata(hObject, handles);

