%   Se genera el kernel de correccion de la incidencia de la luz en la
%   imagen
function [kernel] = calibracion(imagen)

    if isempty(imagen)
        % Se lee la imagen de calibración (sin muestra)
        im = double(imread('calibracion.jpg'))/255;
    else
        im = double(imagen)/255;
    end
    
    im_g=rgb2gray(im);
    media = mean(mean(im_g));
    kernel = media./im_g;
end