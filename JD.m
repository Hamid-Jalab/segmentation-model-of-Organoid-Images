function [similarityJ,similarityD]=JD(I,G,v)

 
  gray = I; 


% Morphological Closing
se = strel('disk',1);
close = imclose(gray,se);
% Complement Image
K= imcomplement(close)
% figure, imshow(K),title('Imclose');

I2=im2bw(K)
%   figure,imshow(I2),title('Gray-Binary');

% 2-D wavelet Decomposition using B-Spline
[cA,cH,cV,cD] = dwt2(K,'bior1.1');
%% Otsu thresholding on each of the 4 wavelet outputs
thresh1 = multithresh(cA);
thresh2 = multithresh(cH);
thresh3 = multithresh(cV);
thresh4 = multithresh(cD);
% Calculating new threshold from sum of the 4 otsu thresholds and dividing by 2
level = (thresh1 + thresh2 + thresh3 + thresh4)/2;
% single level inverse discrete 2-D wavelet transform
X = idwt2(cA,cH,cV,cD,'bior1.1')
% Black and White segmentation
BW=imquantize(X,level);
% Iterative Canny Edge (Novel Method)
BW1 = edge(edge(BW,'canny'), 'canny');
% figure, imshow( (BW1)),title('BW1');

% Post-Processing
BW3 = imclearborder(BW1);
% figure, imshow( (BW3)),title('BW3');
BW3 = imcomplement(BW3);

BW4 = imfill(BW3,'holes');
% figure
imshow(BW4)
% title('Filled Image')

CC = bwconncomp(BW3);
S = regionprops(CC, 'Area');
L = labelmatrix(CC);
BW4 = ismember(L, find([S.Area] >= 50));
BW51 = imfill(BW4,'holes');
I3 = imcomplement(BW51);

% figure, imshow(BW51),title('BW51');
% figure, imshow(G),title('G');

 %%% Jaccard %%%%%%%
similarityJ=jaccard(BW51, G);%similarity

 figure,imshowpair(BW51, G,"falsecolor"),title(['Jaccard Index = ' num2str(similarityJ)])
X=0;
   
% % %%% Dice %%%%%%%
similarityD=dice(BW51, G);%similarity
 figure,imshowpair(BW51, G,"falsecolor"),title(['Dice Index = ' num2str(similarityD)])

