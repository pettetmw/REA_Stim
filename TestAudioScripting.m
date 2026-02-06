% TestAudioScripting.m

function TestAudioScripting

%%%
%%% SETUP
%%%

% Running on PTB-3? Abort otherwise.
AssertOpenGL;

% setup folders and files
workf = fileparts(which(mfilename('fullpath'))); % working folder, i.e. the one containing this mfile
stimsf = fullfile( workf, 'Stims', 'gonogo' );
prompt_aud_f = fullfile( stimsf, 'Gonogo audio' );
cue_img_f = fullfile( stimsf, 'Gonogo visuals' );

resf = fullfile( workf, 'Results', 'gonogo' ); % results folder
if ~isfolder( resf ), mkdir( resf ); end

sbj_resf = uigetdir( resf, 'Choose or create new Subject folder:' );
[~,SID] = fileparts( sbj_resf ); % subject ID

dtag = char(datetime('now','Format','yyMMdd')); % date tag
sbj_date_resf = fullfile( sbj_resf, [ SID '_' dtag ] ); % subject date result folder
if ~isfolder(sbj_date_resf), mkdir(sbj_date_resf); end


% set up everything needed by present_image function
debugMode = 1;
fixCrossDimPix = 40;
lineWidthPix = 4;
[ cue_ffs, cue_txts, white, grey, black, colours, window, windowRect, ifi, ...
	xCenter, yCenter, xCoords, yCoords, allCoords, baseRect, centeredRect ] = deal( [] );
setup_cue_images;

% set up everything needed by play_audio_prompt function
freq = 48000;
[ device, audio_fnms, wbs, pahandle ] = deal( [] );
setup_audio_prompts;

% set up trial schedule
n_prac_trls = 10; % number of practice trials in each block
n_tot_prac_trls = n_prac_trls * 2;
n_test_trls = 100; % number of test trials in each block
n_tot_test_trls = 4 * n_test_trls;
n_tot_trls = n_tot_prac_trls + n_tot_test_trls; % total number of trials
nt_per_d = 4; % number of trials per distractor
trl_iti_range = [1.5 1.9]; % range of inter-trial intervals
trl_sched = []; % sequence of targets (1) or distractors (2)
trl_iti = []; % inter-trial intervals for each trial
% last two assigned by set_trial_schedule() before each call to run_trials()

% trial timing
stim_dur = 1.0; % stimulus duration
trl_dur = 2.0; % trial duration
tslr = 20; % trial sampling loop rate, Hz

% responses
rsp_accs = nan(n_tot_trls,1); % response accuracies; true for response to target or no reponse to distractor
rsp_rts = nan(n_tot_trls,1); % response reaction times
trg_or_dst = nan(n_tot_trls,1); % target or distractor

escapeKey = KbName('ESCAPE');
spaceKey = KbName('space');
enterKey = KbName('return');

%%%
%%% RUN THE TRIALS
%%%

% preamble
present_image( 'apples' );
play_audio_prompt('lets_pick_some_fruit');
erase_screen;

iTrl = 0; % index of the current trial; incremented by run_trials()

isQuitEarly = false;

isPractice = true;

set_trial_schedule( n_prac_trls );
trl_sched(:) = 1; % practice only showing targets
run_trials( 'apple', 'touch_when_you_see_an_apple', [], [] );
if isQuitEarly, wrap_up; return; end

set_trial_schedule( n_prac_trls );
trl_sched(:) = 2; % practice only showing distractors
run_trials( 'worm', 'now_do_not_touch_worm', [], [] ); % announce only the distractor
if isQuitEarly, wrap_up; return; end

isPractice = false;

%clear screen
play_audio_prompt('apple_or_worm'); % transitional instruction

set_trial_schedule( n_test_trls );
run_trials( 'apple', 'remember_apple', 'worm', 'do_not_touch_worm' );
if isQuitEarly, wrap_up; return; end

set_trial_schedule( n_test_trls );
run_trials( 'banana', 'touch_banana', 'monkey', 'do_not_touch_monkey' );
if isQuitEarly, wrap_up; return; end

set_trial_schedule( n_test_trls );
run_trials( 'strawberry2', 'touch_strawberry', 'squirrel', 'do_not_touch_squirrel' );
if isQuitEarly, wrap_up; return; end

set_trial_schedule( n_test_trls );
run_trials( 'orange', 'touch_orange', 'bird', 'do_not_touch_bird' );
wrap_up;

