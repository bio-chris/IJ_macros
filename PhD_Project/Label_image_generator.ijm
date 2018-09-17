/*
 * 03/07/2018
 * 
 * Create labelled masks based on binary mask for later python analysis
 * 
 * Python scipy library unable to connect objects by one pixel diagonally
 * 
 * 
 */

 dir = getDirectory("Select Directory in which all segmented images are stored");
 files = getFileList(dir);


  if(File.isDirectory(dir + File.separator + "Labelled_Mask")){	
 	 
 }
 else{
 	
 	File.makeDirectory(dir + File.separator + "Labelled_Mask");
 	
 }

 
 for (i=0; i<files.length; i++){

 	open(dir + File.separator + files[i]);
	img = getTitle(); 

	run("Analyze Particles...", "  show=[Count Masks]");

	selectWindow(img);
	run("Close");

	saveAs("Tiff", dir + File.separator + "Labelled_Mask" + File.separator + img + ".tif");
	run("Clear Results");
	run("Close All");


 }