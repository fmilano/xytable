function varargout = Visualizador(varargin)
% VISUALIZADOR M-file for Visualizador.fig
%      VISUALIZADOR, by itself, creates a new VISUALIZADOR or raises the existing
%      singleton*.
%
%      H = VISUALIZADOR returns the handle to a new VISUALIZADOR or the handle to
%      the existing singleton*.
%
%      VISUALIZADOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VISUALIZADOR.M with the given input arguments.
%
%      VISUALIZADOR('Property','Value',...) creates a new VISUALIZADOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Visualizador_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Visualizador_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Visualizador

% Last Modified by GUIDE v2.5 29-May-2014 16:31:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Visualizador_OpeningFcn, ...
                   'gui_OutputFcn',  @Visualizador_OutputFcn, ...
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
end

% --- Executes just before Visualizador is made visible.
function Visualizador_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Visualizador (see VARARGIN)

% Choose default command line output for Visualizador
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Visualizador wait for user response (see UIRESUME)
% uiwait(handles.figure1);
clc;
ud = get(0,'userdata');
ud.titulo = 'Muestra_01';
load(['/home/axel/Desktop/XYTableAcData/data_' ud.titulo '.mat']);

% Tamaño en pixeles del axes del visualizador
ud.true_size = [1000 600];

% Se carga la nueva matriz de im_pos
load(['/home/axel/Desktop/XYTableAcData/final_im_pos_' ud.titulo '.mat']);
ud.im_pos = final_im_pos;

num_filas = size(final_im_pos,1);

% Se toman como limites la mayor imagen reconstruida posible
ud.sizeX = min(ud.im_pos(1:num_filas,end,1));
ud.sizeY = ud.im_pos(num_filas,1,1);
ud.xlim = [1 ud.sizeX];
ud.ylim = [1 ud.sizeY];

% Porcion extra porcentual hacia los 4 sentidos, para permitir el Span
ud.porcion_extra = 0.3;

[ud.imagen,ud.escala,ud.num_imagenes] = find_image(['Final_' ud.titulo],ud.xlim,ud.ylim,ud.im_pos,[1000 600],0);

ud.cambio_zoom = 0;
ud.cambio_titulo = 0;
ud.fin = 0;
ud.reset = 0;
ud.zoom_out_final = 1;
ud.zoom = 1;
ud.pan = 0;
set(0,'userdata',ud);

set(handles.text_titulo,'string',ud.titulo); 

end

% --- Outputs from this function are returned to the command line.
function varargout = Visualizador_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% Cada vez que se hace zoom se devuelve la zona de zoom de la imagen 
% (en pixeles de la imagen original)
function [] = myPostCallback_zoom(obj,event_obj)

    ud = get(0,'userdata');
    ud.zoom_out_final = 0;
    
    % Si entra es porque hubo un zoom out
    if (diff(xlim) > ud.true_size*0.99)
        % Se escribe el zoom out en pixeles absolutos de la imagen total
        spanX = round(diff(ud.xlim)*0.5);
        spanY = round(diff(ud.ylim)*0.5);
        
        ud.xlim = [max(1,ud.xlim(1)-spanX) min(ud.xlim(2)+spanX,ud.sizeX)];
        ud.ylim = [max(1,ud.ylim(1)-spanY) min(ud.ylim(2)+spanY,ud.sizeY)];
        
        % Si se hizo el máximo zoom out, no se permite crear porciones
        if sum(((ud.xlim == [1 ud.sizeX])&(ud.ylim== [1 ud.sizeY])) > 0)
            ud.zoom_out_final = 1;
        end
        
    else
        
        % Se resizea el limiteY, para conservar la simetria del axes
        limiteX = round(xlim);
        limiteY = round(ylim);
        limiteY(2) = limiteY(1) + round(diff(limiteX)*(ud.true_size(2)/ud.true_size(1)));
        
        % Se convierte a pixeles de la imagen original
        ud.xlim = ud.porcionX(1) + round((limiteX-1)/ud.escala);
        ud.ylim = ud.porcionY(1) + round((limiteY-1)/ud.escala);
    
    end
    ud.cambio_zoom = 1;
    ud.zoom = 1;
    ud.pan = 0;
    %ud.escala = ud.true_size/max(diff(ud.xlim),diff(ud.ylim));
    set(0,'userdata',ud);  
end

function [] = myPostCallback_pan(obj,event_obj)
    % Se escribe el pan en pixeles absolutos de la imagen total
    ud = get(0,'userdata');
    
    % Si está en el zoom out final, no tiene sentido hacer un span
    if (ud.zoom_out_final == 1)
        return;
    end
    
    % Se resizea el limiteY, para conservar la simetria del axes
    limiteX = round(xlim);
    limiteY = round(ylim);
    limiteY(2) = limiteY(1) + round(diff(limiteX)*(ud.true_size(2)/ud.true_size(1)));
    
    % Conversión entre limiteXY (de 1 a 1000) y porcion (pixeles absolutos)
    ud.xlim = round(ud.porcionX(1) + (1/ud.escala)*(limiteX-1));
    ud.ylim = round(ud.porcionY(1) + (1/ud.escala)*(limiteY-1));

    ud.cambio_zoom = 1;
    ud.zoom = 0;
    ud.pan = 1;
    set(0,'userdata',ud);
end

