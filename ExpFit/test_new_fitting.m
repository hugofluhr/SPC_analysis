%% Test model fct shape
expDecay = @(A,B,tau1,tau2,t) heaviside(t).*((A.*exp(-t./tau1)+B.*exp(-t./tau2)));
IRF = @(w,shift,t) normpdf(t-shift,0,w);
modelF = @(w,shift,A,B,tau1,tau2,t) mean(diff(t))*conv(expDecay(A,B,tau1,tau2,t),IRF(w,shift,t),'same');
singleExp = @(tau,t) heaviside(t).*(exp(-t./tau));
% modelAlt = @(w,shift,A,B,tau1,tau2,t) mean(diff(t))*(conv(singleExp(A,tau1,t),IRF(w,shift,t),'same') +...
%     conv(singleExp(B,tau2,t),IRF(w,shift,t),'same'));

comp = @(w,shift,tau,t) mean(diff(t))*(conv(singleExp(tau,t),IRF(w,shift,t),'same'));
bins=load_bins();
 
%%
% max(modelAlt(w,shift,A,B,tau1,tau2,tv)-A*modelAlt(w,shift,1,B,tau1,tau2,tv))

w=0.0627;
shift=7.2;
tau1=0.74;
tau2=2.04;

comp1=comp(w,shift,tau1,bins);
comp2=comp(w,shift,tau2,bins);


%% test data, try to apply mask
countThresh = 5;
testData = squeeze(Q(301,:,:,:));
% imtool(sum(testData,3),[]);
mask=max(testData,[],3)>countThresh;
tic
for i = 1:size(testData,1)
    for j = 1:size(testData,2)
        if ~mask(i,j)
            testData(i,j,:)=0;
        end
    end
end
toc
fprintf('%d pixels left\n',numel(find(mask(:))));

%% test functions

[meanLT,fracMat] = computeMeanT_Ratio(testData,'default');
%% Fitting
clear b dev stats
tic
for idx = 1:prod(sizePix)
    [i, j] = ind2sub(sizePix,idx);
    pixel=squeeze(testData(i,j,:));
    if sum(pixel)==0
        b{idx}=[0; 0]; dev{idx} = nan; stats{idx} = nan;
    else
        [b{idx},dev{idx},stats{idx}] = glmfit([comp1 comp2],pixel,[],'constant','off');
    end
%     [b,dev,stats] = glmfit([comp1 comp2],testPix,[],'constant','off');
end
toc

%%
% 
% figure
% plot(bins,testPix,bins,b(1)*comp1+b(2)*comp2)
if iscell(b)
    b = cell2mat(b);
end
p1 = round(reshape(b(1,:),sizePix(1),sizePix(2)),1);
p2 = round(reshape(b(2,:),sizePix(1),sizePix(2)),1);
R = zeros(sizePix);
% figure
for i =1:sizePix(1)
    for j = 1:sizePix(2)
        if p1(i,j)<=0 || p2(i,j)<=0
            R(i,j) = 0;
        else
            R(i,j) = p1(i,j)./p2(i,j);
%             plot(bins,squeeze(testData(i,j,:)))
%             hold on
%             plot(bins,p1(i,j)*comp1+p2(i,j)*comp2,'LineWidth',2)
%             hold off
%             drawnow
%             pause(0.5)
        end
    end
end
% histogram(R)
% set(gca,'YScale','log')
if iscell(dev)
    dev = cell2mat(dev);
    dev = reshape(dev,sizePix);
end

%%
figure
histogram(p1(:),20)
set(gca,'YScale','log')
hold on
histogram(p2(:),20)
set(gca,'YScale','log')
legend({'p1','p2'})
imtool((R),[],'InitialMagnification',300)
return
%% Stuff
% plot(bins,testPix,bins,b(1)*comp1+b(2)*comp2)
figure
subplot(131)
histogram(b(1,:),10)
title('A')
subplot(132)
histogram(b(2,:),10)
title('B')
subplot(133)
histogram(b(1,:)./b(2,:),10)
title('Ratio')

%% figure with photCount and R overlayed
clear residuals
if ~exist('residuals','var')
   residuals=stats;
   for i = 1:numel(residuals)
       if isstruct(residuals{i})
           residuals{i}=sumsqr(residuals{i}.resid);
       end
   end
   residuals=reshape(residuals,sizePix);
   residuals = cell2mat(residuals);
end

%%
cleanR=R;cleanR(cleanR>prctile(R(:),95))=0;
photCount=sum(testData,3);
figure
subplot(311)
imshow(photCount,[])
title('Photon Count')
subplot(312)
imshow(cleanR,[])
title('Ratio')
subplot(313)
% imshow(dev./photCount,[])
imshow(residuals./photCount,[])
title('Deviance divided by Photon Count')
%% compare with old fitting, super slow

lower = [w,shift,0.1,0.1,tau1,tau2];
upper = [w,shift,50,50,tau1,tau2];
opts = {'METHOD','NonlinearLeastSquares','Display','final',...
    'Robust','LAR','Lower',lower,'Upper',upper,'TolX',1e-2};
x=bins;
g = fittype(modelF,'independent','t');
fo = fitoptions(opts{:});
clear f gof
tic
for i = 1:size(highPix,1)%1:size(pixels,1)
    testPix=highPix(i,:);
%     [f,gof] = fit(x,testPix',g,fo);
    [f{i},gof{i}] = fit(x,testPix',g,fo);
end
toc
% figure
% plot(bins,testPix,bins,modelF(w,shift,f.A,f.B,tau1,tau2,bins))

%% Trying to convert thingsss
fieldsArray = {'A','B','tau1','tau2'};
pixParams = obj2struct(f,fieldsArray);
temp=num2cell([pixParams.A]./[pixParams.B]);
[pixParams.Ratio]=temp{:};
clear temp

fieldsArray = {'sse','rsquare','dfe','adjrsquare','rmse'};
pixRes = obj2struct(gof,fieldsArray);


figure
subplot(131)
histogram([pixParams.A],10)
title('A')
subplot(132)
histogram([pixParams.B],10)
title('B')
subplot(133)
histogram([pixParams.Ratio],10)
title('Ratio')