function varargout = Image_composer(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Image_composer_OpeningFcn, ...
                   'gui_OutputFcn',  @Image_composer_OutputFcn, ...
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


% --- Executes just before Image_composer is made visible.
function Image_composer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Image_composer (see VARARGIN)

% Choose default command line output for Image_composer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Image_composer wait for user response (see UIRESUME)
% uiwait(handles.figure1);
clc;
loadlibrary('libcameraControl.so', 'cameraControl.h');

% Inicialización de todas las constantes y variables de configuración del
% sistema
ud = get(0,'userdata');
ud.modo = 'hd';
set(0,'userdata',ud);
configuracion_constantes(handles);


ud = get(0,'userdata');
ud.test_i = 1;
ud.indice_foto = 1;
ud.factor_ld = 0.033;
ud.tiempo_espera = 1;
ud.ld_ftype = 4;
ud.hd_image_repetition = 5;
set(0,'userdata',ud);
set(handles.text_foto,'string','Tome la primera foto en el borde superior izquierdo de la muestra');
set(handles.text_sesion,'string',ud.titulo);



% --- Outputs from this function are returned to the command line.
function varargout = Image_composer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Iniciar_camara.
function Iniciar_camara_Callback(hObject, eventdata, handles)
% hObject    handle to Iniciar_camara (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Se activn y desactivan botones
set(hObject,'enable','off');
set(handles.primer_foto,'enable','on');
set(handles.calibracion,'enable','on');
set(handles.sesion,'enable','off');
set(handles.text_slider,'visible','on');
set(handles.edit_pasosX,'enable','on');
set(handles.edit_pasosY,'enable','on');
set(handles.push_derecha,'enable','on');
set(handles.push_izquierda,'enable','on');
set(handles.push_arriba,'enable','on');
set(handles.push_abajo,'enable','on');

% Se inicializa la camara
init = calllib('libcameraControl', 'Initialize');
if (init == 1)
    set(handles.text_camara,'string','Cámara inicializada exitosamente');
    set(handles.text_foto,'visible','on');
    ud = get(0,'userdata');
    ud.seteo_pos_inicial = 0;    
    
    % Apertura del puerto de comunicacion serie
    ud.ser = comenzar_comunicacion(ud.COM,9600);
    set(0,'userdata',ud);
    
    % Comienza un loop que muestra el preview de la camara, hasta que se
    % tome la primera foto y se acepte
    while (ud.comenzar == 0)
        ud = get(0,'userdata');
        
        if (ud.seteo_pos_inicial == 0)    
            ud.image = get_preview(handles);
            image_corregida = ud.image;
            % Se corrige la luz de la imagen (si así se desea)
            if (get(handles.check_correccion,'value') == 1)
                image_corregida = corregir_imagen(image_corregida,ud.kernel_pv);
            end
            % Se ecualiza la imagen (si así se desea)
            if (get(handles.check_eq,'value') == 1)
                image_corregida = eq_rgb(image_corregida);
            end
            % Se realiza la corrección geométrica (si así se desea)
            if (get(handles.check_geom,'value') == 1)
                image_corregida = correccion_geometrica(image_corregida, ud.factor_ld,ud.ld_ftype);
            end
            % Se muestra en pantalla la imagen
            imshow(image_corregida,'parent',handles.axes1);
            % Si se está calibrando, se actualiza la imagen en la otra
            % figura
            if (ud.calibracion_activa == 1)
                imshow(ud.image,'parent',ud.handles2.axes1);
                set(0,'userdata',ud);
            end
        end
        % El refresco de pantalla se realiza cada 100 ms
        pause(0.1);
    end
else
    set(handles.text_camara,'string','La cámara no pudo ser inicializada');
end


% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Se activan y desactivan botones
set(hObject,'enable','off');
set(handles.primer_foto,'enable','off');
set(handles.text_foto,'visible','off');
set(handles.comunicacion,'enable','off');
set(handles.pb_nueva_foto,'enable','off');
ud = get(0,'userdata');

% Se genera un directorio para las fotos a tomar
mkdir('/home/axel/Desktop/XYTableAcData',ud.titulo);

% Se saca la foto de preview y la de alta definicion
pause(ud.tiempo_espera);
first_image = get_preview(handles);

first_image_HD = get_best_quality_image(handles,ud.hd_image_repetition);

if (strcmp(ud.modo,'pv'))
    kernel = ud.kernel_pv;
else
    kernel = ud.kernel_hd;
end     

% Se corrige la luz de la imagen (si así se desea)
if (get(handles.check_correccion,'value') == 1)
    first_image = corregir_imagen(first_image,ud.kernel_pv);
    first_image_HD = corregir_imagen(first_image_HD,kernel);
end
% Se realiza la corrección geométrica (si así se desea)
if (get(handles.check_geom,'value') == 1)
    first_image = correccion_geometrica(first_image,ud.factor_ld,ud.ld_ftype);
    first_image_HD = correccion_geometrica(first_image_HD,ud.factor_ld,ud.ld_ftype);
end
% Se ecualiza la imagen (si así se desea)
if (get(handles.check_eq,'value') == 1)
    first_image = eq_rgb(first_image);
    first_image_HD = eq_rgb(first_image_HD);
end

% Se muestra la imagen en la pantalla izquierda
axes(handles.axes1);imshow(first_image);

% Set point y constantes para el sistema de control
SP                      = ud.const.SP;
MAXIMA_DIFERENCIA_MOV   = ud.const.MAXIMA_DIFERENCIA_MOV;     

% Variables para determinar numero de imagenes, pasos tomados, etc
foto_indice = 0;
contador_pasos_x = 0;
contador_pasos_y = 0;
sizeX_total = 0;
pasosX_acumulados = 0;

%% Comienzo del programa de barrido de imágenes
while (ud.fin == 0)
    ud = get(0,'userdata');
    
    second_image = get_preview(handles); 
    
    % Se corrige la luz de la imagen
    if (get(handles.check_correccion,'value') == 1)
        second_image = corregir_imagen(second_image,ud.kernel_pv);
    end
    % Se realiza la corrección geométrica
    if (get(handles.check_geom,'value') == 1)
        second_image = correccion_geometrica(second_image,ud.factor_ld,ud.ld_ftype);
    end
    % Se ecualiza la imagen
    if (get(handles.check_eq,'value') == 1)
        second_image = eq_rgb(second_image);
    end
    
    % Si será el primer movimiento luego de haber sacado una foto
    if (ud.primer_movX == 1)
        mov = [0 0];
        mp1 = [];
        mp2 = [];
        metric = 0;
    else
        % Se calcula el desplazamiento entre imágenes en escala de preview
        [mov,mp1,mp2,metric] = match(first_image,second_image,20,0.7,'preview');
    end
    
    % Se muestran las imágenes y el match encontrado
    axes(handles.axes1);hold off;imshow(first_image);hold on; plot(mp1);
    axes(handles.axes2);hold off;imshow(second_image);hold on;plot(mp2);
    ud.first_image = first_image;
    ud.second_image = second_image;
    set(0,'userdata',ud);
    set(handles.text_metric,'string',['Metric = ' num2str(metric)]);
    
    if (isempty(mov))
        disp('****ERROR**** No hay coincidencias');
        continue;
    end
    
    mean_mov = round(mov);
    
    set(handles.text_movX,'string',['MovX = ' num2str(mean_mov(2))]);
    set(handles.text_movY,'string',['MovY = ' num2str(mean_mov(1))]);
    
    if (ud.sentido == ud.DERECHA)
        porcentaje = 200 - round(100*(size(first_image,2)+mean_mov(2))/size(first_image,2));
    else
        porcentaje = round(100*(size(first_image,2)+mean_mov(2))/size(first_image,2));
    end
    set(handles.text_porcentaje,'string',['Porcentaje de foto anterior = ' num2str(porcentaje) '%']);
    
    pause(0.5);
    
    %% Sistema de control
    
    % Dependiendo del sentido, se fijan los limites del sistema de control
    switch (ud.sentido)
        case {ud.DERECHA,ud.IZQUIERDA}
            SPY = 0;
            SPX_min = ud.const.SPX_min;
            SPX_max = ud.const.SPX_max;
            SPY_min = ud.const.SPY_min;
            SPY_max = 0;
        case {ud.ABAJO}
            SPY = -ud.sizeY_preview*0.75;
            SPX_min = 99;
            SPX_max = 101;
            SPY_min = ud.sizeY_preview*0.7;
            SPY_max = ud.sizeY_preview*1.1;
    end
    set(0,'userdata',ud);
    
    % Condición de desplazamiento en X alcanzada
    if ((porcentaje > SPX_min) && (porcentaje < SPX_max))
        
        % Condición de nueva foto alcanzada
        if ((mean_mov(1) > SPY_min) && (mean_mov(1) <= SPY_max))
%             disp('Nueva foto');

            pause(ud.tiempo_espera);
            % Se saca la nueva foto de alta resolución
            ud.im1 = first_image_HD;
            ud.im2 = get_best_quality_image(handles,ud.hd_image_repetition);
            
            
            if (strcmp(ud.modo,'pv'))
                kernel = ud.kernel_pv;
            else
                kernel = ud.kernel_hd;
            end    
            % Se corrige la luz de la segunda imagen
            if (get(handles.check_correccion,'value') == 1)
                ud.im2 = corregir_imagen(ud.im2,kernel);
            end
            % Se realiza la corección geométrica
            if (get(handles.check_geom,'value') == 1)
                ud.im2 = correccion_geometrica(ud.im2,ud.factor_ld,ud.ld_ftype);
            end
            
            % Se ecualiza la segunda imagen
            if (get(handles.check_eq,'value') == 1)
                ud.im2 = eq_rgb(ud.im2);
            end

%            ud.mov = match(ud.im1,ud.im2,20,0.7,'hd'); Debug
            ud.mov = mov;

            % Si el movimiento no se parece al calculado en el preview, se
            % descarta, y se utiliza el del preview
            if (sum(abs(ud.mov - mov/ud.preview_scale) > MAXIMA_DIFERENCIA_MOV))
                % Se resamplea la imagen a escala preview para calcular el mov
                ud.im1_prev = imresize(ud.im1,ud.preview_scale);
                ud.im2_prev = imresize(ud.im2,ud.preview_scale);
                 % Se calcula el movimiento entre fotos
                ud.mov = match(ud.im1_prev,ud.im2_prev,20,0.7,'preview')/ud.preview_scale;
                disp(['En la imagen final ' num2str(foto_indice+1) ' se resampleó la imagen HD']);
                
                if (sum(abs(ud.mov - mov/ud.preview_scale) > MAXIMA_DIFERENCIA_MOV))
                    ud.mov = mov/ud.preview_scale;
                    disp(['En la imagen final ' num2str(foto_indice+1) ' se utilizó el MOV del preview']);
                elseif (ud.mov(1) > 0)
                    ud.mov(1) = 0;
                end
                
            elseif (ud.mov(1) > 0)
                ud.mov(1) = 0;
            end

            set(0,'userdata',ud);
            % Se realiza el stitching
            [im_final,first_image_HD] = stitch(ud.im1,ud.im2,ud.mov,ud.sentido,ud.sizeX);
            foto_indice = foto_indice+1;

            % Se actualiza la nueva first_image
            first_image = imresize(first_image_HD,ud.preview_scale);

            % Se guarda la imagen final
            imwrite(im_final,['/home/axel/Desktop/XYTableAcData/' ud.titulo '/' ud.titulo '_0' num2str(foto_indice) '.png'],'png');
            
            set(handles.text_im,'string',['Numero de imagenes: ' num2str(foto_indice)]);
            axes(handles.axes1);imshow(first_image);
            sizeX_total = sizeX_total + size(im_final,2);
            
            % Como se sacó la foto, el nuevo porcentaje deberia ser 100%
            ud.primer_movX = 1;
            set(0,'userdata',ud);
            % Los pasos acumulados para el desplazamiento de la imagen 
            % tomada se resetean
            pasosX_acumulados = 0;
            
            % Si se llegó al extremo de la fila, se guarda la ultima imagen
            % y se cambia el sentido de movimiento
            if (contador_pasos_x >= ud.total_pasos_x)   
                % Se escribe la última imagen de la fila
                foto_indice = foto_indice + 1;
                imwrite(first_image_HD,['/home/axel/Desktop/XYTableAcData/' ud.titulo '/' ud.titulo '_0' num2str(foto_indice) '.png'],'png');
                set(handles.text_im,'string',['Numero de imagenes: ' num2str(foto_indice)]);
                sizeX_total = sizeX_total + size(first_image_HD,2);
                
                % Si es la ultima fila, se termina el programa
                if (contador_pasos_y >= ud.total_pasos_y)
                    disp('***Fin del programa***');
                    ud.fin = 1;
                    ud.matriz_filas(ud.num_fila,2) = foto_indice - ud.matriz_filas(ud.num_fila,1) + 1;    
                    ud.matriz_filas(ud.num_fila,3) = ud.sentido;
                    ud.matriz_filas(ud.num_fila,4) = sizeX_total;
                    data{1} = ud.titulo;
                    data{2} = ud.matriz_filas;
                    set(0,'userdata',ud);
                    save(['/home/axel/Desktop/XYTableAcData/data_' ud.titulo '.mat'],'data');
                    
                % Si no, se baja una fila
                else
                    ud.num_fila = ud.num_fila + 1;
                    contador_pasos_x = 0;
                    
                    % Se actualiza la matriz de filas
                    ud.matriz_filas(ud.num_fila,1) = foto_indice+1;
                    ud.matriz_filas(ud.num_fila-1,2) = ud.matriz_filas(ud.num_fila,1)-ud.matriz_filas(ud.num_fila-1,1);    
                    ud.matriz_filas(ud.num_fila-1,3) = ud.sentido;
                    ud.matriz_filas(ud.num_fila-1,4) = sizeX_total;
                    sizeX_total = 0;
                    
                    % Se salvan los cambios
                    data{1} = ud.titulo;
                    data{2} = ud.matriz_filas;
                    save(['/home/axel/Desktop/XYTableAcData/data_' ud.titulo '.mat'],'data');
                    
                    % Se baja hacia la siguiente fila
                    pasosY = ud.const.pasosY;
                    int = mover_motor(ud.MOTOR2,-pasosY);
                    % Se acumulan los pasos
                    contador_pasos_y = contador_pasos_y + pasosY;
                    set(handles.text_pasosY,'string',['Pasos en Y: ' num2str(contador_pasos_y) ' = ' num2str(contador_pasos_y/ud.MM_PASOS) ' mm']);
                    % Se toma la primera foto de la nueva fila
                    pause(ud.tiempo_espera);
                    first_image_HD = get_best_quality_image(handles,ud.hd_image_repetition);
                    
                    % Se corrige la luz
                    if (get(handles.check_correccion,'value') == 1)
                        first_image_HD = corregir_imagen(first_image_HD,kernel);
                    end
                    % Se realiza la corección geométrica
                    if (get(handles.check_geom,'value') == 1)
                        first_image_HD = correccion_geometrica(first_image_HD,ud.factor_ld,ud.ld_ftype);
                    end
                    % Se ecualiza
                    if (get(handles.check_eq,'value') == 1)
                        first_image_HD = eq_rgb(first_image_HD);
                    end
                    
                    first_image = imresize(first_image_HD,ud.preview_scale);
                    axes(handles.axes1);imshow(first_image);
                    
                    % Se invierte el sentido de movimiento
                    ud.sentido = -ud.sentido;
                    set(0,'userdata',ud);
                    set(handles.text_num_fila,'string',['Numero de fila: ' num2str(ud.num_fila)]);
                end
            end
            continue;
            
        % Si no se alcanzó la condición de nueva foto (condición satisfecha
        % en X pero no en Y)
        else
            % Cálculo del desplazamiento en Y necesario
            pasosY = simulador_control('Y',mean_mov(1),ud.sizeX,SPY,ud.sentido);
            
            % Si el mov calculado en Y está dentro del rango, se realiza el
            % desplazamiento en Y
            if (abs(mean_mov(1)) > ud.const.tope_control_Y)
                disp('Movimiento en Y descartado');
            else
                % Se mueve el motor, se aguarda la respuesta del micro 
                int = mover_motor(ud.MOTOR2,pasosY);

                % Si no hubo respuesta del micro en tiempo y forma
                if (int == 0)
                    disp('El micro no respondio, se reenvian los datos');
                    pause(4);
                    int = mover_motor(ud.MOTOR2,pasosY);
                    if (int == 0)
                        disp('Se resetea la comunicacion');
                        ud.ser = comenzar_comunicacion(ud.COM,9600);set(0,'userdata',ud);
                        pause(1);
                        int = mover_motor(ud.MOTOR2,pasosY);
                        if (int == 0)
                            error('Error de comunicación con el micro');
                        end
                    end
                end
            end
        end
    
    % Si no se alcanzó la condición de desplazamiento en X 
    else
        % Si ya se movió al menos una vez, debería estar cerca del SP
        if (ud.primer_movX == 0)
            if ((porcentaje < SP+30) && (porcentaje > SP-30) && (mean_mov(1) > -12) && (mean_mov(1) < 12))
                disp('Coincidencia encontrada');
                ud.intentos_fallidos = 0;
                ud.forzar_coincidencia = 0;
                set(0,'userdata',ud);
            else
                disp('Coincidencia no encontrada');
                ud.intentos_fallidos = ud.intentos_fallidos + 1;
                disp(num2str(ud.intentos_fallidos));
                
                if (ud.intentos_fallidos == 5)
                    ud.forzar_coincidencia = 1;
                    ud.intentos_fallidos = 0;           
                end
                set(0,'userdata',ud);
                continue;
            end
            
        else
%             disp('Primer movimiento');
            mean_mov = [0 0];
        end
        
        % Calculo del desplazamiento en X necesario
        pasosX = simulador_control('X',mean_mov(2),ud.sizeX_preview,SP,ud.sentido);
        
        % La cantidad de pasos a dar no debe superar el maximo acumulado
        % seteado
        if (abs(pasosX+pasosX_acumulados) > ud.const.tope_control_X_acumulado)
            disp('Movimiento en X descartado');
            pasosX = round(ud.const.tope_control_X_acumulado-abs(pasosX_acumulados))*sign(pasosX);
        end
            
        if (abs(pasosX) > 0)
            % Se mueve el motor, se aguarda la respuesta del micro 
            int = mover_motor(ud.MOTOR1,pasosX);
            % Si no hubo respuesta del micro en tiempo y forma
            if (int == 0)
                error('Error de comunicación con el micro');
            end
            % Como ya se movio al menos una vez, el porcentaje deberia ser 40%
            ud.primer_movX = 0;
            set(0,'userdata',ud);
            % Se acumulan los pasos dentro del movimiento de la imagen
            pasosX_acumulados = pasosX_acumulados + pasosX;
            % Se acumulan los pasos totales en la fila
            contador_pasos_x = contador_pasos_x + ud.sentido*pasosX;
            set(handles.text_pasosX,'string',['Pasos en X: ' num2str(contador_pasos_x) ' = ' num2str(contador_pasos_x/ud.MM_PASOS) ' mm']);
        end
    end
end
close all;
stitch_filas;
    
% --- Executes on button press in primer_foto.
function primer_foto_Callback(hObject, eventdata, handles)
% hObject    handle to primer_foto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ud = get(0,'userdata');
ud.seteo_pos_inicial = 1;
set(0,'userdata',ud);
set(handles.check_eq,'enable','off');
set(handles.check_correccion,'enable','off');
set(handles.check_geom,'enable','off');
set(handles.text_foto,'string','¿Está seguro?');
set(handles.cancelar,'visible','on');
set(handles.aceptar,'visible','on');


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

def = get(0,'userdata');
save('default.mat','def');
if (exist('def.ser'))
    fclose(def.ser);
end
def.comenzar = 1;
def.fin = 1;
set(0,'userdata',def);

delete(hObject);
calllib('libcameraControl', 'Finalize');
unloadlibrary libcameraControl;


% --- Executes on button press in check_correccion.
function check_correccion_Callback(hObject, eventdata, handles)
% hObject    handle to check_correccion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_correccion


% --- Executes on button press in check_eq.
function check_eq_Callback(hObject, eventdata, handles)
% hObject    handle to check_eq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_eq


% --- Executes on button press in cancelar.
function cancelar_Callback(hObject, eventdata, handles)
% hObject    handle to cancelar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ud = get(0,'userdata');
ud.seteo_pos_inicial = 0;
set(0,'userdata',ud);

set(handles.cancelar,'visible','off');
set(handles.aceptar,'visible','off');
set(handles.text_foto,'string','Tome la primera foto en el borde superior izquierdo de la muestra');
set(handles.check_eq,'enable','on');
set(handles.check_correccion,'enable','on');
set(handles.check_geom,'enable','on');


% --- Executes on button press in aceptar.
function aceptar_Callback(hObject, eventdata, handles)
% hObject    handle to aceptar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ud = get(0,'userdata');
ud.comenzar = 1;
set(0,'userdata',ud);
set(handles.cancelar,'visible','off');
set(handles.aceptar,'visible','off');
set(handles.start,'enable','on');
set(handles.text_foto,'visible','off');
set(handles.primer_foto,'enable','off');
set(handles.calibracion,'enable','off');
set(handles.text_slider,'visible','off');
set(handles.edit_pasosX,'enable','off');
set(handles.edit_pasosY,'enable','off');
set(handles.push_derecha,'enable','off');
set(handles.push_izquierda,'enable','off');
set(handles.push_arriba,'enable','off');
set(handles.push_abajo,'enable','off');

prompt = {'Extension en X de la muestra (en mm):','Extension en Y de la muestra (en mm):'};
dlg_title = 'Extension de la muestra';
num_lines = 1;
def = {'53','40'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
if (~isempty(answer))
    MM_PASOS = 150;
    ud.total_pasos_x = abs(round(str2double(answer(1))*MM_PASOS));
    ud.total_pasos_y = abs(round(str2double(answer(2))*MM_PASOS));
    set(0,'userdata',ud);
end

% --------------------------------------------------------------------
function calibrar_luz_Callback(hObject, eventdata, handles)
% hObject    handle to calibrar_luz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.figure1,'visible','off');
set(hObject,'enable','off');
Calibracion_luz;
def = get(0,'userdata');
save('default.mat','def');

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
    ud.titulo = answer{1};
end
set(0,'userdata',ud);
set(handles.text_sesion,'string',ud.titulo);


% --------------------------------------------------------------------
function calibrar_motores_Callback(hObject, eventdata, handles)
% hObject    handle to calibrar_motores (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.figure1,'visible','off');
set(hObject,'enable','off');
Calibracion_motores;
def = get(0,'userdata');
save('default.mat','def');

% --------------------------------------------------------------------
function comunicacion_Callback(hObject, eventdata, handles)
% hObject    handle to comunicacion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ud = get(0,'userdata');
prompt = {'Ingrese el puerto de comunicación USB utilizado:'};
dlg_title = 'Comunicación serie';
num_lines = 1;
def = {ud.COM};
answer = inputdlg(prompt,dlg_title,num_lines,def);
if (~isempty(answer))
    ud.COM = answer{1};
end
ud.ser = comenzar_comunicacion(ud.COM,9600);
set(0,'userdata',ud);


% --------------------------------------------------------------------
function calibracion_Callback(hObject, eventdata, handles)
% hObject    handle to calibracion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function edit_pasosX_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pasosX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
valor = get(hObject,'string');
if (~isnumeric(str2double(valor)))
    set(hObject,'string','200');
end

% --- Executes during object creation, after setting all properties.
function edit_pasosX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pasosX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_pasosY_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pasosY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
valor = get(hObject,'string');
if (~isnumeric(str2double(valor)))
    set(hObject,'string','200');
end

% --- Executes during object creation, after setting all properties.
function edit_pasosY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pasosY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_derecha.
function push_derecha_Callback(hObject, eventdata, handles)
% hObject    handle to push_derecha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pasos = str2double(get(handles.edit_pasosX,'string'));
ud = get(0,'userdata');
int = mover_motor(ud.MOTOR1,pasos);

% --- Executes on button press in push_abajo.
function push_abajo_Callback(hObject, eventdata, handles)
% hObject    handle to push_abajo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pasos = str2double(get(handles.edit_pasosY,'string'));
ud = get(0,'userdata');
int = mover_motor(ud.MOTOR2,-pasos);

% --- Executes on button press in push_izquierda.
function push_izquierda_Callback(hObject, eventdata, handles)
% hObject    handle to push_izquierda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pasos = str2double(get(handles.edit_pasosX,'string'));
ud = get(0,'userdata');
int = mover_motor(ud.MOTOR1,-pasos);

% --- Executes on button press in push_arriba.
function push_arriba_Callback(hObject, eventdata, handles)
% hObject    handle to push_arriba (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pasos = str2double(get(handles.edit_pasosY,'string'));
ud = get(0,'userdata');
int = mover_motor(ud.MOTOR2,pasos);


% --- Executes during object creation, after setting all properties.
function push_derecha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to push_derecha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
im = imread('der.jpg');
im = imresize(im,0.1556);
set(hObject,'CData',im);


% --- Executes during object creation, after setting all properties.
function push_izquierda_CreateFcn(hObject, eventdata, handles)
% hObject    handle to push_izquierda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
im = imread('izq.jpg');
im = imresize(im,0.1556);
set(hObject,'CData',im);


% --- Executes during object creation, after setting all properties.
function push_abajo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to push_abajo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
im = imread('abajo.jpg');
im = imresize(im,0.1556);
set(hObject,'CData',im);


% --- Executes during object creation, after setting all properties.
function push_arriba_CreateFcn(hObject, eventdata, handles)
% hObject    handle to push_arriba (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
im = imread('arriba.jpg');
im = imresize(im,0.1556);
set(hObject,'CData',im);


% --- Executes on button press in test.
function test_Callback(hObject, eventdata, handles)
% hObject    handle to test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ud = get(0,'userdata');
set(hObject,'string',['Test ' num2str(ud.test_i)]);
test_bank(ud.test_i,2);
ud.test_i = ud.test_i + 1;
set(0,'userdata',ud);


% --- Executes on button press in check_geom.
function check_geom_Callback(hObject, eventdata, handles)
% hObject    handle to check_geom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_geom


% --- Executes on button press in pb_nueva_foto.
function pb_nueva_foto_Callback(hObject, eventdata, handles)
% hObject    handle to pb_nueva_foto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ud = get(0,'userdata');
ud.indice_foto = ud.indice_foto+1;
imagen = get_image(handles);
if (get(handles.check_geom,'value') == 1)
    imagen = correccion_geometrica(imagen,ud.factor_ld,ud.ld_ftype);
end
imwrite(imagen,['../../fotos_calibracion/imagen_0' num2str(ud.indice_foto) '.jpg']);
set(0,'userdata',ud);



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
value = get(hObject,'String');
ud = get(0,'userdata');
ud.factor_ld = str2double(value);
set(0,'userdata',ud);

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
