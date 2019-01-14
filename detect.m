function [MHW,mclim,m90,mhw_ts]=detect(temp,time,cli_start,cli_end,mhw_start,mhw_end,varargin)
%detect - Detecting spatial MHW/MCS
%  Syntax
%
%  [MHW]=detect(temp,time,cli_start,cli_end,mhw_start,mhw_end)
%  [MHW,mclim,m90,mhw_ts]=detect(temp,time,cli_start,cli_end,mhw_start,mhw_end);
%  [MHW,mclim,m90,mhw_ts]=detect(temp,time,cli_start,cli_end,mhw_start,mhw_end,'Event','MCS','Threshold',0.1);
%
%  Description
%
%  [MHW]=detect(temp,time,cli_start,cli_end,mhw_start,mhw_end) returns
%  all detected MHW events for the m-by-n-by-t matrix TEMP starting in the
%  year DATA_START. m, n and t separately indicate two spatial dimensions
%  (m and n) and one temporal dimension (t). Climatologies used to
%  determine events are calculated based on TEMP from CLI_START to
%  CLI_END. MHW is a table where each row corresponds to a particular
%  event during MHW_START to MHW_END and each column indicates a metric.
%
%  [MHW,mclim,m90,mhw_ts]=detect(temp,time,cli_start,cli_end,mhw_start,mhw_end)
%  also return the spatial climatology MCLIM (m-by-n-by-366) and threshold
%  M90 (m-by-n-by-366) to calculate MHW events and resultant MHW time series
%  MHW_TS (m-by-n-by-t). In the condition that there is no missing value in
%  data TEMP, NaN in all outputs indicates lands and 0 in MHW_TS indicates
%  the corresponding day in that grid is not in a MHW event.
%
%  [MHW,mclim,m90,mhw_ts]=detect(temp,time,cli_start,cli_end,mhw_start,mhw_end,'Event','MCS','Threshold',0.1)
%  returns MCS events based on 10th percentile threshold.
%
%  Input Arguments
%
%   temp - 3D daily temperature to detect MHW/MCS events, specified as a
%   m-by-n-by-t matrix. m and n separately indicate two spatial dimensions
%   and t indicates temporal dimension. 
%
%   time - datenum(start_year,start_month,start_day):datenum(end_year,
%   end_month,end_day)
%
%   cli_start - A numeric value in format of datennum(yyyy,mm,dd), indicating the start date for the period
%   across which the spatial climatology and threshold are calculated. 
%
%   cli_end - A numeric value in format of datennum(yyyy,mm,dd) indicating the end year for the period across
%   which the spatial climatology and threshold are calculated. 
%
%   data_start - A numeric value in format of datennum(yyyy,mm,dd) indicating the start year of your input
%   data TEMP.
%
%   mhw_start - A numeric value in format of datennum(yyyy,mm,dd) indicating the start year for the period
%   across which MHW/MCS events are detected. 
%
%   mhw_end - A numeric value in format of datennum(yyyy,mm,dd) indicating the end year for the period across
%   which MHW/MCS events are detected.
%
%   'Event' - Default is 'MHW'.
%           - 'MHW' - detecting MHW events.
%           - 'MCS' - detecting MCS events.
%
%   'Threshold' - Default is 0.9. Threshold percentile to detect MHW/MCS
%   events.
%
%   'windowHalfWidth' - Default is 5. Width of sliding window to calculate
%   spatial climatology and threshold. 
%
%   'smoothPercentileWidth' - Default is 31. Width of moving mean window to smooth spatial
%   climatology and threshold.
%
%   'minDuration' - Default is 5. Minimum duration to accept a detection of MHW/MCS
%   event.
%
%   'maxGap' - Default is 2. Maximum gap accepting joining of MHW events.
%   
%   'ClimTemp' - Default is TEMP. The data used to calculate climatology
%   and thresholds.
%
%   'ClimTime' - A vector of datenum() corresponding to ClimTemp.
%
%  Output Arguments
%   
%   MHW - A table containing all detected MHW/MCS events where each row
%   corresponds to a particular event and each column corresponds to a
%   metric. Specified metrics are:
%       - mhw_onset - onset date of each event.
%       - mhw_end - end date of each event.
%       - mhw_dur - duration of each event.
%       - int_max - maximum intensity of each event.
%       - int_mean - mean intensity of each event.
%       - int_var - variance of intensity during each event.
%       - int_cum - cumulative intensity across each event.
%       - xloc - location of each event in x-dimension of TEMP.
%       - yloc - location of each event in y-dimension of TEMP. 
%
%   mclim - A 3D matrix (m-by-n-by-366) containing climatologies.
%
%   m90 - A 3D matrix (m-by-n-by-366) containing thresholds.
%
%   mhw_ts - A 3D matrix
%   (m-by-n-by-(datenum(MHW_end,1,1)-datenum(MHW_start)+1)) containing 
%   spatial intensity of MHW/MCS in each day.


