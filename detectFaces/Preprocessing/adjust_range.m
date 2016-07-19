% The function adjusts the dynamic range of the grey scale image to a new
% user-defined interval given by "interval".

% Adapted from:
% Copyright (c) 2011 Vitomir Štruc
% Faculty of Electrical Engineering,
% University of Ljubljana, Slovenia
% http://luks.fe.uni-lj.si/en/staff/vitomir/index.html

function Y=adjust_range(X,interval);

%% default return value
Y=[];

%% Parameter check
if nargin==1
    interval = [0; 255];
elseif nargin == 2
    if length(interval)~= 2
       disp('Error: The argument interval must be a two-component vector.')
       return;
    end
    
    if(interval(1)>interval(2))
        disp('Error: The argument "interval" does not specify a valid interval.');
        return;
    end
else
   disp('Error: The function takes at most two arguments.');
   return;
end

%% Init. operations
X=double(X);
[a,b]=size(X);
min_new = interval(1);
max_new = interval(2);

%% Adjust the dynamic range 
max_old = max(max(X));
min_old = min(min(X));

Y = ((max_new - min_new)/(max_old-min_old))*(X-min_old)+min_new;


