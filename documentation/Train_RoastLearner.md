# Training RoastLearner

RoastLearner utilizes the [PyAudioAnalysis library](https://github.com/tyiannak/pyAudioAnalysis) to "learn" the sounds made by your roaster.  PyAudioAnalysis utilizes trained *classifiers* to *classify* sounds that we hand to it based on the sounds it was trained on.

As every roaster and environment sounds different, you will need to start by recording one or more roasts and then manually classifying the sounds made during that process.  Once we've done that, we can *train* our classification engines using the sounds from your roaster.

#### Recording folder structure
Several folders are created upon installation of RoastLearner under "%LOCALAPPDATA%\RoastLearner" and a shortcut to this folder was placed on your desktop as "RoastLearner Recordings".  The folder structure looks something like this after one roast has been recorded:

    ├───RoastLearner
        ├───classified_recordings
        │   ├───environment
        │   └───firstcrack
        ├───classifiers
        └───recordings
            └───recording_16-09-08_1452

The `classified_recordings` folder contains one folder for each class that RoastLearner will attempt to identify.  Files are manually placed into these folders.

The `classifiers` folder contains trained models used by RoastLearner.  Backups of previous models will also appear under this folder once additional training sessions are run.

The `recordings` folder contains one folder for every run of RoastLearner, named to match the default naming standard used by Artisan for saving individual roast logs.

#### Classifying a recorded roast
Here's the part that involves some work: you need to review the recorded samples in one or more recordings and manually copy the 1-second WAV files into the class folders under `classified_recordings`.

I've found that dragging an entire folder's worth of 1-second samples into Media Player (iTunes, foobar, whatever) will create a playlist which can be listened to as a continuous recording.  Listen to the playlist and then copy WAV files containing "environment" sounds to `%LOCALAPPDATA%\RoastLearner\classified_recordings\environment`.  This would include any sound that isn't "firstcrack".  Similarly, copy 1-second WAV files containing the sounds of first crack into `%LOCALAPPDATA%\RoastLearner\classified_recordings\firstcrack`.

>##### WARNING:
I've found that the PyAudioAnalysis training process tends to bomb out on any half-completed WAV files left behind by SoX, typically found at the very end of the recording.  Before proceeding to the training process, make 100% certain that all files in your `classified_recordings` folder are the exact same size.  If the training process below fails, it's almost certainly due to a bad WAV file.

#### Training your classifier
Once you've manually classified sounds into "environment" and "firstcrack" you can train your first classifier.  Open the "RoastLearner Recordings" on your desktop and run the link labeled "Re-train Classifiers".  This will backup any previously trained classifiers and then create new models based on the WAV files you manually classified.

At the end of each training session a *[confusion matrix](https://en.wikipedia.org/wiki/Confusion_matrix)* is displayed giving you a sense of how well the new models perform against the existing data.
