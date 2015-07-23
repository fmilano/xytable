%   SP: Set Point de overlap porcentual, con x_y = 'X'
%       Set point de mov (en pixeles), con x_y = 'Y'
%   Sentido:     1  --> Derecha
%               -1  --> Izquierda
function [pasos] = simulador_control(x_y,mov,sizeX,SP,sentido)
    ud = get(0,'userdata');
    % Constantes de calibración
    PORCx_MM      = 2/60;                       % (2 mm)/(60%)
    PASOS_PIXELES = ud.pasos_pixeles;           % (109 pixels)/(200 pasos)
    
    % Constantes dependientes de la calibracion
    PORCx_PIXELES = sizeX/100;                  % (240 pixels)/(100 %)
    PORCx_PASOS   = PORCx_PIXELES/PASOS_PIXELES;        
    MM_PASOS      = ud.MM_PASOS;                        % (300 pasos)/(2 mm)
    
    switch (x_y)
        case {'X'}
            % Sentido derecho
            if (sentido == 1)
                porcentaje = 200 - 100*(sizeX+mov)/sizeX;
            % Sentido izquierda
            else
                porcentaje = 100*(sizeX+mov)/sizeX;
            end
            
            delta_porcentual = (porcentaje-SP);
            pasos = sentido*round(delta_porcentual*PORCx_PASOS);
            mm = delta_porcentual*PORCx_MM;      

            if (pasos >= 0)
%                 disp(['Moverse a la derecha ' num2str(abs(mm)) 'mm = ' num2str(abs(pasos)) ' pasos']);
            else
%                 disp(['Moverse a la izquierda ' num2str(abs(mm)) 'mm = ' num2str(abs(pasos)) ' pasos']);
            end
            
        case {'Y'} 
            
            pixeles = mov - SP;
            pasos = pixeles/PASOS_PIXELES;
            mm = pasos/MM_PASOS;
            pasos = round(pasos);
            
            if (pasos < 0)
%                 disp(['Moverse arriba ' num2str(abs(mm)) 'mm = ' num2str(abs(pasos)) ' pasos']);
            else
%                 disp(['Moverse abajo ' num2str(abs(mm)) 'mm = ' num2str(abs(pasos)) ' pasos']);
            end
    end

end