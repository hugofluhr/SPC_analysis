clearvars -except akarMice data Q

rootdir = 'H:\2p\stephen\';
filelist = dir(fullfile(rootdir,'**/*.sdt'));
filelist = struct2table(filelist);
filelist = filelist(~contains(filelist.folder,'blur'),:);

%% group slices and GRIN experiments
slices = filelist(contains(filelist.folder,'slice'),:);
grins = filelist(contains(filelist.folder,'run'),:);

sliceDir = unique(slices.folder,'stable');
if~exist('akarMice','var') load('akarMice.mat'); end
sliceDir = sliceDir(contains(sliceDir,akarMice));

%% get all photon counts
binFactor = 5;
frames2drop = 20;
sliceDir=sliceDir([1:3,5:6,8:11]);
if ~exist('Q','var')
    data = struct('folder',{},'files',{},'photCount',{},'photArrival',{},'acc',{});
    for dirID = 1:numel(sliceDir)
        disp(['########## DIR : ',num2str(dirID),' ##########'])
        data(dirID).folder = sliceDir{dirID};
        currFiles = slices(strcmp(slices.folder,data(dirID).folder),:);
        currFiles = currFiles(frames2drop:end,:);
        data(dirID).files = currFiles;
        parfor f = 1:size(currFiles,1)
            [photCount{f}, photArrival{f}] = read_sdt(fullfile(sliceDir{dirID},currFiles.name{f}),binFactor,'matfile');
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

%%
bins=load_bins();
x=bins;

