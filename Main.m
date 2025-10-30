 
clc;
clear;
close all;
%To avoid this randomness, the random seed is set to reproduce the same results every time.
  rand('seed', 672880951);

 
%Create an image datastore holding the training images.
dataSetDir =fullfile('D:','Sample of OrginalG93');
 %%%%%% 
imageDir = fullfile(dataSetDir,['Orginal' ...
    '-128']);
labelDir = fullfile(dataSetDir,'Sample of GroundTruthG93');

classNames = {'Cell','Background'};
labelIDs = [255 0];
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 imds = imageDatastore(imageDir);
pxds = pixelLabelDatastore(labelDir,classNames,labelIDs);

% 
pximds = pixelLabelImageDatastore(imds,pxds);
tbl = countEachLabel(pximds)
% 
  imageSize = [128 128 1];
  numClasses = 2;

 
numberPixels = sum(tbl.PixelCount);
frequency = tbl.PixelCount / numberPixels;
classWeights = 1 ./ frequency;
%%%%% **************** layers *****%%%%%%%%%%%%%%%%%%

layers = [
    imageInputLayer([128 128 1])
%    %%%%%%%%%% 1 %%%%%%%%%%%
       convolution2dLayer(3,64,'Stride',1,'Padding',1)%,'WeightsInitialize','narrow-normal')
       reluLayer   
       maxPooling2dLayer(2,'Stride',2,'Padding',0')%% last digit control the given same size as the input image
      %%%%%%%%%%%%%% 2v%%%%%%%%%%%%%%%%%
       convolution2dLayer(3,64,'Stride',1,'Padding',1)%,'WeightsInitialize','narrow-normal')
        reluLayer
        transposedConv2dLayer(4,64,'Stride',2,'cropping',1)    
          %%%%%%%%%%%%%%%%%%% 3v%%%%%%%%%%%% 
       convolution2dLayer(1,2,'Stride',1,'Padding',0)%,'WeightsInitialize','narrow-normal') %always 1,2(classes)             
    softmaxLayer;
   pixelClassificationLayer('Classes',classNames,'ClassWeights',classWeights)];
   
%%%%%%%%%%%%%%%%%%Train the network%%%%%%%%%%%%%%%%%%%%%%%%%%.
 options = trainingOptions('sgdm', ...
    'MaxEpochs', 300, ...
    'MiniBatchSize', 64, ... 
    'InitialLearnRate', 1e-3, ...
    'Plots','training-progress');

% 
%              net128 = trainNetwork(pximds,layers,options);
%              save('net128','net128');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 load net128
 
%%%%**************** Testing *************************%%%
   
    pathname1 ='D:\MATLAB\Testing images Original\';% Testing images
      dirlist1 = dir( [pathname1 '*.png'] ); 
% %%%%
      pathname2 ='D:\MATLAB\ Ground\';% Testing image Ground
      dirlist2 = dir( [pathname2 '*.bmp'] );
% %  
 
    

%    %%%%**************** Start *************************%%%
   for v=1:length(dirlist1)
  I = imread([pathname1, dirlist1(v).name]);

  figure, imshow(I),title('Input image');
  
 

[C, DL, allScores]= semanticseg(I,net128);

   figure, imshow(DL),title('DL Seg');
  imwrite(DL, 'T4DL.png');
%%%%%%%%%%%%%5 Image fill %%%%%%%%%%%%%
   BW = imbinarize(DL);
   BW1=edge(BW);
   figure, imshow(BW1),title('Edge Image')

BW2 = imfill(BW1,'holes');
figure,imshow(BW2),title('Filled Image')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
A = imread([pathname2, dirlist2(v).name]);
%   A=imread('T3Ground.bmp');
  B = logical( A )
  G= imcomplement(B);
  figure,imshow(G),title('Ground');
%%%% Symmetry function %%%%%%%
v=3;
[similarityJ(v),similarityD(v)]=JD(A,G,v)
 
    end
 

X=0;
          