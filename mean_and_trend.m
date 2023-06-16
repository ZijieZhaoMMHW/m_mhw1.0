function [mean_metric,annual_metric,trend_metric,p_metric]=mean_and_trend(MHW,mhw_ts,data_start,varargin)
%mean_and_trend - calculating mean states and trends of event metrics
%  Syntax
%  [mean_metric,annual_metric,trend_metric,p_metric]=mean_and_trend(MHW,mhw_ts,data_start);
%  [mean_metric,annual_metric,trend_metric,p_metric]=mean_and_trend(MHW,mhw_ts,data_start,'Metric','Duration');
%  
%  Description
%  [mean_metric,annual_metric,trend_metric,p_metric]=mean_and_trend(MHW,mhw_ts,data_start)
%  returns the mean states and annual trends of MHW/MCS frequency (number
%  of events per year) based on event table MHW and MHW/MCS time series
%  MHW_TS. The start year (DATA_START) is the first year of MHW_TS.
%
%  [mean_metric,annual_metric,trend_metric,p_metric]=mean_and_trend(MHW,mhw_ts,data_start,'Metric','Duration')
%  returns the mean states and annual trends of MHW/MCS duration. 
%
%  Input Arguments
%
%   MHW, mhw_ts - Outputs from function detect
%
%   data_start - A numeric value indicating the start year of MHW_TS.
%
%   'Metric' - Default is 'Frequency'. The metric for which mean states and annual trends are
%   calculated.
%            'Frequency' - The annual number of events.
%            'Duration' - The duration of events.
%            'MaxInt' - The maximum intensity of events.
%            'MeanInt' - The mean intensity of events.
%            'CumInt' - The cumulative intensity of events.
%            'Days' - The annual total MHW/MCS days.
%
%  Output Arguments
%   
%   mean_metric - A 2D numeric matrix (m-by-n) containing the mean states
%   of MHW/MCS metrics.
%   
%   annual_metric - A 3D numeric matrix (m-by-n-by-Y) containing annual
%   mean MHW/MCS metrics, whre Y indicates the number of year based on the
%   start year DATA_START and the size of MHW_TS.
%
%   trend_metric - A 2D numeric matrix (m-by-n) containing linear trend
%   calculated from ANNUAL_METRIC in unit of 'unit of metric/year'.
%
%   p_metric - A 2D numeric matrix (m-by-n) containing p value of
%   TREND_METRIC.


paramNames = {'Metric'};
defaults   = {'Frequency'};

[vMetric]...
    = internal.stats.parseArgs(paramNames, defaults, varargin{:});

MetricNames = {'Frequency','Duration','MaxInt','MeanInt','CumInt','Days'};
vMetric = internal.stats.getParamVal(vMetric,MetricNames,...
    '''Metric''');

[x,y,~]=size(mhw_ts);
MHW=MHW{:,:};

