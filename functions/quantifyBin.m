function [ param ] = quantifyBin( bin )
% Compute parameter such as:
%   1. vascular density

if max(max(bin)) == 255
    bin(bin==255) = 1;
end

param.VD = (sum(sum(bin)) / numel(bin))*100;

end

