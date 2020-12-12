function varargout = EEG(varargin)
% EEG MATLAB code for EEG.fig
%      EEG, by itself, creates a new EEG or raises the existing
%      singleton*.
%
%      H = EEG returns the handle to a new EEG or the handle to
%      the existing singleton*.
%
%      EEG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EEG.M with the given input arguments.
%
%      EEG('Property','Value',...) creates a new EEG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EEG_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EEG_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EEG

% Last Modified by GUIDE v2.5 06-Dec-2020 11:31:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EEG_OpeningFcn, ...
                   'gui_OutputFcn',  @EEG_OutputFcn, ...
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


% --- Executes just before EEG is made visible.
function EEG_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EEG (see VARARGIN)

% Choose default command line output for EEG
handles.output = hObject;


global fs;
fs=512;
global N;
N=4;
global raw;
global time;
time = 0:1/fs:(length(raw)-1)*1/fs;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes EEG wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = EEG_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.

function pushbutton1_Callback(hObject, eventdata, handles)
global raw;
[filename,filepath]=uigetfile({'*.xlsx'});
fullpath=strcat(filepath,filename);
set(handles.edit1,'string',fullpath);
%Loading data from excel to matlab

raw=xlsread(fullpath);

%number of samples condisered for analysis
N=1000;
%Sampling Rate in Hz
global fs;
%time vector, useful for plotting CT signals
t=linspace(0,N/fs,N);

%creating Blank dataset that will be filled later
global EEG;
EEG = zeros(1000,1);

%4th order filters are used
order = 4;

figure('Name',"RAW EEG Waveforms");
subplot(2,1,1);
stem(raw);
title("DT representation of EEG");
subplot(2,1,2);
plot(t,raw);
title("CT representation of EEG");

% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton1.
function pushbutton1_ButtonDownFcn(hObject, eventdata, handles)

% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
global raw;
global fs;
%Max freq compoment of signal is generally 0.5*fs Hz
frequencyLimits = [0 fs/2];

% Filtering Noise from EEG
temp = bandstop(raw,[49.5,50.5],fs,'Steepness',0.85,'StopbandAttenuation',60);
EEG = highpass(temp,0.5,fs,'Steepness',0.95,'StopbandAttenuation',60);

%Computing Power Spectrums of EEG
[P,F] = pspectrum(EEG,fs,'FrequencyLimits',frequencyLimits);
[NP,NF] = pspectrum(raw,fs,'FrequencyLimits',frequencyLimits);

figure('Name',"EEG Spectrums Waveforms");
subplot(2,1,1);
plot(NF,NP);
title("Noisy/Raw EEG Spectrum");
xlabel("Frequency (Hz)");
ylabel("Power (mV^2)");
axis([-10,fs/2,0,5]);

subplot(2,1,2);
plot(F,P);
hold on;
title("Filtered EEG Spectrum (Orange color shows rejected components)");
xlabel("Frequency (Hz)");
ylabel("Power (mV^2)");
axis([-10,fs/2,0,5]);
plot(NF,(NP-P));
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton2.
function pushbutton2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
global raw;
global fs;
global N;
global time;
figure('Name','Delta Waves');

W1 = 1.5/fs % change this to be initial frequency
W2 = 5/fs % change this to final frequency
Wn_t = [W1 W2];
[c,d] = butter(N,Wn_t);
delta= filter(c,d,raw); % where deg is you eeg data
%figure
plot(time, delta);
xlabel('Time(s)');
ylabel('Amplitude');
title('Delta Waves');
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton3.
function pushbutton3_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton4.
function pushbutton5_Callback(hObject, eventdata, handles)
global time;
global raw;
global fs;
global N;
figure('Name','Theta Waves');
W1 = 5/fs % change this to be initial frequency
W2 = 9/fs % change this to final frequency
Wn_t = [W1 W2];
[c,d] = butter(N,Wn_t);
Theta = filter(c,d,raw); % where deg is you eeg data
%figure
plot(time, Theta);
xlabel('Time(s)');
ylabel('Amplitude');
title('Theta Waves');
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton5.
function pushbutton4_Callback(hObject, eventdata, handles)
global time;
global raw;
global fs;
global N;
figure('Name','Alpha Waves');
W1 = 9/fs % change this to be initial frequency
W2 = 13/fs % change this to final frequency
Wn_t = [W1 W2];
[c,d] = butter(N,Wn_t);
Alpha = filter(c,d,raw); % where deg is you eeg data
%figure
plot(time, Alpha);
xlabel('Time(s)');
ylabel('Amplitude');
title('Alpha Waves');
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
global time;
global raw;
global fs;
global N;
figure('Name','Beta Waves');
W1 = 13/fs % change this to be initial frequency
W2 = 31/fs % change this to final frequency
Wn_t = [W1 W2];
[c,d] = butter(N,Wn_t);
beta = filter(c,d,raw); % where deg is you eeg data
%figure
plot(time,beta);
xlabel('Time(s)');
ylabel('Amplitude');
title('Beta Waves');
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
global time;
global raw;
global fs;
global N;
figure('Name','Gamma Waves');
W1 = 31/fs % change this to be initial frequency
W2 = 100/fs % change this to final frequency
Wn_t = [W1 W2];
[c,d] = butter(N,Wn_t);
beta = filter(c,d,raw); % where deg is you eeg data
%figure
plot(time,beta);
xlabel('Time(s)');
ylabel('Amplitude');
title('Gamma Waves');

% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)

clear;
close;
clc;
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton4.
function pushbutton4_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton5.
function pushbutton5_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton6.
function pushbutton6_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton7.
function pushbutton7_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton8.
function pushbutton8_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
