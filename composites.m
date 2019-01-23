function c=composites(d,time,index)
%composites - Calculating composites for a particular dataset across a
%particular index
%  Syntax
%
%  c=composites(d,time,index)
%
%  Description
%
%  c=composites(d,time,index) returns a matrix C containing the calculated
%  composites in each grid of D.
%
%  Input Arguments
%   d - A 3D numeric matrix in size of m-by-n-by-t, where m and n
%   correspond to spatial position and t correspond to temporal record.
%
%   time - A numeric vector indicating the time corresponding to D in the
%   format of datenum().
%   
%   index - A numeric vector corresponding to a
%   set of time for which you would like to calculate composites
%   in the format of datenum().
%
%  Output Arguments
%   c - A numeric matrix in size of m-by-n containing the calculated
%   composites in each grid. 

event_index=NaN(size(d,3),1);
raw_index=index-time(1)+1;
for i=1:length(event_index)
    event_index(i)=nansum(raw_index==i)./length(raw_index);
end
c=nansum(d.*repmat(reshape(event_index,1,1,length(event_index)),120,60,1),3);


    
    