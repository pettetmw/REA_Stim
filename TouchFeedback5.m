function TouchFeedback5

% TouchFeedback5: based on TouchFeedback4, still uses same FeedbackStim4
% subfolder

% During practice trials, use feedback clips featuring a 3rd actress "C"
% that follows same Pos/Neg and LeftRight specs as the tFeedbackMovFNms
% used during the main experiment, e.g.:
% 
% 	tFeedbackMovFNms = {
% 		'PosRightFairA' 'PosRightUnfairB' 'NegLeftFairA' 'NegLeftUnfairB'
% 
% would use the following feedback clips during practice:
% 
% 		'PosRightC' 'PosRightC' 'NegLeftC' 'NegLeftC'
% 
% 
% Here's the comments from v.4:
%
% When program launches, user will be prompted to type in Subject ID to
% create filename storing the touch data; user is futher prompted to choose
% the positive feedback color, the positive feedback position, and which
% distribution movie to show first.
% 
% After all these selections are made, grey screen appears and program
% waits in idle mode.
% 
% In idle mode:
% 
% Press "k" to begin practice mode, "m" to begin trial mode, or "q" to quit
% program.
% 
% In practice mode:
% 
% The program waits for user to press either "p", "n", or "b", respectively
% to show positive, negative, or both targets, or "q" to quit practice mode
% and return to idle mode. When finished practicing with a particular
% target configuration, the press "q", and then "p", "n", or "b" to try
% another target configuration, or  "q" to quit practice mode and return to
% idle mode.
% 
% In trial mode:
% 
% Pressing "space" starts playback of each distribution movie; pressing
% space again during playback toggles pause/play; pressing "q" during
% playback quits the distribution movie; pressing "q" between movies will
% skip the remainder of distribution movies; pressing "q" again will return
% to idle mode.
% 
% After distribution movies are complete, pressing "space" begins the first
% feedback trial. Press "q" to stop trial.  After each trial, "space" can
% be pressed again to start next trial.  The actress shown will alternate
% between trials.  Pressing "q" between trials will return to idle mode.




% based on TouchFeedback3



% ToDo:

% still debugging RunPractice and CheckTargets




CFOUF = @( varargin ) cellfun( varargin{:}, 'uniformoutput', false );

AssertOpenGL;

	tDistMovFNms = {
		'4FairToysA' '4UnfairToysB' '6FairSnacksA' '6UnfairSnacksB'
		'4FairSnacksA' '4UnfairSnacksB' '6FairToysA' '6UnfairToysB'
		'4UnfairToysA' '4FairToysB' '6UnfairSnacksA' '6FairSnacksB'
		'4UnfairSnacksA' '4FairSnacksB' '6UnfairToysA' '6FairToysB'
		'4FairToysB' '4UnfairToysA' '6FairSnacksB' '6UnfairSnacksA'
		'4FairSnacksB' '4UnfairSnacksA' '6FairToysB' '6UnfairToysA'
		'4UnfairToysB' '4FairToysA' '6UnfairSnacksB' '6FairSnacksA'
		'4UnfairSnacksB' '4FairSnacksA' '6UnfairToysB' '6FairToysA'
	};

	tFeedbackMovFNms = {
		'PosRightFairA' 'PosRightUnfairB' 'NegLeftFairA' 'NegLeftUnfairB'
		'PosLeftFairA' 'PosLeftUnfairB' 'NegRightFairA' 'NegRightUnfairB'
		'PosRightUnfairA' 'PosRightFairB' 'NegLeftUnfairA' 'NegLeftFairB'
		'PosLeftUnfairA' 'PosLeftFairB' 'NegRightUnfairA' 'NegRightFairB'
		'PosRightFairB' 'PosRightUnfairA' 'NegLeftFairB' 'NegLeftUnfairA'
		'PosLeftFairB' 'PosLeftUnfairA' 'NegRightFairB' 'NegRightUnfairA'
		'PosRightUnfairB' 'PosRightFairA' 'NegLeftUnfairB' 'NegLeftFairA'
		'PosLeftUnfairB' 'PosLeftFairA' 'NegRightUnfairB' 'NegRightFairA'
	};


	tActressPics = {
		'PosRightA' 'PosRightB'
		'PosLeftA' 'PosLeftB'
		'PosRightA' 'PosRightB'
		'PosLeftA' 'PosLeftB'
		'PosRightB' 'PosRightA'
		'PosLeftB' 'PosLeftA'
		'PosRightB' 'PosRightA'
		'PosLeftB' 'PosLeftA'
	};

	gActressPicFile = [];

	tPracFeedbackMovFNms = regexp( tFeedbackMovFNms, '(PosRight|PosLeft|NegRight|NegLeft)', 'tokens', 'once' );
	tPracFeedbackMovFNms = reshape( cat( 1, tPracFeedbackMovFNms{:} ), size( tPracFeedbackMovFNms ) );
	tPracFeedbackMovFNms =  strcat( tPracFeedbackMovFNms, 'C' );

	if ispc
		tActressPics = CFOUF( @(x) [ x '.jpg' ], tActressPics );
		tDistMovFNms = CFOUF( @(x) [ x '.mp4' ], tDistMovFNms );
		tFeedbackMovFNms = CFOUF( @(x) [ x '.mp4' ], tFeedbackMovFNms );
		tPracFeedbackMovFNms = CFOUF( @(x) [ x '.mp4' ], tPracFeedbackMovFNms );
	else
		tActressPics = CFOUF( @(x) [ x '.png' ], tActressPics );
		tDistMovFNms = CFOUF( @(x) [ x '.mp4' ], tDistMovFNms );
		tFeedbackMovFNms = CFOUF( @(x) [ x '.mov' ], tFeedbackMovFNms );
		tPracFeedbackMovFNms = CFOUF( @(x) [ x '.mov' ], tPracFeedbackMovFNms );
	end
	
    tSbjID = inputdlg( 'Subject ID for filename'' ''User input...' );
	
	tIsPGreen = strcmpi( questdlg('Positive Feedback Color','User input...', 'Green','Orange','Green'), 'Green' );
	tMovSeqSS = listdlg( 'ListString', tDistMovFNms(:,1), 'PromptString', 'Which movie first?' );
% 	tIsPLeft = strcmpi( questdlg('Toys first means positive is on:','User input...','Left','Right','Left'), 'Left' );
	tIsPLeft = strcmpi( questdlg('Positive Feedback Position','User input...','Left','Right','Left'), 'Left' );
	
	tDistMovFNms = tDistMovFNms( tMovSeqSS, : );
	if tIsPLeft
		if any( 1:2:7 == tMovSeqSS )
			% invert toys first == pos right association
			tActressPics = tActressPics( tMovSeqSS + 1, : );
			tFeedbackMovFNms = tFeedbackMovFNms( tMovSeqSS + 1, : );
			tPracFeedbackMovFNms = tPracFeedbackMovFNms( tMovSeqSS + 1, : );
		else
			tActressPics = tActressPics( tMovSeqSS, : );
			tFeedbackMovFNms = tFeedbackMovFNms( tMovSeqSS, : );
			tPracFeedbackMovFNms = tPracFeedbackMovFNms( tMovSeqSS, : );
		end
	else
		if any( 2:2:8 == tMovSeqSS )
			% invert snacks first == pos left association
			tActressPics = tActressPics( tMovSeqSS - 1, : );
			tFeedbackMovFNms = tFeedbackMovFNms( tMovSeqSS - 1, : );
			tPracFeedbackMovFNms = tPracFeedbackMovFNms( tMovSeqSS - 1, : );
		else
			tActressPics = tActressPics( tMovSeqSS, : );
			tFeedbackMovFNms = tFeedbackMovFNms( tMovSeqSS, : );
			tPracFeedbackMovFNms = tPracFeedbackMovFNms( tMovSeqSS, : );
		end
	end
	
	tPracTrlDelay = 3.0; % 10.0; %str2double( inputdlg( 'Practice Target Delay', 'User input...', 1, {'10.0'} ) );
	tPracTrlDur_PN = 30.0;
	tPracTrlDur_B = 60.0;
	tTrlDur = 90.0; % 60; %str2double( inputdlg( 'Trial Duration', 'User input...', 1, {'60.0'} ) );
	tMovTrlDelay = 5.0; % 5.0; %str2double( inputdlg( 'Movie Target Delay', 'User input...', 1, {'5.0'} ) );
	
	tIsShowCursor = strcmpi( questdlg('Show Cursor?','User input...','Yes','No','No'), 'Yes' );
	
	try
		Screen('Preference', 'SkipSyncTests', 1);

		AssertOpenGL;

		tScr=max(Screen('Screens'));
		% Open a double buffered fullscreen window.
		% Use imaging pipeline for good results:
		PsychImaging('PrepareConfiguration');
		tGryCol = [ 127 127 127 ];
		tW = PsychImaging('OpenWindow', tScr, tGryCol);
		[tWd,tHt] = Screen('WindowSize', tW);
		tScreenRct = [ 0 0 tWd tHt ];
		tDestRct = CenterRect( [ 0 0 floor(tWd/3) floor(tWd/4) ] , tScreenRct );
		
		[ tScrParams(1) tScrParams(2) ] = Screen('DisplaySize', tW);
		tScrParams = [ tWd tHt tScrParams / 10 ];
% 		assignin( 'base', 'tScrParams', tScrParams );

		tMP = []; % shared movie pointer
		tTH = []; % shared texture handle for movie playback
		tMovRct = []; % shared movie rect (i.e. "source" rect) for movie playback
		
		gTarg = [];
		tTargs.p.Nm = 'p';
		tTargs.n.Nm = 'n';
		if tIsPGreen
			tTargs.p.Col = [ 28 161 5 ];
			tTargs.n.Col = [ 255 112 0 ];
			tTargs.p.DrawButton = @DrawButton1;
			tTargs.n.DrawButton = @DrawButton2;
		else
			tTargs.p.Col = [ 255 112 0 ];
			tTargs.n.Col = [ 28 161 5 ];
			tTargs.p.DrawButton = @DrawButton2;
			tTargs.n.DrawButton = @DrawButton1;
		end

		if tIsPLeft
			tTargs.p.Rct = [ 0 0 floor(tWd/3) tHt ];
			tTargs.n.Rct = [ floor(2*tWd/3) 0, tWd, tHt ];
		else
			tTargs.p.Rct = [ floor(2*tWd/3) 0, tWd, tHt ];
			tTargs.n.Rct = [ 0 0 floor(tWd/3) tHt ];
		end
		
		InitializePsychSound;
% 		DrawIdle = @() Screen('DrawTexture', tW, tIdleTH, tMovRct, tDestRct );
		
		% prepare export table structure
		tHdr = { 'Mode' 'Seq' 'Stim' 'TrlNum' 'Resp' };
		tTbl = {};
		
		gXYB = []; % cursor data container
		gXYBN = 0; % cursor data container capacity
		iXYB = 1; % cursor data counter
		gTrgSR = 10; % target sample rate, Hz
		gTrgSI = 1.0 / gTrgSR; % target sample interval, sec
		
		ListenChar(2); % see notes on ListenChar(0) below
		gIPractice = 0;
		gIActress = 0;
		tIsBoth = false;
		gCh = 'g';
		tMode = 'x'; % init dummy value forces "switch tMode" below
		tIsFeedBackPlaying = false;

		HideCursor; % for actual experiment, baby must not be distracted by cursor
		if tIsShowCursor, ShowCursor; end% for ease of testing with mouse
		
		while true % practice v. experiment switching loop
			
			% test for state transition
			if CharAvail, gCh = GetChar; end
			if tMode ~= gCh
				% initialize new mode
				tMode = gCh;
				switch tMode
					case 'q'
						break;
					case 'g'
						Screen('Flip', tW); Screen('Flip', tW); % double-flip clears both frame buffers to uniform background color
					case 'k'
						gIPractice = gIPractice + 1;
						RunPractice;
						gCh = 'g';
					case 'm'
						RunExperiment;
						gCh = 'g';
				end
			end

		end  % practice v. experiment switching loop
		
		ShowCursor;
		ListenChar(0); % see notes on ListenChar(0) below
		Screen('CloseAll');
		Screen('Preference', 'SkipSyncTests', 0);
		ExportTbl;

		
	catch tME
		assignin( 'base', 'tME', tME );
		%this "catch" section executes in case of an error in the "try" section
		%above.  Importantly, it closes the onscreen window if its open.

		ShowCursor;
		ListenChar(0); % see notes on ListenChar(0) below
		Screen('CloseAll');
		Screen('Preference', 'SkipSyncTests', 0);
		psychrethrow(psychlasterror);
		ExportTbl;

	end %try..catch..
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% subfunctions...
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	function rSS = CSS( aS )
		if iscell( aS )
			rSS = cellfun( @CSS, aS );
		else
			rSS = find( ismember( tHdr, aS ) ); % column subscript
		end
	end
	
	function PrepareTargetDataRec( aDur )
		% reset cursor data container and counter
% 		gXYB = nan( ( round(aDur) + 2.0 ) * gTrgSR, 4 ); % trial duration plus buffer of 2 sec
		gXYBN = ( round(aDur) + 2.0 ) * gTrgSR;
		gXYB = nan( gXYBN, 4 ); % trial duration plus buffer of 2 sec
		iXYB = 1;
	end

	function EnlargeTargetDataRec
		% Add 60 secs to cursor data container
		tExtraN = 60.0 * gTrgSR;
		gXYB = cat( 1, gXYB, nan( tExtraN, 4 ) );
		gXYBN = gXYBN + tExtraN;
	end

	% must be preceded by gActressPicFile = regexprep( tActressPics{ gIActress }, 'A|B', 'C' );
	% or gActressPicFile = tActressPics{ gIActress };
% 	function DrawIdle, DrawIdleFromMovieFile; end
	function DrawIdle, DrawIdleFromImageFile; end

	function DrawIdleFromMovieFile
		[tMP, ~, ~, tMovWd, tMovHt ] = Screen( 'OpenMovie', tW, tTargs.p.MovFNm );
		tMovRct = [ 1, 1, tMovWd, tMovHt ];
		Screen( 'PlayMovie', tMP, 1 );
		tTH = Screen('GetMovieImage', tW, tMP );
		Screen( 'PlayMovie', tMP, 0 );
		Screen('DrawTexture', tW, tTH, tMovRct, tDestRct );
		Screen('Flip', tW, 0, 1); % preserves back buffer
		Screen('Close', tTH );		
		Screen( 'CloseMovie', tMP );
	end

	function DrawIdleFromImageFile
% 		tIm = imread( fullfile( pwd, 'FeedbackStim4', regexprep( tActressPics{ gIActress }, 'A|B', 'C' ) ) );
		tIm = imread( fullfile( pwd, 'FeedbackStim4', gActressPicFile ) );
		Screen('DrawTexture', tW, Screen( 'MakeTexture', tW, tIm ), [], tDestRct, 0 );
		Screen('Flip', tW, 0, 1); Screen('Flip', tW, 0, 1);  % "dontclear" double-flip sets both frame buffers to same state
	end

	function StartFeedbackMovie
		[tMP, ~, ~, tMovWd, tMovHt ] = Screen( 'OpenMovie', tW, gTarg.MovFNm ); 
		tMovRct = [ 1, 1, tMovWd, tMovHt ];
		Screen( 'PlayMovie', tMP, 1 );
		tIsFeedBackPlaying = 1;
	end

	function ShowNextFeedbackMovieFrame
		tTH = Screen('GetMovieImage', tW, tMP );
		if tTH > 0
			% texture handle refers to next movie frame data
			Screen('DrawTexture', tW, tTH, tMovRct, tDestRct );
			Screen('Flip', tW, 0, 1); % preserves back buffer
			Screen('Close', tTH );
		else
			StopFeedbackMovie;
		end
	end

	function StopFeedbackMovie
		Screen( 'PlayMovie', tMP, 0 );
		Screen( 'CloseMovie', tMP );
		DrawIdle; % Screen('Flip', tW, 0, 1); % preserves back buffer
		tIsFeedBackPlaying = false;
	end

	function CheckTargets( varargin )
		% CheckTargets or CheckTargets( true ) enables hit feedback;
		% CheckTargets( false ) disables feedback
		WaitSecs( gTrgSI );
		[tX,tY,tB] = GetMouse(tW);
		gXYB( iXYB, : ) = [ GetSecs tX tY tB(1)];
		iXYB = iXYB + 1;
		tIsFeedbackDisabled = nargin > 0 && varargin{1} == false;
		if tIsFeedbackDisabled, return; end
		if IsHit( tX, tB(1) )
			if ~tIsFeedBackPlaying, StartFeedbackMovie; end
		else
			if ~tIsFeedBackPlaying, return; end
		end
		ShowNextFeedbackMovieFrame;
		
	end

	function rIsHit = IsHit( aX, aB )
		if tIsBoth
			if xor(tIsPLeft, aX<tWd/2), gTarg = tTargs.n; else gTarg = tTargs.p; end
		end
		rIsHit = aX > gTarg.Rct(1) && aX < gTarg.Rct(3) && aB == 1;
	end

	function rTrgRec = GetTargRecStats( aDelay )
		
		if all( isnan( gXYB(:,1) ) ), rTrgRec = nan( 1, 8 ); return; end
		gXYB = gXYB( ~isnan( gXYB(:,1) ), : );
		gXYB(:,1) = gXYB(:,1) - gXYB(1,1) - aDelay;
		tIsTrgOn = gXYB(:,1) > 0.0;
		tIsHit = arrayfun( @IsHit, gXYB(:,2), gXYB(:,4) );
		tIsFA = ~tIsTrgOn & tIsHit; % "False Alarms"
		tIsNegSide = xor(tIsPLeft, gXYB(:,2)<tWd/2);
		tIsPos = tIsHit & ~tIsNegSide;
		tIsNeg = tIsHit & tIsNegSide;
		tIsHit = tIsTrgOn & tIsHit; % true "Hits", i.e. not false alarms
		tIsInRect = arrayfun( @(x,y) IsInRect(x,y,tDestRct), gXYB(:,2), gXYB(:,3) );
		tIsImOn = gXYB(:,1) > -aDelay;
		tIsImTch = gXYB(:,4) & tIsInRect & tIsImOn;
		tIsMiss = gXYB(:,4) & ~tIsHit & ~tIsFA & ~tIsImTch;
		rTrgRec = [ gXYB tIsHit tIsMiss tIsPos tIsNeg tIsFA tIsImTch ]; % T X Y B IsHit IsMiss IsPos IsNeg IsFA IsImTch
		
	end

	function RunPractice

		% timing variables for CheckTargets loop end
		tBegT = GetSecs;
		tTargT = tBegT + tPracTrlDelay;
% 		tEndT = tTargT + tPracTrlDur; % moved into "switch tMode" below
		tCurT = tBegT;
		
		while true % practice mode switching loop
			if CharAvail, gCh = GetChar; end % test for state transition request
			if gCh == 'q', break; end
			if tMode ~= gCh
				% initialize new mode
				tMode = gCh;
				
				gIActress = mod( gIPractice - 1, 2 ) + 1;
				if gIActress == 1
					tTargs.p.MovFNm = fullfile( pwd, 'FeedbackStim4', 'Movies', tPracFeedbackMovFNms{1} );
					tTargs.n.MovFNm = fullfile( pwd, 'FeedbackStim4', 'Movies', tPracFeedbackMovFNms{3} );
				else
					tTargs.p.MovFNm = fullfile( pwd, 'FeedbackStim4', 'Movies', tPracFeedbackMovFNms{2} );
					tTargs.n.MovFNm = fullfile( pwd, 'FeedbackStim4', 'Movies', tPracFeedbackMovFNms{4} );
				end

				switch tMode
					case 'g'
						Screen('Flip', tW); Screen('Flip', tW); % double-flip clears both frame buffers to uniform background color
						continue;
					case { 'p', 'n', 'P', 'N' }
						tIsBoth = false;
						gTarg = tTargs.(lower(tMode));
						SetMouse(tWd/2,tHt/2); % in absolute coordinates, so need to customize for second monitor
						tEndT = tTargT + tPracTrlDur_PN;
					case { 'b', 'B' }
						tIsBoth = true;
						SetMouse(tWd/2,tHt/2); % in absolute coordinates, so need to customize for second monitor
						tEndT = tTargT + tPracTrlDur_B;
				end
				
				PrepareTargetDataRec( 5 );
				Screen('Flip', tW); % clear the back buffer
				gActressPicFile = regexprep( tActressPics{ gIActress }, 'A|B', 'C' );
				DrawIdle;

				tIsTarg = false;
				while true % CheckTargets loop
					if CharAvail, gCh = GetChar; end % test for state transition request
					if tMode ~= gCh
						if tIsFeedBackPlaying, StopFeedbackMovie; end
						break;
					end
					if ~tIsTarg && tCurT > tTargT
						tIsTarg = true;
						if tMode == 'b'
							DrawBothTargets;
						else
							Screen('FillRect', tW, gTarg.Col, gTarg.Rct );
							gTarg.DrawButton( gTarg.Rct, gTarg.Col/255 );
						end
						Screen('Flip', tW, 0, 1);
					end
					if tCurT > tEndT && ~tIsFeedBackPlaying, gCh = 'q'; break; end
					CheckTargets;
					tCurT = GetSecs;
					if iXYB > gXYBN, EnlargeTargetDataRec; end
				end % CheckTargets loop

				tTbl = cat( 1, tTbl, { tMode [] [] gIPractice GetTargRecStats( 0.0 ) } ); % tHdr = { 'Mode' 'Seq' 'Stim' 'TrlNum' 'Resp' };
				
			end

		end  % practice mode switching loop

	end % function RunPractice

	function RunExperiment
		
		tIsBoth = true;
		Screen('Flip', tW); Screen('Flip', tW); % double-flip clears both frame buffers to uniform background color

		for iM = 1:4
			if WaitForStart
				PlayMovie( tDistMovFNms{iM} );
			else
				break;
			end
		end
		
		iP = 1;
		while WaitForStart
			gIActress = mod( iP-1, 2 ) + 1;
			if gIActress == 1
				tTargs.p.MovFNm = fullfile( pwd, 'FeedbackStim4', 'Movies', tFeedbackMovFNms{1} );
				tTargs.n.MovFNm = fullfile( pwd, 'FeedbackStim4', 'Movies', tFeedbackMovFNms{3} );
			else
				tTargs.p.MovFNm = fullfile( pwd, 'FeedbackStim4', 'Movies', tFeedbackMovFNms{2} );
				tTargs.n.MovFNm = fullfile( pwd, 'FeedbackStim4', 'Movies', tFeedbackMovFNms{4} );
			end
			gActressPicFile = tActressPics{ gIActress };
			ActorTrial;
			tTbl = cat( 1, tTbl, { 'Distribution' tMovSeqSS tActressPics{ gIActress }(1:(end-4)) iP GetTargRecStats( tMovTrlDelay ) } ); % tHdr = { 'Mode' 'Seq' 'Stim' 'TrlNum' 'Resp' };
			iP = iP + 1;
		end

	end

	function PlayMovie( aMvFNm )
		tIsPlay = 1;
		[tMP, ~, ~, tMovWd, tMovHt ] = Screen( 'OpenMovie', tW, fullfile( pwd, 'FeedbackStim4', 'Movies', aMvFNm ) );
		tMovRct = [ 1, 1, tMovWd, tMovHt ];
		Screen( 'PlayMovie', tMP, 1 );
		tTH = Screen('GetMovieImage', tW, tMP );
		while tTH > 0
			if tIsPlay
				Screen('DrawTexture', tW, tTH, tMovRct, tScreenRct );
				Screen('Flip', tW); % clears back buffer
				Screen('Close', tTH );
				tTH = Screen('GetMovieImage', tW, tMP );
			end
			if CharAvail
				tMCh = GetChar;
				if tMCh == ' '
					tIsPlay = xor( tIsPlay, true );
					Screen( 'PlayMovie', tMP, double(tIsPlay) );
				elseif tMCh == 'q'
					break;
				end
			end
		end;
		Screen( 'PlayMovie', tMP, 0 );
		Screen( 'CloseMovie', tMP );
		Screen('Flip', tW); % clears both buffers
	end

	function ActorTrial
		Screen('Flip', tW); Screen('Flip', tW); % double-flip clears both frame buffers to uniform background color
		DrawIdle;
		SetMouse(tWd/2,tHt/2); % in absolute coordinates, so need to customize for second monitor
		
		% when tPicTrlDelay < 0, targets first; requires extra space for target alone prelude data
		tTDRDur = tTrlDur + max( -tMovTrlDelay, 0.0 ); % target data rec duration, for PrepareTargetDataRec(...)
		PrepareTargetDataRec( tTDRDur );
		
		% still some work needed for tPicTrlDelay < 0
		
		tBegT = GetSecs;
		tTargT = tBegT + tMovTrlDelay;
		tEndT = tTargT + tTrlDur;
		tCurT = tBegT;
		
		tIsTarg = false;
		while tCurT < tEndT
			if CharAvail && GetChar == 'q', break; end
			if ~tIsTarg && tCurT > tTargT
				tIsTarg = true;
				DrawBothTargets;
				Screen('Flip', tW, 0, 1);
			end
			CheckTargets( tIsTarg ); % if tIsTarg, feedback delivered
			tCurT = GetSecs;
		end
		if tIsFeedBackPlaying, StopFeedbackMovie; end % in case of quit
		Screen('Flip', tW); Screen('Flip', tW); % double-flip clears both frame buffers to uniform background color
	end

	function ExportTbl
		
		assignin( 'base', 'tTbl', cat( 1, tHdr, tTbl ) );
		
		tNR = size(tTbl,1);
		tFullTbl = cell(tNR,1);
		for iR = 1:tNR
			tNTrgR = size( tTbl{ iR, CSS('Resp') }, 1 );
			tFullTbl{iR} = cat( 2, ...
				repmat( tTbl( iR, CSS({ 'Mode' 'Seq' 'Stim' 'TrlNum' }) ), tNTrgR, 1 ), ...
				num2cell( tTbl{ iR, CSS('Resp') } ) ...
			);
		end
		tFullTbl = cat( 1, tFullTbl{:} );
		
		tHdr = { 'Mode' 'Seq' 'Stim' 'TrlNum' 'T' 'X' 'Y' 'B' 'IsHit' 'IsMiss' 'IsPos' 'IsNeg' 'IsFA' 'IsImTch' };
        tFullTbl = cat( 1, tHdr, tFullTbl );
		assignin( 'base', 'tFullTbl', tFullTbl );
        
        save( fullfile( pwd, tSbjID{1} ), 'tFullTbl', 'tScrParams', 'gTrgSR', 'gTrgSI', 'tDestRct' );
		
	end

	function DrawBothTargets
		Screen('FillRect', tW, tTargs.p.Col, tTargs.p.Rct );
		Screen('FillRect', tW, tTargs.n.Col, tTargs.n.Rct );
		tTargs.p.DrawButton( tTargs.p.Rct, tTargs.p.Col/255 );
		tTargs.n.DrawButton( tTargs.n.Rct, tTargs.n.Col/255 );
	end

	function DrawButton1( aRct, aCol )
		tIm = imread( fullfile( pwd, 'FeedbackStim4', 'Button1.png' ), 'BackgroundColor', aCol );
		tDstRct = CenterRect( [ 0 0 200 200 ], aRct );
		Screen('DrawTexture', tW, Screen( 'MakeTexture', tW, tIm ), [], tDstRct );
	end

	function DrawButton2( aRct, aCol )
		tIm = imread( fullfile( pwd, 'FeedbackStim4', 'Button2.png' ), 'BackgroundColor', aCol );
		tDstRct = CenterRect( [ 0 0 170 170 ], aRct );
		Screen('DrawTexture', tW, Screen( 'MakeTexture', tW, tIm ), [], tDstRct );
	end

	function rVal = WaitForStart
		while true
			if CharAvail
				rVal = GetChar;
				if rVal == ' '
					rVal = true;
				elseif rVal == 'q'
					rVal = false;
				else
					continue;
				end
				break;
			end
		end
	end

end


% If unhandled error causes return to Matlab command line before execution
% of ListenChar(0), keyboard input will be disabled.  It can be restored by
% keying in Cmd-C.















