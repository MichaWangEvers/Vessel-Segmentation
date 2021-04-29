function [ FinalImage, InfoImage ] = tiffLoad( filename )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

tic

FileTif=filename;
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
FinalImage=zeros(nImage,mImage,NumberImages,'single');
 
TifLink = Tiff(FileTif, 'r');
for i=1:NumberImages
   TifLink.setDirectory(i);
   FinalImage(:,:,i)=TifLink.read();
end
TifLink.close();


t = toc;

disp( sprintf('Image sucessfully imported! Loading took %3.2f seconds.', t) );

end

