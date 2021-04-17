clear all; clc
format compact
fs = filesep;

cd('C:\bherrmann\EngEEG')
addpath(genpath('matlab'))

subjID  = 'ee26a'; % Code is all good VI
startbl = 1;

%% experiment1
run_experiment_EEG(subjID, startbl) 


%% resting EYES OPEN for 6 min
 
run_rest_experiment()          

 
 