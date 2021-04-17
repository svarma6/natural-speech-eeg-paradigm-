%this script will take clear stories and add babble to generate
%noisy ones

clear all
format compact

cd('/Users/soniavarma/Desktop/optlis_sv/experiment files')
addpath(genpath('matlab'))
version = 9;

 rng(version*100)
%  fname   = 'stories\TheMoth_JackMarmostien_DasketballwithDack.mp3';
fname= 'story/fn02a_A_Trial1_final.wav'
%  rng(version*200)
% fname   = 'stories\TheMoth_OmarQureshi_NachoChallenge.mp3';

%parameters 
RMS    = -28;                % SNR for normalization
SNR    = 3;                  % SNR for mixing 

%find babble
fbabble = dir(['babble' filesep '*.wav']); % each file is 5 long, but there are rise and falls

%load clear story
[s Sf] = audioread(fname);
if size(s,2) == length(s), s = s'; end
s   = s(:,1);
dur = length(s)/Sf;
t   = 0:1/Sf:dur-1/Sf;

%write wavefile with clear story 
audiowrite([fname(1:end-4) '_C' '.wav'], s, Sf);

%get babble
n = [];
while length(n) < length(s)
	ixr   = round(rand(1)*(length(fbabble)-1)+1);
	tmpB  = audioread(['babble' filesep fbabble(ixr).name]);
	nsamp = round(0.5*Sf);
	n     = [n; tmpB(nsamp:end-nsamp)];
end
n = n(1:length(s));
%babble is now as long as the story 

% normalize to same RMS
s = wav_normalize(s, RMS, 'r');
n = wav_normalize(n, RMS, 'r');

noise = n / norm(n) * norm(s) / 10.0^(0.05*SNR);
sn = s + noise;

%write wav file with noisy story
audiowrite([fname(1:end-4) '_N' '.wav'], sn, Sf);

