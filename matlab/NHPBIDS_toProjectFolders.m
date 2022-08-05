% NHPBIDS_toProjectFolders 
% This script moves the previous NHP-BODS folder into project-based
% subfolders. To this end we first created a `projects` foler under
% `NHP-BIDS` and moved everything into a `default` project.
% Then we process this default folder and move things in predfined project
% folders. The pipelines have also been adjusted to work with these project
% folders now.
% c.klink@nin.knaw.nl

%% define parameters ----------------------------------------------------
%basedir = '/media/NETDISKS/VS03_2/NHP_MRI/NHP-BIDS'; % CK NIN
%basedir = '/media/8TB/NHP-BIDS'; % CK home
basedir = '/media/chris/CK4TB/NHP-BIDS'; % CK portable

defproj = fullfile(basedir, 'projects','default');

proj(1).name = 'CurveTracing';
proj(1).ids = {'curvetracing','ctcheckerboard'};

proj(2).name = 'FigureGround';
proj(2).ids = {'figgnd'};

proj(3).name = 'HRF';
proj(3).ids = {'HRF'};

proj(4).name = 'NaturalMovie';
proj(4).ids = {'naturalmovie'};

proj(5).name = 'PRF';
proj(5).ids = {'prf'};

proj(6).name = 'RestingState';
proj(6).ids = {'rest', 'Rest'};

proj(7).name = 'Stimulation';
proj(7).ids = {'estim'};

proj(8).name = 'Tractography';
proj(8).ids = {'tract'};

proj(9).name = 'Checkerboard';
proj(9).ids = {'task-checkerboard'};

%% - sub-xx -------------------------------------------------------------
cd(fullfile(defproj));
flds = dir('*sub*');
for s=1:length(flds) % different subjects
    fprintf(['Subject ' flds(s).name '\n'])
    cd(fullfile(flds(s).folder,flds(s).name)); %subject
    ses = dir('*ses*'); %sessions
    for ss = 1:length(ses) % sessions
        fprintf(['Session ' ses(ss).name '\n'])
        sesfld = fullfile(ses(ss).folder,ses(ss).name);
        for p=1:length(proj) % check different projects
            fprintf(['Proj ' proj(p).name '\n'])
            for i = 1:length(proj(p).ids)
                fprintf(['ProjID ' proj(p).ids{i} '\n'])
                fn = dir(fullfile(sesfld,'func',['*' proj(p).ids{i} '*']));
                uf=fullfile(basedir,'projects',proj(p).name,...
                    flds(s).name,ses(ss).name);
                if ~isempty(fn)
                    [~,~,~] = mkdir(fullfile(uf,'func'));
                    %  move files
                    for f = 1:length(fn)
                        [~,~] = movefile(fullfile(fn(f).folder,fn(f).name),...
                            fullfile(uf,'func'));
                    end

                    [~,~] = copyfile(fullfile(ses(ss).folder,ses(ss).name,'anat'),...
                        fullfile(uf,'anat'));
                    
                    [~,~] = copyfile(fullfile(ses(ss).folder,ses(ss).name,'fmap'),...
                        fullfile(uf,'fmap'));
                end
            end
            if strcmp(proj(p).name,'Tractography')
                uf=fullfile(basedir,'projects',proj(p).name,...
                    flds(s).name,ses(ss).name);
                if isfolder(fullfile(ses(ss).folder,ses(ss).name,'dwi'))
                    [~,~,~] = mkdir(fullfile(uf));
                    [~,~] = copyfile(fullfile(ses(ss).folder,ses(ss).name,'anat'),...
                        fullfile(uf,'anat'));
                    [~,~] = copyfile(fullfile(ses(ss).folder,ses(ss).name,'fmap'),...
                        fullfile(uf,'fmap'));
                    [~,~] = copyfile(fullfile(ses(ss).folder,ses(ss).name,'dwi'),...
                        fullfile(uf,'dwi'));
                end
            end
        end
    end
end

