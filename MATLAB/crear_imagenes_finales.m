function [] = crear_imagenes_finales(titulo)
    load(['data_' titulo '.mat']);
    bajar_fila(data{1},data{2});
end