% vEvent = 'MHW';
% vThreshold = 0.9;
% vWindowHalfWidth = 5;
% vsmoothPercentileWidth = 31;
% vminDuration = 5;
% vmaxGap = 2;
% ClimTemp = temp;
% ClimTime = time;
% 
paramNames = {'Event','Threshold','WindowHalfWidth','smoothPercentileWidth','minDuration',...
    'maxGap','ClimTemp','ClimTime'};
defaults   = {'MHW',0.9,5,31,5,2,temp,time};
% 
% varargin = reshape(varargin,2,length(varargin)/2);
% 
% for i = 1:length(defaults)
%     if any(ismember(varargin(1,:),paramNames{i}))
%        feval(@()assignin('caller',paramNames{i},varargin{2,ismember(varargin(1,:),paramNames{i})}))
%     end      
% end


[vEvent, vThreshold,vWindowHalfWidth,vsmoothPercentileWidth,vminDuration,vmaxGap,ClimTemp,ClimTime]...
    = internal.stats.parseArgs(paramNames, defaults, varargin{:});

EventNames = {'MHW','MCS'};
vEvent = internal.stats.getParamVal(vEvent,EventNames,...
    '''Event''');

%%  "What if cli_start-window or cli_end+window exceeds the time range of data"

ahead_date=time(1)-(cli_start-vWindowHalfWidth);
after_date=cli_end+vWindowHalfWidth-time(end);
temp_clim=ClimTemp(:,:,ClimTime>=cli_start-vWindowHalfWidth & ClimTime<=cli_end+vWindowHalfWidth);

if ahead_date>0 && after_date>0
    temp_clim=cat(3,NaN(size(temp_clim,1),size(temp_clim,2),ahead_date), ...
    temp_clim,NaN(size(temp_clim,1),size(temp_clim,2),after_date));
elseif ahead_date>0 && after_date<=0
    temp_clim=cat(3,NaN(size(temp_clim,1),size(temp_clim,2),ahead_date), ...
    temp_clim);
elseif ahead_date<=0 && after_date>0
        temp_clim=cat(3, ...
            temp_clim,NaN(size(temp_clim,1),size(temp_clim,2),after_date));
else
    
end

temp_mhw=temp(:,:,time>=mhw_start & time<=mhw_end);

%% Calculating climatology and thresholds

date_true=datevec(cli_start-vWindowHalfWidth:cli_end+vWindowHalfWidth);
date_true=date_true(:,1:3);

date_false = date_true;
date_false(:,1) = 2012;

fake_doy = day(datetime(date_false),'dayofyear');
ind = 1:length(date_false);

mclim=NaN(size(temp,1),size(temp,2),366);
m90=NaN(size(temp,1),size(temp,2),366);

for i=1:366
    if i == 60
        
    else
        ind_fake=ind;
        ind_fake(fake_doy==i & ~ismember(datenum(date_true),cli_start:cli_end))=nan;
        
    m90(:,:,i) = quantile(temp_clim(:,:,any(ind_fake'>=(ind_fake(fake_doy == i)-vWindowHalfWidth) & ind_fake' <= (ind_fake(fake_doy ==i)+vWindowHalfWidth),2)),vThreshold,3);
    mclim(:,:,i) = mean(temp_clim(:,:,any(ind_fake'>=(ind_fake(fake_doy == i)-vWindowHalfWidth) & ind_fake' <= (ind_fake(fake_doy ==i)+vWindowHalfWidth),2)),3,'omitnan');
    end
end
% Dealing with Feb29
m90(:,:,60) = mean(m90(:,:,[59 61]),3,'omitnan');
mclim(:,:,60) = mean(mclim(:,:,[59 61]),3,'omitnan');

% Does running averages of threshold and clim..

