function varargout = m_app(varargin)
% M_APP MATLAB code for m_app.fig
%      M_APP, by itself, creates a new M_APP or raises the existing
%      singleton*.
%
%      H = M_APP returns the handle to a new M_APP or the handle to
%      the existing singleton*.
%
%      M_APP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in M_APP.M with the given input arguments.
%
%      M_APP('Property','Value',...) creates a new M_APP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before m_app_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to m_app_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help m_app

% Last Modified by GUIDE v2.5 14-Jan-2019 17:03:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @m_app_OpeningFcn, ...
                   'gui_OutputFcn',  @m_app_OutputFcn, ...
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


% --- Executes just before m_app is made visible.
function m_app_OpeningFcn(hObject, eventdata, handles, varargin)
setappdata(handles.m_figure,'img_src',0); 
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to m_app (see VARARGIN)

% Choose default command line output for m_app
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes m_app wait for user response (see UIRESUME)
% uiwait(handles.m_figure);


% --- Outputs from this function are returned to the command line.
function varargout = m_app_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function m_file_Callback(hObject, eventdata, handles)
% hObject    handle to m_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function m_file_open_Callback(hObject, eventdata, handles)
[filename, pathname] = uigetfile(  {'*.bmp;*.jpg;*.png;*.jpeg', 'Image Files (*.bmp, *.jpg, *.png, *.jpeg)';  '*.*', 'All Files (*.*)'}, 'ѡ��һ��ͼƬ'); 
if isequal(filename,0) || isequal(pathname,0)
    return;
end
axes(handles.axes_bg);%��axes�����趨��ǰ��������������axes_bg
cla reset
axes(handles.axes_src);%��axes�����趨��ǰ��������������axes_src 
fpath=[pathname filename];%���ļ�����Ŀ¼����ϳ�һ��������·�� 
img_src=imread(fpath);
imshow(img_src);
setappdata(handles.m_figure,'img_src',img_src);

test_img = imread(fpath);
setappdata(handles.m_figure,'test_img',test_img);
test_size = size(test_img);
test_m = test_size(1);
test_n = test_size(2);
setappdata(handles.m_figure,'test_m',test_m);
setappdata(handles.m_figure,'test_n',test_n);
test_cbcr = rgb2ycbcr(test_img);
test_cb = test_cbcr(:,:,2);
test_cr = test_cbcr(:,:,3);

% ��ֵ�˲�(5*5)
filter_cb = medianFiltering(test_cb);
filter_cr = medianFiltering(test_cr);

% ���ƶȼ���
M = [111.0793 153.5395]';  %Ϊ��ɫ��YCbCr��ɫ�ռ��������ֵ
C = [123.5033 -105.4635; -105.4635 197.2520];
P = zeros(test_m, test_n);  %���ƶȾ���
for i = 1:test_m
    for j = 1:test_n
        x = double([filter_cb(i,j), filter_cr(i,j)]');
        index = -0.5*(x-M)'*(C\(x-M));
        P(i,j) = exp(index);
    end
end

%��һ��
max_P = max(P(:));
P = P / max_P;
setappdata(handles.m_figure,'P',P);

%��ֵ��
BW_ = zeros(test_m, test_n);
for i = 1:test_m
    for j = 1:test_n
        if (P(i,j) >= 0.45)
            BW_(i, j) = 1;
        end
    end
end

% ���ղ���
se = strel('square',3);
BW = imopen(BW_, se);
BW = imclose(BW, se);

% �����
BW = imfill(BW, 'holes');

% ��ʴ�����Ͳ���
sel = strel('square',8);
BW = imerode(BW, sel);
BW = imdilate(BW, sel);

% ����������ȡ
[L, num] = bwlabel(BW, 4);
for i = 1:num
    [r,c] = find(L==i); % ���Ϊi�Ķ�����к������ꡣ
    len = max(r) - min(r) + 1;
    wid = max(c) - min(c) + 1;
    area_sq = len * wid;  % ���
    row_num = size(r, 1); % ����

    % �ų�����������
    if (len/wid<0.8) || (len/wid>2.4) || row_num<200 || row_num/area_sq<0.55 || area_sq<640
        for j = 1:row_num
            L(r(j),c(j)) = 0;
        end
    end
end

[r, c] = find(L~=0);
r_max = max(r);
r_min = min(r);
c_max = max(c);
c_min = min(c);

axes(handles.axes_binary);%��axes�����趨��ǰ��������������axes_binary
imshow(L);


% �þ���Ȧ������
axes(handles.axes_detection);%��axes�����趨��ǰ��������������axes_detection
cla reset
imshow(test_img);
width = c_max-c_min;
height = min(r_max-r_min,width*1.4);
hold on
rectangle('Position',[r_min c_min width height],'LineWidth',4,'EdgeColor','r');

% hObject    handle to m_file_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function m_file_save_Callback(hObject, eventdata, handles)
[filename, pathname] = uiputfile({'*.jpg;','JPG files';'*.png;','PNG files';'*.bmp','BMP files'}, '����ͼƬ'); 
if isequal(filename,0) || isequal(pathname,0) 
    return;%������ˡ�ȡ���� 
else
    fpath=fullfile(pathname, filename);%���ȫ·������һ�ַ���
end
img = getappdata(handles.m_figure,'CBImg');
imwrite(img,fpath);%����ͼƬ 
% hObject    handle to m_file_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function m_file_exit_Callback(hObject, eventdata, handles)
% hObject    handle to m_file_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.m_figure);


