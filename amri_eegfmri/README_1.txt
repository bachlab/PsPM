INFORMATION

This folder contains Matlab source code and example data for the toolbox that we
developed to remove gradient- and pulse-artifacts from EEG data acquired during
a simulateous EEG/fMRI experiment.

Note that this is currently Beta software at best, and has not been widely
tested. Please let us know if there are any issues so that we can try to solve
them.

This toolbox is described in detail in the following publication:
Liu Z, de Zwart JA, van Gelderen P, Kuo L-W, Duyn JH
Statistical feature extraction for artifact removal from concurrent fMRI-EEG
recordings.
NeuroImage 2012:59, 2073-2087


A README.txt file inside the code archive describes how to use these Matlab
programs. Note that this code requires the freely available 'eeglab' toolbox,
which can be obtained from here:
http://sccn.ucsd.edu/eeglab/
Our code was tested using eeglab version 8.0.3.2b. We cannot guarantee
compatibility with newer releases, but please notify us if issues arise with
different eeglab versions.



DISCLAIMER AND CONDITIONS FOR USE

This software is distributed under the terms of the GNU General Public License
version 3, dated 2007/06/29 (see http://www.gnu.org/licenses/gpl.html).
Use of this software is at the user's OWN RISK. Functionality is not guaranteed
by creator nor modifier(s), if any. This software may be freely copied and
distributed. The original header MUST stay part of the file and modifications
MUST be reported in the 'MODIFICATION HISTORY'-section, including the
modification date and the name of the modifier.



VERSION HISTORY

2013/07/31 [version 0.1.4]
    Code archive = amri_eegfmri_toolbox.20130731.v0.1.4.tar
    Routine amri_eeg_gac.m now excludes the outlier epochs in the data matrix
    applied with PCA. Minor bugfix in amri_sig_filtfft.m. Routine
    amri_eeg_rpeak.m now provides an option to use either TEO or ECG signal for
    the R-peak detection (TEO is the default, see file header for more info).
2012/08/08 [version 0.1.3]
    Code archive = amri_eegfmri_toolbox.20120808.v0.1.3.tar
    Bugfix: Routine amri_eeg_rpeak.m was modified to support a new EEGLAB
    version, which uses a different data structure.
2012/02/15 [version 0.1.2]
    Code archive = amri_eegfmri_toolbox.20120215.v0.1.2.tar
    Added amri_file_loadnii.m/amri_file_savenii.m (to read/write nifti in matlab)
    Added amri_fmri_retroicor.m (Matlab implementation of RETROICOR)
    Added amri_fmri_nvr.m (nuisance variable regression)
2011/11/18 [version 0.1.1]
    Code archive = amri_eegfmri_toolbox.20111118.v0.1.1.tar
    Bugfix: If only volume triggers are available and TR>2s there was a filter
    design bug. This is now fixed.
2011/11/16 [version 0.1] (First public release)
    Code archive = amri_eegfmri_toolbox.20111116.v0.1.tar
    Example data archive = example_data.20111116.v0.1.tar