m90long=smoothdata(cat(3,m90,m90,m90),3,'movmean',vsmoothPercentileWidth);
m90=m90long(:,:,367:367+365);
mclimlong=smoothdata(cat(3,mclim,mclim,mclim),3,'movmean',vsmoothPercentileWidth);
mclim=mclimlong(:,:,367:367+365);


[x_size,y_size]=deal(size(m90,1),size(m90,2));

mbigadd=temp_mhw;

date_mhw=datevec(mhw_start:mhw_end);
date_mhw(:,1)=2000;
indextocal = day(datetime(date_mhw),'dayofyear');

ts=str2double(string(datestr(mhw_start:mhw_end,'YYYYmmdd')));

mhw_ts=zeros(x_size,y_size,length(ts));




MHW=[];

%% Detecting MHW/MCS in each grid

switch vEvent
    case 'MHW'
        
        for i=1:x_size
            for j=1:y_size
                
                mhw_ts(i,j,isnan(squeeze(mbigadd(i,j,:))))=nan;
                
                if sum(isnan(squeeze(mbigadd(i,j,:))))~=size(mbigadd,3)
                    
                    maysum=zeros(size(mbigadd,3),1);
                    
                    maysum(squeeze(mbigadd(i,j,:))>=squeeze(m90(i,j,indextocal)))=1;
                    
                    trigger=0;
                    potential_event=[];
                    
                    for n=1:size(maysum,1)
                        if trigger==0 && maysum(n)==1
                            start_here=n;
                            trigger=1;
                        elseif trigger==1 && maysum(n)==0
                            end_here=n-1;
                            trigger=0;
                            potential_event=[potential_event;[start_here end_here]];
                        elseif n==size(maysum,1) && trigger==1 && maysum(n)==1
                            trigger=0;
                            end_here=n;
                            potential_event=[potential_event;[start_here end_here]];
                        end
                    end
                    
                    if ~isempty(potential_event)
                        
                        potential_event=potential_event((potential_event(:,2)-potential_event(:,1)+1)>=vminDuration,:);
                        
                        if ~isempty(potential_event)
                            
                            gaps=(potential_event(2:end,1) - potential_event(1:(end-1),2) - 1);
                            
                            while min(gaps)<=vmaxGap
                                %                                  potential_event(find(gaps<=vmaxGap),2)=potential_event(find(gaps<=vmaxGap)+1,2);
                                %                                  potential_event(find(gaps<=vmaxGap)+1,:)=[];
                                %                                  gaps=(potential_event(2:end,1) - potential_event(1:(end-1),2) - 1);
                                
                                potential_event(find(gaps<=vmaxGap),2)=potential_event(find(gaps<=vmaxGap)+1,2);
                                loc_should_del=(find(gaps<=vmaxGap)+1);
                                loc_should_del=loc_should_del(~ismember(loc_should_del,find(gaps<=vmaxGap)));
                                potential_event(loc_should_del,:)=[];
                                gaps=(potential_event(2:end,1) - potential_event(1:(end-1),2) - 1);
                            end
                            
                            mhwstart=NaN(size(potential_event,1),1);
                            mhwend=NaN(size(potential_event,1),1);
                            mduration=NaN(size(potential_event,1),1);
                            mhwint_max=NaN(size(potential_event,1),1);
                            mhwint_mean=NaN(size(potential_event,1),1);
                            mhwint_var=NaN(size(potential_event,1),1);
                            mhwint_cum=NaN(size(potential_event,1),1);
                            
                            for le=1:size(potential_event,1)
                                event_here=potential_event(le,:);
                                endtime=ts(event_here(2));
                                starttime=ts(event_here(1));
                                mcl=squeeze(mclim(i,j,indextocal(event_here(1):event_here(2))));
                                mrow=squeeze(mbigadd(i,j,event_here(1):event_here(2)));
                                manom=mrow-mcl;
                                mhw_ts(i,j,event_here(1):event_here(2))=manom;
                                
                                [maxanom,~]=nanmax(squeeze(manom));
                                
                                mhwint_max(le)=...
                                    maxanom;
                                mhwint_mean(le)=...
                                    mean(manom);
                                mhwint_var(le)=...
                                    std(manom);
                                mhwint_cum(le)=...
                                    sum(manom);
                                mhwstart(le)=starttime;
                                mhwend(le)=endtime;
                                mduration(le)=event_here(2)-event_here(1)+1;
                            end
                            MHW=[MHW;[mhwstart mhwend mduration mhwint_max mhwint_mean mhwint_var mhwint_cum repmat(i,size(mhwstart,1),1) repmat(j,size(mhwstart,1),1)]];
                        end
                    end
                end
                
                
                
                
            end
        end
        
    case 'MCS'
        
        for i=1:x_size
            for j=1:y_size
                
                mhw_ts(i,j,isnan(squeeze(mbigadd(i,j,:))))=nan;
                
                if sum(isnan(squeeze(mbigadd(i,j,:))))~=size(mbigadd,3)
                    
                    maysum=zeros(size(mbigadd,3),1);
                    
                    maysum(squeeze(mbigadd(i,j,:))<=squeeze(m90(i,j,indextocal)))=1;
                    
                    trigger=0;
                    potential_event=[];
                    
                    for n=1:size(maysum,1)
                        if trigger==0 && maysum(n)==1
                            start_here=n;
                            trigger=1;
                        elseif trigger==1 && maysum(n)==0
                            end_here=n-1;
                            trigger=0;
                            potential_event=[potential_event;[start_here end_here]];
                        elseif n==size(maysum,1) && trigger==1 && maysum(n)==1
                            trigger=0;
                            end_here=n;
                            potential_event=[potential_event;[start_here end_here]];
                        end
                    end
                    
                    if ~isempty(potential_event)
                        
                        potential_event=potential_event((potential_event(:,2)-potential_event(:,1)+1)>=vminDuration,:);
                        
                        if ~isempty(potential_event)
                            
                            gaps=(potential_event(2:end,1) - potential_event(1:(end-1),2) - 1);
                            
                            while min(gaps)<=vmaxGap
                                %                                  potential_event(find(gaps<=vmaxGap),2)=potential_event(find(gaps<=vmaxGap)+1,2);
                                %                                  potential_event(find(gaps<=vmaxGap)+1,:)=[];
                                %                                  gaps=(potential_event(2:end,1) - potential_event(1:(end-1),2) - 1);
                                
                                potential_event(find(gaps<=vmaxGap),2)=potential_event(find(gaps<=vmaxGap)+1,2);
                                loc_should_del=(find(gaps<=vmaxGap)+1);
                                loc_should_del=loc_should_del(~ismember(loc_should_del,find(gaps<=vmaxGap)));
                                potential_event(loc_should_del,:)=[];
                                gaps=(potential_event(2:end,1) - potential_event(1:(end-1),2) - 1);
                            end
                            
                            mhwstart=NaN(size(potential_event,1),1);
                            mhwend=NaN(size(potential_event,1),1);
                            mduration=NaN(size(potential_event,1),1);
                            mhwint_max=NaN(size(potential_event,1),1);
                            mhwint_mean=NaN(size(potential_event,1),1);
                            mhwint_var=NaN(size(potential_event,1),1);
                            mhwint_cum=NaN(size(potential_event,1),1);
                            
                            for le=1:size(potential_event,1)
                                event_here=potential_event(le,:);
                                endtime=ts(event_here(2));
                                starttime=ts(event_here(1));
                                mcl=squeeze(mclim(i,j,indextocal(event_here(1):event_here(2))));
                                mrow=squeeze(mbigadd(i,j,event_here(1):event_here(2)));
                                manom=mrow-mcl;
                                mhw_ts(i,j,event_here(1):event_here(2))=manom;
                                
                                [maxanom,~]=nanmin(squeeze(manom));
                                
                                mhwint_max(le)=...
                                    maxanom;
                                mhwint_mean(le)=...
                                    mean(manom);
                                mhwint_var(le)=...
                                    std(manom);
                                mhwint_cum(le)=...
                                    sum(manom);
                                mhwstart(le)=starttime;
                                mhwend(le)=endtime;
                                mduration(le)=event_here(2)-event_here(1)+1;
                            end
                            
                            MHW=[MHW;[mhwstart mhwend mduration mhwint_max mhwint_mean mhwint_var mhwint_cum repmat(i,size(mhwstart,1),1) repmat(j,size(mhwstart,1),1)]];
                            
                        end
                    end
                end
                
                
                
                
                
            end
        end
end

MHW=table(MHW(:,1),MHW(:,2),MHW(:,3),MHW(:,4),MHW(:,5),MHW(:,6),MHW(:,7),MHW(:,8),MHW(:,9),...
    'variablenames',{'mhw_onset','mhw_end','mhw_dur','int_max','int_mean','int_var','int_cum','xloc','yloc'});



