function [mov,match_point1,match_point2,min_metric] = match(imagen1,imagen2,surf_threshold,match_threshold,type)
    ud = get(0,'userdata');
    I1 = rgb2gray(imagen1);
    I2 = rgb2gray(imagen2);

    if (strcmp(type,'preview'))
        numOctaves = ud.const.nunmOctaves_preview*5;
        escala = 0.2;
    elseif (strcmp(type,'hd'))
        numOctaves = ud.const.nunmOctaves_hd;
        surf_threshold = surf_threshold*1000;
    end
    
    POINTS1 = detectSURFFeatures(I1,'NumOctaves',numOctaves,'MetricThreshold',surf_threshold,'NumScaleLevels',12);
    POINTS2 = detectSURFFeatures(I2,'NumOctaves',numOctaves,'MetricThreshold',surf_threshold,'NumScaleLevels',12);
    
    fin = 0;
    while (fin == 0)
        if (size(POINTS1,1) > 5000)
            surf_threshold = surf_threshold*3;
            POINTS1 = detectSURFFeatures(I1,'NumOctaves',numOctaves,'MetricThreshold',surf_threshold,'NumScaleLevels',12);
            POINTS2 = detectSURFFeatures(I2,'NumOctaves',numOctaves,'MetricThreshold',surf_threshold,'NumScaleLevels',12);
        else
            fin = 1;
        end
    end
    
    fin = 0;
    while (fin == 0)
        if (size(POINTS1,1) < 200)
            surf_threshold = surf_threshold/10;
            POINTS1 = detectSURFFeatures(I1,'NumOctaves',numOctaves,'MetricThreshold',surf_threshold,'NumScaleLevels',12);
            POINTS2 = detectSURFFeatures(I2,'NumOctaves',numOctaves,'MetricThreshold',surf_threshold,'NumScaleLevels',12);
        else
            fin = 1;
        end
    end
    
    
    
    
    [FEATURES1, VALID_POINTS1] = extractFeatures(I1, POINTS1, 'SURFSize',64);
    [FEATURES2, VALID_POINTS2] = extractFeatures(I2, POINTS2,'SURFSize',64);
    
    [index_pairs metric] = matchFeatures(FEATURES1, FEATURES2,'MatchThreshold',match_threshold, 'Metric','SSD');

    if (isempty(index_pairs))
        [index_pairs metric] = matchFeatures(FEATURES1, FEATURES2,'MatchThreshold',match_threshold*2);
    end
    
    % Retrieve locations of corresponding points for each image
    matched_points1 = VALID_POINTS1(index_pairs(:, 1), :);
    matched_points2 = VALID_POINTS2(index_pairs(:, 2), :);
    
    %Se toman sólo los pares matcheados de mayor radio
    fin = 0;
    lim_scale = 5;
    while (fin == 0)
    indices_validos = find(matched_points1.Scale>lim_scale);
    
    try
        indices_validos = indices_validos(find(matched_points2(indices_validos).Scale > lim_scale));
    catch
        disp('error de indección');
        indices_validos = [];
    end
    if (isempty(indices_validos))
           lim_scale = lim_scale*0.5;
       else
           fin = 1;
       end
    end
    
    mp1 = matched_points1(indices_validos);
    mp2 = matched_points2(indices_validos);
    
    
%     figure;subplot(1,2,1);imshow(imagen1);hold all;plot(mp1);subplot(1,2,2);imshow(imagen2);hold all;plot(mp2);
    
    indice_mejor = indices_validos(find(metric(indices_validos)==min(metric(indices_validos))));

    % Si no encontro coincidencias, reitera la función, con un threshold
    % más alto
    if (isempty(indice_mejor))
        [mov,match_point1,match_point2,min_metric] = match(imagen1,imagen2,surf_threshold,match_threshold*10,'preview');
    else
        indice_mejor=indice_mejor(1);
        match_point1 = VALID_POINTS1(index_pairs(indice_mejor, 1), :);
        match_point2 = VALID_POINTS2(index_pairs(indice_mejor, 2), :);

        min_metric = min(metric);
        mov = round(fliplr(match_point1.Location - match_point2.Location));

