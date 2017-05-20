% Extract behavior and eye data from MRI experiments
% Netherlands Institute for Neuroscience
% Chris Klink (c.klink@nin.knaw.nl)
% ==================================================
function ProcessEyeAndBehavior

%% datapaths ---------------------------------------
monkey = 'EDDY'; % all caps
sess_date = '20170511/CurveTracing'; %yyyymmdd

% NB! proper logging info is available for 20160721 and later
% =====================================
DoEye = true;
DoHand = false;
DoReward = false;
% =====================================

base_path = '/big/NHP_MRI/';
rundirs_pattern=[base_path 'Data_proc/' monkey '/' sess_date '/run*'];
rundirs=dir(rundirs_pattern);
assert(size(rundirs,1) > 0, ['Did not find directories matching ' ...
    rundirs_pattern ...
    ]);

for i=1:length(rundirs)
    fprintf('%s\n', rundirs(i).name);
    frun(i).dirname = rundirs(i).name;
    frun(i).eyefolder = [base_path 'Data_proc/' monkey '/' sess_date '/' rundirs(i).name '/eye'];
    frun(i).behfolder = [base_path 'Data_proc/' monkey '/' sess_date '/' rundirs(i).name '/behavior'];
    frun(i).modelfolder = [base_path 'Data_proc/' monkey '/' sess_date '/' rundirs(i).name '/model'];
end
startfolder = pwd;

%% collect eye-data from ISCAN files ---------------
% requires manual check:
% all files should be limited to 1 run
% files should be renamed 'runXXX'
% files should have 27 header lines (default)
for i=1:length(frun)
    cd(frun(i).eyefolder);
    fns = dir('*.tda'); % get file-info
    for ef = 1:length(fns)
        nhdrlines = 27;
        fprintf([frun(i).dirname ' eye pos : ' fns(ef).name '\n']);
        d=importdata(fns(ef).name,'\t',nhdrlines);
        eye(i,ef).hdr = d.textdata;
        eye(i,ef).samplerate = 120;
        eye(i,ef).data = d.data;
        eye(i,ef).data(:,1) = eye(i,ef).data(:,1) - eye(i,ef).data(1,1);
        eye(i,ef).columns = {'s', 'H1', 'V1', 'D1', 'H1b', 'V1b', 'Ext'};
        eye(i,ef).t = eye(i,ef).data(:,1)./eye(i,ef).samplerate;
    end
    %plot(eye(ef).data(:,2),eye(ef).data(:,3),'b')
end

%% collect behavioral data from log-files ----------
% folders should be renamed 'runXXX'
for i=1:length(frun)
    cd(frun(i).behfolder)
    fdns = dir();
    for bf = 1:length(fdns)-2
        cd(fdns(2+bf).name) % ignore '.' and '..'
        % Log
        warning off;
        fn=ls('Log*.mat');
        clear L
        L=load(fn(1:end-4), 'Log', 'StimObj');
        beh(i,bf).fn = fn(1:end-4);
        beh(i,bf).Log=L.Log;
        beh(i,bf).Stim=L.StimObj.Stm;
        
        temp =  dir('Log*.csv');
        potential_event_logs = {temp.name};
        fn_csv_ind = regexp(potential_event_logs, '^Log.*_\d{8}T\d{4}(?:_eventlog)?\.csv$');
        fn_csv_mask = cellfun(@(x) length(x)==1, fn_csv_ind);
        fn_csv = potential_event_logs{fn_csv_mask};
        beh(i,bf).event_log = readtable(fn_csv);
        
        %beh(i,bf).Par=L.Par;

        cd ..
        
        if DoEye
            % check the offset changes and adjust for run > first
            LE=beh(i,bf).Log.Eye;
            % first offset change
            j=1;
            first_offset_found=false;
            while j<length(LE)-1 && ~first_offset_found
                if sum(LE(j).ScaleOff-LE(j+1).ScaleOff)~=0
                    first_offset_found=true;
                    offset_ind = j;
                    d_offset = LE(j+1).ScaleOff(1)-LE(j).ScaleOff(1);
                    d_eyex = ((LE(j).CurrEyePos(1)/LE(j).ScaleOff(3))-LE(j).ScaleOff(1))-...
                        ((LE(j-1).CurrEyePos(1)/LE(j-1).ScaleOff(3))-LE(j-1).ScaleOff(1));
                end
                j=j+1;
            end
            if ~first_offset_found
                offset_ind = j;
            end
            
            if first_offset_found && ...
                    (abs(d_eyex) > 0.95* abs(d_offset) && abs(d_eyex) < 1.05* abs(d_offset))
                %accurate offset shift
            elseif i>1 || bf>1 % replace ScaleOffset values with those of previous run
                for jjj=1:offset_ind+1
                    beh(i,bf).Log.Eye(jjj).ScaleOff = ...
                        beh(i-1,bf).Log.Eye(end).ScaleOff;
                end
            end
        end
    end
