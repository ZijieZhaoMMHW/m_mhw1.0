function [MHW,mclim,m90,mhw_ts]=detect_justfortest(temp,time,cli_start,cli_end,mhw_start,mhw_end,m90,varargin)
% This function is designed for test.

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

ahead_date=time(1)-(cli_start-vWindowHalfWidth);
after_date=cli_end+vWindowHalfWidth-time(end);
temp_clim=ClimTemp(:,:,ClimTime>=cli_start-vWindowHalfWidth & ClimTime<=cli_end+vWindowHalfWidth);

if ahead_date>0 && after_date>0;
    temp_clim=cat(3,NaN(size(temp_clim,1),size(temp_clim,2),ahead_date), ...
    temp_clim,NaN(size(temp_clim,1),size(temp_clim,2),after_date));
elseif ahead_date>0 && after_date<=0;
    temp_clim=cat(3,NaN(size(temp_clim,1),size(temp_clim,2),ahead_date), ...
    temp_clim);
elseif ahead_date<=0 && after_date>0;
        temp_clim=cat(3, ...
            temp_clim,NaN(size(temp_clim,1),size(temp_clim,2),after_date));
else
    temp_clim=temp_clim;
end

temp_mhw=temp(:,:,time>=mhw_start & time<=mhw_end);


date_true=datevec(cli_start-vWindowHalfWidth:cli_end+vWindowHalfWidth);
date_true=date_true(:,1:3);

date_false = date_true;
date_false(:,1) = 2012;

fake_doy = day(datetime(date_false),'dayofyear');
ind = 1:length(date_false);

mclim=NaN(size(temp,1),size(temp,2),366);
% m90=NaN(size(temp,1),size(temp,2),366);

for i=1:366
    if i == 60
        ;
    else
        ind_fake=ind;
        ind_fake(fake_doy==i & ~ismember(datenum(date_true),cli_start:cli_end))=nan;
        
%     m90(:,:,i) = prctile_python_R(temp_clim(:,:,any(ind_fake'>=(ind_fake(fake_doy == i)-vWindowHalfWidth) & ind_fake' <= (ind_fake(fake_doy ==i)+vWindowHalfWidth),2)),vThreshold);
    mclim(:,:,i) = mean(temp_clim(:,:,any(ind_fake'>=(ind_fake(fake_doy == i)-vWindowHalfWidth) & ind_fake' <= (ind_fake(fake_doy ==i)+vWindowHalfWidth),2)),3,'omitnan');
    end
end   
% m90(:,:,60) = mean(m90(:,:,[59 61]),3,'omitnan');
mclim(:,:,60) = mean(mclim(:,:,[59 61]),3,'omitnan');


true_time = datevec(time);
true_time = true_time(:,1:3);
true_time(:,1) = 2012;
time_doy = day(datetime(true_time),'dayofyear');


% m90long=smoothdata(cat(3,m90,m90,m90),3,'movmean',vsmoothPercentileWidth);
% m90=m90long(:,:,367:367+365);
mclimlong=smoothdata(cat(3,mclim,mclim,mclim),3,'movmean',vsmoothPercentileWidth);
mclim=mclimlong(:,:,367:367+365);
% does running averages of threshold and clim..

[x_size,y_size]=deal(size(m90,1),size(m90,2));

mbigadd=temp_mhw;

date_mhw=datevec(mhw_start:mhw_end);
date_mhw(:,1)=2000;
indextocal = day(datetime(date_mhw),'dayofyear');

ts=str2num(datestr(mhw_start:mhw_end,'YYYYmmdd'));

mhw_ts=zeros(x_size,y_size,length(ts));


mhwstart=[];
mhwend=[];
mduration=[];
mhwint_max=[];
mhwint_mean=[];
mhwint_var=[];
mhwint_cum=[];

MHW=[];

switch vEvent
    case 'MHW'
        
        for i=1:x_size
            for j=1:y_size
                
                mhw_ts(i,j,isnan(squeeze(mbigadd(i,j,:))))=nan;
                
                if sum(isnan(squeeze(mbigadd(i,j,:))))~=size(mbigadd,3);
                    
                    maysum=zeros(size(mbigadd,3),1);
                    
                    maysum(squeeze(mbigadd(i,j,:))>=squeeze(m90(i,j,indextocal)))=1;
                    
                    trigger=0;
                    potential_event=[];
                    
                    for n=1:size(maysum,1);
                        if trigger==0 && maysum(n)==1
                            start_here=n;
                            trigger=1;
                        elseif trigger==1 && maysum(n)==0
                            end_here=n-1;
                            trigger=0;
                            potential_event=[potential_event;[start_here end_here]];
                        elseif n==size(maysum,1) && trigger==1 && maysum(n)==1;
                            trigger=0;
                            end_here=n;
                            potential_event=[potential_event;[start_here end_here]];
                        end
                    end
                    
                    if ~isempty(potential_event);
                        
                        potential_event=potential_event((potential_event(:,2)-potential_event(:,1)+1)>=vminDuration,:);
                        
                        if ~isempty(potential_event);
                            
                            gaps=(potential_event(2:end,1) - potential_event(1:(end-1),2) - 1);
                            
                            while min(gaps)<=vmaxGap;
