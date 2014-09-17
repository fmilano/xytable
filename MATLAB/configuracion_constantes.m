function [] = configuracion_constantes(handles)
    ud = get(0,'userdata');
    load('default.mat');
    % **************************************************** %
    % *************Variables no configurables************* %
    % **************************************************** %
    ud = [];
    
    % Valores dependientes de la cámara utilizada
    ud.sizeX                            = 1200;
    ud.sizeX_preview                    = 240;
    ud.sizeY_preview                    = 320;
    ud.preview_scale                    = ud.sizeX_preview/ud.sizeX;
    
    % Valores independientes
    ud.fin                              = 0;
    ud.comenzar                         = 0;
    ud.kernel                           = def.kernel;
    ud.handles                          = handles;
    ud.calibracion_activa               = 0;
    ud.total_pasos_x                    = 500;
    ud.total_pasos_y                    = 1e5;
    ud.num_fila                         = 1;
    ud.pasos_pixeles                    = def.pasos_pixeles;
    ud.DERECHA                          = 1;
    ud.IZQUIERDA                        = -1;
    ud.ABAJO                            = 0;
    ud.sentido                          = ud.DERECHA;
    ud.valor_slider_X                   = 0;
    ud.valor_slider_Y                   = 0;
    ud.matriz_filas                     = 1;
    
    ud.intentos_fallidos                = 0;
    ud.forzar_coincidencia              = 0;
    ud.forzar_coincidencia_stitching    = 0;
    ud.mov_estimado                     = 380;
    ud.margen_mov                       = 0.1*ud.mov_estimado;

    % Indica si el porcentaje de solapamiento es 100%
    ud.primer_movX              = 1;    
    
    i = 1;
    ud.COM                      = '/dev/ttyS111';
    if (def.MOTOR1 == def.MOTOR2)
        def.MOTOR1 = 1;
        def.MOTOR2 = 2;
    end
    ud.MOTOR1                   = def.MOTOR1;
    ud.MOTOR2                   = def.MOTOR2;

    % Valores por default de los motores
    ud.MOTOR1_DERECHA           = def.MOTOR1_DERECHA;
    ud.MOTOR1_IZQUIERDA         = def.MOTOR1_IZQUIERDA;
    ud.MOTOR2_DERECHA           = def.MOTOR2_DERECHA;
    ud.MOTOR2_IZQUIERDA         = def.MOTOR2_IZQUIERDA;

    fin = 0;
    % Se chequea la existencia de muestras anteriores, para no pisarlas con la
    % sesión actual
    while (fin == 0)
        if (exist(['/home/axel/Desktop/XYTableAcData/Muestra_0' num2str(i)]) == 0)
            fin = 1;
        else
            i = i+1;
        end
    end
    ud.titulo                   = ['Muestra_0' num2str(i)];

    % Varibale de calibración
    ud.MM_PASOS                 = 150;
    
    
    % ************************************************* %
    % *************Variables configurables************* %
    % ************************************************* %
    
    
    % Set point en sentido X de movimiento, en unidades porcentuales.
    % Indica el grado de solapamiento deseado entre imágenes contiguas
    % Valor por default: 40 %
    ud.const.SP = 50;
    
    % Margenes porcentuales máximos y mínimos para el grado de solapamiento
    % en X deseado. fijan la tolerancia del sistema de control.
    % Valores por default:
    %                       Mínimo SP-15 %
    %                       Máximo SP+21 %
    ud.const.SPX_min = ud.const.SP-10;
    ud.const.SPX_max = ud.const.SP+10;
    
    % Número de píxeles de corrimiento en el sentido Y máximos tolerados 
    % durante el sistema de control de movimiento en X. Debe ser negativo.
    % Valor por default: -5 píxeles
    ud.const.SPY_min = -5;
    
    % Pixeles de diferencia entre el mov del preview y el de alta
    % resolución. Se utiliza para verificar si coinciden o no los cálculos
    % de mov entre la imagen en alta definición y la imagen del preview,
    % con la que funciona el sistema de control.
    % Las unidades son píxeles, normalizados a alta resolución.
    % Valor por default: 25 píxeles
    ud.const.MAXIMA_DIFERENCIA_MOV = 25;    
    
    % Cantidad de pasos que se darán en el sentido Y cada vez que se desee
    % pasar a una nueva fila de imágenes. Debe ser un valor positivo.
    % Valor por default: 400 pasos
    ud.const.pasosY = 400;
    
    % Número de octavas para el match entre imágenes. Dependiendo del
    % tamaño de la imagen, puede ser beneficioso tomar un valor mayor de
    % octavas, para detectar puntos coincidentes más grandes
    ud.const.nunmOctaves_hd = 25;
    ud.const.nunmOctaves_preview = 5;

    ud.const.escala_fila_stitching = 1/5;
    ud.const.mov_estimado = ud.const.pasosY*ud.pasos_pixeles*ud.const.escala_fila_stitching/ud.preview_scale;
    ud.const.margen_mov = 0.25*ud.const.mov_estimado;
    
    % Cantidad de píxeles máximos que se considera puede desplazarse el
    % sistema en Y mientras intenta moverse solo en X, medidos en escala
    % del preview
    % Valor por default: 15 píxeles
    ud.const.tope_control_Y = 15;
    
    % Cantidad de pasos máximos que se considera puede desplazarse el
    % sistema en X, habiéndose ya movido una vez. Los pasos son
    % acumulativos, y deben ser mayores a los dados cuando el sistema
    % detecta 100% de porcentaje de solapamiento
    % Valor por default: (Numero de pasos para porcentaje 100)*(1.4)
    ud.const.tope_control_X_acumulado = ((100-ud.const.SP)*(ud.sizeX_preview/100)/(ud.pasos_pixeles))*(1.4);
    
    
    set(0,'userdata',ud);
end
