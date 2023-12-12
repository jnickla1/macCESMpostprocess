#!/usr/bin/env bash -l
echo "Installing CESM postprocessig tools"
echo "First, creating the new code root directory:"
mkdir cesmppp
cd cesmppp
export cesmppp=$PWD
export POSTPROCESS_PATH=$PWD
echo $cesmppp
echo "Remember to do ~ % export POSTPROCESS_PATH=${PWD} before you instantiate a case"

echo "Installing things with Conda"
conda init
conda update --all
conda create -n cesm-env0
mamba install -n cesm-env0 pynio
mamba install -n cesm-env0 pyngl #SHOULD ENSURE THAT WE HAVE PYTHON 3.11
#mamba install -n cesm-env0 pip
mamba install -n cesm-env0 git
mamba install -n cesm-env0 openmpi-mpicc
mamba install -n cesm-env0 virtualenv
mamba install -n cesm-env0 nco
mamba install -n cesm-env0 ncl
mamba install -n cesm-env0 -c conda-forge gfortran

echo "Installing things with pip"
eval "$(conda shell.bash hook)"
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
sed -i '' "654s|aleph|utley|g" cesm_utils/cesm_utils/create_postprocess
#need our own template
sed -i '' "34s|. activate|eval \"\$(conda shell.bash hook)\"|g" Templates/postprocess.tmpl
sed -i '' "35s|^$|conda activate \${PWD%/*}|g" Templates/postprocess.tmpl
cp Templates/batch_aleph.tmpl Templates/batch_utley.tmpl
#timeseries stuff - caseroot is a scalar
sed -i '' "s|options.caseroot\[0\]|options.caseroot|g" timeseries/timeseries/cesm_tseries_generator.py
#averager stuff - deal with scalar metavariables
unzip cesm-env2/lib/python3.11/site-packages/PyAverager-0.9.17-py3.11.egg -d cesm-env2/lib/python3.11/site-packages/
mv cesm-env2/lib/python3.11/site-packages/PyAverager-0.9.17-py3.11.egg ../../macCESMpostprocess/PyAverager-0.9.17-py3.11.egg-old
sed -i '' "623s|(len(in_meta) > 0):|(np.ndim(in_meta)==0): out_meta[()]==in_meta[()]|g" cesm-env2/lib/python3.11/site-packages/pyaverager/climFileIO.py
sed -i '' "624s|    o|elif (len(in_meta) > 0): o|g" cesm-env2/lib/python3.11/site-packages/pyaverager/climFileIO.py

echo "Install Complete"