%         figure(1);subplot(1,2,1);imshow(imagen1);hold all;plot(match_point1);subplot(1,2,2);imshow(imagen2);hold all;plot(match_point2);
    end
    
    % Se fuerza la coincidencia durante movimientos en X
    if (ud.forzar_coincidencia == 1)
        [index_pairs metric] = matchFeatures(FEATURES1, FEATURES2,'MatchThreshold',match_threshold*5);
        for (i = 1:size(index_pairs,1))
            mov = round(fliplr(VALID_POINTS1(index_pairs(i,1)).Location - VALID_POINTS2(index_pairs(i,2)).Location));
            % Si los puntos coinciden en Y (con cierto margen) se considera
            % una buena coincidencia
            if (mov(1) >= -10) && (mov(1) <= 10)
                if (ud.sentido == ud.DERECHA)
                    porcentaje = 200 - 100*(ud.sizeX_preview+mov(2))/ud.sizeX_preview;
                    SP = ud.const.SP;
                else
                    porcentaje = 100*(ud.sizeX_preview+mov(2))/ud.sizeX_preview;
                    SP = ud.const.SP;
                end
                
                if (porcentaje > SP-15) && (porcentaje < SP+21)
                    %figure(1);subplot(1,2,1);imshow(imagen1);hold on;plot(VALID_POINTS1(index_pairs(i,1)));subplot(1,2,2);hold on;imshow(imagen2);plot(VALID_POINTS2(index_pairs(i,2)));
                    ud.forzar_coincidencia = 0;
                    set(0,'userdata',ud);
                    match_point1 = VALID_POINTS1(index_pairs(i, 1), :);
                    match_point2 = VALID_POINTS2(index_pairs(i, 2), :);
                    
                    break;
                end       
            end
        end
    end
    
    % Se fuerza la coincidencia durante el stiching de las filas
    if (ud.forzar_coincidencia_stitching == 1)
        [index_pairs metric] = matchFeatures(FEATURES1, FEATURES2,'MatchThreshold',match_threshold*5);

        fin = 0;
        
        while (fin == 0)
        
            for (i = 1:size(index_pairs,1))
                mov = round(fliplr(VALID_POINTS1(index_pairs(i,1)).Location - VALID_POINTS2(index_pairs(i,2)).Location));
                mov = round(mov/escala);
                % Si los puntos coinciden en Y (con cierto margen) se considera
                % una buena coincidencia

                mov_estimado = ud.const.mov_estimado;
                margen_mov = ud.const.margen_mov;

                if (mov(1) > mov_estimado-margen_mov) && (mov(1) < mov_estimado+margen_mov) && (mov(2) < 50) && (mov(2) > -50)
                    axes(ud.handles.axes1_1);hold off;imshow(imagen1);hold on;plot(VALID_POINTS1(index_pairs(i,1)));
                    axes(ud.handles.axes1_2);hold off;imshow(imagen2);hold on;plot(VALID_POINTS2(index_pairs(i,2)));

                    pause(1);

                    choice = questdlg('¿Es correcta la coincidencia?', 'Validación de coincidencia', ...
                    'No, siguiente punto','Si, aceptar','Mover puntos','No, siguiente punto');
                    % Handle response
                    switch choice
                        case 'No, siguiente punto'
                            fin = 0;
                        case 'Si, aceptar'
                            fin = 1;
                        case 'Mover puntos'            
                            ud = get(0,'userdata');
                            ud.fin_mover_puntos = 0;set(0,'userdata',ud);
                            set(ud.handles.pb_up,'enable','on');
                            set(ud.handles.pb_down,'enable','on');
                            set(ud.handles.pb_left,'enable','on');
                            set(ud.handles.pb_right,'enable','on');
                            set(ud.handles.pb_aceptar,'enable','on');
                            
                            mp1 = VALID_POINTS1(index_pairs(i,1));

                            while (ud.fin_mover_puntos == 0)
                                ud = get(0,'userdata');
                                if (ud.mov_up == 1)
                                    disp('up');
                                    ud.mov_up = 0;set(0,'userdata',ud);
                                    mp1.Location = mp1.Location + [0 -1];
                                    axes(ud.handles.axes1_1);hold off;imshow(imagen1);hold on;plot(mp1);
                                end
                                if (ud.mov_down == 1)
                                    disp('down');
                                    ud.mov_down = 0;set(0,'userdata',ud);
                                    mp1.Location = mp1.Location + [0 1];
                                    axes(ud.handles.axes1_1);hold off;imshow(imagen1);hold on;plot(mp1);
                                end
                                if (ud.mov_left == 1)
                                    disp('left');
                                    ud.mov_left = 0;set(0,'userdata',ud);
                                    mp1.Location = mp1.Location + [-1 0];
                                    axes(ud.handles.axes1_1);hold off;imshow(imagen1);hold on;plot(mp1);
                                end
                                if (ud.mov_right == 1)
                                    disp('right');
                                    ud.mov_right = 0;set(0,'userdata',ud);
                                    mp1.Location = mp1.Location + [1 0];
                                    axes(ud.handles.axes1_1);hold off;imshow(imagen1);hold on;plot(mp1);
                                end  
                                
                                pause(0.001);
                            end
                            mov = fliplr(mp1.Location - VALID_POINTS2(index_pairs(i,2)).Location);
                            match_point1 = mp1;
                            match_point2 = VALID_POINTS2(index_pairs(i, 2), :);
                            fin = 1;
                            return;
                    end

                    ud.forzar_coincidencia_stitching = 0;
                    set(0,'userdata',ud);

                    if (fin == 1)
                        mov = mov*escala;
                        break;
                    end
                end
            end
            
            set(ud.handles.pb_up,'enable','off');
            set(ud.handles.pb_down,'enable','off');
            set(ud.handles.pb_left,'enable','off');
            set(ud.handles.pb_right,'enable','off');
            set(ud.handles.pb_aceptar,'enable','off');
            
            % Aumento el numero de puntos
            if (fin == 0)
                [mov,match_point1,match_point2,~] = match(imagen1,imagen2,surf_threshold/20,0.7,'preview');
            else
                match_point1 = VALID_POINTS1(index_pairs(i, 1), :);
                match_point2 = VALID_POINTS2(index_pairs(i, 2), :);
                %figure(4);subplot(2,1,1);imshow(imagen1);hold on;plot(match_point1);subplot(2,1,2);hold on;imshow(imagen2);plot(match_point2);
                break;
            end
        end
        
        
    end
    
end