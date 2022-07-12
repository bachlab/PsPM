========
Overview
========

This code base exposes the C SDK by `ADInstruments  <https://www.adinstruments.com/>`_
to Matlab.

General parts include:

- sdk class/package (see adi.sdk) - this is the Matlab code that directly interfaces with the mex code
- sdk_mex (see +adi/private directory) - this is the actual mex code which calls the ADInstruments dll

==========
Motivation
==========

LabChart provides functionality for exporting data to a '.mat' file, although I have yet to get it to work. I also prefer not having files that are simply copies of an original file but in a different format. This code allows reading data directly from LabChart data files.


===================
Top Level Functions
===================
- adi.readFile : Reads a file
- adi.convert : Converts the a given file to another format (e.g. from .adicht to .mat)

===================
File Reading Notes
===================

Like most of my more recent readers, the raw channel data are not returned unless specifically requested. Instead a lightweight (low memory) handle is returned with relevant meta data and the raw channel data can be requested via subsequent method calls.

.. code-block:: matlab

	f = adi.readFile;
	pres_chan = f.getChannelByName('pressure');
	raw_pres_data = pres_chan.getData(1); %Get data from the first record
	
At some point a function could be written that reads everything and reads it into a structure but this is really really low priority for me.

To read these files on a Mac first requires converting the 'adicht' format into a 'mat' format. Unfortunately, the way in which these files needs to be created leaves the mat file looking a bit ugly. Once however it is in the 'mat' format, it can be read via the code in the same way that the original 'adicht' file could.

.. code-block:: matlab

	f = adi.readFile('/Users/Jim/Work/example_file.mat');
	
==============
Current Status
==============

I've fully implemented the reading portion. I've started the writing portion but I haven't finished it. I have no plans to finish the writing portion at this point in time.

===========================
Requirements & Installation
===========================

Requires 64bit Matlab on Windows. 32bit Matlab could be supported but some of the mex code would need to be rewritten.

To install the package ('+adi') needs to be on the Matlab path. Sub-folders of the package should not be added to the path.
