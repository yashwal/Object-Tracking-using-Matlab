redThresh = 0.24; % Threshold for red detection
greenThresh = 0.05; % Threshold for green detection
blueThresh = 0.15; % Threshold for blue detection

answer = questdlg('Which colour would you like to track?', ...
'Colour',...
'Red','Green','Blue','Red');
% Handle response
switch answer
    case 'Red'
        f = msgbox('Red objects shall be detected.')
        colour = 1;
    case 'Green'
        f = msgbox('Green objects shall be detected.')
        colour = 2;
    case 'Blue'
        f = msgbox('Blue objects shall be detected.')
        colour = 3;
end

%f = msgbox('Operation Completed','Success');
%f = msgbox('Invalid Value', 'Error','error');

% Capture the video frames using the videoinput function
% You have to replace the resolution & your installed adaptor name.
vid = videoinput('winvideo',1);

% Set the properties of the video object
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorspace', 'rgb')
vid.FrameGrabInterval = 2;

%start the video aquisition here
start(vid)

% Set a loop that stop after 100 frames of aquisition
while(vid.FramesAcquired<=100)
    
    % Get the snapshot of the current frame
    data = getsnapshot(vid);    
    % Now to track red objects in real time
    % we have to subtract the red component 
    % from the grayscale image to extract the red components in the image.
    diff_im = imsubtract(data(:,:,colour), rgb2gray(data));
    %Use a median filter to filter out noise
    diff_im = medfilt2(diff_im, [3 3]);
    % Convert the resulting grayscale image into a binary image.
    diff_im = im2bw(diff_im,blueThresh);
    
    % Remove all those pixels less than 300px
    diff_im = bwareaopen(diff_im,300);
    
    % Label all the connected components in the image.
    bw = bwlabel(diff_im, 8);
    
    % Here we do the image blob analysis.
    % We get a set of properties for each labeled region.
    stats = regionprops(bw, 'BoundingBox', 'Centroid');
    
    % Display the image
    imshow(data)
    
    hold on
    
    %This is a loop to bound the red objects in a rectangular box.
    for object = 1:length(stats)
        bb = stats(object).BoundingBox;
        bc = stats(object).Centroid;
        rectangle('Position',bb,'EdgeColor','y','LineWidth',2)
        plot(bc(1),bc(2), '-m+')
        a=text(bc(1)+25,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
        set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 8, 'Color', 'black');
    end
    
    hold off
end
% Both the loops end here.

delete(findall(0));
%close(vid);
% Stop the video aquisition.
stop(vid);

% Flush all the image data stored in the memory buffer.
flushdata(vid);
%delete(vid);

%f = msgbox('Operation Completed','Success');
% Clear all variables
clear all