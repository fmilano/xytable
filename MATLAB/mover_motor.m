function [int] = mover_moto(motor,pasos)
    pasos_H = floor(abs(pasos)/255);
    pasos_L = mod(abs(pasos),255);
    
    ud = get(0,'userdata');
    switch(motor)
        case {ud.MOTOR1}
            if (pasos > 0)
                fwrite(ud.ser,ud.MOTOR1_DERECHA);fwrite(ud.ser,abs(pasos_H));fwrite(ud.ser,abs(pasos_L));
            else
                fwrite(ud.ser,ud.MOTOR1_IZQUIERDA);fwrite(ud.ser,abs(pasos_H));fwrite(ud.ser,abs(pasos_L));
            end
        case {ud.MOTOR2}
            if (pasos < 0)
                % Derecha = Arriba
                fwrite(ud.ser,ud.MOTOR2_DERECHA);fwrite(ud.ser,abs(pasos_H));fwrite(ud.ser,abs(pasos_L));
            else
                % Izquierda = Abajo
                fwrite(ud.ser,ud.MOTOR2_IZQUIERDA);fwrite(ud.ser,abs(pasos_H));fwrite(ud.ser,abs(pasos_L));
            end
            
    end 
    
    % Cálculo de timeout
    tic;
    while (ud.ser.BytesAvailable == 0)
        tardanza = toc;
        % Si tarda mas del doble de lo que debería, se sale de la funcion
        % informando error
        if (tardanza > 2 + (0.005*abs(pasos) + 0.5)*2)
            int = 0;
            return;
        end
    end
    int = fread(ud.ser,1,'uint8');
end