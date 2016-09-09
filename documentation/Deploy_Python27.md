# [Python Deployment for RoastLearner](#Python-Deployment-for-RoastLearner)
RoastLearner requires the installation of Python 2.7 for Windows along with several additional modules in order to execute the [PyAudioAnalysis](https://github.com/tyiannak/pyAudioAnalysis) scripts.

#### Download and install the development environment tools:

* Download Python 2.7 installer for 32bit Windows: https://www.python.org/downloads/
* Run Python 2.7 installer. Install for all users, accept the default install location of C:\Python27, then select the installation option "Add python.exe to Path" at the bottom of the Customize Python step (you might need to scroll to find it).
* Download and Install GitHub Desktop from https://desktop.github.com/
* Download "numpy-1.11.1+mkl-cp27-cp27m-win32.whl" from http://www.lfd.uci.edu/~gohlke/pythonlibs/#numpy
* Download "scipy-0.18.0-cp27-cp27m-win32.whl" from http://www.lfd.uci.edu/~gohlke/pythonlibs/#scipy

*Note that these last two requirements can only be found on this one dude's .edu home directory for some reason, and it is slow as heck. Be patient.*

#### Install and configure the development libraries:
* Open an admin command prompt
* You'll likely start in C:\WINDOWS\system32, so let's head over to the default Python scripts folder before we begin:


    cd /d C:\Python27\Scripts

* Paste the following to make sure pip is all up-to-date. *The first command kicked out a bunch of red errors but worked anyway.*


    pip install --upgrade pip

    pip install --upgrade urllib3[secure]

* Install the two compiled libraries you've downloaded. Replace <path to downloads> with the full path to wherever you've deposited these things, add quotes if spaces are involved.


    pip install <path to downloads>\numpy-1.11.1+mkl-cp27-cp27m-win32.whl

    pip install <path to downloads>\scipy-0.18.0-cp27-cp27m-win32.whl


* Now we can install the required libraries. Paste the following to get everything rolled out:


    pip install matplotlib

    pip install sklearn

    pip install hmmlearn

    pip install simplejson
    
    pip install eyed3

#### Download and test pyAudioAnalysis
* Open the Git Shell from the desktop icon deployed when you installed Github Desktop for Windows
* In the Git Shell window, clone the pyAudioAnalysis repo with the following command:


    git clone https://github.com/tyiannak/pyAudioAnalysis.git C:\Python27\scripts\pyAudioAnalysis

* Close the Github Powershell window and go back to your original console session
* Change to the new folder:


    cd /d C:\Python27\scripts\pyAudioAnalysis

Finally, test the installation by running an analysis against the included test data:

    python audioAnalysis.py fileChromagram -i data/doremi.wav

If everything worked correctly the script should open a window that looks something like this:

![Successful example output](images/fileChromagram.png?raw=true "Successful example output")
