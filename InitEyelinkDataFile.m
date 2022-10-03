%Initialize data file on both local and Eyelink server
function [edfFileName, myerr] = InitEyelinkDataFile( edfFileNameBase )

    % Define filename of result file:
    myerr=0;  
    currPath = pwd; 
    filepath = './';
    
    % Update current path then get main file name
    cd(filepath);
    [edfFileName, filepath] = uiputfile('*.edf', 'Data file name? (File name must be less than 8 chars)', edfFileNameBase);		
    cd(currPath);
    
    % if empty, exit program
    if ( isempty(edfFileName) )	
        fprintf('File name required.\n');
        myerr = 1;
        return
    end;

    % if more than 8 chars, exit program
    if ( length(edfFileName)>12 )	
        fprintf('File name must be less than 8 chars excluding 3 chars extension.\n');
        myerr = 1;
        return
    end;
    
    
    % use default path if empty
    if ( isempty(filepath) )
        filepath = currPath; 
    end;				
    
    fullEdfFileName = strcat(filepath, edfFileName);
    
    % check for existing result file to prevent accidentally overwriting
    % files from a previous subject/session (except for subject numbers > 99):
    if ((fopen(fullEdfFileName, 'rt')~=-1))
        fclose('all');
        disp('Result data file already exists! Choose a different subject number.');   
        myerr=1;        
    else
        % Check EyeLink data file avalability
        if (~Eyelink('isconnected')) 
            disp(strcat('Connection problem, cannot create EDF file  ', edfFileName));
            fclose('all');
            myerr=1;
        else
        	% Check EyeLink data file avalability and open the host file
            if (Eyelink('openfile', edfFileName)~=0)
                disp(strcat('Cannot create EDF file on server ', edfFileName));
                Eyelink('shutdown');
                fclose('all');
                myerr=1;
            end
        end
    end
end

