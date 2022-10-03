%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Online Feedback Experiment 
% Version 1.0 on 06/17/2013 by Nada Attar (nada.attar001@umb.edu)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DoExperimentWord( window, el , imgfolder, wRect)
% Do drift correction before start the array of images:
% EyeLink('dodriftcorrect');
EyelinkDoDriftCorrect(el);

[width, height] = Screen('WindowSize', el.window);

% where to display the image:
rect = [wRect(1)+50, wRect(2)+50, wRect(3)-50, wRect(4)-50];

KbName('UnifyKeyNames');
while KbCheck; end % clear keyboard queue

imgfiles = dir(strcat(imgfolder,'/*.jpg'));  % .jpg or jpeg
maskfiles = dir(strcat('mask','/*.jpg'));
length(imgfiles)

load('Random_Order.mat');

% Number of total images in the file 'images'
totalImages = length(imgfiles);

% % PRACTICE TEST
% % Maximum number of blockCounters
% maxBlocks = 3;
% % Maximum trials per blockCounter
% maxTrialsPerBlock = 5;
% i = 80;


% ACTUAL EXPERIMENT
% Maximum number of blockCounters = 6
maxBlocks = 1;
% Maximum trials per blockCounter = 10s
maxTrialsPerBlock = 2;
% i = random image
i = 0;



% Varaible for the type of the next blockCounter:
blockCounter = 1;
imageDisplayCounter = 1;
displayImageInterval = 1.00;
TotalTimePerTrial = 10.00;  %seconds

while blockCounter <= maxBlocks
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize Trial
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Initialize Trial\n');
    % Drop out if connection has been closed
    if (~Eyelink('isconnected'))
        return;
    else
        % Start EyeLink recording
        Eyelink('StartRecording');
    end;
    
    % Display Screen to Introduce the Type of the Block (memory,no-memory)
    % @blockType: Text of the blockCounter type to display it on the Screen
    blockType = '';
    message = sprintf('Block Number: %d', blockCounter)
    Eyelink('message', '%s', message);
    DisplayBlockTitle(window, blockType, blockCounter);
    WaitSecs(0.01);
    
    for trialCounter = 1:maxTrialsPerBlock
        message = sprintf('Start Trial: %d', trialCounter)
        Eyelink('message', '%s', message);
        
        % random image
        i = i + 1;  
        if i > totalImages
            i = 0;
        end
        
        % Choose Random image from the folder
        currentfilename=imread(strcat(imgfolder, '/', char(imgfiles(r(i)).name)));
        % Read target_n_n_n_n.txt that has the correct answers
        % for the particular display:
        [totalNumberOfTargets, word] = ReadTargetFile(imgfiles(r(i)).name, imgfolder)
        DisplayTargetWord( window, word);
        
        
        %put the fixation first for each image
        INTERRUPTION(window , width, height, 'Fixation Point', '', imgfolder, maskfiles, rect);
        
        % Put image on screen
        message = sprintf('Display First Image Starts: %s', char(imgfiles(r(i)).name))
        Eyelink('message', '%s', message);
        
        % now visible on screen
        Screen('PutImage', window, currentfilename, rect);
        Screen('Flip',window);   
                
        % Loop for Subject's Response:
        % If subject is in no-memory Block: Change the Image After Each
        % Interruption up to 10 Different Images. If Subject is in Memory
        % Block: Display the Same Image 10 times
        done = false;
        imgTime = 0;
        timeToChooseOneOption = 0;
       
        targetsCounter = 0;
        
        
        while (~done)  & imgTime <= TotalTimePerTrial % 5 seconds per trial
            tic;
            % Read keyboard input, break out of loop on stop key
            [keyIsDown, secs, keyCode] = KbCheck;
            if keyIsDown
                if keyCode( KbName('SPACE'))
                    message = sprintf('SPACE Pressed')
                    Eyelink('message', '%s', message);
                    FlushEvents('keyDown');

                    % Get the Subject's Response and Compare it with the
                    % Actual Target's Direction:
                    
%                     % Read target_n_n_n_n.txt that has the correct answers
%                     % for the particular display:
%                     [totalNumberOfTargets] = ReadTargetFile(imgfiles(r(i)).name, imgfolder)
%                     
                    % Take subject to another screen where 4 options where
                    % adisplayed andsubjects need to choose the correct
                    % answers among the 4 choices
                    
                    % %%%%%%%%%%%%%%%%% TIME PAUSE %%%%%%%%%%%%%%%%%%%%%
                    [answer, testCorrect, timeToChooseOneOption] = DisplayBlankScreenForReEntering( totalNumberOfTargets, window , width, height, rect);
                    message = sprintf('Image: %s, Key Pressed: %d, Target: %d', imgfiles(r(i)).name, answer, totalNumberOfTargets)
                    Eyelink('message', '%s', message);
                    % %%%%%%%%%%%%%%%% TIME Resume %%%%%%%%%%%%%%%%%%%%%
                    
                    GenerateFeedbackSound( testCorrect );
                                        
                    message = sprintf('Display Image Ends');
                    Eyelink('message', '%s', message);
                    
                    FlushEvents('keyDown');
                    done = true;
                    BriefGrayScreen(window);
                    
                elseif keyCode( KbName('x'))
                    targetsCounter = targetsCounter + 1;
                    if targetsCounter <= totalNumberOfTargets
                        message = sprintf('%d out of: %d Targets During Trial', targetsCounter, totalNumberOfTargets)
                        Eyelink('message', '%s', message);
                        GenerateFeedbackSound( 1 );
                    elseif targetsCounter > totalNumberOfTargets
                        message = sprintf('%d out of: %d Wrong Number of Targets During Trial', targetsCounter, totalNumberOfTargets)
                        Eyelink('message', '%s', message);    
                        GenerateFeedbackSound( 0 );
                    end
                    FlushEvents('keyDown');
                end
            end
            imgTime = imgTime + toc;
        end
        %imgTime = imgTime - timeToChooseOneOption;
        message = sprintf('End Trial For Total Time: %0.4f Time to Re-enter the answer: %0.4f', imgTime, timeToChooseOneOption)
        Eyelink('message', '%s', message);
        
    end
    message = sprintf('End Block Number: %d, Block Type: %s', blockCounter, blockType)
    Eyelink('message', '%s', message);
    blockCounter = blockCounter + 1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Stop EyeLink recording
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Stop EyeLink recording\n');
    % Stop EyeLink recording
    Eyelink('StopRecording');
    % Wait a bit to store data
    WaitSecs(0.2);
