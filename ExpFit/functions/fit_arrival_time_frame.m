function [Parameters, R, J, COVB, MSE] = fit_arrival_time_frame(data, varargin)
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

if ~p.mask
    if ndims(data)==4 % if data is a stack of frames
        if p.individualFrames
            for f = 1:size(data,1)
                fitOut{f} = fitModelFunc(
        y = squeeze(sum(sum(sum(data,1),2),3));
    elseif ndims(data)==3 % data is a single frame
        y = squeeze(sum(sum(data,1),2));
    elseif ndims(data)==2 %#ok<ISMAT> % data is already a timecourse (number of photons per time bin)
        y = data;
    end
    
% case where there is a single mask
% case with multiple masks
%   - 1 fit per mask
%   - 1 fit for all masks
%  might need to require binary mask if user wants to fit all masks
%  together, should do this at level above 
    
end
 

end

