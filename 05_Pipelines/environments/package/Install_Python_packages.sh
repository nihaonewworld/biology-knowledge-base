conda create -n deepl -c conda-forge r-base=4.5.2 python=3.12

python -m pip install --upgrade pip

pip install numpy pandas scipy
pip install matplotlib seaborn plotly
pip install scikit-learn
pip install statsmodels
pip install requests
pip install openpyxl xlrd xlsxwriter

pip install jupyterlab
pip install ipywidgets

pip install snakemake

# Interface to use R from Python
pip install rpy2

# cuda-toolkit v12.8
pip install torch torchvision
pip install tensorflow[and-cuda]

# cuda-toolkit v13.0
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu130
