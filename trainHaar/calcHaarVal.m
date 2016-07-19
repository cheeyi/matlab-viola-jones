% CSCi 5561 Spring 2015 - Semester Project
% Authors: Stephen Peyton, Chee Yi Ong
% Team: Who Is This (WIT)
% calcHaarVal.m - computes intensity differences between white/black region of Haar features 
function val = calcHaarVal(img,haar,pixelX,pixelY,haarX,haarY)
% img: integral image of an input image
% haar: which Haar feature (1-5)
% pixelX/Y: start point in (X,Y)
% haarX/Y: Haar feature size in X and Y directions

% getCorners() finds the total of the pixel intensity values in a white/black "box"
moveX = haarX-1;
moveY = haarY-1;
if haar == 1 % top/down white-black
    white = getCorners(img,pixelX,pixelY,pixelX+moveX,pixelY+floor(moveY/2)); 
    black = getCorners(img,pixelX,pixelY+ceil(moveY/2),pixelX+moveX,pixelY+moveY);
    val = white-black;
elseif haar == 2 % left/right white-black
    white = getCorners(img,pixelX,pixelY,pixelX+floor(moveX/2),pixelY+moveY);
    black = getCorners(img,pixelX+ceil(moveX/2),pixelY,pixelX+moveX,pixelY+moveY);
    val = white-black;
elseif haar == 3 % top/mid/bottom white-black-white
    white1 = getCorners(img,pixelX,pixelY,pixelX+moveX,pixelY+floor(moveY/3));
    black = getCorners(img,pixelX,pixelY+ceil(moveY/3),pixelX+moveX,pixelY+floor((moveY)*(2/3)));
    white2 = getCorners(img,pixelX,pixelY+ceil((moveY)*(2/3)),pixelX+moveX,pixelY+moveY);
    val = white1 + white2 - black;
elseif haar == 4 % left/mid/right white-black-white
    white1 = getCorners(img,pixelX,pixelY,pixelX+floor(moveX/3),pixelY+moveY);
    black = getCorners(img,pixelX+ceil(moveX/3),pixelY,pixelX+floor((moveX)*(2/3)),pixelY+moveY);
    white2 = getCorners(img,pixelX+ceil((moveX)*(2/3)),pixelY,pixelX+moveX,pixelY+moveY);
    val = white1 + white2 - black;
elseif haar == 5 % checkerboard-style white-black-white-black
    white1 = getCorners(img,pixelX,pixelY,pixelX+floor(moveX/2),pixelY+floor(moveY/2));
    black1 = getCorners(img,pixelX+ceil(moveX/2),pixelY,pixelX+moveX,pixelY+floor(moveY/2));
    black2 = getCorners(img,pixelX,pixelY+ceil(moveY/2),pixelX+floor(moveX/2),pixelY+moveY);
    white2 = getCorners(img,pixelX+ceil(moveX/2),pixelY+ceil(moveY/2),pixelX+moveX,pixelY+moveY);
    val = white1+white2-(black1+black2);
end