switch vMetric
    case 'Duration'
       
        period_used=datenum(data_start,1,1):(datenum(data_start,1,1)+size(mhw_ts,3)-1);
        period_used=datevec(period_used);
        
        years_mhw=unique(period_used(:,1),'rows');
        
        mean_metric=NaN(x,y);
        trend_metric=NaN(x,y);
        p_metric=NaN(x,y);
        annual_metric=NaN(x,y,length(years_mhw));
        
        loc_u=unique(MHW(:,8:9),'rows');
        
        for i=1:size(loc_u)
            ts_here=squeeze(mhw_ts(loc_u(i,1),loc_u(i,2),:));
            bw=bwconncomp(~isnan(ts_here));
            mean_metric(loc_u(i,1),loc_u(i,2))=nanmean(cellfun(@length,bw.PixelIdxList));
            
            sd=datevec(cellfun(@nanmin,bw.PixelIdxList)-1+datenum(1982,1,1));
            ed=datevec(cellfun(@nanmax,bw.PixelIdxList)-1+datenum(1982,1,1));
            durc=cellfun(@length,bw.PixelIdxList);
            for j=years_mhw(1):years_mhw(end)
                annual_metric(loc_u(i,1),loc_u(i,2),j-years_mhw(1)+1)=nanmean(durc(sd(:,1)==j | ed(:,1)==j));
            end
            [b,bint]=regress(squeeze(annual_metric(loc_u(i,1),loc_u(i,2),:)),...
                [ones(length(years_mhw),1) (1:length(years_mhw))']);
            trend_metric(loc_u(i,1),loc_u(i,2))=b(2);
            p_metric(loc_u(i,1),loc_u(i,2))=double((bint(2,1)*bint(2,2))>=0);
        end
        
    case 'MaxInt'
        
        period_used=datenum(data_start,1,1):(datenum(data_start,1,1)+size(mhw_ts,3)-1);
        period_used=datevec(period_used);
        
        years_mhw=unique(period_used(:,1),'rows');
        
        mean_metric=nanmax(mhw_ts,[],3);
        trend_metric=NaN(x,y);
        p_metric=NaN(x,y);
        annual_metric=NaN(x,y,length(years_mhw));
        
        loc_u=unique(MHW(:,8:9),'rows');
            
        date_used=datevec(datenum(years_mhw(1),1,1):datenum(years_mhw(end),12,31));
        for i=years_mhw(1):years_mhw(end)
            index_here=date_used(:,1)==i;
            annual_metric(:,:,i-years_mhw(1)+1)=nanmax(mhw_ts(:,:,index_here),[],3);
        end
        
         for i=1:size(loc_u)
            [b,bint]=regress(squeeze(annual_metric(loc_u(i,1),loc_u(i,2),:)),...
                [ones(length(years_mhw),1) (1:length(years_mhw))']);
            trend_metric(loc_u(i,1),loc_u(i,2))=b(2);
            p_metric(loc_u(i,1),loc_u(i,2))=double((bint(2,1)*bint(2,2))>=0);
        end
        
    case 'MeanInt'
        
        period_used=datenum(data_start,1,1):(datenum(data_start,1,1)+size(mhw_ts,3)-1);
        period_used=datevec(period_used);
        
        years_mhw=unique(period_used(:,1),'rows');
        
        mean_metric=nanmean(mhw_ts,3);
        trend_metric=NaN(x,y);
        p_metric=NaN(x,y);
        annual_metric=NaN(x,y,length(years_mhw));
        
        loc_u=unique(MHW(:,8:9),'rows');
            
        date_used=datevec(datenum(years_mhw(1),1,1):datenum(years_mhw(end),12,31));
        for i=years_mhw(1):years_mhw(end)
            index_here=date_used(:,1)==i;
            annual_metric(:,:,i-years_mhw(1)+1)=nanmean(mhw_ts(:,:,index_here),3);
        end
        
         for i=1:size(loc_u)
            [b,bint]=regress(squeeze(annual_metric(loc_u(i,1),loc_u(i,2),:)),...
                [ones(length(years_mhw),1) (1:length(years_mhw))']);
            trend_metric(loc_u(i,1),loc_u(i,2))=b(2);
            p_metric(loc_u(i,1),loc_u(i,2))=double((bint(2,1)*bint(2,2))>=0);
         end
        
    case 'CumInt'
        
        period_used=datenum(data_start,1,1):(datenum(data_start,1,1)+size(mhw_ts,3)-1);
        period_used=datevec(period_used);
        
        years_mhw=unique(period_used(:,1),'rows');
        
        mean_metric=NaN(x,y);
        trend_metric=NaN(x,y);
        p_metric=NaN(x,y);
        annual_metric=NaN(x,y,length(years_mhw));
        
        loc_u=unique(MHW(:,8:9),'rows');
        
        for i=1:size(loc_u)
            ts_here=squeeze(mhw_ts(loc_u(i,1),loc_u(i,2),:));
            bw=bwconncomp(~isnan(ts_here));
            mean_metric(loc_u(i,1),loc_u(i,2))=nanmean(cellfun(@(x)nansum(ts_here(x)),bw.PixelIdxList));
            
            sd=datevec(cellfun(@nanmin,bw.PixelIdxList)-1+datenum(1982,1,1));
            ed=datevec(cellfun(@nanmax,bw.PixelIdxList)-1+datenum(1982,1,1));
            durc=cellfun(@(x)nansum(ts_here(x)),bw.PixelIdxList);
            for j=years_mhw(1):years_mhw(end)
                annual_metric(loc_u(i,1),loc_u(i,2),j-years_mhw(1)+1)=nanmean(durc(sd(:,1)==j | ed(:,1)==j));
            end
            [b,bint]=regress(squeeze(annual_metric(loc_u(i,1),loc_u(i,2),:)),...
                [ones(length(years_mhw),1) (1:length(years_mhw))']);
            trend_metric(loc_u(i,1),loc_u(i,2))=b(2);
            p_metric(loc_u(i,1),loc_u(i,2))=double((bint(2,1)*bint(2,2))>=0);
        end
        
    case 'Days'
        
        period_used=datenum(data_start,1,1):(datenum(data_start,1,1)+size(mhw_ts,3)-1);
        period_used=datevec(period_used);
        
        years_mhw=unique(period_used(:,1),'rows');
        
        mean_metric=nansum(~isnan(mhw_ts),3)./length(years_mhw);
        trend_metric=NaN(x,y);
        p_metric=NaN(x,y);
        annual_metric=NaN(x,y,length(years_mhw));
        
        loc_u=unique(MHW(:,8:9),'rows');
            
        date_used=datevec(datenum(years_mhw(1),1,1):datenum(years_mhw(end),12,31));
        for i=years_mhw(1):years_mhw(end)
            index_here=date_used(:,1)==i;
            annual_metric(:,:,i-years_mhw(1)+1)=nansum(~isnan(mhw_ts(:,:,index_here)),3);
        end
        
         for i=1:size(loc_u)
            [b,bint]=regress(squeeze(annual_metric(loc_u(i,1),loc_u(i,2),:)),...
                [ones(length(years_mhw),1) (1:length(years_mhw))']);
            trend_metric(loc_u(i,1),loc_u(i,2))=b(2);
            p_metric(loc_u(i,1),loc_u(i,2))=double((bint(2,1)*bint(2,2))>=0);
         end
        
    case 'Frequency'
        period_used=datenum(data_start,1,1):(datenum(data_start,1,1)+size(mhw_ts,3)-1);
        period_used=datevec(period_used);
        
        years_mhw=unique(period_used(:,1),'rows');
        
        mean_metric=NaN(x,y);
        trend_metric=NaN(x,y);
        p_metric=NaN(x,y);
        annual_metric=NaN(x,y,length(years_mhw));
        
        loc_u=unique(MHW(:,8:9),'rows');
        
        for i=1:size(loc_u)
            ts_here=squeeze(mhw_ts(loc_u(i,1),loc_u(i,2),:));
            bw=bwconncomp(~isnan(ts_here));
            mean_metric(loc_u(i,1),loc_u(i,2))=length(bw.PixelIdxList)./length(years_mhw);
            
            sd=datevec(cellfun(@nanmin,bw.PixelIdxList)-1+datenum(1982,1,1));
            ed=datevec(cellfun(@nanmax,bw.PixelIdxList)-1+datenum(1982,1,1));
            for j=years_mhw(1):years_mhw(end)
                annual_metric(loc_u(i,1),loc_u(i,2),j-years_mhw(1)+1)=nansum(sd(:,1)==j | ed(:,1)==j);
            end
            [b,bint]=regress(squeeze(annual_metric(loc_u(i,1),loc_u(i,2),:)),...
                [ones(length(years_mhw),1) (1:length(years_mhw))']);
            trend_metric(loc_u(i,1),loc_u(i,2))=b(2);
            p_metric(loc_u(i,1),loc_u(i,2))=double((bint(2,1)*bint(2,2))>=0);
        end
end