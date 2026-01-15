% TestAudioScripting.m

function TestAudioScripting

% Running on PTB-3? Abort otherwise.
AssertOpenGL;

% setup folders and files
workf = fileparts(which(mfilename('fullpath'))); % working folder, i.e. the one containing this mfile
stimsf = fullfile( workf, 'Stims', 'gonogo' );
prompt_aud_f = fullfile( stimsf, 'Gonogo audio' );
cue_img_f = fullfile( stimsf, 'Gonogo visuals' );

% set up everything needed by present_image function
debugMode = 1;
fixCrossDimPix = 40;
lineWidthPix = 4;
[ cue_ffs, cue_txts, white, grey, black, colours, window, windowRect, ifi, ...
	xCenter, yCenter, xCoords, yCoords, allCoords, baseRect, centeredRect ] = deal( [] );
setup_cue_images;

% white = WhiteIndex(screenNumber);
% grey = white / 2;
% black = BlackIndex(screenNumber);
% colours = struct('black', [0, 0, 0], 'white', [255, 255, 255], ...
% [window, windowRect]
% ifi
% [xCenter, yCenter]
% fixation cross coordinates
% xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
% yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
% allCoords = [xCoords; yCoords];
% baseRect = [0 0 200 200];
% 
% % Center the rectangle on the centre of the screen
% centeredRect = CenterRect(baseRect, windowRect);


% set up everything needed by play_audio_prompt function
freq = 48000;
[ device, audio_fnms, wbs, pahandle ] = deal( [] );
setup_audio_prompts;
nfnms = numel(audio_fnms);

n_prac_trls = 10;
n_test_trls = 100;

present_image( 'apples' );
play_audio_prompt('lets_pick_some_fruit');
play_audio_prompt('Woohoo_version_1');

% clear screen

run_practice_trials( 'apple', 'touch_when_you_see_an_apple' );

run_practice_trials( 'worm', 'now_do_not_touch_worm' );

%clear screen
play_audio_prompt('apple_or_worm'); % transitional instruction

run_test_trials( 'apple', 'remember_apple', 'worm', 'do_not_touch_worm' );

run_test_trials( 'banana', 'touch_banana', 'monkey', 'do_not_touch_monkey' );

run_test_trials( 'strawberry2', 'touch_strawberry', 'squirrel', 'do_not_touch_squirrel' );

run_test_trials( 'orange', 'touch_orange', 'bird', 'do_not_touch_bird' );


% for i = 1:nfnms
% 	play_audio_prompt(audio_fnms{i});
% end

% Close the audio device:
PsychPortAudio('Close', pahandle);
Screen('CloseAll');

	function setup_audio_prompts

		audio_fnms = {
		'lets_pick_some_fruit.m4a'
		'touch_when_you_see_an_apple.m4a'

		'now_do_not_touch_worm.m4a'

		'apple_or_worm.m4a'
		'remember_apple.m4a'
		'do_not_touch_worm.m4a'

		'touch_banana.m4a'
		'do_not_touch_monkey.m4a'

		'touch_strawberry.m4a'
		'do_not_touch_squirrel.m4a'

		'touch_orange.m4a'
		'do_not_touch_bird.m4a'

		'ready.m4a'
		'Woohoo_version_1.m4a'
		};
		
		audio_ffs = fullfile( prompt_aud_f, audio_fnms );
		wvdat = cellfun( @(f) psychwavread(f)', audio_ffs, uniformoutput=false );
		audio_fnms = cellfun( @(f) f(1:end-4), audio_fnms, uniformoutput=false );
		wbs = [ audio_fnms wvdat ]'; % wave buffers
		wbs = struct( wbs{:} ); % now addressable as struct fields
		
		nrchannels = 2;
		
		% Perform basic initialization of the sound driver:
		InitializePsychSound;
		
		pahandle = PsychPortAudio('Open', device, [], 0, freq, nrchannels);

	end

	function play_audio_prompt( a_prompt )
		% Fill the audio playback buffer with the audio data 'wavedata':
		PsychPortAudio('FillBuffer', pahandle, [wbs.(a_prompt);wbs.(a_prompt)] );
		PsychPortAudio('Start', pahandle, 1, 0, 1);
		WaitSecs( ceil( length(wbs.(a_prompt)) / freq ) );
		% % Stop playback:
		PsychPortAudio('Stop', pahandle);
	end

	function setup_cue_images

		PsychDefaultSetup(2);
		Screen('Preference', 'SkipSyncTests', 2); % for demo only; check for real experiment
		rng('shuffle'); % freshen the random number generator
		screenNumber = max(Screen('Screens')); % will be external monitor if present
		white = WhiteIndex(screenNumber);
		grey = white / 2;
		black = BlackIndex(screenNumber);
		colours = struct('black', [0, 0, 0], 'white', [255, 255, 255], ...
    		'red', [255, 0  , 0  ], 'blue', [0  , 0, 205  ]);
		
		if debugMode == 1
    		% Open the screen
    		% [window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [0 0 800 450], [], [], [], [], [], kPsychGUIWindow);
    		[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [100 100 900 550], [], [], [], [], [], kPsychGUIWindow);
		
		else
    		% Open the screen
    		[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 2);
		end
		
		% Flip to clear
		Screen('Flip', window);
		
		% Query the inter-frame-interval. This refers to the minimum possible time
		% between drawing to the screen
		ifi = Screen('GetFlipInterval', window);
		
		% Setup the text type for the window
		Screen('TextFont', window, 'Ariel');
		Screen('TextSize', window, 40);
		
		% Query and set the maximum priority level
		topPriorityLevel = MaxPriority(window);
		Priority(topPriorityLevel);
		
		% Get the centre coordinate of the window
		[xCenter, yCenter] = RectCenter(windowRect);
		
		
		%----------------------------------------------------------------------
		%                       Fixation Cross
		%----------------------------------------------------------------------
		
		% fixation cross coordinates
		xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
		yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
		allCoords = [xCoords; yCoords];
		
		%----------------------------------------------------------------------
		%                       Target Square
		%----------------------------------------------------------------------
		
		% Make a base Rect of 200 by 200 pixels. This is the rect which defines the
		% size of our rectangle in pixels.
		% The coordinates define the top left and bottom right coordinates of our rect
		% [top-left-x top-left-y bottom-right-x bottom-right-y].
		baseRect = [0 0 200 200];
		centeredRect = CenterRect(baseRect, windowRect);

		img_fnms = {
		'apples.jpg'
		'apple.jpg'
		'worm.jpg'
		'banana.jpg'
		'monkey.jpg'
		'strawberry2.jpg'
		'squirrel.jpg'
		'orange.jpg'
		'bird.jpg'
		'mango.jpg'
		'orange1.jpg'
		'squirrel2.jpg'
		'check.jpg'
		'x.jpg'
		};

		cue_ffs = fullfile( cue_img_f, img_fnms );
		cue_txts = cellfun( @(f) Screen('MakeTexture', window, imread(f)), cue_ffs, 'uniformoutput', false );
		img_fnms = cellfun( @(f) f(1:end-4), img_fnms, uniformoutput=false );
		cue_txts = [ img_fnms cue_txts ]';
		cue_txts = struct( cue_txts{:} ); % cue textures now addressable as struct fields
		
	end

	function present_image( aImg )
		disp( [ 'showing' aImg ] );
		Screen('DrawTexture', window, cue_txts.(aImg) );
	end

	function run_practice_trials( aTarg,aTargPrompt )
		% Show Target
		present_image(aTarg);
		play_audio_prompt(aTargPrompt);
		%clear screen
		
		play_audio_prompt('ready');

		% loop over trials

	end

	function run_test_trials( aTarg,aTargPrompt,aDist,aDistPrompt )
		% Show Target
		present_image(aTarg);
		play_audio_prompt(aTargPrompt);
		%clear screen
		% Show Distractor
		present_image(aDist);
		play_audio_prompt(aDistPrompt);
		
		play_audio_prompt('ready');

		% loop over trials

	end

end



















