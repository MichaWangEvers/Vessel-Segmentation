function [ param, branchpointimage ] = quantifySkel( skel )
% Find quantifying parameter for skeletons such as
%   1. Vessel length density
%   2. branchpoint index

if max(max( skel )) == 255
    skel(skel==255) = 1; 
end

% 1. VLD
param.VLD = (sum(sum(skel)) / numel( skel ))*100;

% 2. branchpoint index
jxy = bwmorph(skel, 'branchpoints');  % might be too sensitive to artifacts
param.branchP = sum(jxy(:)); %/ numel(skel);


%% Overlay Image
se = strel('disk',2);
jxy = imdilate(jxy,se);
skel1 = im2uint8(skel);
RGB1 = cat(3, jxy * 1, jxy * 0, jxy * 0);
RGB2 = cat(3, skel * 1, skel * 1, skel * 1);
Com = 1.6 * RGB1 + 0.6 * RGB2;
branchpointimage  = imadjust(Com,[0.01 0.99],[]);  
end

