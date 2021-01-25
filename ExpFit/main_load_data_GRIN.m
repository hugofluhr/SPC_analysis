clearvars -except akarMice data Q

rootdir = 'H:\2p\stephen\';
filelist = dir(fullfile(rootdir,'**/*.sdt'));
filelist = struct2table(filelist);
filelist = filelist(~contains(filelist.folder,'blur'),:);

%% group slices and GRIN experiments
slices = filelist(contains(filelist.folder,'slice'),:);
grins = filelist(contains(filelist.folder,'run'),:);

grinDir = unique(grins.folder,'stable');
if~exist('akarMice','var')
    load('akarMice.mat');
end
grinDir = grinDir(contains(grinDir,akarMice));
grinDir = grinDir(randperm(numel(grinDir), 20));
%% get all photon counts
binFactor = 2;
frames2drop = 1;
if ~exist('Q','var')
    data = struct('folder',{},'files',{},'photCount',{},'photArrival',{},'acc',{});
    for dirID = 1:numel(grinDir)
        disp(['########## DIR : ',num2str(dirID),' ##########'])
        data(dirID).folder = grinDir{dirID};
        currFiles = grins(strcmp(grins.folder,data(dirID).folder),:);
        currFiles = currFiles(frames2drop:end,:);
        %----------- new line --------------
        currFiles = currFiles(randperm(height(currFiles),1),:);
        data(dirID).files = currFiles;
        parfor f = 1:size(currFiles,1)
            try
                [photCount{f}, photArrival{f}] = read_sdt(fullfile(grinDir{dirID},currFiles.name{f}),binFactor,'matfile');
            catch ME
                disp('1 error')
            end
        end
        data(dirID).photCount = horzcat(photCount{:});
        data(dirID).photArrival = cat(4,photArrival{:});
        data(dirID).acc = sum(data(dirID).photCount,2);
        
        clear photCount photArrival
    end
    clear dirID
    Q=cat(4,data(:).photArrival);
    data=rmfield(data,'photArrival');
    Q=permute(Q,[4 1 2 3]);
end

%% Aggregate all data
allDat.photCount = horzcat(data(:).photCount);
allDat.acc = sum(allDat.photCount,2);

