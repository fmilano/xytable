% Matriz: n filas del tipo:
% [Indice de primer imagen, cantidad de imagenes, sentido, sizeX total]

function [] = bajar_fila(titulo,matriz)

    num_filas = size(matriz,1);
    largo_nominal = 1000;           % Largo de tira de filas para realizar stitching
    
    if (num_filas == 1)
        return;
    end
    
    for i=1:num_filas
        im_pos{i} = build_matrix(titulo,i,matriz);
    end
    
    im_index = 0;
    anchoY_1 = 0;
    inicio_Y_proxima_fila = 1;
    ultimo_sizeY = 10e5;            % Valor arbitrario, grande
    
    % Repito para cada fila
    for i = 1:num_filas-1
        
        % Numero de imagen dentro de la fila actual
        num_im_fila = 0;

        % Fijo el inicio en Y de la fila
        %inicio_Y = 1+anchoY_1;
        inicio_Y = inicio_Y_proxima_fila;
        
        % Identifico la zona central de ambas filas 
        centro = round(matriz(i,4)/2);
        escala = 1/3;
        
        lim_izq = centro-round(largo_nominal/2);
        lim_der = centro+round(largo_nominal/2);
        anchoX = lim_der-lim_izq+1;
        anchoY_1 = im_pos{i}(1,1,1);
        anchoY_2 = im_pos{i+1}(1,1,1);
        fila1 = find_image(titulo,[lim_izq lim_der],[1 anchoY_1],im_pos{i},[round(anchoX*escala) round(anchoY_1*escala)]);
        fila2 = find_image(titulo,[lim_izq lim_der],[1 anchoY_2],im_pos{i+1},[round(anchoX*escala) round(anchoY_2*escala)]);
        
        %figure;subplot(2,1,1);imshow(fila1);subplot(2,1,2);imshow(fila2);
        
        ud = get(0,'userdata');
        ud.forzar_coincidencia = 0;
        set(0,'userdata',ud);
        
        % Calculo el mov entre las dos filas
        mov = match(fila1,fila2,20,0.7)/escala;  
        
              
        %mov(2) > 0 --> Im2 a la derecha de im1
        %mov(2) < 0 --> Im2 a la izquiera de im1
        
        largo_nominal = 2000;
        max_largo = min(matriz(i,4),matriz(i+1,4));
        
        % Se actualiza el header de la nueva matriz de im_pos
        if (i == 1)
            final_im_pos(1,1,1) = anchoY_1;
        else
            final_im_pos(i,1,1) = final_im_pos(i-1,1,1)+anchoY_1-inicio_Y+1;
        end
        
        inicio_Y_proxima_fila = anchoY_1-mov(1);
        
        % Se determinan los inicios de cada recorte de imagen
        inicioX_1 = max(mov(2)+1,1);
        inicioX_2 = max(-mov(2)+1,1);
        margen = abs(mov(2))*2;
        
        % Se recortan los sobrantes de imagenes, siempre que se cumpla que
        % la fila 2 esta a la derecha de la fila 1. Se recorta la fila 1, y
        % ademas se agrega un offset en todas las filas de arriba, para
        % recortarles el sobrante
        if (inicioX_1 > inicioX_2)
            offset = inicioX_1;
            for m=1:i-1
                % Se recortan offset pixeles de la primer imagen de cada
                % fila
                first_im_index = final_im_pos(m,2,2);
                disp(['Offset de ' num2str(offset) ' agregado en la fila ' num2str(m)]);
                aux = imread(['Final_' titulo '_0' num2str(first_im_index) '.png']);
                aux = aux(:,offset+1:end,:);
                imwrite(aux,['Final_' titulo '_0' num2str(first_im_index) '.png']);
                % Se actualiza la matriz final_im_pos con los nuevos
                % valores de pixeles
                final_im_pos(m,2:end,1)=final_im_pos(m,2:end,1)-offset;
            end
        end
        
        % Se recorre la fila i, en recortes de ancho nominal
        for j =1:largo_nominal:max_largo
        
            if (j+largo_nominal > max_largo)
                largo = max_largo-j-margen-1;
            else
                largo = largo_nominal;
            end
            

            % Se realizan los recortes
            fila1 = find_image(titulo,[j j+largo+margen],[inicio_Y anchoY_1],im_pos{i},[largo+margen anchoY_1-inicio_Y+1]);
            fila2 = find_image(titulo,[j j+largo+margen],[1 anchoY_2],im_pos{i+1},[largo+margen anchoY_2]);
            fila1 = fila1(:,inicioX_1:inicioX_1+largo-1,:);
            fila2 = fila2(:,inicioX_2:inicioX_2+largo-1,:);

            % Se stitchean los recortes
            im_final = stitch(fila1,fila2,mov-inicio_Y+1,0,0);
            figure;imshow(im_final);
             
            % Si no es la ultima fila se toma el stitcheo hasta el fin 
            % de la zona de overlap
            if (i<num_filas-1)  
                im_final = im_final(1:anchoY_1,:,:);
            % Si es la ultima fila, se busca la imagen con el menor sizeY
            else
                ultimo_sizeY = min(ultimo_sizeY,size(im_final,1));
                disp(['Ultima fila: ' num2str(ultimo_sizeY)]);
            end
            
            % Se guarda la imagen final
            im_index = im_index+1;
            imwrite(im_final,['Final_' titulo '_0' num2str(im_index) '.png'],'png');
            
            % Numero de imagen en la fila
            num_im_fila = num_im_fila + 1;
            
            % Se crea una nueva matriz de im_pos, para las imagenes finales
            if (num_im_fila > 1)
                final_im_pos(i,num_im_fila+1,1) = final_im_pos(i,num_im_fila,1) + size(im_final,2); 
            else
                final_im_pos(i,num_im_fila+1,1) = size(im_final,2);   
            end
            final_im_pos(i,num_im_fila+1,2) = im_index;
            save(['final_im_pos_' titulo '.mat'],'final_im_pos');
        end
    end
    
    % Se corrige el header de la ultima fila
    final_im_pos(i,1,1) = final_im_pos(i-1,1,1)+ultimo_sizeY;
    
    save(['final_im_pos_' titulo '.mat'],'final_im_pos');

end