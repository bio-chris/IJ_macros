/*
 * Written mainly for reducing size of dataset when performing spectral unmixing. If dataset is too big, unmixing will fail. Therefore this macro should be
 * used if dataset is too big. Spectral unmixing can then successively be performed on smaller datasets 
 */


out=getDirectory("Select Folder in which all processed files should be stored");
filepath=File.openDialog("Select the processed image containing all timepoints"); 
filename = File.getName(filepath); 

open(filename);
rename("Main");  

getDimensions(width, height, channels, slices, frames); 


Dialog.create("Configuration");

Dialog.addMessage("Number of frames in choosen file is " + frames);
Dialog.addNumber("In how many subfiles do you want to split your selected file?:", 4);
Dialog.addMessage("The number of frames divided by the number of subfiles should not be a fraction!"); 

Dialog.show();

nSubfiles = Dialog.getNumber();

newTimepoints = frames/nSubfiles; 

nTimepoints2 = 1;
nTimepoints3 = newTimepoints; 

for (i=0; i<nSubfiles; i++){
	selectWindow("Main"); 
	run("Make Substack...", "slices=[1-" + slices + "]" +
	"frames=[" + nTimepoints2 + "-" + nTimepoints3 + "]");

	selectWindow("Main-1"); 
	saveAs("Tiff", out + File.separator + "TP" + nTimepoints2 + "-" + nTimepoints3); run("Close");
	nTimepoints2 = nTimepoints2 + newTimepoints;
	nTimepoints3 = nTimepoints3 + newTimepoints; 

}

run("Close All"); 