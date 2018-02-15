/*
 * Code written for Nikhil 
 * 
 * Generates Z-Projection of 4D-Hyperstack.
 * Splits Channels
 * Splits Timepoints for each Channel and saves in new Folder
 * 
 */


out = getDirectory("Choose directory");
File.makeDirectory(out + File.separator + "Channel 1");
File.makeDirectory(out + File.separator + "Channel 2");
File.makeDirectory(out + File.separator + "One Channel");

file_names = getFileList(out);

for (i=0; i<file_names.length; i++){

// Will open only tif-, lsm- and lif-Files

	if (endsWith(file_names[i], ".tif") || endsWith(file_names[i], ".lsm") || endsWith(file_names[i], ".lif")){
		open(file_names[i]);
		getDimensions(width, height, channels, slices, frames);
		
		rename("Main");
	
	// Will only run Z Projection if number of Slices in image is greater than 1 
	
		if (slices>1){
		
		run("Z Project...", "projection=[Max Intensity] all");
	
	// Will only run if number of channels is smaller than 2 
	// Skips the Split Channel function
	
			if (channels<2){
			
			selectWindow("MAX_Main");
			run("Stack to Images");

				// Loop through all single timepoint images and save them into the folder specified for one-channel images 
			
				for(k=1; k<=frames; k++){
			
				selectWindow("MAX_Main-000" + k);
				saveAs("Tiff", out + File.separator + "One Channel" + File.separator + file_names[i] + "TP" + k);
				run("Close"); 
					
				}
			
			}
		
		// Will only run if number of channels is greater than 1 
		
			if (channels>1){
				
			
			run("Split Channels");
		
		// Channel 1 Section
			
			selectWindow("C1-MAX_Main"); 
			run("Stack to Images");
		
				// Loop through all single timepoint images and save them into the folder specified for Channel 1 of a Two-Channel image  
				for(k=1; k<=frames; k++){
			
					// Accounts for difference in designation. 
					//All numbers smaller than 10 are proceeded by 000
			
					if(k < 10){
					selectWindow("C1-MAX_Main-000" + k);
					saveAs("Tiff", out + File.separator + "Channel 1" + File.separator + file_names[i] + "TP" + k);
					run("Close"); 
					}
						
					if(k > 9){
					selectWindow("C1-MAX_Main-00" + k);
					saveAs("Tiff", out + File.separator + "Channel 1" + File.separator + file_names[i] + "TP" + k);
					run("Close"); 
					}
					
				}
			
			// Channel 2 Section (Same structure as for Channel 1 section)
				
				selectWindow("C2-MAX_Main"); 
				run("Stack to Images");
			
				// Loop through all single timepoint images and save them into the folder specified for Channel 2 of a Two-Channel image  
				for(k=1; k<=frames; k++){
			
					if(k < 10){
					selectWindow("C2-MAX_Main-000" + k);
					saveAs("Tiff", out + File.separator + "Channel 2" + File.separator + file_names[i] + "TP" + k);
					run("Close"); 
					}
					if(k > 9){
					selectWindow("C2-MAX_Main-00" + k);
					saveAs("Tiff", out + File.separator + "Channel 2" + File.separator + file_names[i] + "TP" + k);
					run("Close"); 
					}
					
				}
			
			
			}
		}
	}
	
}