%% - sourcedata ---------------------------------------------------------
cd(fullfile(defproj,'sourcedata'));
flds = dir('*sub*');
for s=1:length(flds) % different subjects
    fprintf(['Subject ' flds(s).name '\n'])
    cd(fullfile(flds(s).folder,flds(s).name)); %subject
    ses = dir('*ses*'); %sessions
    for ss = 1:length(ses) % sessions
        fprintf(['Session ' ses(ss).name '\n'])
        sesfld = fullfile(ses(ss).folder,ses(ss).name);
        for p=1:length(proj) % check different projects
            fprintf(['Proj ' proj(p).name '\n'])
            for i = 1:length(proj(p).ids)
                fprintf(['ProjID ' proj(p).ids{i} '\n'])
                fn = dir(fullfile(sesfld,'func',['*' proj(p).ids{i} '*']));
                uf=fullfile(basedir,'projects',proj(p).name,...
                    'sourcedata',flds(s).name,ses(ss).name);
                if ~isempty(fn)
                    [~,~,~] = mkdir(fullfile(uf,'func'));
                    %  move files
                    for f = 1:length(fn)
                        [~,~] = movefile(fullfile(fn(f).folder,fn(f).name),...
                            fullfile(uf,'func'));
                    end

                    [~,~] = copyfile(fullfile(ses(ss).folder,ses(ss).name,'anat'),...
                        fullfile(uf,'anat'));
                    
                    [~,~] = copyfile(fullfile(ses(ss).folder,ses(ss).name,'fmap'),...
                        fullfile(uf,'fmap'));
                end
            end
            if strcmp(proj(p).name,'Tractography')
                uf=fullfile(basedir,'projects',proj(p).name,...
                    flds(s).name,ses(ss).name);
                if isfolder(fullfile(ses(ss).folder,ses(ss).name,'dwi'))
                    [~,~,~] = mkdir(fullfile(uf));
                    [~,~] = copyfile(fullfile(ses(ss).folder,ses(ss).name,'anat'),...
                        fullfile(uf,'anat'));
                    [~,~] = copyfile(fullfile(ses(ss).folder,ses(ss).name,'fmap'),...
                        fullfile(uf,'fmap'));
                    [~,~] = copyfile(fullfile(ses(ss).folder,ses(ss).name,'dwi'),...
                        fullfile(uf,'dwi'));
                end
            end
        end
    end
end

%% - derivatives/undistort ----------------------------------------------
% go to derivatives folder
cd(fullfile(defproj,'derivatives'));
cd undistort
flds = dir('*sub*');

for s=1:length(flds) % different subjects
    fprintf(['Subject ' flds(s).name '\n'])
    cd(fullfile(flds(s).folder,flds(s).name)); %subject
    ses = dir('*ses*');  %sessions
    for ss = 1:length(ses) % sessions
        fprintf(['Session ' ses(ss).name '\n'])
        sesfld = fullfile(ses(ss).folder,ses(ss).name);
        for p=1:length(proj) % check different projects
            fprintf(['Proj ' proj(p).name '\n'])
            for i = 1:length(proj(p).ids)
                fprintf(['ProjID ' proj(p).ids{i} '\n'])
                fn = dir(fullfile(sesfld,'func',['*' proj(p).ids{i} '*']));
                fn2 = dir(fullfile(sesfld,'func','qwarp_plusminus',...
                    ['*' proj(p).ids{i} '*']));
                [length(fn) length(fn2)]
                uf=fullfile(basedir,'projects',proj(p).name,...
                    'derivatives','undistort',...
                    flds(s).name,ses(ss).name);
                if ~isempty(fn)
                    [~,~,~] = mkdir(fullfile(uf,'func','qwarp_plusminus'));
                    %  move files
                    for f = 1:length(fn)
                        [~,~] = movefile(fullfile(fn(f).folder,fn(f).name),...
                            fullfile(uf,'func'));
                    end
                end
                if ~isempty(fn2)
                    %  move qwarp files
                    for f = 1:length(fn2)
                        [~,~] = movefile(fullfile(fn2(f).folder,fn2(f).name),...
                            fullfile(uf,'func','qwarp_plusminus'));
                    end
                end
            end
        end
    end
end

%% - derivatives/resampled-isotropic-1mm/06mm ---------------------------
% go to derivatives folder
cd(fullfile(defproj,'derivatives'));
cd resampled-isotropic-1mm
flds = dir('*sub*');

