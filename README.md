# Installing UCAR's CESM postprocessing tools on Mac
(I got this to work on MacOS12.6.3 in October 2023)
Please see https://github.com/NCAR/CESM_postprocessing/ for the current verison of this code,
but on that github there is only stuff to get this to run on the NCAR Cheyenne and DAV machines.

Note that the computer that I first installed this package was named "utley". So if you want to use a different name, navigate to this git repo after you have downloaded it and run:
```
find . -type f | xargs sed -i '' "s/utley/YOURNAME/g"
mv utley_modules YOURNAME_modules
```
(If on Linux, I have not yet tested, don't use singe quotes like `sed -i '' "s`, instead use `sed -i "s`. You also must make this correction on lines 43-58 of install_postprocessor.sh)

## STEP 0: Navigate to the macCESMpostprocess parent directory.
My script will install everything in this directory adjacent to macCESMpostprocess.
(Note, if you downloaded via a zip file on github.com, you will need to rename the folder from "macCESMpostprocess-main" to "macCESMpostprocess") 
```
cd /path/to/where/you/downloaded/macCESMpostprocess
cd ..
```

## STEP 1: Download, install MAMBA and Command Line Tools
```
xcode-select --install
sudo xcodebuild -license
curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh
```
Respond "yes" to all requests including running conda init.
## STEP 2: Restart the shell (close the Terminal window, open a new one), and run the following interactive script.
```
bash macCESMpostprocess/install_postprocessor.sh
```

## STEP 3: Instantiate postprocessing.
This creates a code folder within your case output directory
```
conda activate cesm-env0
export POSTPROCESS_PATH=/path/to/where/you/installed/CESM_postprocessing
cd /case/directory/to/postprocess
create_postprocess -caseroot $PWD
cd postprocess
```

## STEP 4: Modify the env files to fit your case. 
Look at those in the macCESMpostprocess folder for guidance.
These env files were created for a gx3v7 CESM run that went for 75 years.
**Note that only time series script has been tested, averaging and diagnostic scripts are still being tested.

## STEP 5: Run individual scripts. 
For instance, you can do
```
./timeseries & disown
```