% --- Executes on button press in comenzar.
function comenzar_Callback(hObject, eventdata, handles)
    % hObject    handle to comenzar (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    set(hObject,'enable','off');
    set(hObject,'visible','off');
    set(handles.resetear,'enable','on');
    set(handles.resetear,'visible','on');
    ud = get(0,'userdata');
    
    num_imagenes = ud.num_imagenes;
    axes(handles.axes);
    imshow(ud.imagen);
    set(handles.text1,'String',['Imágenes cargadas: ' num2str(num_imagenes)]);

    h = zoom;
    set(h,'ActionPostCallback',@myPostCallback_zoom);
    set(h,'Enable','on');
    h2 = pan;
    set(h2,'ActionPostCallback',@myPostCallback_pan);
    set(h2,'Enable','on');
    
    ud.porcionX = ud.xlim;
    ud.porcionY = ud.ylim;
    set(0,'userdata',ud);
    
    while(ud.fin == 0)
        ud = get(0,'userdata');
        if (ud.cambio_zoom == 1)
            zoom off;
            pan off;
            hw = waitbar(0,'Buffering Image...');
            ud.cambio_zoom = 0;
            set(0,'userdata',ud);
            
            % Si aun no se hizo el máximo zoom out
            if (ud.zoom_out_final == 0)
                extraX = round(diff(ud.xlim)*ud.porcion_extra);
                extraY = round(diff(ud.ylim)*ud.porcion_extra);
                % Porciones respecto de la imagen total
                porcionX = [max(1,round(ud.xlim(1)-extraX)) min(ud.xlim(2)+extraX,ud.sizeX)];
                porcionY = [max(1,round(ud.ylim(1)-extraY)) min(ud.ylim(2)+extraY,ud.sizeY)];
            % Si ya se hizo el máximo zoom out
            else
                porcionX = ud.xlim;
                porcionY = ud.ylim;
            end
            
            ud.porcionX = porcionX;
            ud.porcionY = porcionY;
            set(0,'userdata',ud);
                    
            waitbar(0,hw);
            [imagen,ud.escala,num_imagenes] = find_image(['Final_' ud.titulo],porcionX,porcionY,ud.im_pos,(1+ud.porcion_extra)*ud.true_size,hw);
            [sizeY,sizeX,sizeZ] = size(imagen);
            set(handles.text1,'String',['Imágenes cargadas: ' num2str(num_imagenes)]);
            set(0,'userdata',ud);
            
            if (ud.zoom_out_final == 0)
                % Limites dentro de la porcion de imagen obtenida
                factor_extra = (1-(1/(1+2*ud.porcion_extra)))/2;
                extraX_lim = round(sizeX*factor_extra);
                extraY_lim = round(sizeY*factor_extra);
                limiteX = [extraX_lim sizeX-extraX_lim];
                limiteY = [extraY_lim sizeY-extraY_lim];            
                axes(handles.axes);imshow(imagen);zoom reset;xlim(limiteX);ylim(limiteY);
            else
                axes(handles.axes);imshow(imagen);zoom reset;
            end
            
            % Fin del waitbar, se actualiza la imagen y se vuelve a
            % permitir ela herramienta de zoom o de pan
            waitbar(1,hw);
            close(hw);
            if (ud.zoom == 1)
                zoom on;
            end
            if (ud.pan == 1)
                pan on;
            end
            
        else
            pause(0.01);
            % Boton reset
            if (ud.reset == 1)
                ud.reset = 0;
                ud.xlim = [1 ud.sizeX];
                ud.ylim = [1 ud.sizeY];
                ud.cambio_zoom = 1;
                ud.zoom_out_final = 1;
                set(0,'userdata',ud);
            end
            
            % Cambio de sesión
            if (ud.cambio_titulo == 1)
                ud.cambio_titulo = 0;
                % Se recalcula la imagen total
                
                % Se carga la nueva matriz de im_pos
                load(['/home/axel/Desktop/XYTableAcData/final_im_pos_' ud.titulo '.mat']);
                ud.im_pos = final_im_pos;

                num_filas = size(final_im_pos,1);

                % Se toman como limites la mayor imagen reconstruida posible
                ud.sizeX = min(ud.im_pos(1:num_filas,end,1));
                ud.sizeY = ud.im_pos(num_filas,1,1);
                ud.xlim = [1 ud.sizeX];
                ud.ylim = [1 ud.sizeY];
                
                ud.cambio_zoom = 1;
                ud.zoom_out_final = 1;
                set(0,'userdata',ud);
            end
        end
    end
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
ud = get(0,'userdata');
ud.fin = 1;
set(0,'userdata',ud);
delete(hObject);
end


% --- Executes on button press in resetear.
function resetear_Callback(hObject, eventdata, handles)
% hObject    handle to resetear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ud = get(0,'userdata');
ud.reset = 1;
set(0,'userdata',ud);
end

% --------------------------------------------------------------------
function sesion_Callback(hObject, eventdata, handles)
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
    if (exist(['/home/axel/Desktop/XYTableAcData/' answer{1} '/Final_' answer{1} '_01.png']) == 0)
        errordlg('Muestra no encontrada','Error');
    else
        ud.titulo = answer{1};
        ud.cambio_titulo = 1;
    end
end
set(0,'userdata',ud);
set(handles.text_titulo,'string',ud.titulo);
end