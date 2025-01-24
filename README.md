---
layout: home
title: PsPM
permalink: /
---
##### A matlab suite for Psycho Physiological Modelling




**Current version: PsPM 6.1.2, released on 25.01.2024.**

<img class="PsPM_Web" src="assets/images/PsPM_Website_Figure_1.jpg" type="image/jpg" alt="PsPM" >

**PsPM** stands for PsychoPhysiological Modelling. It is a powerful matlab toolbox for model-based analysis of psychophysiological signals, for example SCR, ECG, respiration, pupil size, or startle eye-blink EMG. Currently, PsPM implements models for all of these modalities, and we are working towards further models, for example, for skin potential and ocular scan path length.

A PsPM allows inferring a psychological variable from observable physiological data. For example, associative memory can be inferred from observed skin conductance responses (SCR). This allows for quantitative description of hidden processes, increases the temporal resolution of analysis, and suppresses noise.

**PsPM** implements simple General Linear Convolution Models (GLM) for evoked SCR, or uses the Dynamic Causal Modelling (DCM) framework - as a tool to invert more complicated, non-linear models of SCR signals, for example for spontaneous fluctuations or anticipatory responses. Inference is drawn in a hierarchical summary-statistic approach (similar to SPM software for functional magnetic resonance imaging).

**PsPM** also supports other kinds of data for which no models exist yet, in particular we have extended support for eyetracking data.

The flexible software allows import of a number of data formats, including Spike, Biopac, VarioPort, (exported) ADInstruments LabChart, (exported) Biograph Infiniti, (exported) MindMedia BioTrace, Dataq/Windaq, AckKnowledge, ScanPhysLog, EDF, (exported) Eyelink, Matlab, and Text files.

Further features are simple programming of add-ons for import and modelling of new data types and automatic creation of batch scripts via the GUI.

**PsPM** incorporates the previous software package **SCRalyze** and offers all features of SCRalyze plus many more. If you started working on a project with SCRalyze and want to continue, you can still find previous software versions, help, and resources on <a title="http://scralyze.sourceforge.net" href="http://scralyze.sourceforge.net">http://scralyze.sourceforge.net</a>.

**PsPM** is provided under the GNU General Public License (c) <a title="The Bach lab" href="http://www.bachlab.org">Dominik R. Bach</a>, University of Zurich and University College London.
