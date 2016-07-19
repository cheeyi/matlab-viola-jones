% CSCi 5561 Spring 2015 - Semester Project
% Authors: Stephen Peyton, Chee Yi Ong
% Team: Who Is This (WIT)
% cascade.m - takes in a set of classifiers and an image subwindow and
% classifies it as either a face or non-face
function output = cascade(classifiers,img,thresh)
result = 0;
px = size(classifiers,1);
weightSum = sum(classifiers(:,12));
% iterate through each classifier
for i = 1:px
    classifier = classifiers(i,:);
    haar = classifier(1);
    pixelX = classifier(2);
    pixelY = classifier(3);
    haarX = classifier(4);
    haarY = classifier(5);
    % calculate the feature value for the subwindow using the current
    % classifier
    haarVal = calcHaarVal(img,haar,pixelX,pixelY,haarX,haarY);
    if haarVal >= classifier(9) && haarVal <= classifier(10)
        % increase score by the weight of the corresponding classifier
        score = classifier(12);
    else
        score = 0;
    end
   result = result + score;
end
% compare resulting weighted success rate to the threshold value
if result >= weightSum*thresh
    output = 1; % hit
else
    output = 0; % miss
end
end