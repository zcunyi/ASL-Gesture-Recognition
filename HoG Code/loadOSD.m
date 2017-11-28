clc;
clear all;
close all;

%% Load DataSets

path = 'C:\Courses\Computer Vision\ASL Gesture Recognition\Datasets\osd\Dataset';
dirFolders = dir(path)

letter = ['abcdefghijklmnopqrstuvwxyz'];
count = 1;
for i=3:size(dirFolders,1)
    if size(dirFolders(i).name,2) == 1
        dataset.letter = dirFolders(i).name;
        newPath = strcat(path,'\',dirFolders(i).name);
        files = dir(newPath);
        [dataset.originalIm,dataset.thresholdIm,dataset.area,dataset.defects,dataset.hull] = loadFiles(newPath,files);
        datasets{count} = dataset;
        count = count + 1;
    end    
end
nDatasets = count-1;

%% Part 1 - Using the Thresholded Image -> HoG Features
%% Divide into Training and Testing 

%Insert all the thresholded matrices in a single one and create a response
%matrix
nObservations = 1;
for i=1:nDatasets
    threshImTemp = datasets{i}.thresholdIm;
    currLetter = datasets{i}.letter;
    nThreshIm = size(threshImTemp,2);
    threshIm(nObservations:nObservations+nThreshIm-1) = threshImTemp; 
    response(nObservations:nObservations+nThreshIm-1) = repmat(currLetter,1,nThreshIm);
    nObservations = nObservations + nThreshIm - 1;
end;

for i =1:nObservations;
    hogThreshIm{i} = extractHOGFeatures(threshIm{i});
end;

k = 0.8;
[trainHog trainLetter testHog testLetter] = splitdataset(hogThreshIm,response,k) ;
trainHog = double(reshape(cell2mat(trainHog),[],size(trainHog,2)));
testHog = double(reshape(cell2mat(testHog),[],size(testHog,2)));

%% Part2 - Fit the SVM
mdl = fitcecoc(trainHog',trainLetter');

%% Part3 - Test the SVM
predict(mdl,testHog')


