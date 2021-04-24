function varargout = Extraction(varargin)
% EXTRACTION MATLAB code for Extraction.fig
%      EXTRACTION, by itself, creates a new EXTRACTION or raises the existing
%      singleton*.
%
%      H = EXTRACTION returns the handle to a new EXTRACTION or the handle to
%      the existing singleton*.
%
%      EXTRACTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXTRACTION.M with the given input arguments.
%
%      EXTRACTION('Property','Value',...) creates a new EXTRACTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Extraction_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Extraction_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Extraction

% Last Modified by GUIDE v2.5 31-Mar-2021 14:55:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Extraction_OpeningFcn, ...
                   'gui_OutputFcn',  @Extraction_OutputFcn, ...
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


% --- Executes just before Extraction is made visible.
function Extraction_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Extraction (see VARARGIN)

% Choose default command line output for Extraction
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Extraction wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Extraction_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%untuk ekstraksi

if isfield(handles, 'fullpathname')
%Membagi sinyal audio ke dalam frame
f_d = 0.00144; %durasi per frame
Fs = handles.Fs;
X = handles.X;
f_size = round(f_d * Fs); % sample per frame
n = length(X);
n_f = floor(n/f_size);  %jumlah frame
temp = 0;
for i = 1 : n_f
   frames(i,:) = X(temp + 1 : temp + f_size);
   temp = temp + f_size;
end

%hamming window
wintype = 'hamming';
winlen = 32;
winamp = [0.5,1]*(1/winlen);


%Hitung STE di setiap frame
temp = 0;
[a, b] = size(frames);
for i = 1 : a
   energy_frames(i,:) = energy(frames(i,:),wintype,winamp(2),winlen);
   temp = temp + f_size;   
end
ste = sum(energy_frames.');
ste = ste';

%Hitung nilai ZCC di setiap frame
temp = 0;
for i = 1 : a
   zcc_frames(i,:) = zerocross(frames(1,:),wintype,winamp(1),winlen);
   temp = temp + f_size;   
end
zc = sum(zcc_frames.');
zc = zc';

%Menentukan voiced frames
%Menentukan unvoiced frames
ste_batas = max(ste)/2; %Tracehold ditentukan
zcc_batas = max(zc)/1; %Tracehold ditentukan
temp1 = 1;
temp2 = 1;
ste_index = []; %menyediakan ruang kosong
voice_frame = [];
unvoice_frame = [];
for i = 1 : length(ste)
    if ste(i) >= ste_batas
        if zc(i) <= zcc_batas            
            ste_index (i,1) = 1;          
            voice_frame(temp1,:) = frames(i,:);
            temp1 = temp1 + 1;          
        end
    else
        ste_index(i,1) = 0;
        unvoice_frame(temp2, :) = frames(i,:);
        temp2 = temp2 + 1;        
    end    
end




% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%persiapan file audio
[filename, pathname] = uigetfile({'*.wav'});
fullpathname = fullfile (pathname, filename);
[X, Fs] = audioread(fullpathname);  %Fs adalah sampling

%check apakah user menekan cancel pada dialog
if isequal(filename,0) || isequal(pathname,0)
uiwait(msgbox ('User menekan Cancel','failed','modal') )
hold on;
else
uiwait(msgbox('Audio sudah dipilih','sucess','modal'));
hold off;
        X = X (:,1)
        N = length(X);
        t = (0:N-1)/Fs; 

         %plot
         axes(handles.axes6);
         plot(t,X)
         grid on
         xlabel('Time (s)')
         ylabel('Amplitudo')
end
handles.output = hObject;
handles.fullpathname = fullpathname;
handles.Fs = Fs;
handles.X = X;
guidata(hObject, handles);
%------------------------------------------------------------------------------------------------%
