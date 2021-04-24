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
%Browse Audio%
function Browse_Audio(hObject, eventdata, handles)
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

%------------------------------------------------------------------------------------------------%
%Browse Watermark1%
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
%Browse Watermark2%
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
%Fungsi Emmbedding watermark ke audio%
function Embed(hObject, eventdata, handles)
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


%persiapan watermark
watermark1 = handles.watermark1;
watermark2 = handles.watermark2;

Gambar = [watermark1 watermark2]; %gambar dimasukkan ke dalam array
ste_index;
voice_frame2 = [];  
for j = 0 : length(Gambar)/16
    for i = 1 : length(voice_frame(:,1))    
        x = voice_frame(i,1:16);        
        y = Gambar (1+j*16 : 16*(j+1));
%------------------------------------------------------------------------------------------------------------------------------
        [Sn,Un,Vn] = embeed_function(x,y);  %Fungsi DCT dan SVD dari file Embeed Function
        
        %koresponden_Un = koleksi Un   
        U = reshape(Un.',1,[]);     % Reshape digunakan untuk mengubah ukuran matriks
        koresponden_Un(i,17:32) = U;    % untuk ekstraksi, U dan V digunakan untuk ekstraksi
         
        %koresponden_Vn = Koleksi Vn
        V = reshape(Vn.',1,[]);
        koresponden_Vn(i,17:32) = V;
%---------------------------------------------------------------------------------------------------------------------------  
        voice_frame2(i,1:16) = Sn; 
        j = j+1;
        x = voice_frame(i,17:32);        
        y = Gambar (1+j*16 : 16*(j+1));        
        [Sn,Un,Vn] = embeed_function(x,y);        
        voice_frame2(i,17:32) = Sn;
        
        %koresponden_Un = koleksi Un   
        U = reshape(Un.',1,[]);
        koresponden_Un(i,17:32) = U;
        
        %koresponden_Vn = Koleksi Vn
        V = reshape(Vn.',1,[]);
        koresponden_Vn(i,17:32) = V;
    end
end

%---------------------------------------------------------------------------------------------------------------------------  
%menggabungkan voiced dan unvoiced frames menjadi audio_join
audio_join = [];    %di audio join inilah voiced dan unvoiced digabungkan
temp1 = 1;
temp2 = 1;
for i = 1 : length(frames)    
    if ste_index(i) == 1
        audio_join(i, :) = voice_frame2(temp1, :);
        temp1 = temp1 + 1;        
    else 
        audio_join(i, :) = unvoice_frame(temp2, :);
        temp2 = temp2 + 1;
    end
end

frames_baru = reshape(frames.',1,[]);
audiojoin_baru = reshape(audio_join.',1,[]);


%--------------------------------------------------------------------------------------------------------------------------- 
%membuat audio baru(audiowrite)  
%audiowrite('original.wav', frames_baru, fs); untuk membuat file audio original
audiowrite('audio-berwatermark.wav', audiojoin_baru, Fs);   %membuat audio berwatermark

 %plot audio berwatermark
         axes(handles.axes9);
         plot(audiojoin_baru);
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
    % jika tidak ada file ya    ng disimpan maka akan kembali
    return
end
%------------------------------------------------------------------------------------------------%


%------------------------------------------------------------------------------------------------%
function Back_Menu(hObject, eventdata, handles)
strGui4 = ('E:\KULIAH\semester6\TA 2\Code_TA-02\Home.fig'); %Lokasi GUI
open (strGui4);
closereq;
%------------------------------------------------------------------------------------------------%