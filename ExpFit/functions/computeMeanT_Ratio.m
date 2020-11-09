function [meanLT,fracMat] = computeMeanT_Ratio(data,Params,varargin)
% Extract mean lifetime and ratio from a frame or stack of frame
%  TODO :
%       - add threshold on pixels
if isequal(Params,'default')
    load ('PATH2DEFAULT.mat','Params')
end

Pfrac = @(tau1,tau2,meanT) (tau2*(meanT-tau2))./(tau1*(tau1-meanT));

meanLT = zeros(size(data));
fracMat = zeros(size(data));
bins = load_bins();

if ndims(data) == 3
    for i = 1:size(data,1)
        for j = 1:size(data,2)
            pixel = squeeze(data(i,j,:));
            pixel(bins<=Params.t0)=0; %ignore photons arriving before t0 (Thornquist)
            meanLT(i,j) = sum(bins.*pixel)./sum(pixel)-Params.t0;
            fracMat(i,j)=Pfrac(Params.tau1,Params.tau2,meanLT(i,j));
        end
    end
elseif ndims(data) == 4
    for f = 1:size(data,1)
        for i = 1:size(data,2)
        for j = 1:size(data,3)
            pixel = squeeze(data(f,i,j,:));
            pixel(bins<=Params.t0)=0; %ignore photons arriving before t0 (Thornquist)
            meanLT(f,i,j) = sum(bins.*pixel)./sum(pixel)-Params.t0;
            fracMat(f,i,j)=Pfrac(Params.tau1,Params.tau2,meanLT(i,j));
        end
        end
    end
end

