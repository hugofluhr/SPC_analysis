%% Harvey model
H1 = @(t0,tau,tauG,t) 0.5 .* exp(((tauG.^2)./(2*tau.^2))-(t-t0)./tau).*erfc((tauG.^2-tau*(t-t0))./(sqrt(2)*tau*tauG));
Harvey = @(t0,tau1,tau2,tauG,P1,P2,t) P1*H1(t0,tau1,tauG,t)+P2*H1(t0,tau2,tauG,t);
HarveyB = @(b,x) b(5)*H1(b(1),b(2),b(4),x)+b(6)*H1(b(1),b(3),b(4),x);


figure
plot(bins,H1(5,1,0.1,bins))

%% fit all data with harvey model
x=bins;
% y=allDat.acc;
y=squeeze(sum(sum(testData,1),2));
% 
lower = [0,0.5,0.5,0.01,1e3,1e3];
% upper = [5,5,5,5,1e9,1e9];
% 
% opts = {'METHOD','NonlinearLeastSquares','Display','off',...
%     'Robust','LAR','Lower',lower,'Upper',upper};
% g = fittype(Harvey,'independent','t');
% fo = fitoptions(opts{:});
% [f,gof] = fit(x,y,g,fo);
% disp(f)
betaNlin=nlinfit(bins,y,HarveyB,lower);
% betaLS = lsqcurvefit(HarveyB,lower,bins,y,lower,upper);

% global fit figure
figure
plot(x,y,'LineWidth',1)
hold on
% plot(x,Harvey(f.t0,f.tau1,f.tau2,f.tauG,f.P1,f.P2,x),'r.')
plot(x,HarveyB(betaNlin,x),'r.')
legend('Signal','Fit')
xlabel('[ns]')
ylabel('Photon Count')
title('Fit the whole field of view')

Params.t0=betaNlin(1);
Params.tau1=betaNlin(2);
Params.tau2=betaNlin(3);
Params.tauG=betaNlin(4);

%% determine mean arrival time (not equal to meanlifetime due to offset)
% Pfrac = @(tau1,tau2,meanT) (tau1*(tau1-meanT))./((tau1-tau2)*(tau1+tau2-meanT));
Pfrac = @(tau1,tau2,meanT) (tau2*(meanT-tau2))./(tau1*(tau1-meanT));

meanLT = zeros(sizePix);
fracMat = zeros(sizePix);
for i = 1:sizePix(1)
    for j = 1:sizePix(2)
        pixel = squeeze(testData(i,j,:));
        pixel(bins<=Params.t0)=0; %ignore photons arriving before t0 (Thornquist)
        meanLT(i,j) = sum(bins.*pixel)./sum(pixel)-Params.t0;
        fracMat(i,j)=Pfrac(Params.tau1,Params.tau2,meanLT(i,j));
    end
end

% 2d histogram to compare the ratio computed and the Harvey method
Rclipped = cleanR;
Rclipped(Rclipped<0.5)=nan;
fracClipped = fracMat(:);
fracClipped(fracClipped>6)=nan;
X = [Rclipped(:), fracClipped];
figure
hist3(X,[100,100],'CdataMode','auto')
xlabel('Ratio from indiv pixel fit')
ylabel('fraction from analytical model')
colorbar
view(2)

%%
figure
subplot(311)
imshow(photCount,[])
title('Photon Count')
subplot(312)
imshow(meanLT,[])
title('Mean Lifetime')
subplot(313)
imshow(fracMat,[])
title('Ratio from new method')