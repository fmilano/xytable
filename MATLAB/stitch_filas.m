function varargout = stitch_filas(varargin)
% STITCH_FILAS MATLAB code for stitch_filas.fig
%      STITCH_FILAS, by itself, creates a new STITCH_FILAS or raises the existing
%      singleton*.
%
%      H = STITCH_FILAS returns the handle to a new STITCH_FILAS or the handle to
%      the existing singleton*.
%
%      STITCH_FILAS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STITCH_FILAS.M with the given input arguments.
%
%      STITCH_FILAS('Property','Value',...) creates a new STITCH_FILAS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stitch_filas_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stitch_filas_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stitch_filas

% Last Modified by GUIDE v2.5 26-Sep-2014 11:35:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stitch_filas_OpeningFcn, ...
                   'gui_OutputFcn',  @stitch_filas_OutputFcn, ...
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


% --- Executes just before stitch_filas is made visible.
function stitch_filas_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to stitch_filas (see VARARGIN)

% Choose default command line output for stitch_filas
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes stitch_filas wait for user response (see UIRESUME)
% uiwait(handles.figure1);
clc;

ud = get(0,'userdata');
titulo = ud.titulo;
set(handles.text_titulo,'string',titulo);
set(0,'userdata',ud);
configuracion_constantes(handles);
ud = get(0,'userdata');
ud.titulo = titulo;
set(0,'userdata',ud);

% --- Outputs from this function are returned to the command line.
function varargout = stitch_filas_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in comenzar.
function comenzar_Callback(hObject, eventdata, handles)
% hObject    handle to comenzar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ud = get(0,'userdata');
crear_imagenes_finales(ud.titulo,handles);
close all;
delete(['/home/axel/Desktop/XYTableAcData/' num2str(ud.titulo) '/datos_visualizador.mat']);
delete(['/home/axel/Desktop/XYTableAcData/' num2str(ud.titulo) '/datos_visualizador_50.mat']);
delete(['/home/axel/Desktop/XYTableAcData/' num2str(ud.titulo) '/datos_visualizador_25.mat']);
delete(['/home/axel/Desktop/XYTableAcData/' num2str(ud.titulo) '/datos_visualizador_13.mat']);
Visualizador;

% --------------------------------------------------------------------
function sesion_Callback(hObject, eventdata, handles)
% hObject    handle to sesion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% hObject    handle to sesion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ud = get(0,'userdata');
prompt = {'Ingrese el nombre de la muestra:'};
dlg_title = 'Sesión';
num_lines = 1;
def = {ud.titulo};
answer = inputdlg(prompt,dlg_title,num_lines,def);
if (~isempty(answer))
    if (exist(['/home/axel/Desktop/XYTableAcData/data_' answer{1} '.mat']) == 0)
        errordlg('Muestra no encontrada','Error');
    else
        ud.titulo = answer{1};
        ud.cambio_titulo = 1;
    end
end
set(0,'userdata',ud);
set(handles.text_titulo,'string',ud.titulo);
