function [psychtoolbox_trigger_id] = TriggerInit()

psychtoolbox_trigger_id=[];

% List of vendor IDs for valid FORP devices:
vendorIDs = [1240];

KeyPressed  =   '';
keydata     =   [];

% Try to detect first FORP device at first invocation:
if isempty(psychtoolbox_trigger_id)
    Devices = PsychHID('Devices');
    % Loop through all KEYBOARD devices with the vendorID of FORP's vendor:
    for i=1:size(Devices,2)
        if strcmp(Devices(i).usageName,'Keyboard') & ismember(Devices(i).vendorID, vendorIDs)
            psychtoolbox_trigger_id=i;
            break;
        end
    end
end

if isempty(psychtoolbox_trigger_id)
    error('FORPCheck: No trigger-Device detected on your system');
end