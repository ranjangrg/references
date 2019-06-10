# GNU Octave Cheat Sheet
## Read audio files and write to CSV File
```matlab
[y,fs] = audioread("C:\\sound.flac");	% reads sound.flac from C: ... // is to use / symbol
csvwrite("C:\\samples.csv", y);		% create a basic CSV file in C:
```
	
## Create soundfile (e.g. ogg file)
```matlab
filename='cosine.ogg';
fs=44100;				% Frequency (Samples Hz)
t=0:1/fs:10;				% 1/fs is the increment; 0, 1/fs, 2/fs, ... , 10
w=2*pi*440*t;				% w = Omega i.e. 2.pi.f.t
signal=cos(w);				% Convert that to a cosine wave signal
audiowrite(filename, signal, fs);	% Write to file 
```
	
## Read and plot Images
```matlab
I = rand (100, 100); 		% creates a random list of values
OR
I = imread('C:\Images\Image.png')
[row, col] = find (I > 0.99);	% red circles on points where intensity is above 0.99
hold ("on");
imshow (I);
plot (col, row, "ro");		% red circles on points where intensity is above 0.99
hold ("off");
```

## Read CSV files
```matlab
data = csvread('filepath/fileName');
firstCol = data(:, 1);
secondCol = data(:, 2);
% ... etc ...
% (if only one column in the csv, 'data' variable is an 1D-Array)
```