end

%% Get the start-moment of the eye recording -------
for i=1:size(beh,1)
    for run_n = 1:size(beh,2)
        eyeRecOnMsk = strcmp(beh(i,run_n).event_log.event, 'EyeRecOn');
        assert(sum(eyeRecOnMsk)==1);
        
        % JW: needed for JW's annoying column name changes
        if ~any(strcmp('time',beh(i,run_n).event_log.Properties.VariableNames))
            if any(strcmp('time_s',beh(i,run_n).event_log.Properties.VariableNames))
                beh(i,run_n).event_log.time = beh(i,run_n).event_log.time_s;
            end
        end
        
        eyestart = beh(i,run_n).event_log.time(eyeRecOnMsk)/1000;
        
        mriTriggerMsk = strcmp(beh(i,run_n).event_log.event, 'MRI_Trigger');
        assert(sum(mriTriggerMsk)>0);
        mritriggers = beh(i,run_n).event_log.time(mriTriggerMsk);
        mristart = mritriggers(1)/1000;
        
        eye(i,run_n).t0_eye = eyestart;
        eye(i,run_n).tt = eye(i,run_n).t+eyestart;
        eye(i,run_n).t0_mri = mristart;
    end
end

%% Eye trace from ISCAN log ------------------------
if DoEye
    for r=1:size(eye,1)
        for rr=1:size(eye,2)
            % eye trace from tracker log
            tracker_eye{r,rr}=[];
            for i = 1:length(beh(r,rr).Log.Eye)
                tracker_eye{r,rr}=[tracker_eye{r,rr};...
                    beh(r,rr).Log.Eye(i).t ...
                    beh(r,rr).Log.Eye(i).CurrEyePos ...
                    beh(r,rr).Log.Eye(i).ScaleOff' ...
                    beh(r,rr).Log.Eye(i).CurrEyeZoom ...
                    ];
            end
            
            xy_mat{r,rr}=[];
            for bs=1:size(tracker_eye{r,rr},1)
                xy_mat{r,rr} = [ xy_mat{r,rr}; ...
                    tracker_eye{r,rr}(bs,1:7) ...
                    eye(r,rr).data(find(eye(r,rr).tt<=tracker_eye{r,rr}(bs,1),...
                    1,'last'),2:4)];
            end
            
            % blink removal ------------------------
            xy_mat_nb=xy_mat;
            d = xy_mat_nb{r,rr}(:,10);
            md=median(d);
            maxd=max(d);
            % blinks detected at 75% eye closure
            blinks=(d<=0.25*maxd);
            % also remove
            sb=smooth(double(blinks),5)>0;
            
            %remove blink flags
            xy_mat_nb{r,rr}(sb,:)=nan;
            
            % Calculate relation between signals ------------------------------
            m=xy_mat_nb{r,rr};
            
            c=[];
            for i=2:size(m,1)
                if sum(m(i,4:7)-m(i-1,4:7))~=0
                    c=[c i];
                end
            end
            
            % TRACKER_x = ((((ISCAN_x*ISCAN_g)+ISCAN_o)*DAS_g)+TRACKER_o).*TRACKER_g;
            %
            % (TRACKER_x./TRACKER_g)-TRACKER_o = DAS_g*ISCAN_o + DAS_g*ISCAN_g*ISCAN_x;
            % (TRACKER_x./TRACKER_g)-TRACKER_o = DI_o + DI_g*ISCAN_x;
            % TRACKER_x = ((DI_o + DI_g*ISCAN_x)+TRACKER_o).*TRACKER_g;
            
            % estimate based on those values between -200 and 200
            sel_pts = abs(m(:,2))<200 & abs(m(:,2))<200;
            
            % Set up fittype and options.
            ft = fittype( 'poly1' );
            opts = fitoptions( 'Method', 'LinearLeastSquares' );
            opts.Robust = 'LAR';
            % Fit model to data.
            warning off;
            ISCAN_x = m(sel_pts,8);
            TRACKER_x = m(sel_pts,2);
            TRACKER_ox = m(sel_pts,4);
            TRACKER_gx = m(sel_pts,6);
            
            ISCAN_y = m(sel_pts,9) ;
            TRACKER_y = m(sel_pts,3) ;
            TRACKER_oy = m(sel_pts,5) ;
            TRACKER_gy = m(sel_pts,7) ;
            
            Yx = (TRACKER_x./TRACKER_gx)-TRACKER_ox;
            Yy = (TRACKER_y./TRACKER_gy)-TRACKER_oy;
            
            [fitresult, gof] = fit( ISCAN_x,Yx, ft, opts );
            DI_gx = fitresult.p1;
            DI_ox = fitresult.p2;
            
            [fitresult, gof] = fit( ISCAN_y, Yy, ft, opts );
            DI_gy = fitresult.p1;
            DI_oy = fitresult.p2;
            warning on;
            
            %         figure
            %         subplot(3,1,1); hold on
            %         plot(m(:,1),((DI_ox + DI_gx*m(:,8))+m(:,4)).*m(:,6),'r')
            %         plot(m(:,1),m(:,2),'b')
            %
            %         subplot(3,1,2); hold on
            %         plot(m(:,1),((DI_oy + DI_gy*m(:,9))+m(:,5)).*-m(:,7),'r')
            %         plot(m(:,1),-m(:,3),'b')
            %
            %         subplot(3,1,3); hold on
            %         plot(m(:,1),m(:,10),'k')
            %
            %         figure; hold on;
            %         scatter(m(:,2),m(:,3))
            %         scatter(((DI_ox + DI_gx*m(:,8))+m(:,4)).*m(:,6),...
            %             ((DI_oy + DI_gy*m(:,9))+m(:,5)).*m(:,6),'r')
            
            run(r,rr).m=xy_mat{r,rr};
            
            run(r,rr).DI_gx = DI_gx;
            run(r,rr).DI_ox = DI_ox;
            
            run(r,rr).DI_gy = DI_gy;
            run(r,rr).DI_oy = DI_oy;
            
        end
    end
