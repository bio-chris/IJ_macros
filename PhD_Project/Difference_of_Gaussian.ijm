/*
 * Automates manual steps to perform Difference of Gaussian Filter 
 */


//waitForUser("Select the image that you want to process and then click ok"); 

image = getTitle(); 

setBatchMode(true);

run("Duplicate...", "title=duplicate.tif duplicate");

selectWindow(image); 
run("Gaussian Blur 3D...", "x=2 y=2 z=2");

selectWindow("duplicate.tif"); 
run("Gaussian Blur 3D...", "x=4 y=4 z=4"); 

setBatchMode(false);
imageCalculator("Subtract create stack", ""+ image +"","duplicate.tif");

selectWindow(image); run("Close"); 
selectWindow("duplicate.tif"); run("Close"); 


