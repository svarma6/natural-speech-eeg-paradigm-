function run_rest_experiment()

% set parameters
Sf   = 44100;
dur  = 360;

% prepare all key and trigger responses 
exitKey = zeros(1,256);
exitKey(KbName({'ESCAPE'})) = 1;
exitK   = find(exitKey);
KbQueueCreate(); % make queue for abort key condition

% initialize audio
InitializePsychSound;
pahandle = PsychPortAudio('Open',ptb_findaudiodevice('Focusrite USB ASIO'),[],0,Sf,4);
PsychPortAudio('FillBuffer',pahandle,[0 0 0 0]');
PsychPortAudio('Start',pahandle,1,0,1);

try
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
	Screen('TextSize', shandle, 20);
	Screen('TextStyle', shandle, 1);
	HideCursor;

	% instructions
	DrawFormattedText(shandle, [['This is a 6 min resting blocks.\n\n\n'] ...
								['Just sit and relax. Nothing specific is required.\n\n\n\n'] ...
								['Please do not close your eye continously as this changes your brain activity.\n\n'] ...
								['Blinks are no problem.\n\n\n\n'] ...
								['The experimenter will start the block when ready.']], 'center', 'center', txtcolor);
	Screen('Flip', shandle);
	keyIsDown = KbCheck;
	while ~keyIsDown
		keyIsDown = KbCheck;
	end
		
	% blank screen
	DrawFormattedText(shandle, '', 'center', 'center', txtcolor);
	Screen('Flip', shandle);
	
	% trigger
	y = [zeros([440 2]) ones([440 2])];

	% buffer
	PsychPortAudio('FillBuffer',pahandle,y');

	% play
	paTime = PsychPortAudio('Start',pahandle,1,0,1);
		
	% check whether experimenter terminates
	while paTime+dur >= GetSecs
		[~, ~, keyCode] = KbCheck;
		if sum(ismember(exitK,find(keyCode))) > 0
			error('Experiment terminated by user!')
		end
	end
		
		
	DrawFormattedText(shandle, 'Done.', 'center', 'center', txtcolor);
	Screen('Flip', shandle);
	keyIsDown = KbCheck;
	while ~keyIsDown
		keyIsDown = KbCheck;
	end
		
	sca;
	PsychPortAudio('Close', pahandle);
	KbQueueStop;
catch
    sca;
	PsychPortAudio('Close', pahandle);
	KbQueueStop;
    rethrow(lasterror);
end

