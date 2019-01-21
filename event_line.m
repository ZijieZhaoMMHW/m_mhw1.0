function event_line(temp,MHW,mclim,m90,loc,data_start,date_start,date_end,varargin)
%event_line - visualizing a MHW/MCS time series
%  Syntax
%  event_line(temp,MHW,mclim,m90,loc,data_start,date_start,date_end)
%  event_line(temp,MHW,mclim,m90,loc,data_start,date_start,date_end,'Event','MCS')
%  
%  Description
%  event_line(temp,MHW,mclim,m90,loc,data_start,date_start,date_end)
%  creates a graph to show the MHW time series in grid LOC based on raw
%  temperature (TEMP starting in year DATA_START), climatology (MCLIM) 
%  and threshold (M90), during DATE_START to DATE_END.
%
%  event_line(temp,MHW,mclim,m90,loc,data_start,date_start,date_end,'Event',MCS','Color',[0.5 0.5 1])
%  creates a graph to show the MCS time series. 
%
%  Input Arguments
% 
%   temp - 3D daily temperature to detect MHW/MCS events, specified as a
%   m-by-n-by-t matrix. m and n separately indicate two spatial dimensions
%   and t indicates temporal dimension.
%   
%   MHW, mclim, m90 - Outputs from function detect
%
%   loc - A vector containing two numeric value indicating the grid of
%   MHW/MCS in TEMP.
%
%   data_start - A numeric value indicating the start year of TEMP.
%
%   date_start - A vector indicating the starting date of graph.
%   
%   date_end - A vector indicating the end date of graph. 
%   
%   'Event' - Default is 'MHW'.
%           - 'MHW' - plotting for MHW events.
%           - 'MCS' - plotting for MCS events.
% 
%   'Color' - Default is [1 0.5 0.5]. Line color, specified as an RGB
%   triplet.
%
%   'Alpha' - Default is 0.5. The transparency of color lump.
%
%   'LineWidth' - Default is 2. The line width of time series.
%
%   'Fontsize' - Default is 16. The size of font in plot.

paramNames = {'Event','Color','Alpha','LineWidth','FontSize'};
defaults   = {'MHW',[1 0.5 0.5],0.5,2,16};

[vEvent, vColor,vAlpha,vLineWidth,vFontSize]...
    = internal.stats.parseArgs(paramNames, defaults, varargin{:});

EventNames = {'MHW','MCS'};
vEvent = internal.stats.getParamVal(vEvent,EventNames,...
    '''Event''');


temp_here=squeeze(temp(loc(1),loc(2),:));

MHW=MHW{:,:};
MHW=MHW(MHW(:,8)==loc(1) & MHW(:,9)==loc(2),:);
period_plot=datenum(data_start,1,1):1:(datenum(data_start,1,1)+size(temp,3)-1);
period_mhw=[datenum(num2str(MHW(:,1)),'yyyymmdd') datenum(num2str(MHW(:,2)),'yyyymmdd')];

period_plot_v=datevec(period_plot);
period_unique=datevec(datenum(2016,1,1):datenum(2016,12,31));

[~,loc_plot]=ismember(period_plot_v(:,2:3),period_unique(:,2:3),'rows');

mclim_plot=squeeze(mclim(loc(1),loc(2),loc_plot));
m90_plot=squeeze(m90(loc(1),loc(2),loc_plot));

h1=plot(period_plot,mclim_plot,'b','linewidth',vLineWidth);
hold on
h2=plot(period_plot,m90_plot,'g','linewidth',vLineWidth);
hold on
h3=plot(period_plot,temp_here,'k','linewidth',vLineWidth);
hold on

switch vEvent
    case 'MHW'
        
        for i=1:size(MHW,1)
            MHW_here=period_mhw(i,:);
            x1=(MHW_here(1):MHW_here(2))';
            y1=m90_plot(x1-datenum(data_start,1,1)+1);
            
            x2=x1(end:-1:1);
            y2=(temp_here(x2-datenum(data_start,1,1)+1));
            
            x_here=[x1(:);x2(:)];
            y_here=[y1(:);y2(:)];
            hold on
            h4=fill(x_here,y_here,vColor,'linestyle','none','FaceAlpha',vAlpha);
            hold on
        end
        
    case 'MCS'
        
        for i=1:size(MHW,1)
            MHW_here=period_mhw(i,:);
            x1=(MHW_here(1):MHW_here(2))';
            y1=temp_here(x1-datenum(data_start,1,1)+1);
            
            x2=x1(end:-1:1);
            y2=(m90_plot(x2-datenum(data_start,1,1)+1));
            
            x_here=[x1(:);x2(:)];
            y_here=[y1(:);y2(:)];
            hold on
            h4=fill(x_here,y_here,vColor,'linestyle','none','FaceAlpha',vAlpha);
            hold on
        end
        
end
        

xlim([datenum(date_start) datenum(date_end)]);

legend([h1 h2 h3 h4],{'Climatology','Threshold','Temp','Event'},'location','best','fontsize',12);

ylabel('^{o}C','fontsize',16);

set(gca,'fontsize',vFontSize);

grid on
    
datetick('x','dd/mm/yy','keeplimits','keepticks');