end

%% Reconstruct eyetraces at ISCAN resolution -------
if DoEye
    for r=1:size(eye,1)
        fprintf(['Reconstructing eye-trace for ' num2str(r) '/' num2str(size(eye,1)) '\n']);
        for rr=1:size(eye,2)
            % create high resolution offset and gain vectors
            % 1 - find moments of new offset/scale
            moments = [];
            for i=1:size(run(r,rr).m,1)
                if i==1
                    moments=[moments; i];
                elseif ~isnan(run(r,rr).m(i,4)) && mean(abs(run(r,rr).m(i,4:7)-run(r,rr).m(moments(end),4:7))) ~= 0
                    moments=[moments; i];
                end
            end
            
            % 2 - create a list of scale/offset
            new_ScaleOffset = [];
            nt = run(r,rr).m(moments,1);
            for i=1:size(eye(r,rr).tt,1)
                if eye(r,rr).tt(i) < run(r,rr).m(1,1)
                    new_ScaleOffset = [new_ScaleOffset; run(r,rr).m(1,4:7)];
                else
                    n = find(nt<eye(r,rr).tt(i),1,'last');
                    new_ScaleOffset = [new_ScaleOffset; run(r,rr).m(moments(n),4:7)];
                    
                end
            end
            eye(r,rr).ScaleOff = new_ScaleOffset;
            
            % create adjusted eye-traces
            eye(r,rr).xyd = [...
                ((run(r,rr).DI_ox + run(r,rr).DI_gx* eye(r,rr).data(:,2))+ eye(r,rr).ScaleOff(:,1)).*eye(r,rr).ScaleOff(:,3) ...
                ((run(r,rr).DI_oy + run(r,rr).DI_gy* eye(r,rr).data(:,3))+ eye(r,rr).ScaleOff(:,2)).*-eye(r,rr).ScaleOff(:,4) ...
                eye(r,rr).data(:,4) ];
            
            % ad blink detection (<25% pupil)
            eye(r,rr).blinks = eye(r,rr).xyd(:,3) < 0.25*max(eye(r,rr).xyd(:,3)); %raw
            eye(r,rr).blinks(:,2) = ceil(smooth(double(eye(r,rr).blinks),5)); %smooth
            
        end
    end
