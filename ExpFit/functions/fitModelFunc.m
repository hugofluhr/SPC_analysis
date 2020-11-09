function [Parameters, R, J, COVB, MSE] = fitModelFunc(data, varargin)
% Fits one frame to extract global parameters :
%   - t0 (offset)
%   - tauG (width of the Gaussian modeled Instrument Response Function
%   - tau1 and tau2, lifetimes of the two states
% Other fit outputs are given (Residuals, Jacobian, Covariance matrix and 
% MSE) 

% TODO :
%       - handle masks for cells
%       - add threshold on pixels

H1 = @(t0,tau,tauG,t) 0.5 .* exp(((tauG.^2)./(2*tau.^2))-(t-t0)./tau).*erfc((tauG.^2-tau*(t-t0))./(sqrt(2)*tau*tauG));
% Harvey = @(t0,tau1,tau2,tauG,P1,P2,t) P1*H1(t0,tau1,tauG,t)+P2*H1(t0,tau2,tauG,t);
HarveyB = @(b,x) b(5)*H1(b(1),b(2),b(4),x)+b(6)*H1(b(1),b(3),b(4),x);
bins = load_bins();

if ndims(data)==4 % if data is a stack of frames
    y = squeeze(sum(sum(sum(data,1),2),3));
elseif ndims(data)==3 % data is a single frame
    y = squeeze(sum(sum(data,1),2));
elseif ndims(data)==2 %#ok<ISMAT> % data is already a timecourse (number of photons per time bin)
    y = data;
end
 
beta0 = [0,0.5,0.5,0.01,1e3,1e3];
[beta,R,J,COVB,MSE]=nlinfit(bins,y,HarveyB,beta0);

Parameters.t0 = beta(1);
Parameters.tauG = beta(4);
if beta(2)<beta(3)
    Parameters.tau1 = beta(2);
    Parameters.tau2 = beta(3);
    Parameters.P1 = beta(5);
    Parameters.P2 = beta(6);
else
    Parameters.tau1 = beta(3);
    Parameters.tau2 = beta(2);
    Parameters.P1 = beta(6);
    Parameters.P2 = beta(5);   
end

end

