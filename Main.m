function Main
close all;
clear all;

% Input: set motion_artifacts to 1 to remove vertial lines from image by
% using a Wavelet And Fourier Transform
motion_artifacts = 0;

[FileName,PathName] = uigetfile({'*.tiff';'*.tif'},'MultiSelect','on');
FileName = cellstr(FileName);

nIm = length(FileName);     %Number of images
VD = cell(1,nIm);           %Initialize VD variable
VLD = cell(1,nIm);          %Initialize VLD variable
NBP = cell(1,nIm);          %Initialize NBP variable

f = waitbar(0, ['Start processing all ', num2str(nIm), ' images']);
pairwise = []; % to use the graph for the graphcut again for same image-sizes



for i = 1:nIm
    loadFile = [PathName, FileName{i}];
    SavePath = [PathName 'Output\'];

    % loading and processing data
    waitbar(i/(nIm+1), f, ['Loading image ', num2str(i), ' / ', num2str(nIm)]);
    image = tiffLoad(loadFile);
    saveFile = FileName{i}(1:end-5);
        
    % analysing image
    waitbar((i+.5)/(nIm+1), f, ['Analysing image ', num2str(i), ' / ', num2str(nIm)]);
    [bin, skel, pairwise, composite] = Parameters(image, pairwise, motion_artifacts, SavePath, saveFile);

    param = quantifyBin(bin);
    VD{i} = param.VD;
    [param, branchpointimage] = quantifySkel(skel);
    VLD{i} = param.VLD; 
    NBP{i} = param.branchP;
    
    % saving
    waitbar((i+.8)/(nIm+1), f, ['Saving results of image ', num2str(i), ' / ', num2str(nIm)]);
    imwrite(bin, [SavePath, saveFile, '-seg-binary.png'],'png','WriteMode','overwrite');
    imwrite(skel, [SavePath, saveFile, '-seg-skeleton.png'],'png','WriteMode','overwrite');
    imwrite(branchpointimage, [SavePath, saveFile, '-seg-branchpoint.png'],'png','WriteMode','overwrite'); 
    imwrite(double(composite), [SavePath, saveFile, '-Composite.png'],'png','WriteMode','overwrite'); 

end

T = table(FileName', VD', VLD', NBP',  'VariableNames', {'File', 'Vessel_Density', 'Vessel_Length_Density', 'Number_Branch_Points'});
writetable(T, [SavePath, 'Vessel_Segmentation_Analysis.xls']);