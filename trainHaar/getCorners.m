% CSCi 5561 Spring 2015 - Semester Project
% Authors: Stephen Peyton, Chee Yi Ong
% Team: Who Is This (WIT)
% getCorners.m - takes in an integral image and computes the sum of intensities
% in the area bounded by the four coordinates
function intensity = getCorners(img,startX,startY,endX,endY)
    a = img(startY,startX);
    b = img(startY,endX);
    c = img(endY,startX);
    d = img(endY,endX);
    intensity = d-(b+c)+a; % by property of the integral image
end