from ij import IJ # imports the IJ class

from ij.plugin import ImageCalculator # imports the Image Calculator from the ImageJ Plugins

imp = IJ.getImage() # gets the title of the image 

IJ.run(imp, "Duplicate...", "title=duplicate.tif duplicate") # runs duplication on selected image

imp_2 = IJ.getImage() # gets title of duplicated image

IJ.run(imp, "Gaussian Blur 3D...", "x=2 y=2 z=2"); # runs gaussian blur 3D on original image
IJ.run(imp_2, "Gaussian Blur 3D...", "x=4 y=4 z=4"); # runs gaussian blur 3D on duplicated image

calc = ImageCalculator() # setting the function equal to the variable calc
calc.calculate("Subtract create stack", imp, imp_2) # calling the ImageCalculator() to subtract imp minus imp_2

imp.close() # closes original image
imp_2.close() # closes duplicate image


#print imp.title






