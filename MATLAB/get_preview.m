function [image] = get_preview (handles)
    w=[0];
    h=[0];
    [res] = calllib('libcameraControl', 'CapturePreview');
    if (~res)
         set(handles.text_camara,'string','No se pudo tomar el preview');
         return;
    end

    size = calllib('libcameraControl', 'GetPreviewSize');
    data = zeros(1,size);
    [res, preview, w, h] = calllib('libcameraControl', 'GetPreviewData', data, size, w, h);

    if (~res)
        set(handles.text_camara,'string','No se pudo tomar el preview');
        return;
    end
    
    R = preview(1:3:end);
    G = preview(2:3:end);
    B = preview(3:3:end);
    rgb = [R G B];
    image = reshape(rgb, [w h 3]);
    image = image(41:end-40,:,:);
end