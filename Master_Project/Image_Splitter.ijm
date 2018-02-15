/*
 * Splits Image in different parts along the y-axis to allow tracking on less powerful computers 
 */

out=getDirectory("Select Folder in which all processed files should be stored");
filepath=File.openDialog("Select the processed image containing all timepoints"); 
filename = File.getName(filepath); 

open(filename); 
rename("Main"); 

getDimensions(width, height, channels, slices, frames);

Dialog.create("Configuration");
Dialog.addNumber("In how many parts do you want to split your image?:", 4);
Dialog.show();

nParts = Dialog.getNumber(); 

x_coordinate = 0;
y_coordinate = 0; 

ROI_height = height/nParts;

File.makeDirectory(out + File.separator + "Single parts");

for (i=0; i<nParts; i++){

	selectWindow("Main"); 
	makeRectangle(x_coordinate, y_coordinate, width, ROI_height);
	run("Duplicate...", "duplicate");
	selectWindow("Main-1"); 
	saveAs("Tiff", out + "Single parts" + File.separator + "Part-" + i); 
	run("Close"); 

	y_coordinate += ROI_height; 
	
}
