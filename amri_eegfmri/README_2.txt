Included in this folder (and its sub-folders) are a set of Matlab programs for
removing artifacts from EEG data recorded during concurrent fMRI acquisition.
For a detailed description of this tool, please see [Ref 1].

The functions of individual programs are briefly described as follows: 

Main functions:
amri_eeg_gac.m          remove MR gradient artifacts from EEG
amri_eeg_rpeak.m        detect QRS complex from ECG and insert R markers to EEG
amri_eeg_cbc.m          remove cardiact pulse artifacts from EEG

amri_fmri_retroicor.m   retroicor [Ref 4]
amri_fmri_nvr.m         nuisance variable regression for fmri dataset
amri_file_loadnii.m     load a nifti file
amri_file_savenii.m     save a nifti file

Sub functions: 
amri_sig_corr.m         compute pearson correlation coefficient 
amri_sig_xcorr.m        compute auto- or cross-correlation with time shift
amri_sig_filtfft.m      lowpass, highpass, bandpass or bandstop filtering based
                        on fft/ifft
amri_sig_findpeaks.m    find peaks and troughs in a time course
amri_sig_nvr.m          nuisance variable regression
amri_stat_iqr.m         compute inter-quatile range
amri_stat_outlier.m     detect outliers from a set of samples 
mi/*                    a set of C programs for computing mutualinfo 
                        (originally developed by Hanchuan Peng [Ref 2] and
                        re-distributed with permission from the author)

Users are recommended to use these programs together with EEGLAB [Ref 3], which
is a comprehensive Matlab-based software for EEG processing and visualization
(http://sccn.ucsd.edu/eeglab/). For example, one can use pop_eegplot() to check
the EEG signals after each processing step.  

Users are recommended to first check a demo program (my_demo.m) for a
step-by-step example of how to use these tools. 

For detailed description of individual programs, please check the file headers
or use the 'help' command in Matlab. 

Users are encouraged to acknowledge the authors by citing [Ref 1].

[Ref 1] Liu Z, de Zwart JA, van Gelderen P, Kuo L-W, Duyn JH, Statistical
        feature extraction for artifact removal from concurrent fMRI-EEG
        recordings. NeuroImage (2012), 59(3): 2073-2087.
[Ref 2] Peng H, Long F, Ding C, Feature selection based on mutual information:
        criteria of max-dependency, max-relevance, and min-redundancy. IEEE
        Transactions on Pattern Analysis and Machine Intelligence (2005),
        27:1226-1238
[Ref 3] Delorme A and Makeig S, EEGLAB: an open source toolbox for analysis of
        single-trial EEG dynamics. Journal of Neuroscience Methods (2004),
        134-9:21
[Ref 4] Glover G, Li TQ, Ress D, Image-based method for retrospective 
        correction of physiological motion effects in fMRI: RETROICOR. Magn. 
        Reson. Med. (2000), 44: 162-167.
