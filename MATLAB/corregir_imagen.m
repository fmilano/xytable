function [im_corregida] = corregir_imagen(im,kernel)
    im = double(im)/255;
    R = im(:,:,1);
    G = im(:,:,2);
    B = im(:,:,3);
    
    im_corregida(:,:,1) = R.*kernel;
    im_corregida(:,:,2) = G.*kernel;
    im_corregida(:,:,3) = B.*kernel;

    im = uint8(im*255);
    im_corregida = uint8(im_corregida*255);
end