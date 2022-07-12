% SON32
%
% Files
%   son32                - Prototype file. Create structures to define interfaces found in 'matlab'.
%   SONAppID             - sets or gets the creator lable from a SON file
%   SONBlocks            - returns the number of blocks written to disk for the channel
%   SONBookFileSpace     - Allocates disk space for a file
%   SONCanWrite          - test whether a file can be written to
%   SONChanBytes         - returns the number of bytes written, or buffered, on the 
%   SONChanDelete        - deletes a channel from a SON file
%   SONChanDivide        - returns the clock ticks per ADC value from the specified
%   SONChanInterleave    - Returns the channel interleave factor for ADCMark channels
%   SONChanKind          - Returns the channel type 
%   SONChanMaxTime       - returns the sample time for the last data item on a channel
%   SONCleanUp           - File cleanup. Not used in Windows
%   SONCloseFile         - closes an opened SON file
%   SONCommitFile        - flushes data to disc
%   SONCreateFile        - creates a new SON file
%   SONDateTime          - gets or sets the creation data/time data in a SON file 
%   SONDelBlocks         - returns the number of deleted blocks in file FH on channel CHAN
%   SONEmptyFile         - Deletes data written to file FH
%   SONExtMarkAlign      - gets and sets the alignment state for marker channels
%   SONFActive           - tests filter mask layers to see if they are active
%   SONFControl          - Reads, sets or clears specified bits in a filter mask structure
%   SONFEqual            - Tests a filter mask structure for active layers
%   SONFileBytes         - Returns the number of bytes in the file 
%   SONFileSize          - Returns the expected size of a file
%   SONFilter            - tests whether a set of markers are included in the set defined
%   SONFMode             - creates a filter mask structure and/or 
%   SONGetADCData        - returns data for Adc, AdcMark, RealWave ( and RealMark?)
%   SONGetADCInfo        - Returns information about an ADC data channel
%   SONGetChanComment    - returns the comment string for the specified channel
%   SONGetChanTitle      - Returns the channel title
%   SONGetEventData      - returns the timings for an Event or marker channel
%   SONGetExtMarkData    - returns the timings, marker values and extra data
%   SONGetExtMarkInfo    - returns details about an extended marker channel
%   SONGetExtraData      - reads or writes the extra data area of a SON file
%   SONGetExtraDataSize  - Returns the size of the extra data area of file FH in bytes
%   SONGetFileComment    - returns the file comment
%   SONGetFreeChan       - returns the number of the first free channel in a file
%   SONGetFreeChanl      - SONGETFREECHAN returns the number of the first free channel in a file
%   SONGetMarkData       - returns the timings and marker values for a Marker, AdcMark,
%   SONGetRealData       - returns data for Adc, AdcMark, RealWave ( and RealMark?)
%   SONGetTimePerADC     - returns the number of clock ticks per ADC conversion
%   SONGetusPerTime      - returns the tick interval in units of SONTimeBase()
%   SONGetVersion        - returns the SON file system version number for a file
%   SONIdealRate         - gets or sets the ideal sampling rate on a channel
%   SONIsSaving          - returns the save state for a specified channel
%   SONItemSize          - returns the size of a data item on the specified channel (bytes)
%   SONKillRange         - attempts to discard data from a file between two times
%   SONLastPointsTime    - returns the time for which a read will terminate
%   SONLastTime          - returns information about the last entry on a channel
%   SONLatestTime        - is used to flush data to disk
%   SONLoad              - loads the son32.dll library and defines global constants
%   SONMaxChans          - returns the  number of channels supported by a SON file
%   SONMaxTime           - returns the maximum time for data in a file
%   SONOpenNewFile       - (obsolete) creates a new SON file and returns the handle
%   SONOpenOldFile       - opens an existing a SON file and returns a handle
%   SONPhyChan           - returns the physical channel (hardware port) for a channel
%   SONPhysChan          - SONPHYCHAN returns the physical channel (hardware port) for a channel
%   SONPhySz             - returns the buffer size for the specified chanel
%   SONSave              - sets the write state for a channel from a specified time
%   SONSaveRange         - sets the write state to save for a channel in the given time range
%   SONSetADCOffset      - sets the offset on an ADC channel
%   SONSetADCScale       - sets the scale on an ADC channel
%   SONSetADCUnits       - sets the units string for a channel
%   SONSetBuffering      - specifies the buffer size for writing to a channel
%   SONSetBuffSpace      - allocates buufer space for file writes
%   SONSetChanComment    - sets the channel comment
%   SONSetChanTitle      - sets the channel title
%   SONSetEventChan      - sets up a new event or marker channel
%   SONSetFileClock      - sets the basic time units and the clocks per ADC conversion
%   SONSetFileComment    - sets one of the five file comment fields
%   SONSetInitLow        - sets the initial state on an EventBoth (level) channel
%   SONSetMarker         - replaces the data associated with a marker on disc
%   SONSetRealChan       - creates real wave channel     
%   SONSetRealMarkChan   - creates a REALMARK channel
%   SONSetTextMarkChan   - creates a TEXTMARK channel
%   SONSetWaveChan       - creates an ADC channel     
%   SONSetWaveMarkChan   - creates a REALMARK channel
%   SONTimeBase          - Get or set the base time units for the file
%   SONUpdateStart       - flushes the SON file header to disc
%   SONVersion           - returns the MATLAB library version number (Not a CED function)
%   SONWriteADCBlock     - writes data to an ADC channel
%   SONWriteEventBlock   - writes data to an ADC channel
%   SONWriteExtMarkBlock - writes data to a marker channel
%   SONWriteMarkBlock    - writes data to a marker channel
%   SONWriteRealBlock    - SONWRITERealBLOCK writes data to an Real channel
%   SONYRange            - returns the expected minimum and maximum values for a channel
