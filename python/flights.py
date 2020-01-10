import pandas

pip in
stall google.colab
from google.colab import files
uploaded = files.upload()
alldata = pd.read_csv(io.BytesIO(uploaded['lipids_dem_ml_data.csv']), header=None)
