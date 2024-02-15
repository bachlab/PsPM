%This file was me messing around with the COM interface via .NET
%
%Due to the interface code I would need to write most of what I need in C#
%and then call my code.
%
%The COM interface exposes the raw data where as the C SDK only exposes
%data as floating point data (single).
%
%For now I'm going to hold off on doing anything with this approach.


%wtf   = NET.addAssembly('C:\Users\Jim\Documents\ADInstruments\SimpleDataFileSDKCOM\DotNETInterop\bin\Debug\ADIDatIOWInLib.dll');


base_path = 'C:\repos\matlab_git\ad_sdk\+adinstruments\private\interfaceConverterCode';
adi_asm  = NET.addAssembly(fullfile(base_path,'ADIDatIOWinLib.dll'));

obj = ADIDatIOWinLib.ADIDataObject();
t   = adi_asm.AssemblyHandle.GetType('ADIDatIOWinLib.IADIDataReader');

adi_data = t.InvokeMember('GetADIData',System.Reflection.BindingFlags.InvokeMethod,[],obj,[]);

%Inputs:
%1) function name
%2) System.Reflection.BindingFlags invokeAttr
%3) System.Reflection.Binder binder
%4) System.Object target
%   - the created class
%5) Args
%   - 

conv_asm = NET.addAssembly(fullfile(base_path,'interfaceConv.dll'));
%clark = ADIDatIOWinLib.ADIDataObject();

%wtf.OpenFileForRead('C:\Data\GSK\ChrisRaw\140113 pelvic and hypogastric nerve recordings.adicht')
wtf   = interfaceConv.converter.getReader(obj,'C:\Data\GSK\ChrisRaw\140113 pelvic and hypogastric nerve recordings.adicht');

file_path = 'C:\Data\GSK\ChrisRaw\140113 pelvic and hypogastric nerve recordings.mat';
tic;
huh = load(file_path,'data__chan_4_rec_4');
toc;

tic;
fid = fopen(file_path,'r');
arg = fread(fid,[1 Inf],'*uint8');
fclose(fid);
toc;

   %wtf = c.getReader(clark);




%% Load Assembly
A = NET.addAssembly([pwd '\ClassLibrary1.dll']);
% Get Type information for the IClass interface
t = A.AssemblyHandle.GetType('ClassLibrary1.IClass');
%% Create an object instance
obj = ClassLibrary1.Class1;
%% Call the method (through reflection)
% First define an Object[] for the inputs
inputs = NET.createArray('System.Object',1);
% Define the actual inputs
inputs(1) = System.String('World');
% Call the method
t.InvokeMember('myFunction',System.Reflection.BindingFlags.InvokeMethod,[],obj,inputs)


%{
Structures:
    'ADIDatIOWinLib.ADIChannelId'
    'ADIDatIOWinLib.ADIPosition'
    'ADIDatIOWinLib.ADIRational64'
    'ADIDatIOWinLib.ADIScaling'
    'ADIDatIOWinLib.ADITimeDate'
    'ADIDatIOWinLib.BaseUnitsInfo'
    'ADIDatIOWinLib.ChannelYDataRange'
    'ADIDatIOWinLib.ChartCommentPos'
    'ADIDatIOWinLib.RecordTimeInfo'
    'ADIDatIOWinLib.TTickToSample'
    'ADIDatIOWinLib.UserUnitsInfo'
Enums:
    'ADIDatIOWinLib.ADICommentFlags'
    'ADIDatIOWinLib.ADIDataFlags'
    'ADIDatIOWinLib.ADIDataType'
    'ADIDatIOWinLib.ADIDataValueId'
    'ADIDatIOWinLib.ADIEnumDataType'
    'ADIDatIOWinLib.ADIFileOpenFlags'
    'ADIDatIOWinLib.ADIRecordFlags'
    'ADIDatIOWinLib.ADIReservedFlags'
    'ADIDatIOWinLib.EnumCommentFlags'
    'ADIDatIOWinLib.EventFindTypes'
    'ADIDatIOWinLib.TimeDisplayMode'
    'ADIDatIOWinLib.UnitPrefix'
Interfaces:
    'ADIDatIOWinLib.IADIComment'
    'ADIDatIOWinLib.IADIData'
    'ADIDatIOWinLib.IADIDataReader'
    'ADIDatIOWinLib.IADIDataSink'
    'ADIDatIOWinLib.IADIDataWriter'
    'ADIDatIOWinLib.IAutoADIString'
    'ADIDatIOWinLib.IEnumADIComment'
    'ADIDatIOWinLib.IEnumExBase'
    'ADIDatIOWinLib.IEnumFloatEx'
    'ADIDatIOWinLib.IEnumShortEx'

%}

reader = cast(clark,'ADIDatIOWinLib.IADIDataReader')


wtf = ADIDatIOWinLib.IADIDataReader(clark)

%'System.Type requestedType')
%{

ADIDatIOWinLib.ADIDataObject dataObject = new ADIDatIOWinLib.ADIDataObject();
ADIDatIOWinLib.IADIDataReader reader = (ADIDatIOWinLib.IADIDataReader)dataObject;
reader.OpenFileForRead(filePath);
mADIData = reader.GetADIData();

%}