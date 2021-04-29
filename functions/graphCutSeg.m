function [ param, pairwise ] = graphCutSeg( im, seg, pairwise, neighborhood, mode, sigma, labelcost, lambda )
% input:
%   im : image to segment
%   bin: best binary of segmentation

% Using the GCMex method
% Parameters:
%   CLASS:: A 1xN vector which specifies the initial labels of each
%     of the N nodes in the graph
%   UNARY:: A CxN matrix specifying the potentials (data term) for
%     each of the C possible classes at each of the N nodes.
%   PAIRWISE:: An NxN sparse matrix specifying the graph structure and
%     cost for each link between nodes in the graph.
%   LABELCOST:: A CxC matrix specifying the fixed label cost for the
%     labels of each adjacent node in the graph.
%   EXPANSION:: A 0-1 flag which determines if the swap or expansion
%     method is used to solve the minimization. 0 == swap, 
%     1 == expansion. If ommitted, defaults to swap.
%
% Outputs:
%   LABELS:: A 1xN vector of the final labels.
%   ENERGY:: The energy of the initial labeling contained in CLASS
%   ENERGYAFTER:: The energy of the final labels LABELS

% [Label Energy EnergyAfter] = GCMEX(class, unary, pairwise, labelcost, expansion);

% reshape segmentation to 1D vector
class = reshape(seg, [1 numel(seg)]);

% unary
vec = reshape(im, [1 numel(im)]);
lambda1 = lambda(1);
lambda2 = lambda(2);
vecV = vec .* class;
mV = mean(vecV(vecV~=0));

vecB = vec(vecV==0);
mB = mean(vecB(vecB~=0));

unary = zeros(2, length(vec));
unary(1,:) = lambda1*(vec-mB).^2;
unary(2,:) = lambda2*(vec-mV).^2;

% pairwise (-> define cost for link cuts)
if size(im) == [923,923]
    load('graph923x923px.mat');
elseif exist('temporary.mat') == 1
    load('temporary.mat');    
end
if isempty(pairwise)
    pairwise = getGraph( im, neighborhood, mode, sigma);
    save('temporary.mat','pairwise');
end

% perform graph cut
[Label, Energy, EnergyAfter] = GCMex(double(class), single(unary), pairwise, single(labelcost), 0);

binary = reshape(Label, size(seg));

% write output struct
param.Binary = binary;
param.Energy = Energy;
param.EnergyAfter = EnergyAfter;

end

