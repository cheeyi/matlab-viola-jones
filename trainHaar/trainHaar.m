% CSCi 5561 Spring 2015 - Semester Project
% Authors: Stephen Peyton, Chee Yi Ong
% Team: Who Is This (WIT)
% trainHaar.m - trains Haar features for face detection using Viola-Jones algorithm 
clc;
clear all;

%%%%% Convert to Integral Image %%%%%
% set image database sizes
faceSize = 2429;
nonFaceSize = 4547;
% construct image arrays
faces = cell(1,faceSize);
nonFaces = cell(1,nonFaceSize);

% temp arrays as failsafe, in case training gets interrupted halfway
temp1 = []; temp2=[]; temp3=[]; temp4=[]; temp5=[];

% iterate through each face image to get corresponding integral images
fprintf('Reading Face Images\n');
for faceNum = 1:faceSize
    % read face image
    str = 'TrainingFaces/';
    img = int2str(faceNum);
    fullPath = strcat(str,img,'.pgm');
    img = imread(fullPath);
    % convert to integral image
    integral = integralImg(img);
    % append to image array
    faces{faceNum} = integral;
end

% append to full list of images
allImages = faces;

% iterate through each non-face image to get corresponding integral images
fprintf('Reading Non-Face Images\n');
for nonFaceNum = 1:nonFaceSize
    % read non-face image
    str = 'TrainingNonFaces/';
    img = int2str(nonFaceNum);
    fullPath = strcat(str,img,'.pgm');
    img = imread(fullPath);
    % convert to integral image
    integral = integralImg(img);
    % append to image array
    nonFaces{nonFaceNum} = integral;
    % append to full list of images
    allImages{nonFaceNum+faceSize} = integral;
end
   
%%%%% Constructing Haar Features %%%%%
%%% Variable Definitions %%%
    % haar = the haar-like feature type
    % dimX, dimY = the x,y dimensions of the original haar features
    % pixelX, pixelY = the x,y index value for the starting pixel of
    % each haar feature
    % haarX, haarY = the x,y dimensions of the transformed haar features

