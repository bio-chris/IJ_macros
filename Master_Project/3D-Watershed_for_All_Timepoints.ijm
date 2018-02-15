/*
 * Applies a 3D-Watershed to large datasets by splitting it into subsets and then performing the 3D-Watershed on each subset.
 * 
 * NOTE: This macro is redundant if one just reduces the size of the entire dataset to not more than 20 Gb!!! Then 3D Watershed can be applied to the 4D Hyperstack. 
 * 
 */

Dialog.create("Configuration");


Dialog.addNumber("How many timepoints in existing file:", 50);
Dialog.addNumber("How many timepoints in each new file:", 12);
Dialog.addMessage("Make sure that the number of files generated is an integer. There are no two and a half files!"); 

Dialog.show();


nAll_Timepoints = Dialog.getNumber();
nTimepoints = Dialog.getNumber(); 

out=getDirectory("Select Folder in which all processed files should be stored");
filepath=File.openDialog("Select the processed image containing all timepoints"); 
filename = File.getName(filepath); 

File.makeDirectory(out + File.separator + "Separated timepoints"); 

out1 = out + File.separator + "Separated timepoints"; 

runs = nAll_Timepoints/nTimepoints; 


open(filename); 
getDimensions(width, height, channels, slices, frames);


nTimepoints2 = 1;
nTimepoints3 = nTimepoints; 

for (i=0; i<runs; i++){
	
	run("Make Substack...", "slices=[1-" + slices + "]" +
	"frames=[" + nTimepoints2 + "-" + nTimepoints3 + "]");

	saveAs("Tiff", out1 + File.separator + "TP" + nTimepoints2 + "-" + nTimepoints3); run("Close");
	nTimepoints2 = nTimepoints2 + nTimepoints;
	nTimepoints3 = nTimepoints3 + nTimepoints; 
	
}

run("Close All"); 

File.makeDirectory(out + File.separator + "3D Watershed Timepoints"); 
out2 = out + File.separator + "3D Watershed Timepoints"; 

names=getFileList(out1);

for (i=0; i<names.length; i++){

	open(out1 + File.separator + names[i]);
	names[i] = replace(names[i], ".tif", ""); 
	run("3D Watershed", "seeds_threshold=3 image_threshold=0 image=["+ names[i] +"] seeds=Automatic radius=5");
	selectWindow(""+ names[i] + ".tif" +""); run("Close"); 
	selectWindow("watershed");

	run("Stack to Hyperstack...", "order=xyczt(default) channels=1 slices=["+ slices +"] frames=["+ nTimepoints +"] display=Color");
	saveAs("Tiff", out2 + File.separator + "Watershed_" + names[i]); run("Close All");
}

filepath2=File.openDialog("Select the first image that was processed by 3D-Watershed"); 
filename2 = File.getName(filepath2); 


