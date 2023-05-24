function [psychtoolbox_forp_id] = FORPInit()

psychtoolbox_forp_id=[];

% List of vendor IDs for valid FORP devices:
vendorIDs = [6171];

KeyPressed  =   '';
keydata     =   [];

% Try to detect first FORP device at first invocation:
if isempty(psychtoolbox_forp_id)
    Devices = PsychHID('Devices');
    % Loop through all KEYBOARD devices with the vendorID of FORP's vendor:
    for i=1:size(Devices,2)
        if strcmp(Devices(i).usageName,'Keyboard') & ismember(Devices(i).vendorID, vendorIDs)
            psychtoolbox_forp_id=i;
            break;
        end
    end
end

if isempty(psychtoolbox_forp_id)
    error('FORPCheck: No FORP-Device detected on your system');
end