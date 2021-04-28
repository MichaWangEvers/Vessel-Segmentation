function [bin, skel, pairwise, composite] = Parameters(im, pairwise, motion_artifacts, SavePath, saveFile)
im = im.* (255/max(max(im)));

%% Optimization based vessel segmentation scaled by:
%BM3D
sigma = 30;                 %change Std. dev. of the noise (corresponding to intensities in range [0,255]

%CLAHE
nTiles = [24 24];           %change Number of rectangular contextual regions (tiles) into which adapthisteq divides the image
cLimit = 0.1;               %change Contrast enhancement limit, specified as a number in the range [0, 1]. Higher limits result in more contrast
cDist = 'uniform';          %change Desired histogram shape: 'uniform' 'rayleigh' 'exponential'

%Local Adaptive Threshold
wr = 45;                    %change Neighborhoodsize for adaptthresh (2*wr)+1 Size of neighborhood used to compute local statistic around each pixel
noiseL = 0.05;              %change Sensitivity — Determine which pixels get thresholded as foreground pixels default is 0.5
statistic = 'gaussian';     %change Statistic used to compute local threshold at each pixel: 'mean' 'median' 'gaussian'

%GraphCut
gcNeigh = 4;                %change Define neighborhood: '4' '8' '16'
gcWeighting = 'potts';      %change Define weighting mode: 'potts' 'eucl' 'Boykov2003'
gcSigma = 1;                   
gcLabelcost = [1, 1; 1, 1]; 
gcLambda = [1, 4];          

%% Remove Movement Artifacts (vertical lines) Using Wavelet And Fourier Transform

if motion_artifacts == 1
    ima = im;
    decNum = 18;
    wname = 'db45';
    sigma1 = 8;

       % wavelet decomposition
       for ii=1:decNum
           [ima,Ch{ii},Cv{ii},Cd{ii}]=dwt2(ima,wname);
       end
      
       % FFT transform of horizontal frequency bands
       for ii=1:decNum
           % FFT
           fCv=fftshift(fft(Cv{ii}));
           [my,mx]=size(fCv);

           % damping of vertical stripe information
           damp=1-exp(-(-floor(my/2):-floor(my/2)+my-1).^2/(2*sigma1^2));
           fCv=fCv.*repmat(damp',1,mx);

           % inverse FFT
           Cv{ii}=ifft(ifftshift(fCv));
       end

       % wavelet reconstruction
       nima=ima;
       for ii=decNum:-1:1
           nima=nima(1:size(Ch{ii},1),1:size(Ch{ii},2));
           nima=idwt2(nima,Ch{ii},Cv{ii},Cd{ii},wname);
       end
        
    im = abs(single(nima));
    im(1,:)=[];
    im(:,size(im,1))=[];
    wavelet = im;
    saveastiff(wavelet,[SavePath, saveFile, '-MIP1.tiff']);
    else
end

       
%% Segment Vessel
% denoise image ->  BM3D     denoising and smoothing of the image
[~, imageF] = BM3D(0, im, sigma);
imageF = imageF .* 255;

%% Enhance Contrast  ->  CLAHE
imageC = single(adapthisteq( uint8(imageF), 'NumTiles', nTiles, 'ClipLimit', cLimit,'Distribution', cDist ));
imageC = imageC./(max(max(imageC)));

%% Binarize  ->   Local Adaptive Threshold    Turns Image Into Binary Vessel
imC = imageC ./ max(max(imageC));
map = adaptthresh( imC, noiseL, 'ForegroundPolarity', 'bright', 'NeighborhoodSize', (2*wr)+1, 'Statistic', statistic );
bin = zeros(size(imC));
bin(imC>map) = 1;

%% Refinement    ->  Graphcut
[cut, pairwise] = graphCutSeg( imageC, bin, pairwise, gcNeigh, gcWeighting, gcSigma, gcLabelcost, gcLambda);
bin = cut.Binary; %makes the binary vessel map cleaner, change values to reduce VAD

%% Skeletonize Morphological
skel = bwmorph(bin, 'skel', Inf);

%% Overlay Images
if motion_artifacts == 1
    Image = wavelet./255;
else
    Image = im./255;
end

Image = imadjust(Image);
RGB1 = cat(3, bin * 1, bin * 0, bin * 0);
RGB2 = cat(3, Image * 1, Image * 1, Image * 1);
composite = RGB1 + RGB2;

end

