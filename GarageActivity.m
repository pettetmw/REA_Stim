function GarageActivity

% Based on TouchFeedback5.m: see comments therin.

% rough outline:

% tWR = getRect(tW); % needs tweak
% targ_mask = zeros(size(tWR)); % non target areas are zero
%
% (statements to fill in target areas with 1, 2, or 3)
%
% for i_round = 1:n_rounds
%	 idle screen?
%	 garage closed image onset
%	 start_time = GetSecs;
%	 targ_tf = true(3,1); % whether each door is still a target
%	 trial_count = 0;
%	 isPrompt = true;  % this logic is still not correct
%	 while any( targ_tf )
%		if isPrompt, prompt: "Pick a door to make the car go!"; isPrompt = false; end
%		targ_time = GetSecs;
%		response_latency = (targ_time-start_time);
%		if response_latency > 30.0
%			start_time = GetSecs;
%			isPrompt = true;
%		else
%			[tX,tY,tB] = GetMouse(tW);
%			if ~any(tB)
%				continue;
%			end
%			targ = targ_mask(tX,tY);
%			isTarg = 0;
%			if targ > 0, isTarg = targ_tf(targ); end
%			% record i_round response_latency targ and isTarg;
%			if targ_tf(targ)
%				show_correct(targ);
%				targ_tf(targ) = false;
%				break;
%			else
%				show_incorrect(targ);
%				break;
%			end
%			feedback(targ)?
%		end
%		trial_count = trial_count + 1;
%	 end
% end

% additional timeout/restart logic?

% Clear the workspace
close all;
clear;
sca;

%--------------------
% Setup Variables
%--------------------

% Debug view toggle
% Altering the screen size 
% (0: experimental -> full screen | 1: debugging -> 800x450 application window)
debugMode = 0;  

% Observer number
obsNum = 1;

% How many trials are we doing in total
nTrls = 10;

workf = fileparts(mfilename('fullpath')); % working folder, i.e. the one containing this mfile
resf = fullfile( workf, 'Results' ); % results folder
if ~isfolder( resf ), mkdir( resf ); end

sbj_resf = uigetdir( resf, 'Choose or create new Subject folder:' );
[~,SID] = fileparts( sbj_resf ); % subject ID

dtag = char(datetime('now','Format','yyMMdd')); % date tag
sbj_date_resf = fullfile( sbj_resf, [ SID '_' dtag ] ); % subject date result folder
if ~isfolder(sbj_date_resf), mkdir(sbj_date_resf); end

%--------------------
%   Screen setup
%--------------------

% Setup PTB with some default values
PsychDefaultSetup(2);

% Skip sync tests ** This is for demo purposes only ** It should not be
% done in a real experiment.
Screen('Preference', 'SkipSyncTests', 2);

% Set the random number generator so we get random numbers, not the same
% sequency if we restart Matlab
rng('shuffle');

% Set the screen number to the external secondary monitor if there is one
% connected
screenNumber = max(Screen('Screens'));

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;
black = BlackIndex(screenNumber);

% Define colours for drawing stimuli
colors = struct('black', [0, 0, 0], 'white', [255, 255, 255], ...
    'red', [255, 0, 0], 'blue', [0, 0, 205], 'yellow', [255, 255, 0]);

cue_ff = fullfile( workf, 'Stims', '3 car videos', 'GarageClosed.png' );
cue_im = imread(cue_ff);
[im_y,im_x,~] = size( cue_im );
im_rect = [0,0,im_x,im_y];
trg_rects = [ 209 130 364 307; 383 132 527 305; 547 129 678 297 ] * 1.25; %???

if debugMode == 1
    % Open the screen
    % [window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [0 0 800 450], [], [], [], [], [], kPsychGUIWindow);
    % [window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [0 0 958 525], [], [], [], [], [], kPsychGUIWindow);
    % [window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [0 0 im_x im_y], [], [], [], [], [], kPsychGUIWindow);
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, im_rect, [], [], [], [], [], kPsychGUIWindow);

else
    % Open the screen
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 2);
	im_rect = CenterRect( im_rect, windowRect );
	trg_off = im_rect(1:2) - windowRect(1:2);
	trg_rects = OffsetRect( trg_rects, trg_off(1), trg_off(2) );
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
%                       Target Square
%----------------------------------------------------------------------

% Make a base Rect of 200 by 200 pixels. This is the rect which defines the
% size of our rectangle in pixels.
% The coordinates define the top left and bottom right coordinates of our rect
% [top-left-x top-left-y bottom-right-x bottom-right-y].
% trg_rects = [0 0 200 200];
% 
% % Center the rectangle on the centre of the screen
% trg_rects = CenterRect(trg_rects, windowRect);
% trg_rects = [ OffsetRect( trg_rects, -300, 0 ); trg_rects; OffsetRect( trg_rects, 300, 0 ) ];

