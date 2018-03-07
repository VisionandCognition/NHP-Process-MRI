clear all; clc;
startfolder = pwd;

addpath(genpath('/home/chris/Documents/TRACKER/VCscripts-MRI/SharedScripts/jsonlab'));

%LogRoot = '/media/NETDISKS/VCNIN/NHP_MRI/Data_raw/DANNY';
LogRoot = '/media/NETDISKS/VCNIN/NHP_MRI/Data_raw/EDDY';

Sessions_to_include = {'all'}

cd(LogRoot);
F=dir;
for f=1:length(F)
    if ~strcmp(F(f).name(1),'.') && ...
        ~strcmp(F(f).name,'json_posthoc_log.txt') && ...
        (any(strcmp(F(f).name,Sessions_to_include)) || strcmp(Sessions_to_include{1},'all)')
        cd(LogRoot);
        cd(F(f).name);
        F2 = dir;
        for f2=1:length(F2)
            if strcmp(F2(f2).name,'Behavior')
                cd(F2(f2).name);
                F3 = dir;
                for f3=1:length(F3)
                    if ~strcmp(F3(f3).name(1),'.')
                        if isdir(F3(f3).name)
                            cd(F3(f3).name);
                        end
                        ff = dir('Log_*.json');
                        warning off
                        for ff1=1:length(ff)
                            newname=[ff(ff1).name(1:end-5) '_session.json'];
                            system(['mv ' ff(ff1).name newname]);
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