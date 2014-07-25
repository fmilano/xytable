% Crea la matriz pos_im, indicando la ubicacion de cada imagen en la imagen
% resultante.
% La primera columna de pos_im(:,:,1) es el header, que indica el fin (en
% pixeles) de cada fila de imagenes
% El resto de los datos indican el final (en pixeles) de cada imagen dentro
% de la fila

% La funcion chequea el sentido de las imagenes

function [pos_im] = build_matrix(titulo,fila,matriz_filas)
    
    numColumnas = matriz_filas(fila,2);
    header_anterior = 0;  
    pos_im = zeros(1,numColumnas+1,1);
        
    sentido = matriz_filas(fila,3);
    
    % Sentido derecha
    if (sentido == 1)
        i = matriz_filas(fila,1);
    % Sentido izquierda
    else
        i = matriz_filas(fila,1)+numColumnas-1;
    end
    
    
    % Recorro las columnas
    for columna=1:numColumnas
        proxima_imagen{i} = imread([titulo '_0' num2str(i) '.png']);

        pos_im(1,columna+1,1) = pos_im(1,columna,1) + size(proxima_imagen{i},2);
        pos_im(1,columna+1,2) = i;
        i = i+sentido;
    end
    
    % Se escribe el header de la fila
    % Sentido derecha
    if (sentido == 1)
        i = matriz_filas(fila,1);
        pos_im(1,1,1) = size(imread([titulo '_0' num2str(i+numColumnas-1) '.png']),1);
    % Sentido izquierda
    else
        i = matriz_filas(fila,1)+numColumnas-1;
        pos_im(1,1,1) = size(imread([titulo '_0' num2str(i) '.png']),1);
    end

end