cue_txt = Screen( 'MakeTexture', window, cue_im );

d = dir( fullfile( workf, 'Stims', '3 car videos', '*.mov' ) );
% cue_ffs = fullfile( {d.folder}', {d.name}' );
% cue_txts = cellfun( @(f) Screen('MakeTexture', window, imread(f)), cue_ffs, 'uniformoutput', false );






%----------------------------------------------------------------------
%                       Timings
%----------------------------------------------------------------------

% Here we determine the presentation time for stimuli and calculating the
% corresponded frames. It is important for precise timing.

% Fixation point time in seconds and frames
fixTimeSecs = 0.5;
fixTimeFrames = round(fixTimeSecs / ifi);

% Stimuli time in seconds and frames
stimTimeSecs = 5;
stimTimeFrames = round(stimTimeSecs / ifi);

% Intertrial interval time
isiTimeSecs = 0.5;
isiTimeFrames = round(isiTimeSecs / ifi);

% Frames to wait before redrawing
waitframes = 1;

%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------
% KbName('KeyNames') returns a table of all keycodes->keynames mappings

% Define the keyboard keys that are listened for. We will be using the space key
% as a response key for the task and the escape key as an exit/reset key
escapeKey = KbName('ESCAPE');
spaceKey = KbName('space');
enterKey = KbName('return');

% Hide the mouse cursor
% HideCursor;



%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------

isQuitEarly = false;
ShowCursor;

nTrls = 10;
dataMat = zeros( nTrls, 3 );
% loop for the total number of trials
for iTrl = 1:nTrls

    % Set the blend funciton for a nice antialiasing
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    % If this is the first trial we present a start screen and wait for a
    % key-press
    if iTrl == 1

        % Draw the instructions
        DrawFormattedText(window, 'Press any key to start when you are ready', 'center', 'center', colors.white);

        % Flip to the screen
        Screen('Flip', window);

        % Wait for a key press
        KbStrokeWait(-1);

        % Flip the screen grey
        Screen('FillRect', window, grey);
        vbl = Screen('Flip', window);
        WaitSecs(0.5);

    end

    % Set data variables for this trial
    response = 0;

    % Present the stimuli
    for i = 1:stimTimeFrames

        % Draw the square to the screen.
		Screen('DrawTexture', window, cue_txt );
        Screen('FillRect', window, colors.blue, trg_rects(1,:) );
        Screen('FillRect', window, colors.red, trg_rects(2,:) );
        Screen('FillRect', window, colors.yellow, trg_rects(3,:) );

        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

        [keyIsDown,secs, keyCode] = KbCheck(-1);
        if keyCode(escapeKey), isQuitEarly = true; break; end % end trial and trial loop

		[tX,tY,tB] = GetMouse(window);
		% if tB(1)
		if any( tB )
			% disp([tX,tY,tB(1)]);
			% disp([tX,tY,tB]);
			isHit = [ IsInRect(tX,tY,trg_rects(1,:)) ...
				IsInRect(tX,tY,trg_rects(2,:)) ...
				IsInRect(tX,tY,trg_rects(3,:)) ];
			if ~any(isHit), continue; end
            dataMat(iTrl,:) = isHit;
            break; % end trial
		end
		
	end

	if isQuitEarly, break; end % end trial loop

    % Clear the screen ready for a response
    Screen('FillRect', window, grey);
    vbl = Screen('Flip', window, vbl + (1 - 0.5) * ifi);

	while KbCheck, ; end
    % Inter trial interval screen
    for i = 1:isiTimeFrames
        Screen('FillRect', window, grey);
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    end

    % If this is the last trial we present screen saying that the experimet
    % is over.
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    if iTrl == nTrls

        % Draw the instructions: in reality the person could press any of
        % the listened to keys to exist. But they do not know that.
        DrawFormattedText(window, 'Experiment Complete!\n\n\n press ESCAPE to exit', 'center', 'center', black);

        % Flip to the screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

        % Wait for a key press
        KbStrokeWait(-1);

    end

end

sid_dttag = [ SID '_GarageActivity_' char(datetime('now','Format','yyMMdd_HHmm')) ];
save( fullfile( sbj_date_resf, [ sid_dttag '.mat' ] ), 'sid_dttag', 'dataMat' );

% Saved!
disp('Data Saved')

% Show the mouse cursor
% ShowCursor;

% Done!
disp('Experiment Finished')

sca



% If unhandled error causes return to Matlab command line before execution
% of ListenChar(0), keyboard input will be disabled.  It can be restored by
% keying in Cmd-C.















