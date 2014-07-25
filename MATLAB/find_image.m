% Función que devuelve la porción de la imagen final, en la ventana 
% especificada, con la resolución adecuada para que pueda ser vista sin
% pérdida de información en una figura de (true_sizeX x tru_esizeY) píxeles
function [imagen,escala,num_imagenes] = find_image(titulo,ventanaX,ventanaY,pos_im,true_size)

    num_imagenes = 0;
    % Si la ventana X es mayor, se escala en X
    if (diff(ventanaX) > diff(ventanaY))
        escala = true_size(1)/diff(ventanaX);
    % Si no, se escala en Y
    else
        escala = true_size(2)/diff(ventanaY);
    end
    
    %escala = true_size(1)/max(diff(ventanaX),diff(ventanaY));
    %imagen = uint8(zeros(length(ventanaX),length(ventanaY),3));
    imagen = [];
    
    primer_fila = find(pos_im(1:end,1,1)>=ventanaY(1),1,'first');
    ultima_fila = find(pos_im(1:end,1,1)>=ventanaY(2),1,'first');
    
    borde_down = ventanaY(1)-1;
    
    imagen = [];
    
    for fila = primer_fila:ultima_fila
        
        primer_imagen_index = find(pos_im(1,2:end,1)>=ventanaX(1),1,'first');
        ultima_imagen_index = find(pos_im(1,2:end,1)>=ventanaX(2),1,'first');
           
        borde_up = borde_down + 1;
        borde_down = min( pos_im(fila,1,1) , ventanaY(2) );
        alto = borde_down - borde_up;
        
        if (fila==1)
            inicioY = borde_up;
        else
            inicioY = borde_up - pos_im(fila-1,1,1);
        end
 
        i = 1;
        
        fila_actual = [];
        borde_der = ventanaX(1)-1;
        
        % Se forma cada fila de la imagen resultante
        for im_index = primer_imagen_index:ultima_imagen_index
            num_imagenes = num_imagenes+1;
            im_aux = imread([titulo '_0' num2str(pos_im(fila,1+im_index,2)) '.png']); 
            
            borde_izq = borde_der+1;
            borde_der = min( pos_im(fila,1+im_index,1) , ventanaX(2) );
            ancho = borde_der - borde_izq;
            if (im_index==1)
                inicioX = borde_izq;
            else
                inicioX = borde_izq - pos_im(fila,im_index,1);
            end
               
            % Se concatenan las columnas de porciones de imágenes para
            % formar una fila de porciones
            porcion = im_aux(inicioY:inicioY+alto,inicioX:inicioX+ancho,:);
            if (isempty(porcion))
                disp('Error');
                imagen = 0;
                escala = 0;
                num_imagenes = 0;
                return;
            end
            % Se baja la resolucion de la imagen a mostrar
            fila_actual = [fila_actual imresize(porcion,escala)];
            i = i+1;
        end
        
        % Se concatenan las filas de porciones de imágenes
        if (~isempty(imagen))
            size_imagen_X = min(size(imagen,2),size(fila_actual,2)); 
            imagen = [imagen(:,1:size_imagen_X,:) ; fila_actual(:,1:size_imagen_X,:)];
        else
            imagen = [imagen ; fila_actual];
        end
        
        
    end

end