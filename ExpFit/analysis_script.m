
% Get data
testData = squeeze(Q(301:302,:,:,:));

% Threshold the frames to get rid of dark pixels
testDataThresholded = threshold_lt_data(testData,5);

% Fit the data to extract the model parameters
% This step is optional since we can use the default parameters computed
% from fitting multiple pooled experiments.
fitOut = fit_arrival_time_frame(testDataThresholded,'individualFrames',false);

% Using either fitted or default parameters, compute the mean lifetime of
% each pixel and from there extract the Ratio of the two states.
[meanLT,Ratio] = compute_meanLT_ratio(testDataThresholded,'parameters',[fitOut.Parameters],'individualFrames',false);


%% Plot the results
figure
subplot(311)
imshow(sum(testData,3),[])
title('Photon Count')
subplot(312)
imshow(meanLT,[])
title('Mean Life Time')
subplot(313)
imshow(Ratio,[])
title('Ratio of the two states')