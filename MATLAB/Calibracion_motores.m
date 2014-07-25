function varargout = Calibracion_motores(varargin)
% CALIBRACION_MOTORES MATLAB code for Calibracion_motores.fig
%      CALIBRACION_MOTORES, by itself, creates a new CALIBRACION_MOTORES or raises the existing
%      singleton*.
%
%      H = CALIBRACION_MOTORES returns the handle to a new CALIBRACION_MOTORES or the handle to
%      the existing singleton*.
%
%      CALIBRACION_MOTORES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CALIBRACION_MOTORES.M with the given input arguments.
%
%      CALIBRACION_MOTORES('Property','Value',...) creates a new CALIBRACION_MOTORES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Calibracion_motores_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Calibracion_motores_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Calibracion_motores

% Last Modified by GUIDE v2.5 05-Jun-2014 16:00:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Calibracion_motores_OpeningFcn, ...
                   'gui_OutputFcn',  @Calibracion_motores_OutputFcn, ...
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


% --- Executes just before Calibracion_motores is made visible.
function Calibracion_motores_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Calibracion_motores (see VARARGIN)

% Choose default command line output for Calibracion_motores
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Calibracion_motores wait for user response (see UIRESUME)
% uiwait(handles.figure1);
set(handles.text,'string','¿Confirma que los puntos resaltados en verde coinciden en ambas imágenes?');
ud = get(0,'userdata');
ud.calibracion_activa = 1;
ud.handles2 = handles;
ud.ser = comenzar_comunicacion(ud.COM,9600);

ud.motor_movido = 0;

set(0,'userdata',ud);


% --- Outputs from this function are returned to the command line.
function varargout = Calibracion_motores_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in motor1.
function motor1_Callback(hObject, eventdata, handles)
% hObject    handle to motor1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'enable','off');
ud = get(0,'userdata');
ud.calibracion_activa = 0;

im1 = get_preview(handles);
% Se corrige la luz de la imagen
if (get(ud.handles.check_correccion,'value') == 1)
    im1 = corregir_imagen(im1,ud.kernel);
end
% Se ecualiza la imagen
if (get(ud.handles.check_eq,'value') == 1)
    im1 = eq_rgb(im1);
end

h = waitbar(0,'Moviendo el motor 1...');
waitbar(0.3,h);
ud.motor_movido = 1;
fwrite(ud.ser,1);fwrite(ud.ser,0);fwrite(ud.ser,200);
%int = mover_motor(ud.motor_movido,200);
pause(2);
close(h);

im2 = get_preview(handles);
% Se corrige la luz de la imagen
if (get(ud.handles.check_correccion,'value') == 1)
    im2 = corregir_imagen(im2,ud.kernel);
end
% Se ecualiza la imagen
if (get(ud.handles.check_eq,'value') == 1)
    im2 = eq_rgb(im2);
end

[ud.mov_motor_aux,mp1,mp2,metric] = match(im1,im2,20,0.7);
axes(handles.axes1);hold off;imshow(im1);hold on; plot(mp1);
axes(handles.axes2);hold off;imshow(im2);hold on;plot(mp2);
set(handles.text,'visible','on');
set(handles.aceptar,'enable','on');
set(handles.cancelar,'enable','on');
set(0,'userdata',ud);

% --- Executes on button press in motor2.
function motor2_Callback(hObject, eventdata, handles)
% hObject    handle to motor1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'enable','off');
ud = get(0,'userdata');
ud.calibracion_activa = 0;

im1 = get_preview(handles);
% Se corrige la luz de la imagen
if (get(ud.handles.check_correccion,'value') == 1)
    im1 = corregir_imagen(im1,ud.kernel);
end
% Se ecualiza la imagen
if (get(ud.handles.check_eq,'value') == 1)
    im1 = eq_rgb(im1);
end

h = waitbar(0,'Moviendo el motor 2...');
waitbar(0.3,h);
ud.motor_movido = 2;
fwrite(ud.ser,4);fwrite(ud.ser,0);fwrite(ud.ser,200);
%int = mover_motor(ud.motor_movido,200);

pause(2);
close(h);

im2 = get_preview(handles);
% Se corrige la luz de la imagen
if (get(ud.handles.check_correccion,'value') == 1)
    im2 = corregir_imagen(im2,ud.kernel);
end
% Se ecualiza la imagen
if (get(ud.handles.check_eq,'value') == 1)
    im2 = eq_rgb(im2);
end

[ud.mov_motor_aux,mp1,mp2,metric] = match(im1,im2,20,0.7);
axes(handles.axes1);hold off;imshow(im1);hold on; plot(mp1);
axes(handles.axes2);hold off;imshow(im2);hold on;plot(mp2);
set(handles.text,'visible','on');
set(handles.aceptar,'enable','on');
set(handles.cancelar,'enable','on');
set(0,'userdata',ud);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
ud = get(0,'userdata');
set(ud.handles.figure1,'visible','on');
set(ud.handles.calibrar_motores,'enable','on');
ud.calibracion_activa = 0;
set(0,'userdata',ud);
delete(hObject);


% --- Executes on button press in aceptar.
function aceptar_Callback(hObject, eventdata, handles)
% hObject    handle to aceptar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.aceptar,'enable','off');
set(handles.cancelar,'enable','off');
set(handles.text,'visible','off');
ud = get(0,'userdata');

mov = ud.mov_motor_aux;

if (abs(mov(1)) > abs(mov(2)))
    % Movimiento en Y se asigna al MOTOR 2
    ud.MOTOR2 = ud.motor_movido;
    % Se actualiza el MOTOR 1
    if (ud.MOTOR2 == 1)
        ud.MOTOR1 = 2;
    else
        ud.MOTOR1 = 1;
    end
    
    if (mov(1) > 0)
        disp('Movimiento hacia abajo');
        ud.MOTOR2_DERECHA = ud.motor_movido*2;
        ud.MOTOR2_IZQUIERDA = ud.motor_movido*2-1;
    else
        disp('Movimiento hacia arriba');
        ud.MOTOR2_DERECHA = ud.motor_movido*2-1;
        ud.MOTOR2_IZQUIERDA = ud.motor_movido*2;
    end
else
    % Movimiento en X se asigna al MOTOR 1
    ud.MOTOR1 = ud.motor_movido;
    % Se actualiza el MOTOR 2
    if (ud.MOTOR1 == 1)
        ud.MOTOR2 = 2;
    else
        ud.MOTOR2 = 1;
    end
    
    if (mov(2) > 0)
        disp('Movimiento hacia la derecha');
        ud.MOTOR1_DERECHA = ud.motor_movido*2-1;
        ud.MOTOR1_IZQUIERDA = ud.motor_movido*2;
    else
        disp('Movimiento hacia la izquierda');
        ud.MOTOR1_DERECHA = ud.motor_movido*2;
        ud.MOTOR1_IZQUIERDA = ud.motor_movido*2-1;
    end
end

ud.pasos_pixeles = max(abs(mov))/200;
set(0,'userdata',ud);
close(handles.figure1);

% --- Executes on button press in cancelar.
function cancelar_Callback(hObject, eventdata, handles)
% hObject    handle to cancelar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.aceptar,'enable','off');
set(handles.cancelar,'enable','off');
set(handles.text,'visible','off');
set(handles.motor1,'enable','on');
