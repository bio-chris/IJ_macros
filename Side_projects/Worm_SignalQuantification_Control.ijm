/*
 * 13.02.2017 - Author Christian Fischer
 * Automatically runs all steps for signal quantification of C. Elegans fluorescence signal 
 * 
 * Intended for controls with very weak signal. Use Channel 0 for generation of mask!
 * 
 */

filepath=File.openDialog("Select Channel 0 image for mask generation"); 
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

run("Close All"); 

filepath2=File.openDialog("Select Channel 1 image for measurement"); 
filename2 = File.getName(filepath2); 

open(filename2); 

run("Restore Selection");
run("Measure"); 
run("Make Inverse");
run("Measure"); 

Ext.Manager3D_Reset();
