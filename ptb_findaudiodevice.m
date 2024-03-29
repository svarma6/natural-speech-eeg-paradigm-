function [dix] = ptb_findaudiodevice(dname)

% [dix] = ptb_findaudiodevice
%
% dix - index of primary sound driver device
%
% Description: The script provides the id for the primary sound driver.
% ----------------------------------------------------------------------


dix = [];
devices = PsychPortAudio('GetDevices');
for ii = 1 : length(devices)
	if strcmp(devices(ii).DeviceName,dname)
		dix = devices(ii).DeviceIndex;
	end
end
disp([devices(dix+1).DeviceName ' selected!'])