%%%
%%% HELPER FUNCTIONS
%%%

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
		'beep2.wav'
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

	function set_trial_schedule( a_ntrls )
		% trl_sched and trl_iti are both traversable by index "i" in
		% run_trials() below, not by iTrl.
		if isPractice
			trl_sched = zeros( a_ntrls, 1 );
		else
			n_per_block = nt_per_d + 1;
			n_blocks = a_ntrls / (n_per_block^2);
			trl_sched = repmat( eye( n_per_block ) + ones( n_per_block ), 1, n_blocks );
			trl_sched = trl_sched( :, randperm( size(trl_sched,2) ) );
			trl_sched = trl_sched(:);
		end
		trl_iti = linspace( trl_iti_range(1), trl_iti_range(2), a_ntrls )';
		trl_iti = trl_iti( randperm( a_ntrls ) );
	end

	function present_image( aImg )
		% disp( [ 'showing' aImg ] );
		Screen('DrawTexture', window, cue_txts.(aImg) );
		Screen('Flip', window );
	end

	function erase_screen()
		Screen('FillRect', window, white);
		Screen('Flip', window);
	end

	function draw_fixation()
		Screen('FillRect', window, white);
        Screen('DrawLines', window, allCoords,...
            lineWidthPix, colours.black, [xCenter yCenter] );
		Screen('Flip', window );
	end

	function run_trials( aTarg,aTargPrompt,aDist,aDistPrompt )

		% Show and announce target
		% (if practice, distractor will be announced here)
		present_image(aTarg);
		play_audio_prompt(aTargPrompt);
		erase_screen;
		%clear screen

		if ~isempty( aDist ) % otherwise practice
			% Show and announce distractor
			present_image(aDist);
			play_audio_prompt(aDistPrompt);
			erase_screen;
		end

		play_audio_prompt('ready');

		stms = { aTarg aDist };
		if isPractice, stms{2} = aTarg; end % use target only during practice

		n_trls = numel(trl_sched); % determined by calls to set_trial_schedule above
		for i = 1:n_trls
			iTrl = iTrl + 1;
			isStimOn = true;
			for sFr = 1:round(trl_dur * tslr) % sampling frame
				if sFr == 1
					draw_fixation;
					WaitSecs( trl_iti(i) );
					startResp = GetSecs; % start timer for reaction time measurement
					tResponse = 0;
					present_image( stms{ trl_sched( i ) } );
				end
				if isStimOn && sFr > round( stim_dur * tslr ) % stimulus ends before the trial does
					erase_screen;
					isStimOn = false;
				end

        		[ ~, ~, keyCode ] = KbCheck(-1);
        		if keyCode(escapeKey), isQuitEarly = true; break; end % end trial and trial loop
		
				[~,~,tB] = GetMouse(window);

				if keyCode(enterKey) || any( tB )
					tResponse = 1;
            		break; % end trial
				end

				WaitSecs( 1 / tslr ); % wait for sampling frame to end
			end

			erase_screen;
			if isQuitEarly, break; end % end trial loop

			trg_or_dst(iTrl) = trl_sched(i);
			if tResponse == 1
				rsp_accs(iTrl) = trl_sched(i) == 1; % 1 == target
        		rsp_rts(iTrl) = GetSecs - startResp;
			else
				rsp_accs(iTrl) = trl_sched(i) == 2; % true if no response to distractor
        		rsp_rts(iTrl) = 0.0;
			end

			if rsp_accs(iTrl)
				present_image('check');
				play_audio_prompt('Woohoo_version_1');
			else
				play_audio_prompt('beep2');
			end

		end

	end

	function wrap_up()
		PsychPortAudio('Close', pahandle);
		Screen('CloseAll');
		sid_dttag = [ SID '_' char(datetime('now','Format','yyMMdd_HHmm')) ];

		tIsPrc = zeros( n_tot_trls, 1 );
		tIsPrc(1:n_tot_prac_trls) = 1;

		tf = ~isnan(trg_or_dst);
		tIsPrc = tIsPrc(tf);
		trg_or_dst = trg_or_dst(tf);
		rsp_accs = rsp_accs(tf);
		rsp_rts = rsp_rts(tf);

		mat_ff = fullfile( sbj_date_resf, [ sid_dttag '.mat' ] );
		save( mat_ff, 'sid_dttag', 'tIsPrc', 'trg_or_dst', 'rsp_accs', 'rsp_rts' );

		sid_dttags = repmat( {sid_dttag}, size(tIsPrc) );
		rsp_rts = cellfun( @(r) sprintf('%1.3f',r), num2cell(rsp_rts), UniformOutput=false );
		tbl = [ sid_dttags num2cell( [ tIsPrc trg_or_dst rsp_accs ] ) rsp_rts ];
		var_names = { 'sid_dttag', 'tIsPrc', 'trg_or_dst', 'rsp_accs', 'rsp_rts' };
		tbl_ff = fullfile( sbj_date_resf, [ sid_dttag '.csv' ] );
		writetable( cell2table(tbl,"VariableNames",var_names), tbl_ff );
	end

end



















