/*
 *     Automatically crops all images in Channel 1 and Channel 2 folders based on cropping performed on one calibration image 
 */

filepath=File.openDialog("Select an image for cropping calibration"); 
filename = File.getName(filepath); 

open(filename); 

waitForUser("Step 1","Go to Image > Transform > Rotate. Rotate your image in a way that will allow to fit your area of interest into a rectangle"); 

Dialog.create("Rotation calibration");
Dialog.addNumber("Enter the angle at which you rotated the image:", 10);
Dialog.show();

rotation = Dialog.getNumber();

waitForUser("Step 2","Create a rectangular selection around your region of interest and click ok"); 

Roi.getBounds(x, y, width, height);

waitForUser("Step 3", "Estimate the starting and ending plane in the stack that contains biologically relevant information. Click ok if you know which values to enter");  

Dialog.create("Stack calibration");
Dialog.addNumber("First plane of your stack:", 10);
Dialog.addNumber("Last plane of your stack:", 50);
Dialog.show();

first_plane = Dialog.getNumber();
last_plane = Dialog.getNumber(); 

run("Close All"); 

out=getDirectory("Select Folder in which all Channel 1 files that need to be cropped are stored");
out2=getDirectory("Select Folder in which all Channel 2 files that need to be cropped are stored");

names=getFileList(out);
names2=getFileList(out2); 

setBatchMode(true); 

for (i = 0; i<names.length; i++){

	open(out + names[i]);
	run("Rotate... ", "angle="+ rotation +" grid=1 interpolation=Bilinear enlarge stack"); 
	makeRectangle(x, y, width, height);
	run("Crop");
	run("Slice Keeper", "first="+ first_plane +" last="+ last_plane +" increment=1");
	saveAs("Tiff", out + File.separator + names[i]); run("Close All"); 
		
}


for (i = 0; i<names2.length; i++){

	open(out2 + names2[i]);
	run("Rotate... ", "angle="+ rotation +" grid=1 interpolation=Bilinear enlarge stack"); 
	makeRectangle(x, y, width, height);
	run("Crop");
	run("Slice Keeper", "first="+ first_plane +" last="+ last_plane +" increment=1");
	saveAs("Tiff", out2 + File.separator + names2[i]); run("Close All"); 
		
}




