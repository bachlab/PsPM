----------------
The Labchart SDK
----------------
This file is meant to briefly discuss how this repo came about and how the code is organized.

This code is based on the Labchart SDK provided by ADInstruments. An installer for 
the SDK can be found in the Labchart folder following installation of Labchart.
The SDK provides a Windows dll and information on what functions are available
in the dll.

A mex file has been written that calls these dll functions from Matlab.
A separate set of Matlab functions exist that expose this mex file to Matlab.
These functions are currently located in adi.sdk (although I plan on moving this).

On top of these functions I've written classes that make it slightly easier
to work with the SDK.

-------------------
Code in the Library
-------------------

The adi package contains all relevant code.

Within the adi package are meant to be relevant entry points. 
Ideally I want to move most of the non-entry functions outside of the base package but this is a very low priority

Entry functions include: (may be outdated)
- adi.readFile
- adi.createFile
- adi.editFile
- adi.convert