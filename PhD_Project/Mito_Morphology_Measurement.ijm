/*
 * 11/04/18
 * 
 * Macro will automatically perform morphological measurements (area, circularity, aspect ratio, roundness, solidity)
 * on all segmented objects in image and store them in a csv file (one file per image)
 * 
 */

 dir = getDirectory("Select Directory in which all segmented images are stored");
 files = getFileList(dir);

 run("Set Measurements...", "area shape redirect=None decimal=3");

 if(File.isDirectory(dir + File.separator + "Morphology_Measurements")){	
 	 
 }
 else{
 	
 	File.makeDirectory(dir + File.separator + "Morphology_Measurements");
 	
 }

//setBatchMode(true);

 for (i=0; i<files.length; i++){

 	open(dir + File.separator + files[i]);
	img = getTitle(); 

	// temporary: set, set all values above 128 to 255 
	/*
	setThreshold(0, 128);
	setOption("BlackBackground", false);
	run("Convert to Mask");

	run("Invert");
	run("Invert LUT");
	*/
	//
 		
 	run("Invert");
 	
	// filter out all particles below 10px in size
 	run("Analyze Particles...", "size=10-Infinity show=Nothing display");

 	print(files[i]);

	selectWindow("Results");
 	saveAs("Results", dir + File.separator + "Morphology_Measurements" + File.separator + img + ".csv");
	//saveAs("Results", dir + File.separator + i + ".csv");
	run("Close");
	
 	run("Close All");

 	
 }
