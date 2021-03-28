function varargout = Embedding(varargin)
% EMBEDDING MATLAB code for Embedding.fig
%      EMBEDDING, by itself, creates a new EMBEDDING or raises the existing
%      singleton*.
%
%      H = EMBEDDING returns the handle to a new EMBEDDING or the handle to
%      the existing singleton*.
%
%      EMBEDDING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EMBEDDING.M with the given input arguments.
%
%      EMBEDDING('Property','Value',...) creates a new EMBEDDING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Embedding_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Embedding_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Embedding

% Last Modified by GUIDE v2.5 28-Mar-2021 16:53:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Embedding_OpeningFcn, ...
                   'gui_OutputFcn',  @Embedding_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Embedding is made visible.
function Embedding_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Embedding (see VARARGIN)

% Choose default command line output for Embedding
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Embedding wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Embedding_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% --- Executes on button press in pushbutton1.

%------------------------------------------------------------------------------------------------%
function Browse_Audio(hObject, eventdata, handles)
%persiapan file audio
[filename, pathname] = uigetfile({'*.wav'}, 'Pilih File');
fullpathname = fullfile (pathname, filename);
[x, fs] = audioread(fullpathname);

%check apakah user menekan cancel pada dialog
if isequal(filename,0) || isequal(pathname,0)
uiwait(msgbox ('User menekan Cancel','failed','modal') )
hold on;
else
uiwait(msgbox('Audio sudah dipilih','sucess','modal'));
hold off;
        x = x (:,1)
        N = length(x);
        t = (0:N-1)/fs; 

         %plot
         axes(handles.axes6);
         plot(t,x)
         grid on
         xlabel('Time (s)')
         ylabel('Amplitudo')
end
handles.output = hObject;
handles.fullpathname = fullpathname;
handles.x = x;
guidata(hObject, handles);
%------------------------------------------------------------------------------------------------%

%------------------------------------------------------------------------------------------------%
function Browse_Watermark1(hObject, eventdata, handles)
global watermark1;
[a, b] = uigetfile({'*.png'});
watermark1 = strcat(b, a);
watermark1 = imread(watermark1);
axes(handles.axes2);
imshow(watermark1);

handles.watermark1 = watermark1;
guidata(hObject, handles);
%------------------------------------------------------------------------------------------------%


%------------------------------------------------------------------------------------------------%
function Browse_Watermark2(hObject, eventdata, handles)
global watermark2;
[c, d] = uigetfile({'*.png'});
watermark2 = strcat(d, c);
watermark2 = imread(watermark2);
axes(handles.axes7);
imshow(watermark2);

handles.watermark2 = watermark2;
guidata(hObject, handles);


%------------------------------------------------------------------------------------------------%
function Embed(hObject, eventdata, handles)
if isfield(handles, 'fullpathname')
 %hamming window
sr =  44100; %sampling rate
w = 512; %window size
T = w/sr; %period
% t is an array of times at which the hamming function is evaluated
t = linspace(0, 1, 44100);
twindow = t(1:3000);
hamming = 0.54 - 0.46 * cos((2 * pi * twindow)/T);
axes(handles.axes9);
plot(hamming);    
end
%------------------------------------------------------------------------------------------------%


%------------------------------------------------------------------------------------------------%.
function Save_Audio(hObject, eventdata, handles)
% menampilkan menu save file
[filename, pathname] = uiputfile('*.wav');
% jika ada file yang disimpan maka akan mengeksekusi:
if ~isequal(filename,0)
    % membaca variabel Fs
    Fs = handles.Fs;
    audiowatermarked = handles.audiowatermarked;
    % menyimpan file sinyal suara
    audiowrite(fullfile(pathname,filename),audiowatermarked,Fs)
else
    % jika tidak ada file yang disimpan maka akan kembali
    return
end
%------------------------------------------------------------------------------------------------%


%------------------------------------------------------------------------------------------------%
function Back_Menu(hObject, eventdata, handles)
strGui4 = ('E:\KULIAH\semester6\TA 2\Code_TA-02\Home.fig'); %Lokasi GUI
open (strGui4);
closereq;
%------------------------------------------------------------------------------------------------%