end

%% Get behavioral events ---------------------------
for r=1:size(beh,1)
    for rr=1:size(beh,2)
        if DoReward
            % Reward events
            Reward = []; ev=1;
            while ev<=size(beh(r,rr).Log.Events,2)
                if strcmp(beh(r,rr).Log.Events(ev).type,'RewardAutoTask') || ...
                        strcmp(beh(r,rr).Log.Events(ev).type,'RewardMan')
                    t_rew = beh(r,rr).Log.Events(ev).t;
                    rewrunning=true;
                    while rewrunning && ev<=size(beh(r,rr).Log.Events,2)
                        if strcmp(beh(r,rr).Log.Events(ev).type,'RewardStopped')
                            rewrunning=false;
                            dt_rew = beh(r,rr).Log.Events(ev).t-t_rew;
                            Reward = [Reward; t_rew dt_rew 1];
                        else
                            ev=ev+1;
                        end
                    end
                else
                    ev=ev+1;
                end
            end
            beh(r,rr).RewardEvents = Reward;
        end
        
        if DoHand
            % Hand movements
            Hand_1 = [];Hand_2 = [];
            for ev=1:size(beh(r,rr).Log.Events,2)
                if strcmp(beh(r,rr).Log.Events(ev).type,'BeamStateChange[false;true]')
                    Hand_1=[Hand_1; beh(r,rr).Log.Events(ev).t];
                elseif strcmp(beh(r,rr).Log.Events(ev).type,'BeamStateChange[true;false]')
                    Hand_2=[Hand_2; beh(r,rr).Log.Events(ev).t];
                end
            end
            beh(r,rr).Hand1Events = Hand_1;
            beh(r,rr).Hand2Events = Hand_2;
            
            % Go Signal
            Go_sig=[];
            for ev=1:size(beh(r,rr).Log.Events,2)
                if strcmp(beh(r,rr).Log.Events(ev).type,'HandTaskState-Go')
                    Go_sig=[Go_sig; beh(r,rr).Log.Events(ev).t - beh(r,rr).Par.ExpStart];
                end
            end
            beh(r,rr).GoEvents = Go_sig;
        end
    end
end

