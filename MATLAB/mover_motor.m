function [int] = mover_motor(motor,pasos)
    pasos_H = floor(abs(pasos)/255);
    pasos_L = mod(abs(pasos),255);
    
    ud = get(0,'userdata');
    switch(motor)
        case {ud.MOTOR1}
            if (pasos > 0)
                try
                    fwrite(ud.ser,ud.MOTOR1_DERECHA);fwrite(ud.ser,abs(pasos_H));fwrite(ud.ser,abs(pasos_L));
                catch
                    disp('Error en el Fwrite');
                    pause(2);
                    fwrite(ud.ser,ud.MOTOR1_DERECHA);fwrite(ud.ser,abs(pasos_H));fwrite(ud.ser,abs(pasos_L));
                end
            else
                try
                    fwrite(ud.ser,ud.MOTOR1_IZQUIERDA);fwrite(ud.ser,abs(pasos_H));fwrite(ud.ser,abs(pasos_L));
                catch
                    disp('Error en el Fwrite');
                    pause(2);
                    fwrite(ud.ser,ud.MOTOR1_IZQUIERDA);fwrite(ud.ser,abs(pasos_H));fwrite(ud.ser,abs(pasos_L));
                end
            end
        case {ud.MOTOR2}
            if (pasos < 0)
                % Derecha = Arriba
                try
                    fwrite(ud.ser,ud.MOTOR2_DERECHA);fwrite(ud.ser,abs(pasos_H));fwrite(ud.ser,abs(pasos_L));
                catch
                    disp('Error en el Fwrite');
                    pause(2);
                    fwrite(ud.ser,ud.MOTOR2_DERECHA);fwrite(ud.ser,abs(pasos_H));fwrite(ud.ser,abs(pasos_L));
                end
            else
                % Izquierda = Abajo
                try
                    fwrite(ud.ser,ud.MOTOR2_IZQUIERDA);fwrite(ud.ser,abs(pasos_H));fwrite(ud.ser,abs(pasos_L));
                catch
                    disp('Error en el Fwrite');
                    pause(2);
                    fwrite(ud.ser,ud.MOTOR2_IZQUIERDA);fwrite(ud.ser,abs(pasos_H));fwrite(ud.ser,abs(pasos_L));
                end
            end       
    end
    
    % Cálculo de timeout
    tic;
    while (ud.ser.BytesAvailable == 0)
        tardanza = toc;
        % Si tarda mas del doble de lo que debería, se sale de la funcion
        % informando error
        if (tardanza > 3 + (0.005*abs(pasos) + 0.5)*2)
            int = 0;
            return;
        end
        ud = get(0,'userdata');
    end
    try
        int = fread(ud.ser,1,'uint8');
    catch
        disp('Error en el Fread');
        pause(2);
        int = fread(ud.ser,1,'uint8');
    end
end