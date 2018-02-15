/*
 * 15.12.2016 - Author Christian Fischer
 * Automatically runs all steps for signal quantification of C. Elegans fluorescence signal 
 */

filepath=File.openDialog("Select an image for measurement"); 
filename = File.getName(filepath); 

open(filename); 

run("Duplicate...", "title=duplicate.tif duplicate");

selectWindow("duplicate.tif");
run("Auto Threshold", "method=Triangle ignore_black white");
run("Invert");

//// minimum size of particle can be changed adjusting number within code below
run("Analyze Particles...", "size=4-Infinity pixel show=Masks");
////

selectWindow("duplicate.tif");
run("Close"); 

waitForUser("Check if mask contains any irrelevant signal and remove if necessary. Click OK when done"); 

selectWindow("Mask of duplicate.tif");
run("3D Manager");
Ext.Manager3D_AddImage();
Ext.Manager3D_Select(0);
run("Create Selection");

selectWindow(filename);

run("Restore Selection");
run("Measure");
run("Make Inverse");
run("Measure");

selectWindow("Mask of duplicate.tif");
run("Close"); 

Ext.Manager3D_Reset();




