from sdtfile import SdtFile
from scipy import io
import numpy as np
import os

def convert_and_save(file):
    matPath = os.path.splitext(file)[0]+'.mat'
    if os.path.isfile(matPath):
        return
    sdt = SdtFile(file)
    reshaped=(np.reshape(sdt.data[0],(512,-1,256)))[:,:1250,:]
    reshaped = reshaped.astype('uint8')
    io.savemat(matPath,{'data':reshaped})