for s=1:length(flds) % different subjects
    fprintf(['Subject ' flds(s).name '\n'])
    cd(fullfile(flds(s).folder,flds(s).name)); %subject
    ses = dir('*ses*'); %sessions
    for ss = 1:length(ses) % sessions
        fprintf(['Session ' ses(ss).name '\n'])
        sesfld = fullfile(ses(ss).folder,ses(ss).name);
        for p=1:length(proj) % check different projects
            fprintf(['Proj ' proj(p).name '\n'])
            for i = 1:length(proj(p).ids)
                fprintf(['ProjID ' proj(p).ids{i} '\n'])
                fn = dir(fullfile(sesfld,'func',['*' proj(p).ids{i} '*']));
                uf=fullfile(basedir,'projects',proj(p).name,...
                    'derivatives','resampled-isotropic-1mm',...
                    flds(s).name,ses(ss).name);
                uf2=fullfile(basedir,'projects',proj(p).name,...
                    'derivatives','resampled-isotropic-06mm',...
                    flds(s).name,ses(ss).name);
                if ~isempty(fn)
                    [~,~,~] = mkdir(fullfile(uf,'func'));
                    %  move files
                    for f = 1:length(fn)
                        [~,~] = movefile(fullfile(fn(f).folder,fn(f).name),...
                            fullfile(uf,'func'));
                    end

                    [~,~] = copyfile(fullfile(ses(ss).folder,ses(ss).name,'anat'),...
                        fullfile(uf,'anat'));
                    [~,~] = copyfile(fullfile(ses(ss).folder,ses(ss).name,'dwi'),...
                        fullfile(uf,'dwi'));
                    [~,~] = copyfile(fullfile(ses(ss).folder,ses(ss).name,'fmap'),...
                        fullfile(uf,'fmap'));

                    [~,~,~] = mkdir(fullfile(uf2));
                    [~,~] = copyfile(fullfile(defproj,...
                        'derivatives','resampled-isotropic-06mm',...
                        flds(s).name,ses(ss).name,'anat'),...
                        fullfile(uf2,'anat'));
                end
            end
        end
    end
end

%% - derivatives/featpreproc --------------------------------------------
sf = {'funcbrains','highpassed_files','mean',...
    'motion_corrected','motion_outliers','pre_motion_corrected',...
    'reference','smoothed_files','warp2nmt','warp2nmt_v1','dilate_mask'};