%                                  potential_event(find(gaps<=vmaxGap),2)=potential_event(find(gaps<=vmaxGap)+1,2);
%                                  potential_event(find(gaps<=vmaxGap)+1,:)=[];
%                                  gaps=(potential_event(2:end,1) - potential_event(1:(end-1),2) - 1);
                                 
                                 potential_event(find(gaps<=vmaxGap),2)=potential_event(find(gaps<=vmaxGap)+1,2);
                                 loc_should_del=(find(gaps<=vmaxGap)+1);
                                 loc_should_del=loc_should_del(~ismember(loc_should_del,find(gaps<=vmaxGap)));
                                 potential_event(loc_should_del,:)=[];
                                 gaps=(potential_event(2:end,1) - potential_event(1:(end-1),2) - 1);
                            end
                            
                            for le=1:size(potential_event,1);
                                event_here=potential_event(le,:);
                                endtime=ts(event_here(2));
                                starttime=ts(event_here(1));
                                mcl=squeeze(mclim(i,j,indextocal(event_here(1):event_here(2))));
                                mrow=squeeze(mbigadd(i,j,event_here(1):event_here(2)));
                                manom=mrow-mcl;
                                mhw_ts(i,j,event_here(1):event_here(2))=manom;
                                
                                [maxanom,locanom]=nanmax(squeeze(manom));
                                mhwint_max=[mhwint_max;...
                                    maxanom];
                                mhwint_mean=[mhwint_mean;...
                                    mean(manom)];
                                mhwint_var=[mhwint_var;...
                                    std(manom)];
                                mhwint_cum=[mhwint_cum;...
                                    sum(manom)];
                                mhwstart=[mhwstart;starttime];
                                mhwend=[mhwend;endtime];
                                mduration=[mduration;event_here(2)-event_here(1)+1];
                            end
                             MHW=[MHW;[mhwstart mhwend mduration mhwint_max mhwint_mean mhwint_var mhwint_cum repmat(i,size(mhwstart,1),1) repmat(j,size(mhwstart,1),1)]];
                        end
                    end
                end
                
               
                
                mhwstart=[];
                mhwend=[];
                mduration=[];
                mhwint_max=[];
                mhwint_mean=[];
                mhwint_var=[];
                mhwint_cum=[];
            end
        end
        
    case 'MCS'
        
        for i=1:x_size
            for j=1:y_size
                
                mhw_ts(i,j,isnan(squeeze(mbigadd(i,j,:))))=nan;
                
                if sum(isnan(squeeze(mbigadd(i,j,:))))~=size(mbigadd,3);
                    
                    maysum=zeros(size(mbigadd,3),1);
                    
                    maysum(squeeze(mbigadd(i,j,:))<=squeeze(m90(i,j,indextocal)))=1;
                    
                    trigger=0;
                    potential_event=[];
                    
                    for n=1:size(maysum,1);
                        if trigger==0 && maysum(n)==1
                            start_here=n;
                            trigger=1;
                        elseif trigger==1 && maysum(n)==0
                            end_here=n-1;
                            trigger=0;
                            potential_event=[potential_event;[start_here end_here]];
                        elseif n==size(maysum,1) && trigger==1 && maysum(n)==1;
                            trigger=0;
                            end_here=n;
                            potential_event=[potential_event;[start_here end_here]];
                        end
                    end
                    
                    if ~isempty(potential_event);
                        
                        potential_event=potential_event((potential_event(:,2)-potential_event(:,1)+1)>=vminDuration,:);
                        
                        if ~isempty(potential_event);
                            
                            gaps=(potential_event(2:end,1) - potential_event(1:(end-1),2) - 1);
                            
                            while min(gaps)<=vmaxGap;
%                                  potential_event(find(gaps<=vmaxGap),2)=potential_event(find(gaps<=vmaxGap)+1,2);
%                                  potential_event(find(gaps<=vmaxGap)+1,:)=[];
%                                  gaps=(potential_event(2:end,1) - potential_event(1:(end-1),2) - 1);
                                 
                                 potential_event(find(gaps<=vmaxGap),2)=potential_event(find(gaps<=vmaxGap)+1,2);
                                 loc_should_del=(find(gaps<=vmaxGap)+1);
                                 loc_should_del=loc_should_del(~ismember(loc_should_del,find(gaps<=vmaxGap)));
                                 potential_event(loc_should_del,:)=[];
                                 gaps=(potential_event(2:end,1) - potential_event(1:(end-1),2) - 1);
                            end
                            
                            for le=1:size(potential_event,1);
                                event_here=potential_event(le,:);
                                endtime=ts(event_here(2));
                                starttime=ts(event_here(1));
                                mcl=squeeze(mclim(i,j,indextocal(event_here(1):event_here(2))));
                                mrow=squeeze(mbigadd(i,j,event_here(1):event_here(2)));
                                manom=mrow-mcl;
                                mhw_ts(i,j,event_here(1):event_here(2))=manom;
                                
                                [maxanom,locanom]=nanmin(squeeze(manom));
                                mhwint_max=[mhwint_max;...
                                    maxanom];
                                mhwint_mean=[mhwint_mean;...
                                    mean(manom)];
                                mhwint_var=[mhwint_var;...
                                    std(manom)];
                                mhwint_cum=[mhwint_cum;...
                                    sum(manom)];
                                mhwstart=[mhwstart;starttime];
                                mhwend=[mhwend;endtime];
                                mduration=[mduration;event_here(2)-event_here(1)+1];
                            end
                            
                             MHW=[MHW;[mhwstart mhwend mduration mhwint_max mhwint_mean mhwint_var mhwint_cum repmat(i,size(mhwstart,1),1) repmat(j,size(mhwstart,1),1)]];
                            
                        end
                    end
                end
                
                
                
                
                mhwstart=[];
                mhwend=[];
                mduration=[];
                mhwint_max=[];
                mhwint_mean=[];
                mhwint_var=[];
                mhwint_cum=[];
            end
        end
end

MHW=table(MHW(:,1),MHW(:,2),MHW(:,3),MHW(:,4),MHW(:,5),MHW(:,6),MHW(:,7),MHW(:,8),MHW(:,9),...
    'variablenames',{'mhw_onset','mhw_end','mhw_dur','int_max','int_mean','int_var','int_cum','xloc','yloc'});
