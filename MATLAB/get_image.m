function [image] = get_image (handles)
    w=[0];
    h=[0];
    [res] = calllib('libcameraControl', 'CaptureImage');
    if (~res)
         set(handles.text_camara,'string','No se pudo tomar la foto');
         return;
    end

    size = calllib('libcameraControl', 'GetPreviewSize');
    data = zeros(1,size);
    [res, imagen, w, h] = calllib('libcameraControl', 'GetPreviewData', data, size, w, h);

    if (~res)
        set(handles.text_camara,'string','No se pudo tomar la foto');
        return;
    end
    
    R = imagen(1:3:end);
    G = imagen(2:3:end);
    B = imagen(3:3:end);
    rgb = [R G B];
    image = reshape(rgb, [w h 3]);
end