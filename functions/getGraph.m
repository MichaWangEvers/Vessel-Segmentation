function [ graph ] = getGraph( im, neighborhood, mode, sigma )
% Construct a graph with the links for the sparse matrix (pairwise)
% Choose betweend modi and sigma

% define neighborhood
if neighborhood == 4
    n = [0 1; -1 0; 0 -1; 1 0];
elseif neighborhood == 8
    n = [0 1; -1 1; -1 0; -1 -1; 0 -1; 1 -1; 1 0; 1 1];
elseif neighborhood == 16
    n = [0 1;-1 2; -1 1; -2 1; -1 0; -2 -1; -1 -1; -1 -2; 0 -1; 1 -2; 1 -1; 2 -1; 1 0; 2 1; 1 1; 1 2];
else
    disp('Invalid neighborhood size');
end

% pairwise
pairwise = sparse(numel(im), numel(im));

sX = size(im,1);
sY = size(im,2);

if strcmp( mode, 'potts' )
    % Pott's model
    for x = 1 : sX
        for y = 1 : sY
            px = (x-1)*sY + y; % pixel vector index
            for j = 1:size(n,1)
                if x + n(j,1) >= 1 && x + n(j,1) <= size(im,1) && y + n(j,2) >=1 && y + n(j,2) <= size(im,2)
                    % find neighborpixel in vector
                    pxJ = (x-1+n(j,1))*sY + (y+n(j,2));
                    
                    % apply weighting
                    pairwise( px, pxJ ) = pairwise( px, pxJ ) + sigma;
                end
            end
        end
    end
    
elseif strcmp( mode, 'eucl')
    for x = 1 : sX
        for y = 1 : sY
            px = (x-1)*sY + y; % pixel vector index
            for j = 1:size(n,1)
                if x + n(j,1) >= 1 && x + n(j,1) <= size(im,1) && y + n(j,2) >=1 && y + n(j,2) <= size(im,2)
                    % find neighborpixel in vector
                    pxJ = (x-1+n(j,1))*sY + (y+n(j,2));
                    
                    % apply weighting
                    % Boykov and Jolly 2003 (paper) same as Zhao et al. 2015
                    deltaPhi = acos(dot( n(1,:), n(j,:) ) / ( norm(n(1,:)) * norm(n(j,:)) ));
                    l = sqrt(sum(n(j,:).^2));
                    w_ij = deltaPhi / (2*l);
                    pairwise( px, pxJ ) = sigma * w_ij;
                end
            end
        end
    end
    
elseif strcmp( mode, 'Boykov2003' )
    for x = 1 : sX
        for y = 1 : sY
            px = (x-1)*sY + y; % pixel vector index
            for j = 1:size(n,1)
                if x + n(j,1) >= 1 && x + n(j,1) <= size(im,1) && y + n(j,2) >=1 && y + n(j,2) <= size(im,2)
                    % find neighborpixel in vector
                    pxJ = (x-1+n(j,1))*sY + (y+n(j,2));
                    
                    % angle independent
                    pairwise( px, pxJ ) = sigma / sqrt(sum(n(j,:).^2));
                end
            end
        end
    end
end

graph = pairwise;

end