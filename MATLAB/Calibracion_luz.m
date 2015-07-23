function varargout = Calibracion_luz(varargin)
% CALIBRACION_LUZ MATLAB code for Calibracion_luz.fig
%      CALIBRACION_LUZ, by itself, creates a new CALIBRACION_LUZ or raises the existing
%      singleton*.
%
%      H = CALIBRACION_LUZ returns the handle to a new CALIBRACION_LUZ or the handle to
%      the existing singleton*.
%
%      CALIBRACION_LUZ('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CALIBRACION_LUZ.M with the given input arguments.
%
%      CALIBRACION_LUZ('Property','Value',...) creates a new CALIBRACION_LUZ or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Calibracion_luz_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Calibracion_luz_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Calibracion_luz

% Last Modified by GUIDE v2.5 27-May-2014 13:36:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Calibracion_luz_OpeningFcn, ...
                   'gui_OutputFcn',  @Calibracion_luz_OutputFcn, ...
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


% --- Executes just before Calibracion_luz is made visible.
function Calibracion_luz_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Calibracion_luz (see VARARGIN)

% Choose default command line output for Calibracion_luz
handles.output = hObject;
ud = get(0,'userdata');
ud.calibracion_activa = 1;
ud.handles2 = handles;
set(0,'userdata',ud);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Calibracion_luz wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Calibracion_luz_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in aceptar.
function aceptar_Callback(hObject, eventdata, handles)
% hObject    handle to aceptar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ud = get(0,'userdata');
imagen = get_image(ud.handles);
% ud.kernel = calibracion(ud.image);
ud.kernel_hd = calibracion(imagen);
ud.kernel_pv = imresize(ud.kernel_hd,ud.preview_scale);
set(0,'userdata',ud);
close(handles.figure1);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
ud = get(0,'userdata');
set(ud.handles.calibrar_luz,'enable','on');
set(ud.handles.figure1,'visible','on');
ud.calibracion_activa = 0;
set(0,'userdata',ud);
delete(hObject);