%% Export to text files ----------------------------
for f=1:size(frun,2)
    cd(frun(f).modelfolder)
    r=f;
    fprintf(['Exporting events to text files ' num2str(r) '/' num2str(size(eye,1)) '\n']);
    for rr=1:size(beh,2)
        if DoEye
            % eye
            eye_x = [...
                eye(r,rr).tt ...
                (1/eye(r,rr).samplerate)*ones(size(eye(r,rr).tt,1),1) ...
                eye(r,rr).xyd(:,1) ...
                ];
            eye_x(eye(r,rr).blinks(:,2),:)=[];
            eye_x(:,1)=eye_x(:,1)-eye(r,rr).t0_mri;
            eye_x(eye_x(:,1)<0,:)=[];
            dlmwrite('EyeX.txt',eye_x,'\t');
            
            eye_y = [...
                eye(r,rr).tt ...
                (1/eye(r,rr).samplerate)*ones(size(eye(r,rr).tt,1),1) ...
                eye(r,rr).xyd(:,2)...
                ];
            eye_y(eye(r,rr).blinks(:,2),:)=[];
            eye_y(:,1)=eye_y(:,1)-eye(r,rr).t0_mri;
            eye_y(eye_y(:,1)<0,:)=[];
            dlmwrite('EyeY.txt',eye_y,'\t');
            
            eye_d = [...
                eye(r,rr).tt ...
                (1/eye(r,rr).samplerate)*ones(size(eye(r,rr).tt,1),1) ...
                eye(r,rr).xyd(:,3)...
                ];
            eye_d(eye(r,rr).blinks(:,2),:)=[];
            eye_d(:,1)=eye_d(:,1)-eye(r,rr).t0_mri;
            eye_d(eye_d(:,1)<0,:)=[];
            dlmwrite('EyeD.txt',eye_d,'\t');
            
            if ~isempty(eye(r,rr).blinks)
                eye_closed = [...
                    eye(r,rr).tt(eye(r,rr).blinks(:,2)) ...
                    (1/eye(r,rr).samplerate)*ones(size(eye(r,rr).tt(eye(r,rr).blinks(:,2)),1),1) ...
                    ones(size(eye(r,rr).tt(eye(r,rr).blinks(:,2)),1),1)...
                    ];
                eye_closed(:,1)=eye_closed(:,1)-eye(r,rr).t0_mri;
                eye_closed(eye_closed(:,1)<0,:)=[];
                dlmwrite('EyeClosed.txt',eye_closed,'delimiter','\t','precision',6);
            else
                fclose(fopen('EyeClosed.txt','w'));
            end
        end
        
        if DoReward
            % reward
            if ~isempty(beh(r,rr).RewardEvents)
                beh(r,rr).RewardEvents(:,1) = ...
                    beh(r,rr).RewardEvents(:,1) - eye(r,rr).t0_mri;
                beh(r,rr).RewardEvents(beh(r,rr).RewardEvents(:,1)<0,:)=[];
                dlmwrite('RewardEvents.txt',beh(r,rr).RewardEvents,'\t');
                
                cumrew = [ beh(r,rr).RewardEvents(:,1) + beh(r,rr).RewardEvents(:,2) ...
                    diff([0;beh(r,rr).RewardEvents(:,1)]) ...
                    cumsum(beh(r,rr).RewardEvents(:,2)) ];
                dlmwrite('RewardCumState.txt',cumrew,'\t');
            else
                fclose(fopen('RewardEvents.txt','w'));
                fclose(fopen('RewardCumState.txt','w'));
            end
        end
        
        if DoHand
            % hand
            if ~isempty(beh(r,rr).Hand1Events)
                beh(r,rr).Hand1Events(:,1) = ...
                    beh(r,rr).Hand1Events(:,1) - eye(r,rr).t0_mri;
                beh(r,rr).Hand1Events(beh(r,rr).Hand1Events(:,1)<0,:)=[];
                dlmwrite('Hand1Events.txt',beh(r,rr).Hand1Events,'\t');
            else
                fclose(fopen('Hand1Events.txt','w'));
            end
            
            if ~isempty(beh(r,rr).Hand2Events)
                beh(r,rr).Hand2Events(:,1) = ...
                    beh(r,rr).Hand2Events(:,1) - eye(r,rr).t0_mri;
                beh(r,rr).Hand2Events(beh(r,rr).Hand2Events(:,1)<0,:)=[];
                dlmwrite('Hand2Events.txt',beh(r,rr).Hand2Events,'\t');
            else
                fclose(fopen('Hand2Events.txt','w'));
            end
            
            % go
            if ~isempty(beh(r,rr).GoEvents)
                beh(r,rr).GoEvents(:,1) = ...
                    beh(r,rr).GoEvents(:,1) - eye(r,rr).t0_mri;
                beh(r,rr).GoEvents(beh(r,rr).GoEvents(:,1)<0,:)=[];
                dlmwrite('GoEvents.txt',beh(r,rr).GoEvents,'\t');
            else
                fclose(fopen('GoEvents.txt','w'));
            end
        end
    end
end
cd(startfolder);