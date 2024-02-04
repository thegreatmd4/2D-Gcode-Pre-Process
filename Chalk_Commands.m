clc; clear; close all;

%xy_gcode = splitlines(fileread('W_Simplified.gcode'));     % Read GCode
[filename, pathname] = uigetfile({'*.gcode'},'Select the GCODE file');
if isequal(filename,0)
   disp('User selected Cancel')
else
   disp(['User selected ', fullfile(pathname, filename)])
   xy_gcode = splitlines(fileread(fullfile(pathname, filename)));
end

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

Chalk_Active = 0;                               % Bolean Value for chalk
Distance_Chalk_Active = 0;                      % Driven Distance by chalk
for i=1:nl
    if xy_Commands(i,3)~=0
        Chalk_Active = not(Chalk_Active);       % Toggle the chalk
    end
    xy_Commands(i,4) = Chalk_Active;            % Check chalk for each line
end

for i=1:nl-3
    if xy_Commands(i+1,4)&&xy_Commands(i+2,4)&&xy_Commands(i+3,4)
        x1=xy_Commands(i+2,1);
        x2=xy_Commands(i+3,1);
        y1=xy_Commands(i+2,2);
        y2=xy_Commands(i+3,2);                  % Calc. the driven dis. (Usage)
        Distance_Chalk_Active = Distance_Chalk_Active+...
                                sqrt((x2-x1)^2+(y2-y1)^2);  

        z=Distance_Chalk_Active/37795.2*80;     % 37795.2 mm distance = 255 pulse servomotor
        xy_Commands(i+2,5)=floor(z)+10;          % Round the Z command - CAN BE IMPROVED
    end
end

Delete = []; 
xyz_gcode = cell(nl,1);                         % Initialize 3D gcode
for i=1:nl-1
    line = string(xy_gcode(i));                 % Get the 2D gcode
    if contains(xy_gcode(i),'Z')                % Delete the old Z
        %line = erase(line,extractBetween(xy_gcode(i),'Z',';'));
        %line = erase(line,' Z');
        line ={};                               % Empty old line with z=68.0
        Delete = [Delete,i]; %#ok               % Gather empty lines to eliminate afterwards 
    end
    line = erase(line,";");                     % Delete ";"
    line = line+" Z"+xy_Commands(i,5)+".0;";      % Add Z+ ";"   .0 because of Arduino
    xyz_gcode(i)={line};                        % Save line as cell
end

Delete = uint64(Delete);
xyz_gcode(Delete) = [];                         % Eliminate empty lines


writecell(xyz_gcode,[filename(1),'_Chalk.txt']) % Save new gcode
movefile([filename(1),'_Chalk.txt'],[filename(1),'_Chalk.gcode'])






