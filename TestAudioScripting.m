% TestAudioScripting.m

function TestAudioScripting(repetitions, wavfilename, device)

% Running on PTB-3? Abort otherwise.
AssertOpenGL;

% setup folders and files
workf = fileparts(which(mfilename('fullpath'))); % working folder, i.e. the one containing this mfile
stimsf = fullfile( workf, 'Stims', 'gonogo' );
prompt_aud_f = fullfile( stimsf, 'Gonogo audio' );
cue_img_f = fullfile( stimsf, 'Gonogo visuals' );

% set up everything needed by play_audio_prompt function
freq = 48000;
[ device, audio_fnms, wbs, pahandle ] = deal( [] );
setup_audio_prompts;
nfnms = numel(audio_fnms);

% set up everything needed by present_image function
[ cue_ffs, cue_txts ] = deal( [] );
setup_cue_images;

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

		% d = dir( fullfile( cue_img_f, img_fnms ) );
		% cue_ffs = fullfile( {d.folder}', {d.name}' );
		% cue_txts = cellfun( @(f) Screen('MakeTexture', window, imread(f)), cue_ffs, 'uniformoutput', false );

	end

	function present_image( aImg )
		disp( [ 'showing' aImg ] );
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



















