% set parameters
Sf        = 44100;
likert    = 1:7;    % rating scale
likKeys   = 49:55;  % corresponding numbers on the keyboard
dir_logs  = 'logs\';
dir_story = 'stories\';
dir_list  = 'lists\';%lists have story orders to be loaded specific to subject ID
soundred  = -18;
% prepare all key and trigger responses 
KbName('UnifyKeyNames');
exitKey = zeros(1,256);
exitKey(KbName({'ESCAPE'})) = 1;
exitK   = find(exitKey);
KbQueueCreate(); % make queue for abort key condition
% initialize audio
InitializePsychSound;
pahandle = PsychPortAudio('Open',ptb_findaudiodevice('Focusrite USB ASIO'),[],0,Sf,3);
PsychPortAudio('FillBuffer',pahandle,[0 0 0]');
PsychPortAudio('Start',pahandle,1,0,1);
% setup visual presentation
	sca;                                             % close all screens
	screens      = Screen('Screens');                % get all screens available
	screenNumber = max(screens);                     % present stuff on the last screen
	Screen('Preference', 'SkipSyncTests', 1);
	white        = WhiteIndex(screenNumber);         % get white given the screen used
	bgcolor      = 0;                                % background color 0-255
	txtcolor     = round(white*0.8);                 % text color 0-255
	[shandle, wRect] = PsychImaging('OpenWindow', screenNumber, bgcolor); % open window

	% Select specific text font, style and size:
	Screen('TextFont', shandle, 'Arial');
	Screen('TextSize', shandle, 18);
	Screen('TextStyle', shandle, 1);
	HideCursor;

%% instructions for narrative experiment 

list = load([dir_list subjID '.mat']);
	DrawFormattedText(shandle, [['You will hear a story. Please listen to the story as if you were listening\n\n'] ...
									['to it at home. Some parts of the story will be noisy. Please ignore the noise.\n\n\n\n'] ...
									['After you listen to the story you will be asked a few comprehension questions\n\n'] ...
									['and questions about your experience with the story.\n\n\n\n'] ...
									['Please do not close your eyes continously as this changes your brain activity.\n\n'] ...
									['Blinks are no problem.\n\n\n\n'] ...
									['The experimenter will start the story when ready.']], 'center', 'center', txtcolor);
Screen('Flip', shandle);
		keyIsDown = KbCheck;
		while ~keyIsDown
			keyIsDown = KbCheck;
        end
		
% blank screen
DrawFormattedText(shandle, '', 'center', 'center', txtcolor);
Screen('Flip', shandle);
% load story and add trigger
y = audioread([dir_story list.noise.story '.wav']); %loads the specific story
if size(y,2)==length(y), y = y'; end
y = [y(:,1) y(:,1)]*db2ratio(soundred);
y(:,3) = [ones([440 1]); zeros([length(y(:,1))-440 1])]; %these are the triggers

%divide story into 3 blocks
% audiowrite([subjID fs subjID '_noiseb1.wav'],y(1:length(y)/3),48000);
% audiowrite([subjID fs subjID '_noiseb2.wav'],y((length(y)/3)+48000: 2*(length(y)/3)),48000); 
% audiowrite([subjID fs subjID '_noiseb3.wav'],y(2*(length(y)/3)+ 48000:end), 48000);

y1= y(1:length(y)/3 +1,:);
y2= y((length(y)/3): 2*(length(y)/3),:); 
y3= y(2*(length(y)/3): length(y),:);

Y=cat(3,y1,y2,y3);
%% start block 1 

% buffer story
PsychPortAudio('FillBuffer',pahandle,y1');
		
% wait a little bit
WaitSecs(7);
        
% play story, and wait buffer time
paTime = PsychPortAudio('Start',pahandle,1,0,1);

% check whether experimenter terminates
% uncomment for testing
%PsychPortAudio('Stop', pahandle);
% Wait briefly
WaitSecs(1);

% instructions for questions 
WaitSecs(2);
DrawFormattedText(shandle, [['You will see 3 variations of a sentence. \n\n']...
									['Only 1 version corresponsds to what you heard in the story. \n\n']...
                                    ['Press the key number that corresponds to the option you are choosing. \n\n']...
                                    ['For example, if the answer is option number 1, press the 1 key. \n\n']...
                                    ['Press a key to start.']], 'center', 'center', txtcolor);
Screen('Flip', shandle);
		keyIsDown = KbCheck;
		while ~keyIsDown
			keyIsDown = KbCheck;
        end
        
% blank screen
DrawFormattedText(shandle, '', 'center', 'center', txtcolor);
Screen('Flip', shandle);
WaitSecs(1);

% intelligibility questions
		resp = [];
		for qi = 1 : length(list.noise.options)/3 %first 5 questions// change this after to correspond to trigger?
			DrawFormattedText(shandle, [list.noise.options{qi} '\n\n\n\n' ...
										'1 - option 1\n\n2 - option 2\n\n3 - option 3'], 'center', 'center', txtcolor);
			Screen('Flip', shandle);
			ixq     = [1  2 3];   % unsure of this line
			ixhkey  = [49 50 51]; % 1 2 3 on the keyboard 
			[~, keyCode] = KbPressWait;
			while sum(ismember(ixhkey,find(keyCode)))==0
				[~, keyCode] = KbPressWait;
			end
			resp(qi) = ixq(ismember(ixhkey,find(keyCode)));
			
            % break
			if sum(ismember(exitK,find(keyCode))) > 0
				PsychPortAudio('Stop', pahandle);
				error('Experiment terminated by user!')
			end
            
			% blank screen
			DrawFormattedText(shandle, '', 'center', 'center', txtcolor);
			Screen('Flip', shandle);
			
			% wait briefly
			WaitSecs(0.6);
        end

% wait briefly
WaitSecs(2)


%% start experiment (loop version)

for x=1:3
    %choose a section
    story_section= Y(:,:,x);
    % buffer story
    PsychPortAudio('FillBuffer',pahandle,story_section');
    % wait a little bit
    WaitSecs(7);
     % play story, and wait buffer time
    paTime = PsychPortAudio('Start',pahandle,1,0,1);
    % check whether experimenter terminates
    % uncomment for testing
    %PsychPortAudio('Stop', pahandle);
    % Wait briefly
    WaitSecs(1);   
    % instructions for questions 
    WaitSecs(2);
    DrawFormattedText(shandle, [['You will see 3 variations of a sentence. \n\n']...
									['Only 1 version corresponsds to what you heard in the story. \n\n']...
                                    ['Press the key number that corresponds to the option you are choosing. \n\n']...
                                    ['For example, if the answer is option number 1, press the 1 key. \n\n']...
                                    ['Press a key to start.']], 'center', 'center', txtcolor);
    Screen('Flip', shandle);
		keyIsDown = KbCheck;
		while ~keyIsDown
			keyIsDown = KbCheck;
        end
        
    % blank screen
    DrawFormattedText(shandle, '', 'center', 'center', txtcolor);
    Screen('Flip', shandle);
    WaitSecs(1);
    
    %intelligibility questions
    resp = [];
		for qi = (x* length(list.noise.options)- length(list.noise.options)+1): (x* length(list.noise.options)- length(list.noise.options)+1)+ (length(list.noise.options)/3)-1
			DrawFormattedText(shandle, [list.noise.options{qi} '\n\n\n\n' ...
										'1 - option 1\n\n2 - option 2\n\n3 - option 3'], 'center', 'center', txtcolor);
			Screen('Flip', shandle);
			ixq     = [1  2 3];   % unsure of this line
			ixhkey  = [49 50 51]; % 1 2 3 on the keyboard 
			[~, keyCode] = KbPressWait;
			while sum(ismember(ixhkey,find(keyCode)))==0
				[~, keyCode] = KbPressWait;
			end
			resp(qi) = ixq(ismember(ixhkey,find(keyCode)));
			
            % break
			if sum(ismember(exitK,find(keyCode))) > 0
				PsychPortAudio('Stop', pahandle);
				error('Experiment terminated by user!')
			end
            
			% blank screen
			DrawFormattedText(shandle, '', 'center', 'center', txtcolor);
			Screen('Flip', shandle);
			
			% wait briefly
			WaitSecs(0.6);
        end
end

WaitSecs(2)

%% 	Experience questions 

		
DrawFormattedText(shandle, [['Please answer a few questions about your experience with the story.\n\n'] ...
									['Press a key to start.']], 'center', 'center', txtcolor);
Screen('Flip', shandle);
keyIsDown = KbCheck;
		while ~keyIsDown
			keyIsDown = KbCheck;
        end
        
% blank screen
DrawFormattedText(shandle, '', 'center', 'center', txtcolor);
Screen('Flip', shandle);
WaitSecs(1);
		
% prior exposure question
DrawFormattedText(shandle, ['Have you heard the story before?\n\n\n\n' ...
				                    'y - yes\n\nn - no\n\nu - unsure'], 'center', 'center', txtcolor);
Screen('Flip', shandle);
ixheard = ['y' 'n' 'u'];
ixhkey  = [89 78 85];
[~, keyCode] = KbPressWait;
		while sum(ismember(ixhkey,find(keyCode)))==0
			[~, keyCode] = KbPressWait;
		end
respH = ixheard(ismember(ixhkey,find(keyCode)));
WaitSecs(0.6);

% Effort questions
		respQs = zeros([1 length(list.expq)]);
		for qi = 1 : length(list.expqs)
			% write questions on screen
			DrawFormattedText(shandle, ['Q' num2str(qi) '/' num2str(length(list.EQs)) ': ' list.EQs{qi} '\n\n\n\n' ...
				                        '(completely disagree) 1 .. 2 .. 3 .. 4 .. 5 .. 6 .. 7 (completely agree)'], 'center', 'center', txtcolor);
			Screen('Flip', shandle);
			
			% wait for specific key press
			[~, keyCode] = KbPressWait;
			while sum(ismember(likKeys,find(keyCode)))==0
				[~, keyCode] = KbPressWait;
			end
			
			% break
			if sum(ismember(exitK,find(keyCode))) > 0
				PsychPortAudio('Stop', pahandle);
				error('Experiment terminated by user!')
			end
			
			% save key press
			respQs(qi) = likert(ismember(likKeys,find(keyCode)));
			
			% empty screen
			DrawFormattedText(shandle, '', 'center', 'center', txtcolor);
			Screen('Flip', shandle);
			WaitSecs(0.6);
		end