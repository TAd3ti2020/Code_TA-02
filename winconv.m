function y = winconv(x,varargin)

error(nargchk(1,4,nargin,'struct'));

len = length(varargin);
switch len
    case 0
        wintype = 'rectwin';
        A = 1;
        L = length(x);
    case 1
        if ischar(varargin{1})
            wintype = lower(varargin{1});
            A = 1;
            L = length(x);
        end
    case 2
        if ischar(varargin{1}) && isreal(varargin{2})
            wintype = lower(varargin{1});
            A = varargin{2};
            L = length(x);
        end
    case 3
        if ischar(varargin{1}) && isreal(varargin{2}) &&...
                isreal(varargin{3})
            wintype = lower(varargin{1});
            A = varargin{2};
            L = varargin{3};
        end
end

% generate the window
w1 = (window(str2func(wintype),L)).'; A = A(:).';
w = A.*w1;

% perform the convolution using FFT
NFFT = 2^(nextpow2(length(x)+L));
X = fft(x,NFFT); W = fft(w,NFFT);
Y = X.*W;
y = ifft(Y,NFFT);
    