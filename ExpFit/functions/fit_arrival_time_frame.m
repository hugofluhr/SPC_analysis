function fitOut = fit_arrival_time_frame(data, varargin)
% Fits one frame to extract global parameters :
%   - t0 (offset)
%   - tauG (width of the Gaussian modeled Instrument Response Function
%   - tau1 and tau2, lifetimes of the two states
% Other fit outputs are given (Residuals, Jacobian, Covariance matrix and 
% MSE) 

% TODO :
%       - handle masks for cells
%       - add threshold on pixels (done prior to fct call?), yes for now


p = inputParser;
addOptional(p,'mask',false);
addOptional(p,'individualFrames',false);
% addOptional(p,'individualMasks',false);

% Unpack if needed
if iscell(varargin) && size(varargin,1) * size(varargin,2) == 1
    varargin = varargin{:};
end

parse(p, varargin{:});
p = p.Results;

if isequal(p.mask,false) % no masks inputted
    if ndims(data)==4 % if data is a stack of frames
        if p.individualFrames
            for f = 1:size(data,1)
                y = squeeze(sum(sum(data(f,:,:,:),2),3));
                fitOut{f} = fitModelFunc(y);
            end
            fitOut = cell2mat(fitOut);
        else
            y = squeeze(sum(sum(sum(data,1),2),3));
            fitOut = fitModelFunc(y);
        end
    elseif ndims(data)==3 % data is a single frame
        y = squeeze(sum(sum(data,1),2));
        fitOut = fitModelFunc(y);
    elseif ndims(data)==2 %#ok<ISMAT> % data is already a timecourse (number of photons per time bin)
        y = data;
        fitOut = fitModelFunc(y);
    end
elseif ismatrix(squeeze(p.mask))
    p.mask = squeeze(p.mask);
    if ndims(data)==4 % if data is a stack of frames, I assume that all frames of the stack use the same mask(s)
        % also this does not support fitting individual frames for now.
        if p.individualFrames
            for f = 1:size(data,1)
                frameMasked = bsxfun(@times,squeeze(data(f,:,:,:)),p.mask);
                y = squeeze(sum(sum(data(f,:,:,:),2),3));
                fitOut{f} = fitModelFunc(y);
            end
            fitOut = cell2mat(fitOut);
        else
            y = squeeze(sum(sum(sum(data,1),2),3));
            fitOut = fitModelFunc(y);
        end
    elseif ndims(data)==3 % data is a single frame
        y = squeeze(sum(sum(data,1),2));
        fitOut = fitModelFunc(y);
%     if numel(unique(p.mask) == 2 % only 1 mask / binary mask
%     end
    end
end
        
    
% case where there is a single mask
% case with multiple masks
%   - 1 fit per mask
%   - 1 fit for all masks
%  might need to require binary mask if user wants to fit all masks
%  together, should do this at level above 
    
end


