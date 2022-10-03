function [totalNumberOfTargets, word, displayName] = ReadTargetFile(imageName, imgfolder)
word = '';

% Open the text fiel 'Target' to read the number of targets in each circle
% and the total number of targets.
imgNumber = strtok(imageName, 'image');
imgNumber = strtok(imgNumber, '.');
imgNumber = str2double(imgNumber);
% Read the text file to identify the target direction: item type in the text
% file (last column) 1 means horizontal target and 2 means vertical target

% Check and change image77 -> image077, image2 -> image002, ...
if length(num2str(imgNumber)) == 1    %ex: image8 -> image008
    displayName = strcat(imgfolder,'/','targets00',num2str(imgNumber),'.txt');
elseif length(num2str(imgNumber)) == 2
        displayName = strcat(imgfolder,'/','targets0',num2str(imgNumber),'.txt');
else
    displayName = strcat(imgfolder,'/','targets',num2str(imgNumber),'.txt');
end

fid1 =fopen(displayName, 'r');



getOneLine = fgetl(fid1);
splitGetOneLine = regexp(getOneLine,'([^ \t][^\t]*)', 'match');

% Store the total number of targets and the targets in each circle
totalNumberOfTargets = str2double(splitGetOneLine(1));
if length(splitGetOneLine) > 1
    word = splitGetOneLine(2)
end

fclose(fid1);
end

