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
debugMode = 1;  

% Observer number
obsNum = 1;

% How many trials are we doing in total
numTrials = 10;

% Ratio for Go and No-Go Task (Go / No-Go)*100
% Set the percentage of trials in which "Go" stimuli will be presented out of the total number of trials. 
% Example: 0.6 corresponds to 60% of the trials being Go stimuli.
% The task is being more difficult when there are more Go than No-go trials
taskRatio = 0.6; 

% Check value is correct
if taskRatio < 0 || taskRatio > 1

    disp("The value for task ratio is incorrect")
    return

end

%----------------------------------
%           Data Folder
%----------------------------------

% Make the folder where the data will be saved
obsFidB = [cd filesep 'Data' filesep 'Observer ' num2str(obsNum) ' ' char(datetime('now', 'Format', 'yyyy-MM-dd HH_mm_ss'))];
if exist(obsFidB, 'dir') < 1
    mkdir(obsFidB);
end


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
colours = struct('black', [0, 0, 0], 'white', [255, 255, 255], ...
    'red', [255, 0  , 0  ], 'blue', [0  , 0, 205  ]);

if debugMode == 1
    % Open the screen
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [0 0 800 450], [], [], [], [], [], kPsychGUIWindow);

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

% Set the size of the arms of our fixation cross
fixCrossDimPix = 40;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)

% fixation cross coordinates
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];

allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 4;


%----------------------------------------------------------------------
%                       Target Square
%----------------------------------------------------------------------

% Make a base Rect of 200 by 200 pixels. This is the rect which defines the
% size of our rectangle in pixels.
% The coordinates define the top left and bottom right coordinates of our rect
% [top-left-x top-left-y bottom-right-x bottom-right-y].
baseRect = [0 0 200 200];

% Center the rectangle on the centre of the screen using fractional pixel
% values.
% For help see: CenterRectOnPointd
centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);


%----------------------------------------------------------------------
%                       Timings
%----------------------------------------------------------------------

% Here we determine the presentation time for stimuli and calculating the
% corresponded frames. It is important for precise timing.

% Fixation point time in seconds and frames
fixTimeSecs = 0.5;
fixTimeFrames = round(fixTimeSecs / ifi);

% Stimuli time in seconds and frames
stimTimeSecs = 2;
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

% Hide the mouse cursor
HideCursor;

%----------------------------------------------------------------------
%                        Procedure / Trial Sequence
%----------------------------------------------------------------------

% Target squares will appear in the center either blue (Go) or red (No-Go)
% in colour according to the condition Go or No-Go. Go will be signalled by a one
% and No-Go a zero. 

% We calculate the number of Go and No-Go trials according to task difficulty (taskRatio)
numGoTrials = round(numTrials * taskRatio);
numNoGoTrials = numTrials - numGoTrials;

% We create a vector array including total number of trials with the 2 possible conditions.
condArray = [zeros(1, numNoGoTrials) ones(1, numGoTrials)];

% Randomise the trials
condArrayShuff = Shuffle(condArray, 2);

% Make our response matrix which will save the condition, response, RT and correctness of the
% response choice. We preallocate the matrix with nans.
dataMat = nan(numTrials, 4);


%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------

% loop for the total number of trials
for trial = 1:numTrials

    % Task Condition: Go (1) or No-Go (0)
    taskCon = condArrayShuff(1, trial);

    % Logic to assign the correct colour to the target stimuli
    if taskCon == 0
        rectColor = colours.red;
    elseif taskCon == 1
        rectColor = colours.blue;
    end

    % Set the blend funciton for a nice antialiasing
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    % If this is the first trial we present a start screen and wait for a
    % key-press
    if trial == 1

        % Draw the instructions
        DrawFormattedText(window, 'Simple Go No-Go Task Demo\n\n\n Press any key to continue', 'center', 'center', black);

        % Flip to the screen
        Screen('Flip', window);

        % Wait for a key press
        KbStrokeWait(-1);

        % Draw the instructions
        DrawFormattedText(window, 'You will either see a blue \n\n or a red square.\n\n\n If you see the blue, press the spacebar as quickly as possible.\n\n If you see the red, do nothing!\n\n\n Press any key to continue', 'center', 'center', black);

        % Flip to the screen
        Screen('Flip', window);

        % Wait for a key press
        KbStrokeWait(-1);

        % Draw the instructions
        DrawFormattedText(window, 'Press any key to start when you are ready', 'center', 'center', colours.white);

        % Flip to the screen
        Screen('Flip', window);

        % Wait for a key press
        KbStrokeWait(-1);

        % Flip the screen grey
        Screen('FillRect', window, grey);
        vbl = Screen('Flip', window);
        WaitSecs(0.5);

    end

    % Present the fixation cross only
    for i = 1:fixTimeFrames

        % Draw the fixation cross in black, set it to the center of our screen
        Screen('DrawLines', window, allCoords,...
            lineWidthPix, colours.black, [xCenter yCenter], 2);

        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    end
    
    % Set data variables for this trial
    startResp = GetSecs;
    response = 0;
    rt = NaN;                        
    % Present the stimuli
    for i = 1:stimTimeFrames

        % Draw the square to the screen.
        Screen('FillRect', window, rectColor, centeredRect);

        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

        % Wait for a keyboard button signaling the observers response.
        % The space key signals a "Go" response labeled by 1. 
        % You can also press escape if you want to exit the program
        [keyIsDown,secs, keyCode] = KbCheck(-1);

        if keyCode(escapeKey)
            ShowCursor;
            sca;
            return
        elseif keyCode(spaceKey)
            % Update data variables if space pressed
            response = 1;
            endResp = GetSecs;
            rt = endResp - startResp;
            break
        end
    end

    % Clear the screen ready for a response
    Screen('FillRect', window, grey);
    vbl = Screen('Flip', window, vbl + (1 - 0.5) * ifi);

    % Work out if the response for Go task was identified correctly
    % and get correctness data
    if taskCon == response 
        correctness = 1;
    elseif taskCon ~= response 
        correctness = 0;
    end

    % Add the data to the data matrix for this trial
    dataMat(trial, :) = [taskCon response rt correctness];
    
    % Inter trial interval screen
    for i = 1:isiTimeFrames
        Screen('FillRect', window, grey);
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    end

    % If this is the last trial we present screen saying that the experimet
    % is over.
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    if trial == numTrials

        % Draw the instructions: in reality the person could press any of
        % the listened to keys to exist. But they do not know that.
        DrawFormattedText(window, 'Experiment Complete!\n\n\n press ESCAPE to exit', 'center', 'center', black);

        % Flip to the screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

        % Wait for a key press
        KbStrokeWait(-1);

    end

end

% Generate the specific file name according to the observer and session time
dataFid = ['OBS' num2str(obsNum) '_goNoGoData.txt'];

% Save out the data. We save to the "obsFidB" directory as the code as a tab delimited text file
writematrix(dataMat, [obsFidB filesep dataFid], 'Delimiter', '\t')

% Saved!
disp('Data Saved')

% Show the mouse cursor
ShowCursor;

% Done!
disp('Experiment Finished')
sca
