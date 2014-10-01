% Matriz: n filas del tipo:
% [Indice de primer imagen, cantidad de imagenes, sentido, sizeX total]

function [] = bajar_fila(titulo,matriz,handles)

    ud = get(0,'userdata');
    num_filas = size(matriz,1);
    % DEBUG
    %num_filas = 7;
    largo_nominal = 1000;           % Largo de tira de filas para realizar stitching
    
    if (num_filas == 1)
        return;
    end
    
    % DEBUG
    for i=1:num_filas
        im_pos{i} = build_matrix(titulo,i,matriz);
    end
    
    im_index = 0;
    anchoY_1 = 0;
    inicio_Y_proxima_fila = 1;
    inicio_X_proxima_fila = 1;
    ultimo_sizeY = 10e5;            % Valor arbitrario, grande
    recorte_x = 0;
    
    % Repito para cada fila
    for i = 1:num_filas-1
        
        disp(['Fila ' num2str(i)]);
        
        % Numero de imagen dentro de la fila actual
        num_im_fila = 0;

        % Fijo el inicio en Y y en X de la fila  
        inicio_Y = inicio_Y_proxima_fila;
        inicio_X = inicio_X_proxima_fila;
        
        % Identifico la zona central de ambas filas 
        centro = round(matriz(i,4)/2);
        escala = ud.const.escala_fila_stitching;
        
        lim_izq = max(centro-round(largo_nominal),1);
        lim_der = min([centro+round(largo_nominal) matriz(i,4) matriz(i+1,4)]);
        anchoX = lim_der-lim_izq+1;
        anchoY_1 = im_pos{i}(1,1,1);
        anchoY_2 = im_pos{i+1}(1,1,1);
        fila1 = find_image(titulo,[lim_izq lim_der],[1 anchoY_1],im_pos{i},[round(anchoX*escala) round(anchoY_1*escala)],0);
        fila2 = find_image(titulo,[lim_izq lim_der],[1 anchoY_2],im_pos{i+1},[round(anchoX*escala) round(anchoY_2*escala)],0);
        
        %figure(1);subplot(2,1,1);imshow(fila1);subplot(2,1,2);imshow(fila2);
        
        ud = get(0,'userdata');
        ud.forzar_coincidencia = 0;
        set(0,'userdata',ud);
        
        % Calculo el mov entre las dos filas
        [mov,mp1,mp2,~] = match(fila1,fila2,20,0.7,'preview');  
        mov = mov/escala;
        
        mov_estimado = ud.const.mov_estimado/escala;
        margen_mov = ud.const.margen_mov/escala;
        
        % Si el mov no da dentro del rango de tolerancia, se fuerza
        if ((mov(1) < (mov_estimado-margen_mov) ) || (mov(1) > (mov_estimado+margen_mov)) )
            disp('Se forzó el stitching');
            ud.forzar_coincidencia_stitching = 1;
            set(0,'userdata',ud);
            [mov,mp1,mp2,~] = match(fila1,fila2,20,0.7,'preview');
            mov = mov/escala;
        end
        
        % Se muestran los puntos de coincidencia entre las dos filas
        if (~isempty(handles))
            axes(handles.axes1_1);
            imshow(fila1);hold on;plot(mp1);title(['Fila ' num2str(i)]);
            axes(handles.axes1_2);
            imshow(fila2);hold on;plot(mp2);title(['Fila ' num2str(i+1)]);
        end
        
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
        
        % Se actualiza el inicio en Y de la proxima fila
        inicio_Y_proxima_fila = anchoY_1-mov(1);
        
        % Se determinan los inicios en X de cada recorte de imagen
        inicioX_1 = max(mov(2)+1,1);
        inicioX_2 = max(-mov(2)+1,1);
        
        % Si se cumple, ambas filas deben recortarse
        if (max(inicioX_1,inicioX_2) < inicio_X)
            inicioX_1 = inicio_X + inicioX_1 -1;
            inicioX_2 = inicio_X + inicioX_2 -1;
        end
        
        % Se actualiza el inicio en X de la proxima fila
        inicio_X_proxima_fila = inicioX_2;
        
        % Se recortan los sobrantes de imagenes, siempre que se cumpla que
        % la fila 2 esta a la derecha de la fila 1. Se recorta la fila 1, y
        % ademas se agrega un offset en todas las filas de arriba, para
        % recortarles el sobrante
        if (inicioX_1 > inicioX_2)
            offset = inicioX_1-inicio_X;
            for m=1:i-1
                % Se recortan offset pixeles de la primer imagen de cada
                % fila
                new_offset = offset;
                first_im_index = final_im_pos(m,2,2);
                disp(['Offset de ' num2str(offset) ' agregado en la fila ' num2str(m)]);
                aux = imread(['/home/axel/Desktop/XYTableAcData/'  titulo '/Final_' titulo '_0' num2str(first_im_index) '.png']);
                
                % Si el offset es mayor al tamaño de la primera imagen, se
                % toma también la segunda imagen
                if (size(aux,2) <= offset)
                    new_offset = offset-size(aux,2);
                    first_im_index = final_im_pos(m,3,2);
                    aux = imread(['/home/axel/Desktop/XYTableAcData/' titulo '/Final_' titulo '_0' num2str(first_im_index) '.png']);
                end
                aux = aux(:,new_offset+1:end,:);
                imwrite(aux,['/home/axel/Desktop/XYTableAcData/' titulo '/Final_' titulo '_0' num2str(first_im_index) '.png']);
                % Se actualiza la matriz final_im_pos con los nuevos
                % valores de pixeles
                final_im_pos(m,2:end,1)=final_im_pos(m,2:end,1)-offset;
            end
        end
        
        % Se recorre la fila i, en recortes de ancho nominal
        for j =1:largo_nominal:max_largo
        
            if (j+largo_nominal > max_largo)
                largo = max_largo-j+1;
            else
                largo = largo_nominal;
            end
            

            % Se realizan los recortes
            ventanaX = [j min(j+largo-1,max_largo)];
            if (ventanaX(2) == max_largo)
                ventanaX(2) = ventanaX(2) - max(inicioX_1,inicioX_2) +1;
                
                % Si la ultima imagen no puede recortarse, se descarta
                if (ventanaX(1) >= ventanaX(2))
                    continue;
                end
                
            end
            ventanaX_1 = ventanaX + inicioX_1 -1;
            ventanaX_2 = ventanaX + inicioX_2 -1; 
            
            if (ventanaX_1(2) > max_largo)
                ventanaX_1(2) = max_largo;
                ventanaX_2(2) = ventanaX_2(1) + diff(ventanaX_1);
            end
            
            if (ventanaX_2(2) > max_largo)
                ventanaX_2(2) = max_largo;
                ventanaX_1(2) = ventanaX_1(1) + diff(ventanaX_2);
            end
            
            ventanaY_1 = [inicio_Y anchoY_1];
            ventanaY_2 = [1 anchoY_2];
            
            fila1 = find_image(titulo,ventanaX_1,ventanaY_1,im_pos{i},[diff(ventanaX_1) diff(ventanaY_1)],0);
            fila2 = find_image(titulo,ventanaX_2,ventanaY_2,im_pos{i+1},[diff(ventanaX_2) diff(ventanaY_2)],0);
            
            if (size(fila1,2) ~= size(fila2,2))
                min_size = min(size(fila1,2),size(fila2,2));
                fila1 = fila1(:,1:min_size,:);
                fila2 = fila2(:,1:min_size,:);
            end

            % Se stitchean los recortes
            im_final = stitch(fila1,fila2,mov-inicio_Y+1,0,0);
            
            if (~isempty(handles))
                axes(handles.axes2);imshow(im_final);title(['Imagen numero ' num2str(num_im_fila+1)]);
            end
            
            
             
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
            imwrite(im_final,['/home/axel/Desktop/XYTableAcData/' titulo '/Final_' titulo '_0' num2str(im_index) '.png'],'png');
            
            
            % Numero de imagen en la fila
            num_im_fila = num_im_fila + 1;
            disp(['Imagen número ' num2str(num_im_fila)]);
            
            % Se crea una nueva matriz de im_pos, para las imagenes finales
            if (num_im_fila > 1)
                final_im_pos(i,num_im_fila+1,1) = final_im_pos(i,num_im_fila,1) + size(im_final,2); 
            else
                final_im_pos(i,num_im_fila+1,1) = size(im_final,2);   
            end
            final_im_pos(i,num_im_fila+1,2) = im_index;
            save(['/home/axel/Desktop/XYTableAcData/final_im_pos_' titulo '.mat'],'final_im_pos');
        end
    end
    
    % Se corrige el header de la ultima fila
    if (i==1)
        final_im_pos(i,1,1) = ultimo_sizeY;
    else
        final_im_pos(i,1,1) = final_im_pos(i-1,1,1)+ultimo_sizeY;
    end
    
    % Se copian en los contenidos de final_im_pos que valgan 0 el último
    % valor válido de la fila
    for fila=1:num_filas-1 
        imagen0 = find(final_im_pos(fila,2:end,2)==0);
        if (~isempty(imagen0))
            imagen0 = imagen0(1);
        end
        final_im_pos(fila,1+imagen0,2) = final_im_pos(fila,imagen0,2);
        final_im_pos(fila,1+imagen0,1) = final_im_pos(fila,imagen0,1);
    end
    save(['/home/axel/Desktop/XYTableAcData/final_im_pos_' titulo '.mat'],'final_im_pos');

end