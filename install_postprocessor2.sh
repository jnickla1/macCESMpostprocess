#!/usr/bin/env bash -l

echo "Installing things with pip"
conda activate cesm-env0
pip3 install netcdf4 
pip3 install scipy matplotlib 
pip3 install cf_units
pip3 install cartopy
pip3 install mpi4py virtualenv-clone

echo "Installing one thing from source via github"
git clone https://github.com/NCAR/ASAPPyTools
cd ASAPPyTools
python setup.py install
cd ..
###These two components will be installed by CESM_postprocessing itself, but if that doesnt work, try to install individually
##git clone https://github.com/NCAR/PyReshaper
##cd PyReshaper
##python setup.py install
##cd ..
##pip3 install PyAverager 

git clone https://github.com/NCAR/CESM_postprocessing
cd CESM_postprocessing

make
cp ../../macCESMpostprocess/utley_modules Machines/
sed -i '' "s|/Users/jnicklas1/cesmppp/CESM_postprocessing|${PWD}|g" Machines/utley_modules
cp ../../macCESMpostprocess/machine_postprocess.xml Machines/
PYTHONROOT=$(which python)
envPYTHONRT=${PYTHONROOT%/*}
envROOT=${envPYTHONRT%/*}
#PYTHONverF=$(python -V)
#PYTHONverG=${PYTHONverF:7}
#PYverC=${PYTHONverG%.*}
#sed -i '' "s|python3.12|python${PYverC}|g" Machines/machine_postprocess.xml
sed -i '' "s|/Users/jnicklas1/miniforge3/envs/cesm-env0|${envROOT}|g" Machines/machine_postprocess.xml
./create_python_env -machine utley

echo "Making a few post-install fixes"
cp ../../macCESMpostprocess/activate_this.py cesm-env2/bin
sed -i '' "657s|aleph|utley|g" cesm_utils/cesm_utils/create_postprocess
sed -i '' "34s|. activate|eval \"\$(conda shell.bash hook)\"|g" Templates/postprocess.tmpl
sed -i '' "35s|^$|conda activate \${PWD%/*}|g" Templates/postprocess.tmpl
sed -i '' "73s|caseroot[0]|caseroot|g" timeseries/timeseries/cesm_tseries_generator.py
echo "Install Complete"