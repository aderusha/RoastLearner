# [RoastLearner Installation](#RoastLearner-Installation)

### [Software Overview](#Software-Overview)
RoastLearner is a collection of scripts which coordinates the recording of audio during a roast, handing the recordings to trained "classifiers" every second or so, and collecting the results from each run of the classifier to be displayed in Artisan.

There are 5 scripts involved in this process:

`start_recording.cmd` Called at the start of your roast by Artisan, this script will launch several other processes which will run in the background.  It creates a new folder to save the current roast recording.  It will launch SoX.exe in the background to record audio from your microphone and save the results in the recording folder as 1-second chunks.  Finally, it will launch the classifiers which will run in the background to monitor output from SoX.

`classify_segment.cmd` This script monitors the recorded output folder for new WAV files.  When a new recording is found, it will launch a classifier to examine the recording and will collect the output from the classifier.  This script can be run several times to run more than one classification engine.  The output from each running classifier is saved to a temporary folder.

`external_program_data.cmd` This script is called every sample interval by Artisan to collect data saved to a temporary file by `classify_segment.cmd` and to output that data in a format that Artisan can ingest.

`stop_recording.cmd` Called at the end of your roast by Artisan, this script will close down running processes and clean up any leftover temporary files.

`train_classifiers.cmd` This script needs to be run by the user to train the classifiers against audio recordings from previous roasts which have been manually classified.  See the [Training RoastLearner](Train_RoastLearner.md#Training-RoastLearner) document for details on this process.

### [Software installation](#Software-installation)
1. [Install Artisan](https://github.com/artisan-roaster-scope/artisan/blob/master/wiki/Installation.md) to the default location.
2. [Install Python27, our required modules, and the PyAudioAnalysis libraries](documentation/Deploy_Python27.md).
3. Download the code presented here and execute "install.cmd" to deploy the required scripts, executables, and folders.
4. Launch Artisan for Windows and [configure it to talk to your roaster](https://github.com/artisan-roaster-scope/artisan/blob/master/wiki/Installation.md#device-configuration).

### [Artisan device configuration](#Artisan-device-configuration)
1. In Artisan, select Config > Device > ET/BT > External Program and enter `scripts\RoastLearner\external_program_data.cmd` as the input program.
![Configure_External_Program](images/Configure_External_Program.png?raw=true "Configure_External_Program")
2. Select the "Extra Devices" tab and click the "Add" button twice to add two new devices.  Configure the two devices as shown in the image below and click OK to save your work.
![Configure_Extra_Devices](images/Configure_Extra_Devices.png?raw=true "Configure_Extra_Devices")

### [Artisan alarm configuration](#Artisan-alarm-configuration)
1. Under Config > Alarms, create two new alarms by pressing "Add" twice.  Configure the alarms as shown below.  If you have existing alarms just add these two to your existing configuration.
![Configure_Alarms](images/Configure_Alarms.png?raw=true "Configure_Alarms")
2. One alarm will run at roast start (I had to set this to run at 1 second after the event to get it to start reliably).  This calls our `start_recording.cmd` script to capture audio and send it to our classifiers.
3. The second alarm will run after DROP to call `stop_recording.cmd`.