for sfidx = 1:length(sf)
    cd(fullfile(defproj,'derivatives','featpreproc',sf{sfidx}));
    % different folders, different operations
    if strcmp(sf{sfidx},'dilate_mask')
        flds = dir('*sub*');
        for s=1:length(flds) % different subjects
            fprintf(['Subject ' flds(s).name '\n'])
            cd(fullfile(flds(s).folder,flds(s).name)); %subject
            ses = dir('*ses*'); %sessions
            for ss = 1:length(ses) % sessions
                fprintf(['Session ' ses(ss).name '\n'])
                sesfld = fullfile(ses(ss).folder,ses(ss).name);
                for p=1:length(proj) % check different projects
                    fprintf(['Proj ' proj(p).name '\n'])
                    if isfolder(fullfile(basedir,'projects',proj(p).name,...
                            'derivatives','resampled-isotropic-1mm',...
                            flds(s).name,ses(ss).name))
                        uf=fullfile(basedir,'projects',proj(p).name,...
                            'derivatives','featpreproc',sf{sfidx},...
                            flds(s).name);
                        [~,~,~] = mkdir(fullfile(uf));
                        [~,~] = copyfile(...
                            fullfile(ses(ss).folder,ses(ss).name),...
                            fullfile(uf,ses(ss).name));
                    end
                end
            end
        end
    elseif strcmp(sf{sfidx},'reference')
        for p=1:length(proj) % check different projects
            fprintf(['Proj ' proj(p).name '\n'])

            [~,~,~] = mkdir(fullfile(basedir,'projects',proj(p).name,...
                'derivatives','featpreproc',sf{sfidx}));
            [~,~] = copyfile(fullfile(defproj,'derivatives','featpreproc',...
                sf{sfidx},'func*'),...
                fullfile(basedir,'projects',proj(p).name,...
                'derivatives','featpreproc',sf{sfidx}));
        end
    elseif strcmp(sf{sfidx},'warp2nmt')
        cd('highpassed_files')
        flds = dir('*sub*');
        for s=1:length(flds) % different subjects
            fprintf(['Subject ' flds(s).name '\n'])
            cd(fullfile(flds(s).folder,flds(s).name)); %subject
            ses = dir('*ses*'); %sessions
            for ss = 1:length(ses) % sessions
                fprintf(['Session ' ses(ss).name '\n'])
                sesfld = fullfile(ses(ss).folder,ses(ss).name);
                for p=1:length(proj) % check different projects
                    fprintf(['Proj ' proj(p).name '\n'])
                    for i = 1:length(proj(p).ids)
                        fprintf(['ProjID ' proj(p).ids{i} '\n'])
                        fn = dir(fullfile(sesfld,'func',['*' proj(p).ids{i} '*']));
                        uf=fullfile(basedir,'projects',proj(p).name,...
                            'derivatives','featpreproc',sf{sfidx},...
                            'highpassed_files',flds(s).name,ses(ss).name);
                        if ~isempty(fn)
                            [~,~,~] = mkdir(fullfile(uf,'func'));
                            %  move files
                            for f = 1:length(fn)
                                [~,~] = movefile(fullfile(fn(f).folder,fn(f).name),...
                                    fullfile(uf,'func'));
                            end
                        end
                    end
                end
            end
        end
    elseif strcmp(sf{sfidx},'warp2nmt_v1')
        cd('highpassed_files')
        flds = dir('*sub*');
        for s=1:length(flds) % different subjects
            fprintf(['Subject ' flds(s).name '\n'])
            cd(fullfile(flds(s).folder,flds(s).name)); %subject
            ses = dir('*ses*'); %sessions
            for ss = 1:length(ses) % sessions
                fprintf(['Session ' ses(ss).name '\n'])
                sesfld = fullfile(ses(ss).folder,ses(ss).name);
                for p=1:length(proj) % check different projects
                    fprintf(['Proj ' proj(p).name '\n'])
                    for i = 1:length(proj(p).ids)
                        fprintf(['ProjID ' proj(p).ids{i} '\n'])
                        fn = dir(fullfile(sesfld,['*' proj(p).ids{i} '*']));
                        uf=fullfile(basedir,'projects',proj(p).name,...
                            'derivatives','featpreproc',sf{sfidx},...
                            'highpassed_files',flds(s).name,ses(ss).name);
                        if ~isempty(fn)
                            [~,~,~] = mkdir(fullfile(uf,'func'));
                            %  move files
                            for f = 1:length(fn)
                                [~,~] = movefile(fullfile(fn(f).folder,fn(f).name),...
                                    fullfile(uf,'func'));
                            end
                        end
                    end
                end
            end
        end
    else
        flds = dir('*sub*');
        for s=1:length(flds) % different subjects
            fprintf(['Subject ' flds(s).name '\n'])
            cd(fullfile(flds(s).folder,flds(s).name)); %subject
            ses = dir('*ses*'); %sessions
            for ss = 1:length(ses) % sessions
                fprintf(['Session ' ses(ss).name '\n'])
                sesfld = fullfile(ses(ss).folder,ses(ss).name);
                for p=1:length(proj) % check different projects
                    fprintf(['Proj ' proj(p).name '\n'])
                    for i = 1:length(proj(p).ids)
                        fprintf(['ProjID ' proj(p).ids{i} '\n'])
                        fn = dir(fullfile(sesfld,'func',['*' proj(p).ids{i} '*']));
                        uf=fullfile(basedir,'projects',proj(p).name,...
                            'derivatives','featpreproc',sf{sfidx},...
                            flds(s).name,ses(ss).name);
                        if ~isempty(fn)
                            [~,~,~] = mkdir(fullfile(uf,'func'));
                            %  move files
                            for f = 1:length(fn)
                                [~,~] = movefile(fullfile(fn(f).folder,fn(f).name),...
                                    fullfile(uf,'func'));
                            end
                        end
                    end
                end
            end
        end
    end
end



