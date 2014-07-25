function [mov,match_point1,match_point2,min_metric] = match(imagen1,imagen2,surf_threshold,match_threshold)
    ud = get(0,'userdata');
    I1 = rgb2gray(imagen1);
    I2 = rgb2gray(imagen2);
    POINTS1 = detectSURFFeatures(I1,'NumOctaves',5,'MetricThreshold',surf_threshold);
    POINTS2 = detectSURFFeatures(I2,'NumOctaves',5,'MetricThreshold',surf_threshold);
    [FEATURES1, VALID_POINTS1] = extractFeatures(I1, POINTS1);
    [FEATURES2, VALID_POINTS2] = extractFeatures(I2, POINTS2);
    
    [index_pairs metric] = matchFeatures(FEATURES1, FEATURES2,'MatchThreshold',match_threshold);

    if (isempty(index_pairs))
        [index_pairs metric] = matchFeatures(FEATURES1, FEATURES2,'MatchThreshold',match_threshold*2);
    end
    
    % Retrieve locations of corresponding points for each image
    matched_points1 = VALID_POINTS1(index_pairs(:, 1), :);
    matched_points2 = VALID_POINTS2(index_pairs(:, 2), :);
    
    %figure;subplot(1,2,1);imshow(imagen1);hold all;plot(matched_points1);subplot(1,2,2);imshow(imagen2);hold all;plot(matched_points2);
    
    indice_mejor = find(metric==min(metric));

    % Si no encontro coincidencias, reitera la función, con un threshold
    % más alto
    if (isempty(indice_mejor))
        [mov,match_point1,match_point2,min_metric] = match(imagen1,imagen2,surf_threshold,match_threshold*10);
    else
        indice_mejor=indice_mejor(1);
        match_point1 = VALID_POINTS1(index_pairs(indice_mejor, 1), :);
        match_point2 = VALID_POINTS2(index_pairs(indice_mejor, 2), :);

        min_metric = min(metric);
        mov = round(fliplr(match_point1.Location - match_point2.Location));

        %figure;subplot(1,2,1);imshow(imagen1);hold all;plot(match_point1);subplot(1,2,2);imshow(imagen2);hold all;plot(match_point2);
    end
    
    if (ud.forzar_coincidencia == 1)
        [index_pairs metric] = matchFeatures(FEATURES1, FEATURES2,'MatchThreshold',match_threshold*5);
        for (i = 1:size(index_pairs,1))
            mov = round(fliplr(VALID_POINTS1(index_pairs(i,1)).Location - VALID_POINTS2(index_pairs(i,2)).Location));
            % Si los puntos coinciden en Y (con cierto margen) se considera
            % una buena coincidencia
            if (mov(1) >= -15) && (mov(1) <= 15)
                if (ud.sentido == ud.DERECHA)
                    porcentaje = 200 - 100*(ud.sizeX_preview+mov(2))/ud.sizeX_preview;
                    SP = 40;
                else
                    porcentaje = 100*(ud.sizeX_preview+mov(2))/ud.sizeX_preview;
                    SP = 40;
                end
                
                if (porcentaje > SP-25) && (porcentaje < SP+25)
                    %figure(1);subplot(1,2,1);imshow(imagen1);hold on;plot(VALID_POINTS1(index_pairs(i,1)));subplot(1,2,2);hold on;imshow(imagen2);plot(VALID_POINTS2(index_pairs(i,2)));
                    ud.forzar_coincidencia = 0;
                    set(0,'userdata',ud);
                    break;
                end       
            end
        end
    end
    
end