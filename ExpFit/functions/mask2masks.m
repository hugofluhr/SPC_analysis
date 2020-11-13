function [masks] = mask2masks(mask)
% convert one mask containing multiple cells in a stack of binary masks

cellIDs = unique(mask);
nbCells = numel(cellIDs);

masks = zeros([nbCells size(mask)]);

for c = 1:nbCells
    masks(c,:,:) = 0.^(mask-c);
end
end

