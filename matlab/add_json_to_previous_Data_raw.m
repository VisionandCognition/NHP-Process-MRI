clear all; clc;
startfolder = pwd;

addpath(genpath('/home/chris/Documents/TRACKER/VCscripts-MRI/SharedScripts/jsonlab'));

%LogRoot = '/media/NETDISKS/VCNIN/NHP_MRI/Data_raw/DANNY';
LogRoot = '/media/NETDISKS/VCNIN/NHP_MRI/Data_raw/EDDY';

Sessions_to_include = {'all'};

cd(LogRoot);
fid=fopen('json_posthoc_log.txt','w');
F=dir;
for f=1:length(F)
    if ~strcmp(F(f).name(1),'.') && ...
            ~strcmp(F(f).name,'json_posthoc_log.txt') && ...
            (any(strcmp(F(f).name,Sessions_to_include)) || strcmp(Sessions_to_include{1},'all'))
        cd(LogRoot);
        cd(F(f).name);
        fprintf(fid,[num2str(f) ' - Going to ' F(f).name '\n']);
        F2 = dir;
        for f2=1:length(F2)
            if strcmp(F2(f2).name,'Behavior')
                cd(F2(f2).name);
                fprintf(fid,['Going to ' F2(f2).name '\n']);
                F3 = dir;
                for f3=1:length(F3)
                    if ~strcmp(F3(f3).name(1),'.')
                        if isdir(F3(f3).name)
                            cd(F3(f3).name);
                            fprintf(fid,['Going to ' F3(f3).name '\n']);
                        end
                        ff = dir('Log*mat');
                        warning off
                        for ff1=1:length(ff)
                            if strcmp(ff(ff1).name(end),' ') % there could be a trailing space
                                fn=ff(ff1).name(1:end-1);
                            else
                                fn=ff(ff1).name;
                            end
                            % only if json file doesn't already exist
                            if isempty(dir('Log_*session.json'));
                                load(fn)
                                json.project.method     = 'MRI';
                                if isfield(Par,'ProjectLogDir') && ...
                                        ~strcmp(Par.STIMSETFILE, 'StimSettings_pRF_8bars_3T_TR2500ms')% JW Curvetrace
                                    json.project.title      = 'CurveTracing';
                                    json.dataset.protocol   = '17.29.02';
                                    json.session.investigator = 'JonathanWilliford';
                                    json.session.stimulus   = Par.STIMSETFILE(find(Par.STIMSETFILE=='_',1,'last')+1:end);
                                    json.dataset.name      = 'CurveTracing';
                                    DateString = fn(end-16:end-4);
                                else % CK retinotopy
                                    json.project.title      = 'Retinotopy';
                                    json.dataset.protocol   = '17.25.01';
                                    json.session.investigator = 'ChrisKlink';
                                    json.session.stimulus   = StimObj.Stm.Descript;
                                    json.session.fixperc    = nanmean(Log.FixPerc);
                                    if strcmp(StimObj.Stm.RetMap.StimType{1},'ret')
                                        json.dataset.name      = 'Retinotopy';
                                    elseif strcmp(StimObj.Stm.RetMap.StimType{1},'none')
                                        json.dataset.name      = 'RestingState';
                                    elseif strcmp(StimObj.Stm.RetMap.StimType{1},'checkerboard')
                                        json.dataset.name      = 'Checkerboard';
                                    else
                                        json.dataset.name      = 'Undefined';
                                    end
                                    DateString = fn(end-21:end-9);
                                end
                                json.session.date       = DateString;
                                json.session.subjectId  = Par.MONKEY;
                                json.session.setup      = Par.SetUp;
                                json.session.group      = 'awake';
                                json.session.logfile    = fn;
                                json.session.logfolder  = [Par.MONKEY '_' DateString];
                                if length(ff)>1 && strcmp(fn(end-7:end-5),'Run')
                                    json_name = ['Log_' DateString '_Run' num2str(ff1) '_session.json'];
                                else
                                    json_name = ['Log_' DateString '_session.json'];
                                end
                                savejson('', json, json_name);
                                fprintf(fid,['Saving ' json_name '\n']);
                                clear('Par','StimObj','Log');close all hidden;
                            end
                        end
                        if isdir(F3(f3).name)
                            cd ..
                        end
                    end
                    warning on
                end
            end
        end
    end
end
fclose(fid);
cd(startfolder);
clear all; close all hidden;