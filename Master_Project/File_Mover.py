import os
import shutil 

from ij import IJ
from ij.io import DirectoryChooser

dc = DirectoryChooser("Select Main Folder")
inputPath = dc.getDirectory()

file_list = os.listdir(inputPath)

if not os.path.exists(os.path.join(inputPath, "Channel 1")):
        os.makedirs(os.path.join(inputPath, "Channel 1"))

if not os.path.exists(os.path.join(inputPath, "Channel 2")):
        os.makedirs(os.path.join(inputPath, "Channel 2"))

channel_1 = inputPath + "Channel 1" + "\\"
channel_2 = inputPath + "Channel 2" + "\\"

for files in file_list:
		
	if "Ch1" in files:
	
		shutil.move(inputPath + files, channel_1 + files) 


	if "Ch2" in files:
		
		shutil.move(inputPath + files, channel_2 + files) 
	
		




        

