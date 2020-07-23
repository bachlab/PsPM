## PsPM
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/bachlab/PsPM)](https://github.com/bachlab/PsPM/releases)
[![GitHub Release Date](https://img.shields.io/github/release-date/bachlab/PsPM)](https://github.com/bachlab/PsPM/releases)
[![Build Status](https://sphinx.bli.uzh.ch/jenkins/buildStatus/icon?job=PsPM)](https://github.com/bachlab/PsPM)
[![Website](https://img.shields.io/website?down_color=lightgrey&down_message=offline&up_color=green&up_message=online&url=https%3A%2F%2Fbachlab.github.io%2FPsPM)](https://bachlab.github.io/PsPM)
[![License](https://img.shields.io/github/license/bachlab/PsPM)](https://www.gnu.org/licenses/gpl-3.0)

**PsPM** stands for PsychoPhysiological Modelling. It is a powerful matlab toolbox for model-based analysis of psychophysiological signals, for example SCR, ECG, respiration, pupil size, or startle eye-blink EMG. Currently, **PsPM** implements models for all of these modalities, and we are working towards further models, for example, for skin potential and ocular scan path length.

A **PsPM** allows inferring a psychological variable from observable physiological data. For example, associative memory can be inferred from observed skin conductance responses (SCR). This allows for quantitative description of hidden processes, increases the temporal resolution of analysis, and suppresses noise.

**PsPM** implements simple General Linear Convolution Models (GLM) for evoked SCR, or uses the Dynamic Causal Modelling (DCM) framework – as a tool to invert more complicated, non-linear models of SCR signals, for example for spontaneous fluctuations or anticipatory responses. Inference is drawn in a hierarchical summary-statistic approach (similar to SPM software for functional magnetic resonance imaging).

**PsPM** also supports other kinds of data for which no models exist yet, in particular we have extended support for eyetracking data.

The flexible software allows import of a number of data formats, including Spike, Biopac, VarioPort, (exported) ADInstruments LabChart, (exported) Biograph Infiniti, (exported) MindMedia BioTrace, Dataq/Windaq, AckKnowledge, ScanPhysLog, EDF, (exported) Eyelink, Matlab, and Text files.

Further features are simple programming of add-ons for import and modelling of new data types and automatic creation of batch scripts via the GUI.

**PsPM** incorporates the previous software package SCRalyze and offers all features of SCRalyze plus many more. If you started working on a project with SCRalyze and want to continue, you can still find previous software versions, help, and resources on http://scralyze.sourceforge.net.

## Developer Documentation

### Code Structure
The software is used in two ways, by using the defined matlab functions or via the GUIDE application interface. The GUIDE app includes a batch editor, which uses matlabbatch.

The code relating to the matlabbatch config is found in pspm_cfg, the entire matlabbatch configuration suite is built from pspm_cfg/pspm_cfg.m. Matlabbatch allows the declaration of a UI structure with things like menus, branchs, field entries, valid values etc. Most `pspm_cfg_x_y_z.m` files have an accompanying `pspm_cfg_run_x_y_z.m` file, the run `pspm_cfg_run_x_y_z.m` files take the selections from the `pspm_cfg_x_y_z.m` config and then provide them to other pspm functions. The `pspm_cfg_run_x_y_z.m` file middleware allows for the matlabbatch system to be used, whilst also keeping neat, usable, and more general pspm core functions.

The PSPM software typically creates and maintains a model file for a users model, as such many of the functions in pspm treat model files as first class citizens. It is typical for a function to inclue a filename as an argument, and for the function to load that data, perform it's purpose, then return a result or write back to the file with a status output.


## License
**PsPM** is provided under the GNU General Public License (c) Dominik R. Bach, University of Zurich and University College London
