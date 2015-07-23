%   Si el sentido es 'derecha' (1), se supone que el mov fue calculado siendo
%   la im1 la izquierda, y la im2 la derecha. La im2 debe estar a lo sumo
%   corrida para arriba.
%   Si el sentido es 'izquierda' (-1), el mov se debe calcular igual. La im1 es
%   nuevamente la izquierda, y debe estar a lo sumo corrida hacia abajo.
%   Si el sentido es 'abajo' (0), se está suponiendo que las dos imagenes
%   tienen iguales dimensiones en X
function [im_final,im_siguiente] = stitch(im1,im2,mov,sentido,sizeX)
    DERECHA = 1;
    IZQUIERDA = -1;
    ABAJO = 0;
    num_ceros = 0;
    
    mov = abs(mov);
    dimensionX1 = size(im1,2);
    dimensionX2 = size(im2,2);
    dimensionY1 = size(im1,1);
    dimensionY2 = size(im2,1);
    
    % Si el sentido es izquierda o derecha
    if (sentido ~= ABAJO)
        
        if (sentido == IZQUIERDA)
            aux = im1;
            im1 = im2;
            im2 = aux;
            % Esta bien dar vuelta las imagenes, pero tambien hay que
            % asegurar que im1 sea menor o igual a im2
            if (size(im1,1) > size(im2,1))
                num_ceros = size(im1,1) - size(im2,1);
                im1 = im1(mov(1)+1:end,:,:);
                mov(1) = 0;
                
                dimensionX1 = size(im1,2);
                dimensionX2 = size(im2,2);
                dimensionY1 = size(im1,1);
                dimensionY2 = size(im2,1);
            end
        end

        % Se pegan las 2 imagenes. Se recortan por debajo
        im_fin = uint8(zeros(min(dimensionY1+mov(1),dimensionY2),dimensionX2+mov(2),3));         % Se alocan ceros 
        im_fin(1+mov(1):end,1:mov(2)+1,:) = im1(1:size(im_fin,1)-mov(1),1:mov(2)+1,:);           % Se pega la im1
        im_fin(1:end,mov(2)+1:end,:) = im2(1:size(im_fin,1),:,:);      % Se pega arriba, la im2

        % Se recortan las zonas negras
        im_fin = im_fin(1+mov(1):end,:,:);

        % Se realiza el overlap
        image_1 = double(im1)/255;
        image_fin = double(im_fin)/255;
        pixel1_mat = image_1(1:min(end,dimensionY2-mov(1)),mov(2)+1:end,:);
        pixel2_mat = image_fin(:,mov(2)+1:mov(2)+size(pixel1_mat,2),:);

        % Matrices de pesos en la overlap zone
        distancia_1 = ones(size(pixel1_mat,1),1)*(1:size(pixel1_mat,2));

        % Weight matrices of the overlap zone 
        weight_1 = (1./distancia_1).^4;
        weight_2 = fliplr(weight_1);
        sum_weight = weight_1 + weight_2;
        weight_normalized_1 = weight_1./sum_weight;
        weight_normalized_2 = fliplr(weight_normalized_1);

        weight_normalized_1_3D = zeros(size(pixel1_mat));
        weight_normalized_1_3D(:,:,1) = weight_normalized_1;
        weight_normalized_1_3D(:,:,2) = weight_normalized_1;
        weight_normalized_1_3D(:,:,3) = weight_normalized_1;

        weight_normalized_2_3D = zeros(size(pixel1_mat));
        weight_normalized_2_3D(:,:,1) = weight_normalized_2;
        weight_normalized_2_3D(:,:,2) = weight_normalized_2;
        weight_normalized_2_3D(:,:,3) = weight_normalized_2;

        % Update of output_image, with the new overlap zone
        overlap_image = uint8(255*(pixel1_mat.* weight_normalized_1_3D + pixel2_mat.* weight_normalized_2_3D));
%         im_fin(:,mov(2)+1:mov(2)+size(pixel1_mat,2),:) = overlap_image;

        if (sentido == DERECHA)
            im_siguiente = im_fin(:,end-sizeX:end,:);
            im_final = im_fin(:,1:end-sizeX-1,:);
        elseif (sentido == IZQUIERDA)
            im_final = im_fin(:,sizeX+1:end,:);
            im_siguiente = im_fin(:,1:sizeX,:); 
        end
%        figure;imshow([im_siguiente im_final]);  % Para la izquierda
    
    % Si el sentido es abajo
    else
        
        movY = mov(1);

        % Se pegan las 2 imagenes
        im_fin = [im1(1:movY,:,:) ; im2(:,:,:)];    % Se pega la im2 sobre la im1

        % Se realiza el overlap
        image_1 = double(im1)/255;
        image_2 = double(im2)/255;
        pixel1_mat = image_1(movY+1:end,:,:);
        pixel2_mat = image_2(1:dimensionY1-movY,:,:);

        % Matrices de pesos en la overlap zone
        distancia_1 = (1:size(pixel1_mat,1))' * ones(1,size(pixel1_mat,2));
        
        weight_1 = (1./distancia_1).^4;
        weight_2 = flipud(weight_1);
        sum_weight = weight_1 + weight_2;
        weight_normalized_1 = weight_1./sum_weight;
        weight_normalized_2 = flipud(weight_normalized_1);

        weight_normalized_1_3D = zeros(size(pixel1_mat));
        weight_normalized_1_3D(:,:,1) = weight_normalized_1;
        weight_normalized_1_3D(:,:,2) = weight_normalized_1;
        weight_normalized_1_3D(:,:,3) = weight_normalized_1;

        weight_normalized_2_3D = zeros(size(pixel1_mat));
        weight_normalized_2_3D(:,:,1) = weight_normalized_2;
        weight_normalized_2_3D(:,:,2) = weight_normalized_2;
        weight_normalized_2_3D(:,:,3) = weight_normalized_2;

        % Update of output_image, with the new overlap zone
        overlap_image = uint8(255*(pixel1_mat.* weight_normalized_1_3D + pixel2_mat.* weight_normalized_2_3D));
%         im_fin(movY+1:movY+size(overlap_image,1),:,:) = overlap_image;
        
        im_final = im_fin;        
    end
    
   
end