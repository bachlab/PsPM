# pupil-size
MATLAB scripts for preprocessing pupil size timeseries.

This code assumes that the user is proficient in MATLAB, with knowledge of Object
Oriented Programming and Handle classes.

The code requires the ‘Signal Processing Toolbox’ and the ‘Statistics and Machine Learning Toolbox’, and was tested with MATLAB versions 2012b, 2016a & 2017a, running on Windows 7.

## Data Models:
This repository contains a collection of Matlab classes and helper scripts that can be used for preprocessing pupil size data in an object-oriented manner.

1. **RawFileModel.m**: used to generate standardized matlab files containing raw pupil-size data and segmentation information.

2. **PupilDataModel.m**: this is the main class basic users should interact with, it holds the classes mentioned below, and its methods run the batch segment analysis and plotting functions.

3. **RawSamplesModel.m**: this class manages the raw data of a single pupil, and performs raw-data filtering to remove samples associated with noise and artifacts. The samples that remain after filtering are the *valid samples*.

4. **ValidSamplesModel.m**:  this class handles the valid samples and performs interpolation and smoothing

## Workflow:
The generalized preprocessing pipeline consists of the following steps:

1. Convert eye-tracker output to compatible matlab .mat files containing the pupil size data and metadata, as well as information about how to segments the recording into the desired sections.

2. Instantiate the PupilDataModel objects.

3. Filter the raw data by running the filterRawData() method of the PupilDataModel instances.

4. Process the valid samples and generate smooth interpolated signals by running the processValidSamples() method of the PupilDataModel instances.

5. Analyze each segment by running the analyzeSegments() method of the PupilDataModel instances.

6. Visualize the data by running the plotData() method of the PupilDataModel instances.

NOTE: the abovementioned PupilDataModel methods can be run on PupilDataModel arrays as well as PupilDataModel scalars. See Examples.

## Examples:
The /code/Examples/ folder contains two example applications:
* Dataset 1: Processing monocular pupil size data collected using SR-Research's Eyelink system.
* Dataset 2: Processing binocular pupil size data collected using E-Prime Extensions for Tobii.

