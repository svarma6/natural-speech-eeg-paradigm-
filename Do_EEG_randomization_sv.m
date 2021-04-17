%This script will assign each subject a random sotry for the clear and
%noisy condition. 
clear all;
format compact
fs = filesep;

cd('D:\optlis_sv\experiment files')
addpath(genpath('matlab'))


stories_clear={'TheMoth_OmarQureshi_NachoChallenge_C' ...
    'TheMoth_JackMarmostien_DasketballwithDack_C'}; 
stories_noise={'TheMoth_OmarQureshi_NachoChallenge_N' ...
    'TheMoth_JackMarmostien_DasketballwithDack_N'}; 


subj = {'ol01a' 'ol02a' 'ol03a' 'ol04a' 'ol05a' 'ol06a' 'ol07a' 'ol08a' 'ol09a' 'ol10a' ...
	    'ol11a' 'ol12a' 'ol13a' 'ol14a' 'ol15a' 'ol16a' 'ol17a' 'ol18a' 'ol19a' 'ol20a' ...
		'ol21a' 'ol22a' 'ol23a' 'ol24a' 'ol25a'};
    
a=1; b=length(stories_clear);

clear_story=cell(length(subj),1);
noise_story=cell(length(subj),1);


        
%% randomize stpries based on subjects
clear_dur = zeros(length(subj));
noise_dur = zeros(length(subj));
for i= 1:length(subj)
    %randomly select a clear story
    ix= round(a+(b-a).*rand);
    clear_story{i}= stories_clear{ix};
    %get and store info for clear story
    [Clear_y Clear_Sf]   = audioread(['stories' fs clear_story{i} '.wav']);
    clear_dur(i)  = length(Clear_y)/Clear_Sf;
    [~,~,RAW] = xlsread(['quests' fs clear_story{i}(1:end-2) '.xlsx']);
    clear_options=  RAW(:,[1:3]);
    clear_answers= cell2mat(RAW(:,4));
    %store info in struct
    list.clear    = struct('story', {clear_story{i}},'dur', (clear_dur(i)), 'options', {clear_options}, 'answers', (clear_answers)); 
    %randomly select noise story
    ix2= round(a+(b-a).*rand);
    noise_story{i}= stories_noise{ix2};
    %ensure the stories aren't the same. 
    clear_double =double(clear_story{i});
    clear_double =clear_double(9:19);
    noise_double =double(noise_story{i});
    noise_double =noise_double(9:19);
    if clear_double== noise_double & ix2 < b
         ix2= ix2+1;
         %select a new noisy story
         noise_story{i}= stories_noise{ix2}; 
    elseif clear_double== noise_double & ix2 >= b
        ix2= ix2-1;
        %select a new noisy story
        noise_story{i}= stories_noise{ix2}; 
    end
    %get and store info for stories
    [Noise_y Noise_Sf]   = audioread(['stories' fs noise_story{i} '.wav']);
	noise_dur(i)  = length(Noise_y)/Noise_Sf;
    clear RAW
    [~,~,RAW] = xlsread(['quests' fs noise_story{i}(1:end-2) '.xlsx']);
    noise_options=  RAW(:,[1:3]);
    noise_answers= cell2mat(RAW(:,4));
	%store info in struct
    list.noise    = struct('story', {noise_story{i}},'dur', (noise_dur(i)), 'options', {noise_options}, 'answers', (noise_answers));
	 
    %store experience questions
	clear RAW
    [~,~,RAW] = xlsread(['quests' fs 'Questions.xlsx']);
	abbrev    = RAW(:,1);
	exp_quest = RAW(:,2);
     
    list.expq      = struct('chan', {abbrev}, 'questions', {exp_quest});
     

    save(['lists' fs subj{i} '.mat'],'-struct','list')
    clear clear_double noise_double
    end
        