end

end

function [done,displayTime, timeToChooseOneOption] = INTERRUPTION(window , width, height, intrr, imageName, imgfolder, maskfiles, rect)
done = false;
if strfind(intrr, 'Fixation Point')
    message0 = sprintf('Fixation Point Before Displaying A New Image Starts');
    message1 = 'Fixation Point Before Displaying A New Image Ends';
    % Check if this intermittent point needs a key response
    keyResponse = 0;
elseif strfind(intrr, 'Last')
    message0 = sprintf('Last Interruption Time Starts');
    message1 = 'Last Interruption Time Ends';
    keyResponse = 0;
else
    message0 = sprintf('Interruption Time Starts') ;
    message1 = 'Interruption Time Ends';
    % This is the only interruption point where the subject
    % response is allowed
    keyResponse = 1;
end

message = message0;
Eyelink('message', '%s', message);

% 1.Plus sign only in the middle of the screen
Screen('FillRect', window, [128,128,128]);

% % 2.Plus Sign with the mask of points
% currentfilename=imread(strcat('mask', '/', char(maskfiles(1).name)));
% Screen('PutImage', window, currentfilename, rect);

DrawCrossSign( window , width, height , [0,0,0]);
Screen('Flip', window);

if keyResponse
    [done, displayTime, timeToChooseOneOption] = WaitForKeyResponse(window , width, height,imageName, imgfolder, maskfiles, rect);
else
    WaitSecs(3.0);
end

DrawCrossSign( window , width, height , [0,0,0]);
Screen('Flip', window);

message = message1;
Eyelink('message', '%s', message);
end

function [done, displayTime, timeToChooseOneOption] = WaitForKeyResponse(window , width, height,imageName, imgfolder, maskfiles, rect)
done = false;
displayTime = 0;
timeToChooseOneOption = 0;
while (~done) & displayTime < 3.0000  % 3 Seconds = 3000 Milliseconds
    tic;
    % Read keyboard input, break out of loop on stop key
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown
        if keyCode( KbName('SPACE'))
            message = sprintf('SPACE Pressed')
            Eyelink('message', '%s', message);
            
            % Get the Subject's Response and Compare it with the
            % Actual Target's Direction:
            
            % Read target_n_n_n_n.txt that has the correct answers
            % for the particular display:
            [totalNumberOfTargets, circle1,circle2, circle3, circle4] = ReadTargetFile(imageName, imgfolder);
            
            % Generate 4 choices to the user that are similar to
            % the correct answer:
            [choice1, choice2, choice3, choice4, indexOfCorrectAnswer] = GenerateFourMultipleChoices(totalNumberOfTargets, circle1,circle2, circle3, circle4);
            
            % Take subject to another screen where 4 options where
            % adisplayed andsubjects need to choose the correct
            % answers among the 4 choices
            
            % %%%%%%%%%%%%%%%%% TIME PAUSE %%%%%%%%%%%%%%%%%%%%%
            [answer, testCorrect, timeToChooseOneOption] = DisplayFourChoices(choice1, choice2, choice3, choice4, indexOfCorrectAnswer, window , width, height, rect);
            message = sprintf('Image: %s, Key Pressed: %d, Target: %d', imageName, answer, indexOfCorrectAnswer)
            Eyelink('message', '%s', message);
            % %%%%%%%%%%%%%%%% TIME Resume %%%%%%%%%%%%%%%%%%%%%
            
            GenerateFeedbackSound( testCorrect );
            
            message = sprintf('Display Image Ends');
            Eyelink('message', '%s', message);
            
            % call interruption function
            INTERRUPTION(window , width, height, 'Last', '',imgfolder, maskfiles, rect);
            
            FlushEvents('keyDown');
            done = true;
            BriefGrayScreen(window);
        end
    end
    displayTime = displayTime + toc;
end

end

function EndExperimentESCAPE(key)
%If the key is quit program and save EDF file
message = sprintf('Pressed Key is: %s',  key);
Eyelink('message', '%s', message);
fprintf('\n');
fprintf('Quit program and save EDF file');
end