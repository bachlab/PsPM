---
layout: default
title: Documentation
permalink: /documentation/
---

# Documentation

<img class="PsPM_Doc" src="images/PsPM_Website_Figure_2.png" alt="PsPM" >

 **PsPM** provides a principled approach to
solving the inverse problem in psychophysiology: making inferences about
psychological processes, given physiological data. This is a common
application of psychophysiology - for example, making statements about
fear learning, by "scoring" skin conductance responses. In such cases,
the interest is not on the physiology itself - the interest is in the
psychological process. PsPM offers a theoretically grounded approach to
this problem. When you use PsPM code or concepts, we kindly ask you to
reference our papers. This helps us to justify our continued efforts
towards funders. Some PsPM pre-processing algorithms are based on other
people's work. This is detailed in the help of the respective
functions, and we kindly ask you to reference these researchers' work
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
#### Skin conductance response function
* An indirect test of the
peripheral SCR model, and a development of the SCRF is published in:
Bach DR, Flandin G, Friston KJ, Dolan RJ (2010). Modelling event-related
skin conductance responses. *International Journal of Psychophysiology*,
*75*, 349-356. [\[PubMed\]](http://www.ncbi.nlm.nih.gov/pubmed/20093150)
[\[pdf\]](http://scralyze.sourceforge.net/PDFs/BachFlandinFristonDolan_2010_IJP_SCR_LTI.pdf)
* A direct test, using intraneural recording and stimulation, is provided
in: Gerster S, Namer B, Elam M, Bach DR (2018). Testing a linear time
invariant model for skin conductance responses by intraneural recording
and stimulation. *Psychophysiology*, *55*, e12986.
[\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/28862764)

#### GLM for evoked skin conductance responses (eSCR)
This model assumes that
sympathetic nerve (SN) responses follow a short stimulus with constant
latency. The amplitude of these responses is estimated in the framework
of a general linear convolution model, using a canonical skin
conductance response function (SCRF), under linear time-invariance
assumptions, and an informed, linear neural model.

* The approach was
introduced in: Bach DR, Flandin G, Friston KJ, Dolan RJ (2009).
Time-series analysis for rapid event-related skin conductance responses.
*Journal of Neuroscience Methods*, *184*, 224-234.
[\[PubMed\]](http://www.ncbi.nlm.nih.gov/pubmed/19686778) The latest
recommendations for an improved algorithm are published here: Bach DR,
Friston KJ, Dolan RJ (2013).
* An improved algorithm for model-based
analysis of evoked skin conductance responses. *Biological Psychology*,
*94*, 490-497. [\[PubMed\]](http://www.ncbi.nlm.nih.gov/pubmed/24063955)
A direct comparison with the software Ledalab shows significant
superiority of PsPM to recover known states of sympathetic arousal: Bach
DR (2014).
* A head-to-head comparison of SCRalyze and Ledalab, two
model-based methods for skin conductance analysis. *Biological
Psychology, 103*, 63-88.
[\[PubMed\]](http://www.ncbi.nlm.nih.gov/pubmed/25148785 "http://www.ncbi.nlm.nih.gov/pubmed/25148785")

#### Non-linear model for event-related SCR
This model is used(e. g. for
anticipatory responses in fear conditioning, and assumes that the onset
of the neural response is not precisely known, and estimate onset,
dispersion, and amplitude of the response. They use the same SCRF as
models for eSCR, but the neural model now becomes non-linear. Model
inversion is therefore accomplished in the mathematical framework of
Dynamic Causal Modelling (DCM), using a variational Bayes inversion
scheme.

* This was described in: Bach DR, Daunizeau J, Friston KJ, Dolan
RJ (2010). Dynamic causal modelling of anticipatory skin conductance
responses. *Biological Psychology*, *85*, 163-70.
[\[PubMed\]](http://www.ncbi.nlm.nih.gov/pubmed/20599582)
* The latest
recommendations for an improved algorithm are published here: Staib M,
Castegnetti G, Bach DR (2015). Optimising a model-based approach to
inferring fear learning from skin conductance responses. *Journal of
Neuroscience Methods, 255,* 131-138.
[\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/26291885)

#### Models for spontaneous skin conductance fluctuations (SF)
These models are
entirely uninformed about the onset of neural responses. SF are often
thought to index tonic arousal. A very simple model estimates the mean
number of responses times mean amplitude per time unit, as area under
the curve (AUC) of the signal. The number of responses is however more
informative than their amplitude, such that a more sophisticated model
was developed to estimate neural response onsets and amplitudes
separately. This is similar to the approach for event-related SCR: it
uses a slightly modified SCRF, an uninformed non-linear neural model and
the DCM model inversion framework.

* The AUC model, a test for LTI
assumptions, and a modified SCRF for SF were introduced in: Bach DR,
Friston KJ, Dolan RJ (2010). Analytic measures for quantification of
arousal from spontaneous skin conductance fluctuations. *International
Journal of Psychophysiology*, *76*, 52-55.
[\[PubMed\]](http://www.ncbi.nlm.nih.gov/pubmed/20144665)
* The DCM for
spontaneous fluctuations is described in: Bach DR, Daunizeau J, Kuelzow
N, Friston KJ, Dolan RJ (2011). Dynamic causal modelling of spontaneous
fluctuations in skin conductance. *Psychophysiology*, *48*, 252-257.
[\[PubMed\]](http://www.ncbi.nlm.nih.gov/pubmed/20557485)
* A fast
inversion approximation building on Matching Pursuit is introduced in:
Bach DR, Staib M (2015). A matching pursuit algorithm for inferring
tonic sympathetic arousal from spontaneous skin conductance
fluctuations. *Psychophysiology*, in press.
[\[PubMed\]](http://www.ncbi.nlm.nih.gov/pubmed/25930177)

## Models for pupil data
Models are available for illuminance-elicited changes, cognitive input,
and specifically for fear conditioning. All model build on LTI systems
and are inverted in the framework of GLM. PsPM contains many
pre-processing and convenience functions for eye-tracking data.

* The
illuminance model and its application to cognitive paradigms was
introduced in: Korn CW & Bach DR (2016). A solid frame for the window on
cognition: Modeling event-related pupil responses. *Journal of Vision*,
*16*, 28. [\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/26894512)
* The
model for fear-conditioned pupil size responses (fcPSR) was introduced
in: Korn CK, Staib M, Tzovara A, Castegnetti G, Bach DR (2017). A pupil
size response model to assess fear learning. *Psychophysiology*, *54*,
330-343. [\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/27925650)

## Models for heart data
These models specify patterns of heart-period responses evoked by short
events, or by fear-conditioned stimuli. These models formally build on
LTI systems and are inverted in the framework of GLM. Both were tested
in several independent data sets. Pre-processing functions allow
conversion of ECG, pulsoxymetry data, or pulse time stamps, into the
required format.

* The pre-processing pipeline and the model for evoked
heart period responses (eHPR) was introduced in: Paulus PC, Castegnetti
G, & Bach DR (2016). Modeling event-related heart period responses.
*Psychophysiology, 53,* 837-846.
[\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/26849101)
* The model for
fear-conditioned heart period responses (fcHPR) was introduced in:
Castegnetti G, Tzovara A, Staib M, Paulus PC, Hofer N, & Bach DR (2016).
Modelling fear-conditioned bradycardia in humans. *Psychophysiology,
53*, 930-939. [\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/26950648)

## Models for respiration data
These models specify patterns of respiration period, respiration
amplitude, or respiratory flow rate, evoked by short events. A further
model specifies patterns of respiration amplitude changes evoked by
fear-conditioned stimuli. These models formally build on LTI systems and
are inverted in the framework of GLM. All models were tested in
independent data sets. Pre-processing functions allow conversion of
pressure or bellows chest belt data into the required format.

* The
pre-processing pipeline and the model for evoked respiratory responses
was introduced in: Bach DR, Gerster S, Tzovara A, Castegnetti G (2016).
A linear model for event-related respiration responses. *Journal of
Neuroscience Methods, 270,* 174-155.
[\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/27268156)
* The model for
fear-conditioned respiration amplitude responses (fcRAR) was introduced
in: Castegnetti G, Tzovara A, Staib M, Gerster S, Bach DR (2017).
Assessing fear learning via conditioned respiratory amplitude responses.
*Psychophysiology*, *54*, 215-223.
[\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/27933608)  

## Model for startle-eye blink EMG
This model provides a unified scoring method for startle eye blink
responses (SEBR) as measured by EMG of the M. orbicularis oculi. It is
specified in the framework of LTI systems and inverted using a combined
template matching and GLM approach. Pre-processing is optimised for
measuring fear-potentiated startle, but the method is generally
applicable for any startle response.

* Khemka S, Tzovara A, Gerster S,
Quednow BB, Bach DR (2017). Modelling startle eye blink electromyogram
to assess fear learning. *Psychophysiology*, *54*, 202-214.
[\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/27753123)

## Examples for applications of PsPM
* Tzovara A, Korn CW & Bach DR (2018). Human Pavlovian fear conditioning conforms to probabilistic learning. PLOS Computational Biology,14, e1006243. [\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/30169519)
* Staib M & Bach DR (2018). Stimulus-invariant auditory cortex threat encoding during fear conditioning with simple and complex sounds. Neuroimage, 166, 276-284. [\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/29122722)
* Koban L, Kusko D, Wager TD (2018). Generalization of learned pain modulation depends on explicit learning. Acta Psychologica, 184, 75-84. [\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/29025685)
* Gossett EW, Wheelock MD, Goodman AM, Orem TR, Harnett NG, Wood KH, Mrug S, Granger DA, Knight DC (2018). Anticipatory stress associated with functional magnetic resonance imaging: Implications for psychosocial stress research. International Journal of Psychophysiology, 125, 35-41. [\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/29454000)
* Bach DR, Tzovara A, Vunder J (2018). Blocking human fear memory with the matrix metalloproteinase inhibitor doxycycline. Molecular Psychiatry, 23, 1584–1589. [\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/28373691)
* de Berker AO, Rutledge RB, Mathys C, Marshall L, Cross GF, Dolan RJ, Bestmann S (2016). Computations of uncertainty mediate acute stress responses in humans. Nature Communications, 7, 10996. [\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/27020312)
* Koban L&  Wager TD (2016). Beyond conformity: Social influences on pain reports and physiology. Emotion, 16, 24. [\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/26322566)
* Alvarez RP, Kirlic N, Misaki M, Bodurka J, Rhudy JL, Paulus MP, Drevets WC. (2015). Increased anterior insula activity in anxious individuals is linked to diminished perceived control. Translational Psychiatry, 5, e591. [\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/26125154)
* Bulganin L, Bach DR, & Wittmann BC (2014). Prior fear conditioning and reward learning interact in fear and reward networks. Frontiers in Behavioral Neuroscience, 8, 67. [\[PubMed\]](https://www.ncbi.nlm.nih.gov/pubmed/24624068)
* Sulzer J, Sitaram R, Blefari ML, Kollias S, Birbaumer N, Stephan KE, Luft A, Gassert R. (2013). Neurofeedback-mediated self-regulation of the dopaminergic midbrain. Neuroimage, 83, 817-825. [\[PubMed\]](http://www.ncbi.nlm.nih.gov/pubmed/23791838)
* Hayes DJ, Duncan NW, Wiebking C, Pietruska K, Qin P, Lang S, Gangon J, Blng PG, Verhaeghe J, Kostikov AP, Schirrmacher R, Reader AJ, Doyon J, Rainville P, & Northoff G (2013). GABA(A) Receptors Predict Aversion-Related Brain Responses: An fMRI-PET Investigation in Healthy Humans. Neuropsychopharmacology, 38, 1438-1450. [\[PubMed\]](http://www.ncbi.nlm.nih.gov/pubmed/23389691)
* Fan J, Xu P, Van Dam NT, Eilam-Stock T, Gu X, Luo YJ, Hof PR (2012). Spontaneous brain activity relates to autonomic arousal. Journal of Neuroscience, 32, 11176-11186. [\[PubMed\]](http://www.ncbi.nlm.nih.gov/pubmed/22895703)
* Bach DR, & Friston KJ (2012). No evidence for a negative prediction error signal in peripheral indicators of sympathetic arousal. NeuroImage, 59, 883-884. [\[PubMed\]](http://www.ncbi.nlm.nih.gov/pubmed/21920443)
* Nicolle A, Fleming SM, Bach DR, Driver J, Dolan RJ (2011). A regret-induced status quo bias. Journal of Neuroscience, 31, 3320-7. [\[PubMed\]](http://www.ncbi.nlm.nih.gov/pubmed/21368043)
* Bach DR, Weiskopf N, Dolan RJ (2011). A stable sparse fear memory trace in human amygdala. Journal of Neuroscience, 31, 9383-9389. [\[PubMed\]](http://www.ncbi.nlm.nih.gov/pubmed/21697388)
* Talmi D, Dayan P, Kiebel SJ, Frith CD, Dolan RJ (2009). How humans integrate the prospects of pain and reward during choice. Journal of Neuroscience, 29, 14617-26. [\[PubMed\]](http://http//www.ncbi.nlm.nih.gov/pubmed/19923294)
