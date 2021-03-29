function En = energy(x,wintype,winamp,winlen)

error(nargchk(1,4,nargin,'struct'));

win = (winamp*(window(str2func(wintype),winlen))).';

% enery calculation
x2 = x.^2;
En = winconv(x2,wintype,win,winlen);