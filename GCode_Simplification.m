clc; clear; close all;

%xy_gcode = splitlines(fileread('W.gcode'));     % Read GCode
[filename, pathname] = uigetfile({'*.gcode'},'Select the GCODE file');
if isequal(filename,0)
   disp('User selected Cancel')
else
   disp(['User selected ', fullfile(pathname, filename)])
   xy_gcode = splitlines(fileread(fullfile(pathname, filename)));
end

xy_gcode = xy_gcode(17:end-2);                  % Ignore Initialization

nl = length(xy_gcode);                          % # of Commands
xy_Commands = zeros(nl,3);                      % Convert Commands
for i=1:nl
    if contains(xy_gcode(i),'X')
        xy_Commands(i,1) = str2double(extractBetween(xy_gcode(i),'X',' Y'));
    else
        xy_Commands(i,1) = NaN;
    end
    if contains(xy_gcode(i),'Y')
        xy_Commands(i,2) = str2double(extractBetween(xy_gcode(i),'Y',';'));
    else
        xy_Commands(i,2) = NaN;
    end
    if contains(xy_gcode(i),'Z')
        xy_Commands(i,3) = str2double(extractBetween(xy_gcode(i),'Z',';'));
    end
end

np = 3;                                         % Size of the checked sequence

Corrs = zeros(nl-np,1);                         % Initialize the vecror of Rsq
Delete = [];                                    % Initialize the candidates for elimination
for i=1:nl-np
    X = xy_Commands(i:i+np,1);                  % X vector of the sequence
    Y = xy_Commands(i:i+np,2);                  % Y vector of the sequence
    Corr = corrcoef(Y,X);                       % Calc the Regression
    Corrs(i)=abs(Corr(1,2));                    % Consider the abs. val.
    if Corrs(i)>0.75 && xy_Commands(i+1,3)==0   % Threshhold
        Delete = [Delete,i+1]; %#ok             % Gather the elim. Candidates
    end
    
end
Delete = uint64(Delete);
xy_gcode(Delete) = [];                          % Eliminate unnecessary points
plot(Corrs)                                     % Show the correlations

xy_gcode(2:end+1) = xy_gcode(1:end);
xy_gcode(1) = {"G00 F1500 X975.5000000000000 Y958.4300000000000;"};

writecell(xy_gcode,[filename(1),'_Simplified.txt']) % Save the file
movefile([filename(1),'_Simplified.txt'],[filename(1),'_Simplified.gcode'])