% --------------------------------------------------------------------
function bg_change_Callback(hObject, eventdata, handles)
% hObject    handle to bg_change (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function red_bg_Callback(hObject, eventdata, handles)
% hObject    handle to red_bg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ������ɫ�ֲ㼼���滻������׼�յı���
test_img=getappdata(handles.m_figure,'test_img');
Red = test_img(1:50,:,1);
Green = test_img(1:50,:,2);
Blue = test_img(1:50,:,3);
a_red = mean(Red(:));
a_green = mean(Green(:));
a_blue = mean(Blue(:));

filter_r = medianFiltering(test_img(:,:,1));
filter_g = medianFiltering(test_img(:,:,2));
filter_b = medianFiltering(test_img(:,:,3));

W = 143;
CBImg = test_img;
CBImg(:,:,1) = filter_r;
CBImg(:,:,2) = filter_g;
CBImg(:,:,3) = filter_b;
test_m=getappdata(handles.m_figure,'test_m');
test_n=getappdata(handles.m_figure,'test_n');
P=getappdata(handles.m_figure,'P');
for i = 1:test_m
    for j = 1:test_n
        is_skin = P(i,j) >= 0.40;
        is_background = (abs(double(filter_r(i,j))-a_red)<W/2) && (abs(double(filter_g(i,j))-a_green)<W/2) && (abs(double(filter_b(i,j))-a_blue)<W/2);
        if is_background && ~is_skin
            CBImg(i,j,1) = 220;
            CBImg(i,j,2) = 20;
            CBImg(i,j,3) = 60;
        end
    end
end

setappdata(handles.m_figure,'CBImg',CBImg);
axes(handles.axes_bg);%��axes�����趨��ǰ��������������axes_detection
imshow(CBImg);


% --------------------------------------------------------------------
function white_bg_Callback(hObject, eventdata, handles)
% hObject    handle to white_bg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
test_img=getappdata(handles.m_figure,'test_img');
Red = test_img(1:50,:,1);
Green = test_img(1:50,:,2);
Blue = test_img(1:50,:,3);
a_red = mean(Red(:));
a_green = mean(Green(:));
a_blue = mean(Blue(:));

filter_r = medianFiltering(test_img(:,:,1));
filter_g = medianFiltering(test_img(:,:,2));
filter_b = medianFiltering(test_img(:,:,3));

W = 143;
CBImg = test_img;
CBImg(:,:,1) = filter_r;
CBImg(:,:,2) = filter_g;
CBImg(:,:,3) = filter_b;
test_m=getappdata(handles.m_figure,'test_m');
test_n=getappdata(handles.m_figure,'test_n');
P=getappdata(handles.m_figure,'P');
for i = 1:test_m
    for j = 1:test_n
        is_skin = P(i,j) >= 0.40;
        is_background = (abs(double(filter_r(i,j))-a_red)<W/2) && (abs(double(filter_g(i,j))-a_green)<W/2) && (abs(double(filter_b(i,j))-a_blue)<W/2);
        if is_background && ~is_skin
            CBImg(i,j,1) = 255;
            CBImg(i,j,2) = 255;
            CBImg(i,j,3) = 255;
        end
    end
end

setappdata(handles.m_figure,'CBImg',CBImg);
axes(handles.axes_bg);%��axes�����趨��ǰ��������������axes_detection
imshow(CBImg);


% --------------------------------------------------------------------
function blue_bg_Callback(hObject, eventdata, handles)
% hObject    handle to blue_bg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
test_img=getappdata(handles.m_figure,'test_img');
Red = test_img(1:50,:,1);
Green = test_img(1:50,:,2);
Blue = test_img(1:50,:,3);
a_red = mean(Red(:));
a_green = mean(Green(:));
a_blue = mean(Blue(:));

filter_r = medianFiltering(test_img(:,:,1));
filter_g = medianFiltering(test_img(:,:,2));
filter_b = medianFiltering(test_img(:,:,3));

W = 143;
CBImg = test_img;
CBImg(:,:,1) = filter_r;
CBImg(:,:,2) = filter_g;
CBImg(:,:,3) = filter_b;
test_m=getappdata(handles.m_figure,'test_m');
test_n=getappdata(handles.m_figure,'test_n');
P=getappdata(handles.m_figure,'P');
for i = 1:test_m
    for j = 1:test_n
        is_skin = P(i,j) >= 0.40;
        is_background = (abs(double(filter_r(i,j))-a_red)<W/2) && (abs(double(filter_g(i,j))-a_green)<W/2) && (abs(double(filter_b(i,j))-a_blue)<W/2);
        if is_background && ~is_skin
            CBImg(i,j,1) = 30;
            CBImg(i,j,2) = 144;
            CBImg(i,j,3) = 255;
        end
    end
end

setappdata(handles.m_figure,'CBImg',CBImg);
axes(handles.axes_bg);%��axes�����趨��ǰ��������������axes_detection
imshow(CBImg);

% --------------------------------------------------------------------
function pink_bg_Callback(hObject, eventdata, handles)
% hObject    handle to pink_bg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
test_img=getappdata(handles.m_figure,'test_img');
Red = test_img(1:50,:,1);
Green = test_img(1:50,:,2);
Blue = test_img(1:50,:,3);
a_red = mean(Red(:));
a_green = mean(Green(:));
a_blue = mean(Blue(:));

filter_r = medianFiltering(test_img(:,:,1));
filter_g = medianFiltering(test_img(:,:,2));
filter_b = medianFiltering(test_img(:,:,3));

W = 143;
CBImg = test_img;
CBImg(:,:,1) = filter_r;
CBImg(:,:,2) = filter_g;
CBImg(:,:,3) = filter_b;
test_m=getappdata(handles.m_figure,'test_m');
test_n=getappdata(handles.m_figure,'test_n');
P=getappdata(handles.m_figure,'P');
for i = 1:test_m
    for j = 1:test_n
        is_skin = P(i,j) >= 0.40;
        is_background = (abs(double(filter_r(i,j))-a_red)<W/2) && (abs(double(filter_g(i,j))-a_green)<W/2) && (abs(double(filter_b(i,j))-a_blue)<W/2);
        if is_background && ~is_skin
            CBImg(i,j,1) = 255;
            CBImg(i,j,2) = 105;
            CBImg(i,j,3) = 180;
        end
    end
end

setappdata(handles.m_figure,'CBImg',CBImg);
axes(handles.axes_bg);%��axes�����趨��ǰ��������������axes_detection
imshow(CBImg);

% --------------------------------------------------------------------
function orange_bg_Callback(hObject, eventdata, handles)
% hObject    handle to orange_bg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
test_img=getappdata(handles.m_figure,'test_img');
Red = test_img(1:50,:,1);
Green = test_img(1:50,:,2);
Blue = test_img(1:50,:,3);
a_red = mean(Red(:));
a_green = mean(Green(:));
a_blue = mean(Blue(:));

filter_r = medianFiltering(test_img(:,:,1));
filter_g = medianFiltering(test_img(:,:,2));
filter_b = medianFiltering(test_img(:,:,3));

W = 143;
CBImg = test_img;
CBImg(:,:,1) = filter_r;
CBImg(:,:,2) = filter_g;
CBImg(:,:,3) = filter_b;
test_m=getappdata(handles.m_figure,'test_m');
test_n=getappdata(handles.m_figure,'test_n');
P=getappdata(handles.m_figure,'P');
for i = 1:test_m
    for j = 1:test_n
        is_skin = P(i,j) >= 0.40;
        is_background = (abs(double(filter_r(i,j))-a_red)<W/2) && (abs(double(filter_g(i,j))-a_green)<W/2) && (abs(double(filter_b(i,j))-a_blue)<W/2);
        if is_background && ~is_skin
            CBImg(i,j,1) = 255;
            CBImg(i,j,2) = 165;
            CBImg(i,j,3) = 0;
        end
    end
end

setappdata(handles.m_figure,'CBImg',CBImg);
axes(handles.axes_bg);%��axes�����趨��ǰ��������������axes_detection
imshow(CBImg);

% --------------------------------------------------------------------
function green_bg_Callback(hObject, eventdata, handles)
% hObject    handle to green_bg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
test_img=getappdata(handles.m_figure,'test_img');
Red = test_img(1:50,:,1);
Green = test_img(1:50,:,2);
Blue = test_img(1:50,:,3);
a_red = mean(Red(:));
a_green = mean(Green(:));
a_blue = mean(Blue(:));

filter_r = medianFiltering(test_img(:,:,1));
filter_g = medianFiltering(test_img(:,:,2));
filter_b = medianFiltering(test_img(:,:,3));

W = 143;
CBImg = test_img;
CBImg(:,:,1) = filter_r;
CBImg(:,:,2) = filter_g;
CBImg(:,:,3) = filter_b;
test_m=getappdata(handles.m_figure,'test_m');
test_n=getappdata(handles.m_figure,'test_n');
P=getappdata(handles.m_figure,'P');
for i = 1:test_m
    for j = 1:test_n
        is_skin = P(i,j) >= 0.40;
        is_background = (abs(double(filter_r(i,j))-a_red)<W/2) && (abs(double(filter_g(i,j))-a_green)<W/2) && (abs(double(filter_b(i,j))-a_blue)<W/2);
        if is_background && ~is_skin
            CBImg(i,j,1) = 152;
            CBImg(i,j,2) = 251;
            CBImg(i,j,3) = 152;
        end
    end
end

setappdata(handles.m_figure,'CBImg',CBImg);
axes(handles.axes_bg);%��axes�����趨��ǰ��������������axes_detection
imshow(CBImg);

% --------------------------------------------------------------------
function purple_bg_Callback(hObject, eventdata, handles)
% hObject    handle to purple_bg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
test_img=getappdata(handles.m_figure,'test_img');
Red = test_img(1:50,:,1);
Green = test_img(1:50,:,2);
Blue = test_img(1:50,:,3);
a_red = mean(Red(:));
a_green = mean(Green(:));
a_blue = mean(Blue(:));

filter_r = medianFiltering(test_img(:,:,1));
filter_g = medianFiltering(test_img(:,:,2));
filter_b = medianFiltering(test_img(:,:,3));

W = 143;
CBImg = test_img;
CBImg(:,:,1) = filter_r;
CBImg(:,:,2) = filter_g;
CBImg(:,:,3) = filter_b;
test_m=getappdata(handles.m_figure,'test_m');
test_n=getappdata(handles.m_figure,'test_n');
P=getappdata(handles.m_figure,'P');
for i = 1:test_m
    for j = 1:test_n
        is_skin = P(i,j) >= 0.40;
        is_background = (abs(double(filter_r(i,j))-a_red)<W/2) && (abs(double(filter_g(i,j))-a_green)<W/2) && (abs(double(filter_b(i,j))-a_blue)<W/2);
        if is_background && ~is_skin
            CBImg(i,j,1) = 186;
            CBImg(i,j,2) = 85;
            CBImg(i,j,3) = 211;
        end
    end
end

setappdata(handles.m_figure,'CBImg',CBImg);
axes(handles.axes_bg);%��axes�����趨��ǰ��������������axes_detection
imshow(CBImg);