fprintf('Constructing Haar Features\n');
% initialize image weights
imgWeights = ones(faceSize+nonFaceSize,1)./(faceSize+nonFaceSize);
% matrix of haar feature dimensions
haars = [1,2;2,1;1,3;3,1;2,2];
% size of training images
window = 19;
% number of training iterations
for iterations = 1:2
    % initialize classifier container
    weakClassifiers = {};
    % iterate through features
    for haar = 1:5
        printout = strcat('Working on Haar #',int2str(haar),'\n');
        fprintf(printout);
        % get x dimension
        dimX = haars(haar,1);
        % get y dimension
        dimY = haars(haar,2);
        % iterate through available pixels in window
        for pixelX = 2:window-dimX
            for pixelY = 2:window-dimY
                % iterate through possible haar dimensions for pixel
                for haarX = dimX:dimX:window-pixelX
                    for haarY = dimY:dimY:window-pixelY
                        % initialize haar storage vector (faces)
                        haarVector1 = zeros(1,faceSize);
                        % iterate through each integral image in faces array
                        for img = 1:faceSize
                            % calculate resulting feature value for each image
                            val = calcHaarVal(faces{img},haar,pixelX,pixelY,haarX,haarY);
                            % store feature value
                            haarVector1(img) = val;
                        end
                        % get distribution values for haar feature in faces
                        faceMean = mean(haarVector1);
                        faceStd = std(haarVector1);
                        faceMax = max(haarVector1);
                        faceMin = min(haarVector1);
                        % initialize haar storage vector (faces)
                        haarVector2 = zeros(1,nonFaceSize);
                        % iterate through each integral image in nonFaces array
                        for img = 1:nonFaceSize
                            % calculate resulting feature value for each
                            % image
                            val = calcHaarVal(nonFaces{img},haar,pixelX,pixelY,haarX,haarY);
                            % store feature values
                            haarVector2(img) = val;
                        end
                        % examine haar feature value distribution
                        % initialize storage containers
                        storeRatingDiff = [];
                        storeFaceRating = [];
                        storeNonFaceRating = [];
                        storeTotalError = [];
                        storeLowerBound = [];
                        storeUpperBound = [];
                        strongCounter = 0;
                        % arbitrarily chosen 50 'steps' to look at, starting from mean
                        for iter = 1:50
                            C = ones(size(imgWeights,1),1);
                            minRating = faceMean-abs((iter/50)*(faceMean-faceMin));
                            maxRating = faceMean+abs((iter/50)*(faceMax-faceMean));
                            % capture all false negative values
                            for val = 1:faceSize
                                if haarVector1(val) >= minRating && haarVector1(val) <= maxRating
                                    C(val) = 0;
                                end
                            end
                            % weighted false negative capture rate
                            faceRating = sum(imgWeights(1:faceSize).*C(1:faceSize));
                            if faceRating < 0.05 % if less than 5% faces misclassified
                                % capture all false positive values
                                for val = 1:nonFaceSize
                                    if haarVector2(val) >= minRating && haarVector2(val) <= maxRating
                                    else
                                        C(val+faceSize) = 0;
                                    end
                                end
                                % weighted false positive capture rate
                                nonFaceRating = sum(imgWeights(faceSize+1:nonFaceSize+faceSize).*C(faceSize+1:nonFaceSize+faceSize));
                                % total error
                                totalError = sum(imgWeights.*C);
                                if totalError < .5 % if less than 5% total error
                                    % store this as a weak classifier
                                    strongCounter = strongCounter+1;
                                    storeRatingDiff = [storeRatingDiff,(1-faceRating)-nonFaceRating];
                                    storeFaceRating = [storeFaceRating,1-faceRating];
                                    storeNonFaceRating = [storeNonFaceRating,nonFaceRating];
                                    storeTotalError = [storeTotalError,totalError];
                                    storeLowerBound = [storeLowerBound,minRating];
                                    storeUpperBound = [storeUpperBound,maxRating];
                                end
                            end
                        end

                        % if potential features exist, find index of one with the 
                        % maximum difference between true and false positives
                        if size(storeRatingDiff) > 0
                            maxRatingIndex = -inf; % by default
                            maxRatingDiff = max(storeRatingDiff);
                            for index = 1:size(storeRatingDiff,2)
                                if storeRatingDiff(index) == maxRatingDiff
                                    maxRatingIndex = index; % found the index of maxRatingDiff
                                    break;
                                end
                            end
                        end

                        % store classifier metadata into thisClassifier
                        if size(storeRatingDiff) > 0
                            thisClassifier = [haar,pixelX,pixelY,haarX,haarY,...
                                maxRatingDiff,storeFaceRating(maxRatingIndex),storeNonFaceRating(maxRatingIndex),...
                                storeLowerBound(maxRatingIndex),storeUpperBound(maxRatingIndex),...
                                storeTotalError(maxRatingIndex)];

                            % run Adaboost to obtain updated image weights
                            % and alpha values (classifier weight that
                            % determines how good a classifier is)
                            [imgWeights,alpha] = adaboost(thisClassifier,allImages,imgWeights);
                            % append alpha to classifier metadata
                            thisClassifier = [thisClassifier,alpha];
                            % store whole classifier into a cell array
                            weakClassifiers{size(weakClassifiers,2)+1} = thisClassifier;
                            % temp containers that stores current progress in
                            % case training needs to be interrupted
                            if haar == 1
                                temp1 = [temp1; thisClassifier];
                            elseif haar == 2
                                temp2 = [temp2; thisClassifier];
                            elseif haar == 3
                                temp3 = [temp3; thisClassifier];
                            elseif haar == 4
                                temp4 = [temp4; thisClassifier];
                            elseif haar == 5
                                temp5 = [temp5; thisClassifier];
                            end
                        end
                    end
                end
            end
        end
        printout = strcat('Finished Haar #',int2str(haar),'\n');
        fprintf(printout);
    end 
end

%%%%% Make strong classifiers by sorting according to alpha values %%%%%
fprintf('Make strong classifiers from sorting according to alpha values\n');
alphas = zeros(size(weakClassifiers,2),1);
for i = 1:size(alphas,1)
    % extract alpha column from classifier metadata
    alphas(i) = weakClassifiers{i}(12);
end

% sort weakClassifiers
tempClassifiers = zeros(size(alphas,1),2); % 2 column
% first column is simply original alphas
tempClassifiers(:,1) = alphas;
for i = 1:size(alphas,1)
    % second column is the initial index of alpha values wrt original alphas
   tempClassifiers(i,2) = i; 
end

tempClassifiers = sortrows(tempClassifiers,-1); % sort descending order

% number of strong classifiers tailored to our implementation, might vary
selectedClassifiers = zeros(286,12);
for i = 1:286
    selectedClassifiers(i,:) = weakClassifiers{tempClassifiers(i,2)};
end

% save final set of strong classifiers into a .mat file for easier access
save('finalClassifiers.mat','selectedClassifiers');
