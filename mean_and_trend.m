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

switch vMetric
    case 'Duration'
        
        MHW=MHW{:,:};
        full_mhw_start=datevec(num2str(MHW(:,1)),'yyyymmdd');
        full_mhw_end=datevec(num2str(MHW(:,2)),'yyyymmdd');
        metric=MHW(:,3);
        
        period_used=datenum(data_start,1,1):(datenum(data_start,1,1)+size(mhw_ts,3)-1);
        period_used=datevec(period_used);
        
        years_mhw=unique(period_used(:,1),'rows');
        
        mean_metric=NaN(x,y);
        trend_metric=NaN(x,y);
        p_metric=NaN(x,y);
        annual_metric=NaN(x,y,length(years_mhw));
        
        loc_full=unique(MHW(:,8:9),'rows');
        
        for m=1:size(loc_full)
            loc_here=loc_full(m,:);
            MHW_here=MHW(MHW(:,8)==loc_here(1) & MHW(:,9)==loc_here(2),:);
            metric_here=metric(MHW(:,8)==loc_here(1) & MHW(:,9)==loc_here(2));
            
            mean_metric(loc_here(1),loc_here(2))=nanmean(metric_here);
            
            for i=1:length(years_mhw)
                year_here=years_mhw(i);
                judge_1=(datenum(num2str(MHW_here(:,1)),'yyyymmdd') >= datenum(year_here,1,1)) ...
                    & (datenum(num2str(MHW_here(:,2)),'yyyymmdd') <= datenum(year_here,12,31));
                judge_2=((full_mhw_start(MHW(:,8)==loc_here(1) & MHW(:,9)==loc_here(2),1)==year_here)) ...
                    & ...
                    ((datenum(year_here,12,31)-datenum(num2str(MHW_here(:,1)),'yyyymmdd')) >= (datenum(num2str(MHW_here(:,2)),'yyyymmdd')-datenum(year_here+1,1,1)));
                judge_3=((full_mhw_end(MHW(:,8)==loc_here(1) & MHW(:,9)==loc_here(2),1)==year_here)) ...
                    & ...
                    ((datenum(year_here-1,12,31)-datenum(num2str(MHW_here(:,1)),'yyyymmdd')) <= (datenum(num2str(MHW_here(:,2)),'yyyymmdd')-datenum(year_here,1,1)));
                metric_judge=metric_here(judge_1 | judge_2 | judge_3);
                
                if ~isempty(metric_judge)
                    metric_judge=nanmean(metric_judge);
                else
                    metric_judge=nan;
                end
                
                annual_metric(loc_here(1),loc_here(2),i)=metric_judge;
                
                
            end
            
            ts_here=squeeze(annual_metric(loc_here(1),loc_here(2),:));
            mdl=fitlm(years_mhw,ts_here);
            trend_metric(loc_here(1),loc_here(2))=mdl.Coefficients.Estimate(2);
            p_metric(loc_here(1),loc_here(2))=mdl.Coefficients.pValue(2);
        end
        
    case 'MaxInt'
        
        MHW=MHW{:,:};
        full_mhw_start=datevec(num2str(MHW(:,1)),'yyyymmdd');
        full_mhw_end=datevec(num2str(MHW(:,2)),'yyyymmdd');
        metric=MHW(:,4);
        
        period_used=datenum(data_start,1,1):(datenum(data_start,1,1)+size(mhw_ts,3)-1);
        period_used=datevec(period_used);
        
        years_mhw=unique(period_used(:,1),'rows');
        
        mean_metric=NaN(x,y);
        trend_metric=NaN(x,y);
        p_metric=NaN(x,y);
        annual_metric=NaN(x,y,length(years_mhw));
        
        loc_full=unique(MHW(:,8:9),'rows');
        
        for m=1:size(loc_full)
            loc_here=loc_full(m,:);
            MHW_here=MHW(MHW(:,8)==loc_here(1) & MHW(:,9)==loc_here(2),:);
            metric_here=metric(MHW(:,8)==loc_here(1) & MHW(:,9)==loc_here(2));
            
            mean_metric(loc_here(1),loc_here(2))=nanmean(metric_here);
            
            for i=1:length(years_mhw)
                year_here=years_mhw(i);
                judge_1=(datenum(num2str(MHW_here(:,1)),'yyyymmdd') >= datenum(year_here,1,1)) ...
                    & (datenum(num2str(MHW_here(:,2)),'yyyymmdd') <= datenum(year_here,12,31));
                judge_2=((full_mhw_start(MHW(:,8)==loc_here(1) & MHW(:,9)==loc_here(2),1)==year_here)) ...
                    & ...
                    ((datenum(year_here,12,31)-datenum(num2str(MHW_here(:,1)),'yyyymmdd')) >= (datenum(num2str(MHW_here(:,2)),'yyyymmdd')-datenum(year_here+1,1,1)));
                judge_3=((full_mhw_end(MHW(:,8)==loc_here(1) & MHW(:,9)==loc_here(2),1)==year_here)) ...
                    & ...
                    ((datenum(year_here-1,12,31)-datenum(num2str(MHW_here(:,1)),'yyyymmdd')) <= (datenum(num2str(MHW_here(:,2)),'yyyymmdd')-datenum(year_here,1,1)));
                metric_judge=metric_here(judge_1 | judge_2 | judge_3);
                
                if ~isempty(metric_judge)
                    metric_judge=nanmean(metric_judge);
                else
                    metric_judge=nan;
                end
                
                annual_metric(loc_here(1),loc_here(2),i)=metric_judge;
                
                
            end
            
            ts_here=squeeze(annual_metric(loc_here(1),loc_here(2),:));
            mdl=fitlm(years_mhw,ts_here);
            trend_metric(loc_here(1),loc_here(2))=mdl.Coefficients.Estimate(2);
            p_metric(loc_here(1),loc_here(2))=mdl.Coefficients.pValue(2);
        end
        
    case 'MeanInt'
        
        MHW=MHW{:,:};
        full_mhw_start=datevec(num2str(MHW(:,1)),'yyyymmdd');
        full_mhw_end=datevec(num2str(MHW(:,2)),'yyyymmdd');
        metric=MHW(:,5);
        
        period_used=datenum(data_start,1,1):(datenum(data_start,1,1)+size(mhw_ts,3)-1);
        period_used=datevec(period_used);
        
        years_mhw=unique(period_used(:,1),'rows');
        
        mean_metric=NaN(x,y);
        trend_metric=NaN(x,y);
        p_metric=NaN(x,y);
        annual_metric=NaN(x,y,length(years_mhw));
        
        loc_full=unique(MHW(:,8:9),'rows');
        
        for m=1:size(loc_full)
            loc_here=loc_full(m,:);
            MHW_here=MHW(MHW(:,8)==loc_here(1) & MHW(:,9)==loc_here(2),:);
            metric_here=metric(MHW(:,8)==loc_here(1) & MHW(:,9)==loc_here(2));
            
            mean_metric(loc_here(1),loc_here(2))=nanmean(metric_here);
            
            for i=1:length(years_mhw)
                year_here=years_mhw(i);
                judge_1=(datenum(num2str(MHW_here(:,1)),'yyyymmdd') >= datenum(year_here,1,1)) ...
                    & (datenum(num2str(MHW_here(:,2)),'yyyymmdd') <= datenum(year_here,12,31));
                judge_2=((full_mhw_start(MHW(:,8)==loc_here(1) & MHW(:,9)==loc_here(2),1)==year_here)) ...
                    & ...
                    ((datenum(year_here,12,31)-datenum(num2str(MHW_here(:,1)),'yyyymmdd')) >= (datenum(num2str(MHW_here(:,2)),'yyyymmdd')-datenum(year_here+1,1,1)));
                judge_3=((full_mhw_end(MHW(:,8)==loc_here(1) & MHW(:,9)==loc_here(2),1)==year_here)) ...
                    & ...
                    ((datenum(year_here-1,12,31)-datenum(num2str(MHW_here(:,1)),'yyyymmdd')) <= (datenum(num2str(MHW_here(:,2)),'yyyymmdd')-datenum(year_here,1,1)));
                metric_judge=metric_here(judge_1 | judge_2 | judge_3);
                
                if ~isempty(metric_judge)
                    metric_judge=nanmean(metric_judge);
                else
                    metric_judge=nan;
                end
                
                annual_metric(loc_here(1),loc_here(2),i)=metric_judge;
                
                
            end
            
            ts_here=squeeze(annual_metric(loc_here(1),loc_here(2),:));
            mdl=fitlm(years_mhw,ts_here);
            trend_metric(loc_here(1),loc_here(2))=mdl.Coefficients.Estimate(2);
            p_metric(loc_here(1),loc_here(2))=mdl.Coefficients.pValue(2);
        end
        
        
    case 'CumInt'
        
        MHW=MHW{:,:};
        full_mhw_start=datevec(num2str(MHW(:,1)),'yyyymmdd');
        full_mhw_end=datevec(num2str(MHW(:,2)),'yyyymmdd');
        metric=MHW(:,7);
        
        period_used=datenum(data_start,1,1):(datenum(data_start,1,1)+size(mhw_ts,3)-1);
        period_used=datevec(period_used);
        
        years_mhw=unique(period_used(:,1),'rows');
        
        mean_metric=NaN(x,y);
        trend_metric=NaN(x,y);
        p_metric=NaN(x,y);
        annual_metric=NaN(x,y,length(years_mhw));
        
        loc_full=unique(MHW(:,8:9),'rows');
        
        for m=1:size(loc_full)
            loc_here=loc_full(m,:);
            MHW_here=MHW(MHW(:,8)==loc_here(1) & MHW(:,9)==loc_here(2),:);
            metric_here=metric(MHW(:,8)==loc_here(1) & MHW(:,9)==loc_here(2));
            
            mean_metric(loc_here(1),loc_here(2))=nanmean(metric_here);
            
            for i=1:length(years_mhw)
                year_here=years_mhw(i);
                judge_1=(datenum(num2str(MHW_here(:,1)),'yyyymmdd') >= datenum(year_here,1,1)) ...
                    & (datenum(num2str(MHW_here(:,2)),'yyyymmdd') <= datenum(year_here,12,31));
                judge_2=((full_mhw_start(MHW(:,8)==loc_here(1) & MHW(:,9)==loc_here(2),1)==year_here)) ...
                    & ...
                    ((datenum(year_here,12,31)-datenum(num2str(MHW_here(:,1)),'yyyymmdd')) >= (datenum(num2str(MHW_here(:,2)),'yyyymmdd')-datenum(year_here+1,1,1)));
                judge_3=((full_mhw_end(MHW(:,8)==loc_here(1) & MHW(:,9)==loc_here(2),1)==year_here)) ...
                    & ...
                    ((datenum(year_here-1,12,31)-datenum(num2str(MHW_here(:,1)),'yyyymmdd')) <= (datenum(num2str(MHW_here(:,2)),'yyyymmdd')-datenum(year_here,1,1)));
                metric_judge=metric_here(judge_1 | judge_2 | judge_3);
                
                if ~isempty(metric_judge)
                    metric_judge=nanmean(metric_judge);
                else
                    metric_judge=nan;
                end
                
                annual_metric(loc_here(1),loc_here(2),i)=metric_judge;
                
                
            end
            
            ts_here=squeeze(annual_metric(loc_here(1),loc_here(2),:));
            mdl=fitlm(years_mhw,ts_here);
            trend_metric(loc_here(1),loc_here(2))=mdl.Coefficients.Estimate(2);
            p_metric(loc_here(1),loc_here(2))=mdl.Coefficients.pValue(2);
        end
        
        
        
    case 'Days'
        
        MHW=MHW{:,:};
        
        period_used=datenum(data_start,1,1):(datenum(data_start,1,1)+size(mhw_ts,3)-1);
        period_used=datevec(period_used);
        
        years_mhw=unique(period_used(:,1),'rows');
        
        land_loc=(nansum(isnan(mhw_ts),3)==size(mhw_ts,3));
        
        mean_metric=nansum(mhw_ts~=0 & ~isnan(mhw_ts),3)./length(years_mhw);
        mean_metric(land_loc)=nan;
        
        trend_metric=NaN(x,y);
        p_metric=NaN(x,y);
        annual_metric=NaN(x,y,length(years_mhw));
        
        loc_full=unique(MHW(:,8:9),'rows');
        
        for m=1:size(loc_full)
            loc_here=loc_full(m,:);
            
            for i=1:length(years_mhw)
                year_here=years_mhw(i);
                mhw_here=squeeze(mhw_ts(loc_here(1),loc_here(2),(datenum(year_here,1,1):datenum(year_here,12,31))-datenum(data_start,1,1)+1));
                annual_metric(loc_here(1),loc_here(2),i)=nansum(mhw_here~=0 & ~isnan(mhw_here));
                
                
            end
            
            ts_here=squeeze(annual_metric(loc_here(1),loc_here(2),:));
            mdl=fitlm(years_mhw,ts_here);
            trend_metric(loc_here(1),loc_here(2))=mdl.Coefficients.Estimate(2);
            p_metric(loc_here(1),loc_here(2))=mdl.Coefficients.pValue(2);
        end
        
        
        
        
    case 'Frequency'
        
        
        
        MHW=MHW{:,:};
        full_mhw_start=datevec(num2str(MHW(:,1)),'yyyymmdd');
        full_mhw_end=datevec(num2str(MHW(:,2)),'yyyymmdd');
        
        period_used=datenum(data_start,1,1):(datenum(data_start,1,1)+size(mhw_ts,3)-1);
        period_used=datevec(period_used);
        
        years_mhw=unique(period_used(:,1),'rows');
        
        mean_metric=NaN(x,y);
        trend_metric=NaN(x,y);
        p_metric=NaN(x,y);
        annual_metric=NaN(x,y,length(years_mhw));
        
        loc_full=unique(MHW(:,8:9),'rows');
        
        for m=1:size(loc_full)
            loc_here=loc_full(m,:);
            MHW_here=MHW(MHW(:,8)==loc_here(1) & MHW(:,9)==loc_here(2),:);
            
            mean_metric(loc_here(1),loc_here(2))=(size(MHW_here,1)./length(years_mhw));
            
            for i=1:length(years_mhw)
                year_here=years_mhw(i);
                judge_1=(datenum(num2str(MHW_here(:,1)),'yyyymmdd') >= datenum(year_here,1,1)) ...
                    & (datenum(num2str(MHW_here(:,2)),'yyyymmdd') <= datenum(year_here,12,31));
                judge_2=((full_mhw_start(MHW(:,8)==loc_here(1) & MHW(:,9)==loc_here(2),1)==year_here)) ...
                    & ...
                    ((datenum(year_here,12,31)-datenum(num2str(MHW_here(:,1)),'yyyymmdd')) >= (datenum(num2str(MHW_here(:,2)),'yyyymmdd')-datenum(year_here+1,1,1)));
                judge_3=((full_mhw_end(MHW(:,8)==loc_here(1) & MHW(:,9)==loc_here(2),1)==year_here)) ...
                    & ...
                    ((datenum(year_here-1,12,31)-datenum(num2str(MHW_here(:,1)),'yyyymmdd')) <= (datenum(num2str(MHW_here(:,2)),'yyyymmdd')-datenum(year_here,1,1)));
                
                MHW_judge=MHW_here(judge_1(:) | judge_2(:) | judge_3(:),:);
                
                annual_metric(loc_here(1),loc_here(2),i)=size(MHW_judge,1);
                
                
            end
            
            ts_here=squeeze(annual_metric(loc_here(1),loc_here(2),:));
            mdl=fitlm(years_mhw,ts_here);
            trend_metric(loc_here(1),loc_here(2))=mdl.Coefficients.Estimate(2);
            p_metric(loc_here(1),loc_here(2))=mdl.Coefficients.pValue(2);
        end
        
end
        