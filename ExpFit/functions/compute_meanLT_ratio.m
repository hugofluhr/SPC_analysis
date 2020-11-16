function [meanLT,Ratio] = compute_meanLT_ratio(data,varargin)
% Extract mean lifetime and ratio from a frame or stack of frame

p = inputParser;
addOptional(p,'parameters','default');
addOptional(p,'mask',false);
addOptional(p,'individualFrames',false);

% Unpack if needed
if iscell(varargin) && size(varargin,1) * size(varargin,2) == 1
    varargin = varargin{:};
end

parse(p, varargin{:});
p = p.Results;

if isequal(p.parameters,'default')
    load ('default_global_parameters.mat','Params')
    p.parameters = Params;
    clear Params
end


Pfrac = @(tau1,tau2,meanT) (tau2*(meanT-tau2))./(tau1*(tau1-meanT));

sizeData=size(data);
meanLT = zeros(sizeData(1:end-1));
Ratio = zeros(sizeData(1:end-1));
bins = load_bins();

if ndims(data) == 3
    for i = 1:size(data,1)
    for j = 1:size(data,2)
        pixel = squeeze(data(i,j,:));
        pixel(bins<=p.parameters.t0)=0; %ignore photons arriving before t0 (Thornquist)
        meanLT(i,j) = sum(bins.*pixel)./sum(pixel)-p.parameters.t0;
        Ratio(i,j)=Pfrac(p.parameters.tau1,p.parameters.tau2,meanLT(i,j));
    end
    end
elseif ndims(data) == 4
    if p.individualFrames
        for f = 1:size(data,1)
            parameters=p.parameters(f);
            for i = 1:size(data,2)
            for j = 1:size(data,3)
                pixel = squeeze(data(f,i,j,:));
                pixel(bins<=parameters.t0)=0; %ignore photons arriving before t0 (Thornquist)
                meanLT(f,i,j) = sum(bins.*pixel)./sum(pixel)-parameters.t0;
                Ratio(f,i,j)=Pfrac(parameters.tau1,parameters.tau2,meanLT(f,i,j));
            end
            end
        end
    else
        for f = 1:size(data,1)
            for i = 1:size(data,2)
            for j = 1:size(data,3)
                pixel = squeeze(data(f,i,j,:));
                pixel(bins<=p.parameters.t0)=0; %ignore photons arriving before t0 (Thornquist)
                meanLT(f,i,j) = sum(bins.*pixel)./sum(pixel)-p.parameters.t0;
                Ratio(f,i,j)=Pfrac(p.parameters.tau1,p.parameters.tau2,meanLT(f,i,j));
            end
            end
        end
    end
end

