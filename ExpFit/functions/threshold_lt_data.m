function [thresholdedData, mask] = threshold_lt_data(data,threshold)
% Threshold data, all pixels that have less than *threshold* photons in the
% most populated bin will be set to 0

if nargin<2
    threshold = 5;
end

% in case the data is a single frame, add singleton dimension to process as
% stack of frames
if ndims(data)==3 %&& size(data,1)~=1
    data=reshape(data,[1 size(data)]);
end

thresholdedData = data;
mask=max(data,[],4)>threshold;

for f = 1:size(data,1)
    for i = 1:size(data,2)
        for j = 1:size(data,3)
            if ~mask(f,i,j)
                thresholdedData(f,i,j,:)=0;
            end
        end
    end
end

% get rid of singleton dimensions
thresholdedData = squeeze(thresholdedData);
end

