function CleanUpEyelinkExperiment
% Close window, show mouse cursor, close result file,
% switch Matlab/Octave back to priority 0 -- normal priority
Screen('CloseAll');
ShowCursor;
fclose('all');
Priority(0);

% Close EyeLink data file, give tracker time to excute all commands.
Eyelink('closefile');
WaitSecs(1.0);
Eyelink('shutdown');

end

