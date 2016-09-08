# [RoastLearner](#RoastLearner)
### Machine learning audio classification engine for Artisan

RoastLearner allows your computer to "hear" the sounds of first crack while roasting with the [Artisan Roaster Scope](https://github.com/artisan-roaster-scope/artisan) software.  RoastLearner uses a microphone to record the sound of your roast, provides a platform to *train* the sounds made during that process, and then runs the trained *classifiers* during future roasts to *classify* what it's "hearing" while sending the results to Artisan in (near) real time.

RoastLearner is a collection of scripts to record audio samples during the coffee roasting process and to classify the recorded sounds into user-defined classes like "firstcrack" or "environment".  This data can be presented to the [Artisan Roaster Scope](https://github.com/artisan-roaster-scope/artisan) software to be graphed or to help control the roast in response to audible events.

RoastLearner also includes tools to train classification engines against data recorded from previous roasts.

RoastLearner acts as a "shell" for the excellent [PyAudioAnalysis](https://github.com/tyiannak/pyAudioAnalysis) audio classification toolkit.  The RoastLearner distribution also includes compiled binaries for [SoX](http://sox.sourceforge.net/) to record audio from your default microphone.

Here's a video demonstrating the classifiers in action during a roast being controlled by Artisan.

[![RoastLearner video](documentation/images/Artisan_YouTube_Screenshot.png?raw=true)](https://www.youtube.com/watch?v=CqgeNr_wXbY&t=560 "RoastLearner video")

### [Requirements](#Requirements)
* RoastLearner currently supports Windows installations only.
* [Artisan](https://github.com/artisan-roaster-scope/artisan) 1.0 or above
* Python 2.7 for Windows and a pile of additional modules.  [Read here](documentation/Deploy_Python27.md) for detailed installation instructions on setting up the Python environment.
* A microphone positioned somewhere where it can pick up the sounds from your roaster.  This was developed with [a cheap $9 USB microphone](https://www.amazon.com/gp/product/B014MASID4) so nothing fancy is required here.  The microphone must be set as the default recording device in Windows.

### [Getting Started](#Getting-Started)
1. [Install Artisan](https://github.com/artisan-roaster-scope/artisan/blob/master/wiki/Installation.md) to the default location.
2. [Install Python27, our required modules, and the PyAudioAnalysis libraries](documentation/Deploy_Python27.md#Python-Deployment-for-RoastLearner).
3. [Install RoastLearner](documentation/Install_RoastLearner.md#RoastLearner-Installation).
4. [Configure Artisan to run RoastLearner](documentation/Install_RoastLearner.md#Artisan-device-configuration).
5. Run one or more roasts to collect some initial recordings of the sounds your machine makes during the roast process.
6. [Manually classify your recordings and train the RoastLearner classifier(s)](documentation/Train_RoastLearner.md#Training-RoastLearner).
