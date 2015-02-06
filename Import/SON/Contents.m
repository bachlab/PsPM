% SON
%
% Files
%   progressbar             - WAITBAR Display wait bar.
%   SONADCToDouble          - scales a SON ADC channel to double precision floating point
%   SONADCToSingle          - scales a SON ADC channel to single precision floating point
%   SONChanList             - returns a structure with details of active channels in a SON file
%   SONChannelInfo          - reads the SON file channel header for a channel 
%   SONCreateChannel        - Obsolete function. To write to a file use the SON32 library
%   SONFileHeader           - reads the file header for a SON file
%   SONGetADCChannel        - reads an ADC (waveform) channel from a SON file.
%   SONGetADCMarkerChannel  - reads an ADCMark channel from a SON file.
%   SONGetBlockHeaders      - returns a matrix containing the SON data block headers
%   SONGetChannel           - provides a gateway to the individual channel read functions. 
%   SONGetEventChannel      - reads an event channel from a SON file
%   SONGetMarkerChannel     - reads a marker channel from a SON file.
%   SONGetRealMarkerChannel - reads an RealMark channel from a SON file.
%   SONGetRealWaveChannel   - reads an ADC (waveform) channel from a SON file.
%   SONGetSampleInterval    - returns the sampling interval in seconds 
%   SONGetSampleTicks       - Finds the sampling interval on a data channel in a SON file
%   SONGetTextMarkerChannel - SONGETTESTMARKERCHANNEL reads a marker channel from a SON file.
%   SONRealToADC            - Converts floating point array to int16
%   SONTest                 - tests the integrity of a SON File usinf CED's SonFix program.
%   SONTicksToSeconds       - scales timestamp vector IN
%   SONUpgradeToVersion6    - Obsolete function
%   SONVersion              - returns/displays the version number of the matlab SON library
