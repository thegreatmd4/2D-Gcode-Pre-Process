clc; clear; close all;

%xy_gcode = splitlines(fileread('W.gcode'));     % Read GCode
[filename, pathname] = uigetfile({'*.gcode'},'Select the GCODE file');
if isequal(filename,0)
   disp('User selected Cancel')
else
   disp(['User selected ', fullfile(pathname, filename)])
   xy_gcode = splitlines(fileread(fullfile(pathname, filename)));
end

%xy_gcode = xy_gcode(17:end-2);                  % Ignore Initialization

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

Threshold = 40;
New_Lines = 0;
for i=2:nl+New_Lines
    x1 = xy_Commands(i-1,1);
    x2 = xy_Commands(i,1);
    dx = x2-x1;
    y1 = xy_Commands(i-1,2);
    y2 = xy_Commands(i,2);
    dy = y2-y1;
    Distance = sqrt(dx^2+dy^2);
    if Distance>Threshold
        xy_Commands(i+1:end+1,:) = xy_Commands(i:end,:);
        x_new = x1 + Threshold/Distance*dx;
        y_new = y1 + Threshold/Distance*dy;
        xy_Commands(i,1)=x_new;
        xy_Commands(i,2)=y_new;
        New_Lines = New_Lines+1;
    end
end

nl = nl + New_Lines;
xyz_gcode = cell(nl,1);                         % Initialize 3D gcode
for i=1:nl
    x = xy_Commands(i,1);
    y = xy_Commands(i,2);
    z = xy_Commands(i,3);

    z=sprintf( '%.4f', z );

    if ~isnan(x)
        x=sprintf( '%.4f', x );                 % Keeps the digits always 4
        y=sprintf( '%.4f', y );
        line = "G00 F1500 X"+x+" Y"+y+";";
    else
        line = "G00 F1500 Z"+z+";";
    end
    xyz_gcode(i)={line};                        % Save line as cell
end

writecell(xyz_gcode,[filename(1),'_Segmented.txt']) % Save new gcode
movefile([filename(1),'_Segmented.txt'],[filename(1),'_Segmented.gcode'])






