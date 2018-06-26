function varargout = roiGUI(varargin)
% ROIGUI MATLAB code for roiGUI.fig
%      ROIGUI, by itself, creates a new ROIGUI or raises the existing
%      singleton*.
%
%      H = ROIGUI returns the handle to a new ROIGUI or the handle to
%      the existing singleton*.
%
%      ROIGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROIGUI.M with the given input arguments.
%
%      ROIGUI('Property','Value',...) creates a new ROIGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before roiGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to roiGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help roiGUI

% Last Modified by GUIDE v2.5 26-Jun-2018 11:09:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @roiGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @roiGUI_OutputFcn, ...
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


% --- Executes just before roiGUI is made visible.
function roiGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to roiGUI (see VARARGIN)

% Choose default command line output for roiGUI
resize = false;
handles.output = hObject;
handles.image = varargin{1};
handles.oldmask = varargin{2};
if resize
    handles.image = imresize(handles.image, 1/2);
    handles.oldmask = imresize(handles.oldmask, 1/2);
end
handles.newmask = handles.oldmask;
handles.green = cat(3, zeros(size(handles.oldmask)),ones(size(handles.oldmask)), zeros(size(handles.oldmask)));
handles.discard = false;
handles.mask = ones(size(handles.image));

% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0 0.05 1 0.95]);

% Update handles structure
guidata(hObject, handles);
displayImages(hObject, eventdata, handles);
pushbutton_reset_Callback(hObject, eventdata, handles)

% UIWAIT makes roiGUI wait for user response (see UIRESUME)
%uiwait(handles.figure1);

function displayImages(hObject, eventdata, handles)
%handles = guidata(hObject);
handles.image_handle = imshow(handles.image);
hold on;
handles.green_handle = imshow(handles.green);
set(handles.green_handle, 'AlphaData', handles.newmask*0.5);
hold off;
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = roiGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles.discard;
varargout{3} = handles.newmask;
delete(handles.figure1);


% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
if exist('handles.freehand')
    handles.freehand.delete;
end
if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
% The GUI is still in UIWAIT, us UIRESUME
uiresume(handles.figure1);
end

% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_discard.
function pushbutton_discard_Callback(hObject, eventdata, handles)
if exist('handles.freehand')
    handles.freehand.delete;
end
handles.discard = 1;
if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
% The GUI is still in UIWAIT, us UIRESUME
uiresume(handles.figure1);
end

guidata(hObject, handles);
% hObject    handle to pushbutton_discard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_reset.
function pushbutton_reset_Callback(hObject, eventdata, handles)
if exist('handles.freehand')
    handles.freehand.delete;
end

handles.image_handle = imshow(handles.image);
hold on;
handles.green_handle = imshow(handles.green);
set(handles.green_handle, 'AlphaData', handles.oldmask*0.5);
hold off;

handles.freehand = imfreehand(handles.axes1);
try
    handles.newmask = bitand(handles.oldmask, handles.freehand.createMask(handles.image_handle));
catch
    handles.newmask = handles.oldmask;
end

handles.image_handle = imshow(handles.image);
hold on;
handles.green_handle = imshow(handles.green);
set(handles.green_handle, 'AlphaData', handles.newmask*0.5);
hold off;
guidata(hObject, handles);
uiwait(handles.figure1);

% hObject    handle to pushbutton_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(hObject, 'waitstatus'), 'waiting')
% The GUI is still in UIWAIT, us UIRESUME
uiresume(hObject);
else
% The GUI is no longer waiting, just close it
delete(hObject);
end
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
