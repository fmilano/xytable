function [] = crear_imagenes_finales(titulo,handles)
    load(['/home/axel/Desktop/XYTableAcData/data_' titulo '.mat']);
    bajar_fila(data{1},data{2},handles);
end