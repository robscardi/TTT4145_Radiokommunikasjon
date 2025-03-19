%% Initialize everything
close all
clear variables

samp_rate_hz = 15000;
samp_rate_frame = 300;
                 % HZ  , BYTE CNT
tx = s_transmit(samp_rate_hz, samp_rate_frame);
rx = s_recover(samp_rate_hz, samp_rate_frame);

%% Record Msg

global press;
global e;
press = 0;
e = uicontrol("Style","pushbutton","String","Stop Button",Callback=@s);

% Needed for button to work and trigger within while loop
function s(src, event)
    global press;
    global e;
    press = 1;
    delete(e);
    close();
end

pause(1);

res = [];

while (~press)
    %Get Sound Data
    otu = tx();
    rx(otu);
    %Recommend hz = 15000, frame = 300
    %If you want i can introduce a splice method bcs rn one packet is at
    %2400x1 instead of 200, the quality was too bad and this seems like
    %perfect spot
    % You can test it at hz 10000, frame 200 meaning the packet is 1600x1

    %The sound was much better with packets of 6800x1 at hz = 16000 and
    %frame = 800-400 It was Really good at hz = 16000 and frame = 1600
    %Aka higher frame higher qulity. (Try to match frame as a factor of hz)
    
    % Needed so the button press can be detected.
    pause(0.0001);
end