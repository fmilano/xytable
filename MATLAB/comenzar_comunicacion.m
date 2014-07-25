function [ser] = comenzar_comunicacion(com,br)

    % Validacion del puerto: sudo chmod 777 /dev/ttyUSB1
    delete(instrfind);
    ser = serial(com);           % Puerto USB
    set(ser, 'Terminator', 'CR');   % set communication string to end on ASCII 13
    set(ser, 'BaudRate', br);
    set(ser, 'StopBits', 1);        % Pontech controllers ask for these parameters
    set(ser, 'DataBits', 8);
    set(ser, 'Parity', 'none');
    set(ser, 'Timeout', 1);
    fopen(ser);

    %% Lectura y escritura
%     fwrite(ser, 123, 'uint8');
%     fread(ud.ser,1,'uint8');

end