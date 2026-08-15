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
[\[doi\]](https://doi.org/10.1111/j.1469-8986.2012.01483.x)
* Bach DR,
Castegnetti G, Korn CW, Gerster S, Melinscak F, Moser T (2018).
Psychophysiological modelling - current state and future directions.
*Psychophysiology*, *55*, e13209.
[\[doi\]](https://doi.org/10.1111/psyp.13209)

## Models for skin conductance responses
### General: the skin conductance response function
* Bach DR, Flandin G, Friston KJ, Dolan RJ (2010). Modelling event-related
skin conductance responses. *International Journal of Psychophysiology*,
*75*, 349-356. [\[doi\]](https://doi.org/10.1016/j.ijpsycho.2010.01.005) (Development of the SCRF, and an indirect test of the LTI assumptions)
* Gerster S, Namer B, Elam M, Bach DR (2018). Testing a linear time
invariant model for skin conductance responses by intraneural recording
and stimulation. *Psychophysiology*, *55*, e12986.
[\[doi\]](https://doi.org/10.1111/psyp.12986) (A direct test of the LTI assumptions, using intraneural recording and stimulation)

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
[\[doi\]](https://doi.org/10.1016/j.jneumeth.2009.08.005) (Proof-of-principle of the GLM for SCR) 
* Bach DR,Friston KJ, Dolan RJ (2013). An improved algorithm for model-based
analysis of evoked skin conductance responses. *Biological Psychology*,
*94*, 490-497. [\[doi\]](https://doi.org/10.1016/j.biopsycho.2013.09.010) (optimisation of the algorithm and latest recommendations)
* Bach DR (2014). A head-to-head comparison of SCRalyze and Ledalab, two
model-based methods for skin conductance analysis. *Biological
Psychology, 103*, 63-88.
[\[doi\]](https://doi.org/10.1016/j.biopsycho.2014.08.006) (direct comparison with Ledalab)

### Non-linear model for event-related SCR
This model is used, e.g. for
conditioned (anticiaptory) responses in fear conditioning. It assumes that the onset
of the neural response is not precisely known, and estimates onset,
dispersion, and amplitude of the response. Non-linear model
inversion is accomplished in the computational framework of the [Variational Bayes approach](https://doi.org/10.1371/journal.pcbi.1003441).

* Bach DR, Daunizeau J, Friston KJ, Dolan
RJ (2010). Dynamic causal modelling of anticipatory skin conductance
responses. *Biological Psychology*, *85*, 163-70.
[\[doi\]](https://doi.org/10.1016/j.biopsycho.2010.06.007) (proof of principle of the non-linear model for SCR)
* Staib M,
Castegnetti G, Bach DR (2015). Optimising a model-based approach to
inferring fear learning from skin conductance responses. *Journal of
Neuroscience Methods, 255,* 131-138.
[\[doi\]](https://doi.org/10.1016/j.jneumeth.2015.08.009) (optimisation of the algorithm and latest recommendations)

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
[\[doi\]](https://doi.org/10.1016/j.ijpsycho.2010.01.011) (test for LTI
assumptions, a modified SCRF for SF, AUC method)
* Bach DR, Daunizeau J, Kuelzow
N, Friston KJ, Dolan RJ (2011). Dynamic causal modelling of spontaneous
fluctuations in skin conductance. *Psychophysiology*, *48*, 252-257.
[\[doi\]](https://doi.org/10.1111/j.1469-8986.2010.01052.x) (Non-linear model for SF)
* Bach DR, Staib M (2015). A matching pursuit algorithm for inferring
tonic sympathetic arousal from spontaneous skin conductance
fluctuations. *Psychophysiology*, *52*, 1106-1112.
[\[doi\]](https://doi.org/10.1111/psyp.12434) (MP approximation for SF)

## Models for pupil data
Models are available for illuminance-elicited changes, cognitive input,
and specifically for fear conditioning. All model build on LTI systems
and are inverted in the framework of GLM. PsPM contains many
pre-processing and convenience functions for eye-tracking data.

* Korn CK, Staib M, Tzovara A, Castegnetti G, Bach DR (2017). A pupil
size response model to assess fear learning. *Psychophysiology*, *54*,
330-343. [\[doi\]](https://doi.org/10.1111/psyp.12801) (GLM for fear-conditioned pupil size responses)
* Korn CW & Bach DR (2016). A solid frame for the window on
cognition: Modeling event-related pupil responses. *Journal of Vision*,
*16*, 28. [\[doi\]](https://doi.org/10.1167/16.3.28) (illuminance model and its application to cognitive paradigms)
* Abivardi A, Korn CW, Rojkov I, Gerster S, Hurlemann R, Bach DR (2023). Acceleration of inferred neural responses to oddball targets in an individual with bilateral amygdala lesion compared to healthy controls. *Scientific Reports*, *13*, 41357. [\[doi\]](https://doi.org/10.1038/s41598-023-41357-1) (application of the illuminance model to a lesion patient group)

## Models for heart data
* Castegnetti G, Tzovara A, Staib M, Paulus PC, Hofer N, & Bach DR (2016).
Modelling fear-conditioned bradycardia in humans. *Psychophysiology,
53*, 930-939. [\[doi\]](https://doi.org/10.1111/psyp.12637) (GLM for fear-conditioned bradycardia)
* Paulus PC, Castegnetti
G, & Bach DR (2016). Modeling event-related heart period responses.
*Psychophysiology, 53,* 837-846.
[\[doi\]](https://doi.org/10.1111/psyp.12622) (GLM for evoked heart period responses)

## Models for respiration data
Castegnetti G, Tzovara A, Staib M, Gerster S, Bach DR (2017).
Assessing fear learning via conditioned respiratory amplitude responses.
*Psychophysiology*, *54*, 215-223.
[\[doi\]](https://doi.org/10.1111/psyp.12778) (GLM for fear-conditioned respiration amplitude)
* Bach DR, Gerster S, Tzovara A, Castegnetti G (2016).
A linear model for event-related respiration responses. *Journal of
Neuroscience Methods, 270,* 174-155.
[\[doi\]](https://doi.org/10.1016/j.jneumeth.2016.06.001) (GLM for evoked respiratory responses)

## Model for startle-eye blink EMG
* Khemka S, Tzovara A, Gerster S,
Quednow BB, Bach DR (2017). Modelling startle eye blink electromyogram
to assess fear learning. *Psychophysiology*, *54*, 202-214.
[\[doi\]](https://doi.org/10.1111/psyp.12775)

## Recent examples for research studies using PsPM
* Gomes CA, Bach DR, Razi A et al. (2026). Predicting individual differences of fear and cognitive learning and extinction. *Nature Communications*, *17*, 3780. [\[doi\]](https://doi.org/10.1038/s41467-026-71830-0)
* Guerrero-Hreins E, Greaves MD, Kung PH et al. (2026). Bed nucleus of the stria terminalis connectivity during food cue and taste processing under stress. *Nature Communications*, *in press*. [\[doi\]](https://doi.org/10.1038/s41467-026-71414-y)
* Fraenz C, Metzen D, Packheiser J, Merz CJ, Selpien H, Axmacher N, Genç E (2025). Multi-modal brain properties are associated with interindividual differences in fear acquisition and extinction. [\[preprint\]](https://doi.org/10.1101/2025.04.05.647350)
* Skelton AB, De Vries LA, Silva AM, Limongi R (2026). Writing Through Sympathetic Arousal: A Perceptual Active Inference Model on the Effects of Sympathetic Arousal Interoception on Written and Spoken Grammatical Complexity. In: Albarracin, M., et al. Active Inference. IWAI 2025. *Communications in Computer and Information Science*, *vol 2857*. Springer, Cham. [\[doi\]](https://doi.org/10.1007/978-3-032-16955-6_14)
* Duda JM, Keding TJ, Kribakaran S, Odriozola P, Kitt ER, Cohodes EM, Zacharek SJ, McCauley S, Haberman JT, Joormann J, Gee DG (2025). Exposure to unpredictable childhood environments is associated with amygdala activation during early extinction in adulthood. *Developmental Cognitive Neuroscience*, *74*, 101578. [\[doi\]](https://doi.org/10.1016/j.dcn.2025.101578)
* De Aquino JP, Costa GPA, Nunes JC, Hudak J, Odette M, Garland EL (2025) Cannabis use frequency is associated with emotion dysregulation among persons receiving long-term opioid therapy for chronic pain: A psychophysiological study. *Drug and Alcohol Dependence*, *275*, 112812. [\[doi\]](https://doi.org/10.1016/j.drugalcdep.2025.112812)
* Jelsma E, Zhang A, Goosby BJ, Chadle JE (2024). Sympathetic arousal among depressed college students: Examining the interplay between psychopathology and social activity. *Psychophysiology*, *61*, e14597. [\[doi\]](https://doi.org/10.1111/psyp.14597)
* Becker J, Viertler M, Korn CW, Blank H (2024). The pupil dilation response as an indicator of visual cue uncertainty and auditory outcome surprise. *European Journal of Neuroscience*, *59*, 2686–2701. [\[doi\]](https://doi.org/10.1111/ejn.16306)
* Eickstead CT, Davis ES, Goodman AM, Purcell JB, Dark HE, Grey DK, Bolaram A, Orem TR, Wheelock MD, Mrug S, Knight DC (2025). Violence exposure moderates stress-elicited neurobehavioral function in young people. *Emotion*, *26*, 634–651. [\[doi\]](https://doi.org/10.1037/emo0001590)
* Xia Y, Wehrli J, Abivardi A , Hostiuc M, Kleim B, Bach DR (2024). Attenuating human fear memory retention with minocycline: a randomized placebo-controlled trial. *Translational Psychiatry*, *14*, 28. [\[doi\]](https://doi.org/10.1038/s41398-024-02732-2)
* Wehrli J, Xia Y, Abivardi A , Kleim B, Bach DR (2024). The impact of doxycycline on human contextual fear memory. *Psychopharmacology*, *241*, 1065–1077. [\[doi\]](https://doi.org/10.1007/s00213-024-06540-w)
* Wehrli J, Xia Y, Offenhammer B, Kleim B, Müller D, Bach DR (2023). Effect of the matrix metalloproteinase inhibitor doxycycline on human trace fear memory. *eNeuro*, ENEURO.0243-22.2023. [\[doi\]](https://doi.org/10.1523/ENEURO.0243-22.2023)
* Xia Y, Wehrli J, Gerster S, Kroes M, Houtekamer M, Bach DR (2023). Measuring human context fear conditioning and retention after consolidation. *Learning & Memory*, *30*, 139–150. [\[doi\]](https://doi.org/10.1101/lm.053781.123)
* Ojala KE, Staib M, Gerster S, Ruff CC, Bach DR (2022). Inhibiting human aversive memory by transcranial theta-burst stimulation to primary sensory cortex. *Biological Psychiatry*, *92*, 149-157. [\[doi\]](https://doi.org/10.1016/j.biopsych.2022.01.021)
* Wehrli JM, Xia Y, Gerster S, & Bach DR (2022). Measuring human trace fear conditioning. *Psychophysiology*, *59*, e14119. [\[doi\]](https://doi.org/10.1111/psyp.14119)
* Homan P, Lau HL, Levy I, Raio CM, Bach DR, Carmel D, Schiller S (2021). Evidence for a minimal role of stimulus awareness in reversal of threat learning. *Learning & Memory*, *28*, 95-103. [\[doi\]](https://doi.org/10.1101/lm.050997.119)
