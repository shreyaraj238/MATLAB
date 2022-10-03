%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Online Feedback Experiment 
% Version 1.0 on 06/17/2013 by Nada Attar (nada.attar001@umb.edu)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function OnlineFeedback()
% Clear Matlab/Octave window:
clc;
clear all;  %
commandwindow;  %

warning('off','MATLAB:dispatcher:InexactCaseMatch')
Screen('Preference', 'SkipSyncTests', 1);

% --------------------- ---------------------------------------------------

% check for Opengl compatibility, abort otherwise:
AssertOpenGL;

% % Check if required parameter given:
% if (nargin ~= 1 || isDummyMode ~= 1)
%     isDummyMode = 0;
% end
%    
% isDummyMode = 0;  % forced!!!!!!!!

% imgfolder = input('\nInter Name of Image Folder:', 's');
%imgfolder = 'images for control/jpged Astro';
readfolder = 'read';
  
try
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize Eyelink Connection and Data file.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Initialize Eyelink Connection and Data file\n' );
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize Display Screen
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Initialize Display Screen\n' );
    % Open a graphics window on the main screen
    % using the PsychToolbox's Screen function.
    screenNumber = 1;%max(Screen('Screens'));
    %changed from 0 to 1 to have dual window on mac  
  
    [window, wRect] = Screen('OpenWindow', screenNumber, BlackIndex(screenNumber));
    % Line smoothing doesn't work with alpha-blending disabled!
    % See Screen('BlendFunction') on how to enable it.
    Screen('FillRect', window, wRect);
    
    % % NJ step 1. initialize eyelink default values after opening screen.
    % needed for calibration
%     el = EyelinkInitDefaults(window);
    
    % NJ step 2. initialize Eyelink. use Eyelink toolboxes initialization
    % functions
%     if ~EyelinkInit(isDummyMode)
%         fprintf('Eyelink Init aborted.\n');
%         return;
%     end
    
%     [v vs] = Eyelink('GetTrackerVersion');
%     fprintf('Running experiment on a ''%s'' tracker.\n', vs );
%     
    %NJ make sure you have the latest PTB
    [versionString, vs] = PsychtoolboxVersion;
    %NJ make sure you have the latest PTB
    if([vs.major vs.minor vs.point] ~= [3 0 8])
        fprintf('WARNING: this file is modified to run on PTB 3.0.8 \n');
        fprintf('Currently running on PTB %d.%d.%d\n',vs.major, vs.minor, vs.point);
        fprintf('Please run UpdatePsychtoolbox to get latest PTB version');
    end
    
    %NJ step 3 open data file
    % If file initialize failed, should exit the experiment
    fileNameBase = '';
%     [fullFileName, myerr] = InitEyelinkDataFile(fileNameBase);
    
%     % check for existing result file
%     if (myerr==1)
%         CleanUpEyelinkExperiment;
%         return;
%     else
%         % open ASCII file for writing
%         dataFilePointer = fopen(strcat(fullFileName), 'wt');
%     end
    
    % Hide the mouse cursor:
    
    % Reseed the random-number generator for each expt.
    stream = RandStream('mt19937ar','seed', sum(100*clock));   % %
    RandStream.setGlobalStream(stream);       % %
    
    % Make sure keyboard mapping is the same on all supported operating systems
    % Apple MacOS/X, MS-Windows and GNU/Linux:
    KbName('UnifyKeyNames');
    % Do dummy calls to GetSecs, WaitSecs, KbCheck to make sure
    % they are loaded and ready when we need them - without delays
    % in the wrong moment:
    KbCheck;
    WaitSecs(0.1);
    GetSecs;
    
    % initialize KbCheck and variables to make sure they're
    % properly initialized/allocted by Matlab - this to avoid time
    % delays in the critical reaction time measurement part of the
    % script:
    [KeyIsDown, endrt, KeyCode] = KbCheck;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize & Calibration Eyelink Tracker
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Initialize & Calibration Eyelink Tracker\n' );
    % Set up tracker configuration, data contents and EyeLink traker
%     el = InitEyelinkTracker(window);
%     % Calibrate the eye tracker
%     if (isDummyMode~=1)
%         EyelinkDoTrackerSetup(el);
%     end
    
    
    [width, height] = Screen('WindowSize', screenNumber);
    
    
    %% Run main experiment function:
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Run main experiment function
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Run Main Experiment Function\n\n' );
    
    %--------------------------------------------------
    % Display 
    DisplayExperimentTitle ( window ); % 0.01
    %--------------------------------------------------
     
    % Experiment Function
    DoExperiment(window, wRect);
   
    
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Prepare data then Save on EyeLink recording
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Prepare data then Save on EyeLink recording\n');
%     Eyelink('message', '%s', 'end trail');
   
    WaitSecs(0.5);
    
    % Display thank you message
    DisplayThankYou(window);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Finalize Eyelink Experiment
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Finalize Eyelink Experiment\n' );
    
    % transfer data file
%     TransferFile( fullFileName );
    
    % Clean up Eyelink Experiment
    fprintf('CleanUpEyelinkExperiment\n\n' );
%     CleanUpEyelinkExperiment;
    
    return;
    
catch ME
    
    % Catch error then print
    error(ME.message);
    
    % Do same cleanup as at the end of a regular session...
%     CleanUpEyelinkExperiment;
    
    % Output the error message that describes the error:
    psychrethrow(psychlasterror);
end
