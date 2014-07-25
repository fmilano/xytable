function [im_eq] = eq_rgb(im)
    R = histeq(im(:,:,1));
    G = histeq(im(:,:,2));
    B = histeq(im(:,:,3));
    im_eq(:,:,1) = R;
    im_eq(:,:,2) = G;
    im_eq(:,:,3) = B;
end