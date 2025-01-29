---
layout: post
title: Documentation
permalink: /documentation/
---

When you use PsPM code or concepts, we ask you to
reference our papers - an annotated reference list is provided below. 
Some PsPM pre-processing algorithms are based on other
people's work. This is detailed in the help of the respective
functions, and we ask you to reference these researchers' work
when you use them.

## General background of PsPM and related methods
* Bach DR & Friston KJ (2013). Model-based analysis of skin conductance
responses: Towards causal models in psychophysiology.
*Psychophysiology*, *50(1)*, 15-22.
[\[PubMed\]](http://www.ncbi.nlm.nih.gov/pubmed/23094650)
* Bach DR,
Castegnetti G, Korn CW, Gerster S, Melinscak F, Moser T (2018).
Psychophysiological modelling - current state and future directions.
*Psychophysiology*, *55*, e13209.
[\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/30175471)

## Models for skin conductance responses
### General: the skin conductance response function
* Bach DR, Flandin G, Friston KJ, Dolan RJ (2010). Modelling event-related
skin conductance responses. *International Journal of Psychophysiology*,
*75*, 349-356. [\[PubMed\]](http://www.ncbi.nlm.nih.gov/pubmed/20093150) (Development of the SCRF, and an indirect test of the LTI assumptions)
* Gerster S, Namer B, Elam M, Bach DR (2018). Testing a linear time
invariant model for skin conductance responses by intraneural recording
and stimulation. *Psychophysiology*, *55*, e12986.
[\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/28862764) (A direct test of the LTI assumptions, using intraneural recording and stimulation)

#### GLM for evoked skin conductance responses (eSCR)
This model assumes that
sympathetic nerve (SN) responses follow a short stimulus with constant
latency. The amplitude of these responses is estimated in the framework
of a general linear convolution model, using a canonical skin
conductance response function (SCRF), under linear time-invariance
assumptions, and an informed, linear neural model.

* Bach DR, Flandin G, Friston KJ, Dolan RJ (2009).
Time-series analysis for rapid event-related skin conductance responses.
*Journal of Neuroscience Methods*, *184*, 224-234.
[\[PubMed\]](http://www.ncbi.nlm.nih.gov/pubmed/19686778) (Proof-of-principle of the GLM for SCR) 
*Bach DR,Friston KJ, Dolan RJ (2013). An improved algorithm for model-based
analysis of evoked skin conductance responses. *Biological Psychology*,
*94*, 490-497. [\[PubMed\]](http://www.ncbi.nlm.nih.gov/pubmed/24063955) (optimisation of the algorithm and latest recommendations)
* Bach DR (2014). A head-to-head comparison of SCRalyze and Ledalab, two
model-based methods for skin conductance analysis. *Biological
Psychology, 103*, 63-88.
[\[PubMed\]](http://www.ncbi.nlm.nih.gov/pubmed/25148785) (direct comparison with Ledalab)

### Non-linear model for event-related SCR
This model is used, e.g. for
conditioned (anticiaptory) responses in fear conditioning. It assumes that the onset
of the neural response is not precisely known, and estimates onset,
dispersion, and amplitude of the response. Non-linear model
inversion is accomplished in the computational framework of the [Variational Bayes approach](https://doi.org/10.1371/journal.pcbi.1003441).

* Bach DR, Daunizeau J, Friston KJ, Dolan
RJ (2010). Dynamic causal modelling of anticipatory skin conductance
responses. *Biological Psychology*, *85*, 163-70.
[\[PubMed\]](http://www.ncbi.nlm.nih.gov/pubmed/20599582) (proof of principle of the non-linear model for SCR)
* Staib M,
Castegnetti G, Bach DR (2015). Optimising a model-based approach to
inferring fear learning from skin conductance responses. *Journal of
Neuroscience Methods, 255,* 131-138.
[\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/26291885) (optimisation of the algorithm and latest recommendations)

### Models for spontaneous skin conductance fluctuations (SF)
These models are
entirely uninformed about the onset of neural responses. SF are often
thought to index tonic arousal. A very simple model estimates the mean
number of responses times mean amplitude per time unit, as area under
the curve (AUC) of the signal. The number of responses is however more
informative than their amplitude, such that a more sophisticated model
was developed to estimate neural response onsets and amplitudes
separately. This is similar to the approach for event-related SCR: it
uses a slightly modified SCRF, an uninformed non-linear neural model and
the VBA model inversion framework.

* Bach DR,
Friston KJ, Dolan RJ (2010). Analytic measures for quantification of
arousal from spontaneous skin conductance fluctuations. *International
Journal of Psychophysiology*, *76*, 52-55.
[\[PubMed\]](http://www.ncbi.nlm.nih.gov/pubmed/20144665) (test for LTI
assumptions, a modified SCRF for SF, AUC method)
* Bach DR, Daunizeau J, Kuelzow
N, Friston KJ, Dolan RJ (2011). Dynamic causal modelling of spontaneous
fluctuations in skin conductance. *Psychophysiology*, *48*, 252-257.
[\[PubMed\]](http://www.ncbi.nlm.nih.gov/pubmed/20557485) (Non-linear model for SF)
* Bach DR, Staib M (2015). A matching pursuit algorithm for inferring
tonic sympathetic arousal from spontaneous skin conductance
fluctuations. *Psychophysiology*, *52*, 1106-1112.
[\[PubMed\]](http://www.ncbi.nlm.nih.gov/pubmed/25930177) (MP approximation for SF)

## Models for pupil data
Models are available for illuminance-elicited changes, cognitive input,
and specifically for fear conditioning. All model build on LTI systems
and are inverted in the framework of GLM. PsPM contains many
pre-processing and convenience functions for eye-tracking data.

* Korn CK, Staib M, Tzovara A, Castegnetti G, Bach DR (2017). A pupil
size response model to assess fear learning. *Psychophysiology*, *54*,
330-343. [\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/27925650) (GLM for fear-conditioned pupil size responses)
* Korn CW & Bach DR (2016). A solid frame for the window on
cognition: Modeling event-related pupil responses. *Journal of Vision*,
*16*, 28. [\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/26894512) (illuminance model and its application to cognitive paradigms)
* Abivardi A, Korn CW, Rojkov I, Gerster S, Hurlemann R, Bach DR (2023). Acceleration of inferred neural responses to oddball targets in an individual with bilateral amygdala lesion compared to healthy controls. *Scientific Reports*, *13*, 41357. [\[doi\]](https://doi.org/10.1038/s41598-023-41357-1) (application of the illuminance model to a lesion patient group)

## Models for heart data
* Castegnetti G, Tzovara A, Staib M, Paulus PC, Hofer N, & Bach DR (2016).
Modelling fear-conditioned bradycardia in humans. *Psychophysiology,
53*, 930-939. [\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/26950648) (GLM for fear-conditioned bradycardia)
* Paulus PC, Castegnetti
G, & Bach DR (2016). Modeling event-related heart period responses.
*Psychophysiology, 53,* 837-846.
[\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/26849101) (GLM for evoked heart period responses)

## Models for respiration data
Castegnetti G, Tzovara A, Staib M, Gerster S, Bach DR (2017).
Assessing fear learning via conditioned respiratory amplitude responses.
*Psychophysiology*, *54*, 215-223.
[\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/27933608) (GLM for fear-conditioned respiration amplitude)
* Bach DR, Gerster S, Tzovara A, Castegnetti G (2016).
A linear model for event-related respiration responses. *Journal of
Neuroscience Methods, 270,* 174-155.
[\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/27268156) (GLM for evoked respiratory responses)

## Model for startle-eye blink EMG
* Khemka S, Tzovara A, Gerster S,
Quednow BB, Bach DR (2017). Modelling startle eye blink electromyogram
to assess fear learning. *Psychophysiology*, *54*, 202-214.
[\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/27753123)

## Recent examples for application studies using PsPM
* Xia Y, Wehrli J, Abivardi A , Hostiuc M, Kleim B, Bach DR (2024). Attenuating human fear memory retention with minocycline: a randomized placebo-controlled trial. *Translational Psychiatry*, *14*, 28.
* Wehrli J, Xia Y, Abivardi A , Kleim B, Bach DR (2024). The impact of doxycycline on human contextual fear memory. *Psychopharmacology*, *241*, 1065–1077.
* Wehrli J, Xia Y, Offenhammer B, Kleim B, Müller D, Bach DR (2023). Effect of the matrix metalloproteinase inhibitor doxycycline on human trace fear memory. *eNeuro*, ENEURO.0243-22.2023.
* Xia Y, Wehrli J, Gerster S, Kroes M, Houtekamer M, Bach DR (2023). Measuring human context fear conditioning and retention after consolidation. *Learning & Memory*, *30*, 139–150.
* Ojala KE*, Staib M*, Gerster S, Ruff CC, Bach DR (2022). Inhibiting human aversive memory by transcranial theta-burst stimulation to primary sensory cortex. *Biological Psychiatry*, *92*, 149-157.
* Wehrli JM, Xia Y, Gerster S, & Bach DR (2022). Measuring human trace fear conditioning. *Psychophysiology*, *59*, e14119.
* Homan P, Lau HL, Levy I, Raio CM, Bach DR, Carmel D, Schiller S (2021). Evidence for a minimal role of stimulus awareness in reversal of threat learning. *Learning & Memory*, *28*, 95-103.
