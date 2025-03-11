%% Initialize everything
close all
clear variables

samp_rate_hz = 8000;
samp_rate_frame = 25;
                 % HZ  , BYTE CNT
tx = soundTransmit(samp_rate_hz, samp_rate_frame);
tx.init();
%tx.start_reader();

%rx = s_recover();

%% Record Msg

global press;
global e;
press = 0;
e = uicontrol("Style","pushbutton","String","Stop Button",Callback=@s);

function s(src, event)
    global press;
    global e;
    press = 1;
    delete(e);
    close();
end

pause(1);

out = [];
res = [];

while (~press)
    res = tx();
    res(res == '-') = [];

    if ~isempty(res)
        out = [out; res';];
        %sound_d = rx(res);
        %sound(sound_d, samp_rate_hz);
    end

    %if ~isempty(res)
    %    out = [out; res];
    %end

    % Needed so the button press can be detected.
    pause(0.0001);
end

%% Play Sound

% Probably can integrate this one into s_recover stepImpl but not sure how
% the sound driver would behave?

sound(sound_arr, samp_rate_hz);