// Macro OMX_Aberration_Correction_ by C. Fischer (LMU Faculty of Biology, October/November 2015) 
// To be used after the OMX_Aberration_Correction_Calibration macro 


macro "OMX_Aberration_Correction" {


// Section 1: Defining variables

OUT=getDirectory("Select Folder in which all files that need to be processed are stored"); // Asks the user to select the directory in which all files that need processing are stored
filepath=File.openDialog("Select the previously generated XML Calibration file"); // Asks user to select the regular (3-Channels) XML file
filename = File.getName(filepath); // gets the name of the file from the selected regular XML file
NAMES=getFileList(OUT); // gets a list of all files stored in the selected directory OUT

// Section 2: For-loop, command applies to all files in selected folder 

	for (i=0; i<NAMES.length; i++){ // goes through the following commands for each file, as long as i is smaller than the total number of files in the directory 

		if (!File.isDirectory(OUT+NAMES[i]) && !endsWith(NAMES[i], "_RGB.tif") && !endsWith(NAMES[i], "ALIGNED.tif") && !endsWith(NAMES[i], "COLOC_results.txt")){ // Will apply the following macro only to those files which do not contain the term CALIBRATION.tif, which allows to process all files (except the already processed Calibration file) regardless of their order or names
			
		// Section 2.1: Defining variables, opening image and get properties
	       	       
	        File.copy(filepath, OUT + filename); // copies the regular XML file, which is stored in the variable filepath 
	        setBatchMode(true);
            open(OUT + NAMES[i]); // opens one file per run within the OUT directory
            getVoxelSize(width, height, depth, unit); // measures voxel properties and stores them. Is needed because during MVR original values are lost and can be restored at the end
            getDimensions(width2, height2, channels, slices2, frames2); // reads the number of channels in image. Important for if-statement below so program can differentiate between c=2 and c=3

			colors = newArray(3); // creates array in which the LUT of each channel (1,2,3) are stored (eg. RGB in array will be [R, G, B]
			
			filepath2 = OUT + filename; // storing the path of the XML in a new variable to make the entry shorter 

		// Section 2.2: If number of channels equals 3 do the following
			
			if (channels==3){ 
            
              // Section 2.2.1: Splitting Channels, getting Min and Max, and LUT values of each channel
              
              run("Split Channels"); 

				selectWindow("C1-" + NAMES[i]); // select Window corresponding to Channel 1
				getMinAndMax(a1, b1);

				getLut(red, green, blue); // get the LUTs of the selected window

				isRed = ! (red[red.length-1] == 0); // the Variable isRed is true, if the pre-last number of 256 values for Red is unequal to 0 
				isGreen = ! (green[green.length-1] == 0); // the Variable isGreen is true, if the pre-last number of 256 values for Green is unequal to 0 
				isBlue = ! (blue[blue.length-1] == 0); // the Variable isBlue is true, if the pre-last number of 256 values for Blue is unequal to 0 

					if (isRed==1){ // if isRed is true then save the channel 1 image as C1.tif and generate a dummy file with the ending C1_R.png, which later is needed to recall the LUT
					saveAs("Tiff", OUT  + File.separator + "C1"); run("Close");
					colors[0]="red_red";
					
					}
					else if (isGreen==1){ // if isGreen is true then save the channel 1 image as C1.tif and generate a dummy file with the ending C1_G.png, which later is needed to recall the LUT
					saveAs("Tiff", OUT  + File.separator + "C2"); run("Close");
					colors[1]="green_red";
					}
					else if (isBlue==1){ // if isBlue is true then save the channel 1 image as C1.tif and generate a dummy file with the ending C1_B.png, which later is needed to recall the LUT
					saveAs("Tiff", OUT  + File.separator + "C3"); run("Close");
					colors[2]="blue_red";
	
					}

					selectWindow("C2-" + NAMES[i]);
					getMinAndMax(a2, b2);

					getLut(red, green, blue);

					isRed = ! (red[red.length-1] == 0);
					isGreen = ! (green[green.length-1] == 0);
					isBlue = ! (blue[blue.length-1] == 0);
					
					if (isRed==1){
						saveAs("Tiff", OUT  + File.separator + "C1"); run("Close");
						colors[0]="red_green";
					}
					else if (isGreen==1){
						saveAs("Tiff", OUT  + File.separator + "C2"); run("Close");
						colors[1]="green_green";
					}
					else if (isBlue==1){
						saveAs("Tiff", OUT  + File.separator + "C3"); run("Close");
						colors[2]="blue_green";
					}
					
					
					selectWindow("C3-" + NAMES[i]);
					getMinAndMax(a3, b3);
					
					getLut(red, green, blue);
					
					isRed = ! (red[red.length-1] == 0);
					isGreen = ! (green[green.length-1] == 0);
					isBlue = ! (blue[blue.length-1] == 0);
					
					if (isRed==1){
						saveAs("Tiff", OUT  + File.separator + "C1");  run("Close");
						colors[0]="red_blue";
						
					}
					else if (isGreen==1){
						saveAs("Tiff", OUT  + File.separator + "C2"); run("Close");
						colors[1]="green_blue";
						
					}
					else if (isBlue==1){
						saveAs("Tiff", OUT  + File.separator + "C3");  run("Close");
						colors[2]="blue_blue";
						
					}

            // Section 2.2.2: Multiview Reconstruction  
            	        	     
            run("Fuse/Deconvolve Dataset", // Last step of the MVR, which uses the already generated XML file from the calibration step 
	         "browse=[" + OUT + "]"  
	       + "select_xml=[" + filepath2 + "]" // selecting regular (3-Channels) XML file 
           + "type_of_image_fusion=[Weighted-average fusion]"
           + "bounding_box=[Define manually]"
           + "fused_image=[Display using ImageJ]"
           + "minimal_x=[0]" + "minimal_y=[0]" + "minimal_z=[0]" 
           + "maximal_x=["+ width2-1 +"]" + "maximal_y=["+ height2-1 +"]" + "maximal_z=["+slices2-1+"]"  
           + "pixel_type=[16-bit unsigned integer]" 
           + "imgLib2_container=[CellImg (large images)]"
  	       + "process_views_in_paralell=[All]" 
           + "interpolation=[Linear Interpolation]"  
           + "output_file_directory=[" + OUT + "]"); 


                 // Section 2.2.3: Restores former LUTs of the original image after Multiview Reconstruction 					    
		    
		   			if(colors[0]=="red_red" && colors[1]=="green_green" && colors[2]=="blue_blue"){ 
						selectWindow("TP0_Ch1_Ill0_Ang0");
						run("Red");
						setMinAndMax(a1, b1);
						selectWindow("TP0_Ch2_Ill0_Ang0");
						run("Green");
						setMinAndMax(a2, b2);
						selectWindow("TP0_Ch3_Ill0_Ang0");
						run("Blue");
						setMinAndMax(a3, b3);														
						run("Merge Channels...", "c1=TP0_Ch1_Ill0_Ang0 c2=TP0_Ch2_Ill0_Ang0 c3=TP0_Ch3_Ill0_Ang0 create");
						run("Properties...", "unit=[micron]" + "pixel_width=["+ width +"]" + "pixel_height=[" + height + "]" + "voxel_depth=[" + depth + "]" + "origin=[0,0]");
						saveAs("Tiff", OUT + NAMES[i]  + "_ALIGNED"); run("Close");
					
					}

					 	if(colors[0]=="red_red" && colors[2]=="blue_green" && colors[1]=="green_blue"){ 
						selectWindow("TP0_Ch1_Ill0_Ang0");
						run("Red");
						setMinAndMax(a1, b1);
						selectWindow("TP0_Ch2_Ill0_Ang0");
						run("Green");
						setMinAndMax(a2, b2);
						selectWindow("TP0_Ch3_Ill0_Ang0");
						run("Blue");
						setMinAndMax(a3, b3);														
						run("Merge Channels...", "c1=TP0_Ch1_Ill0_Ang0 c2=TP0_Ch3_Ill0_Ang0 c3=TP0_Ch2_Ill0_Ang0 create");
						run("Properties...", "unit=[micron]" + "pixel_width=["+ width +"]" + "pixel_height=[" + height + "]" + "voxel_depth=[" + depth + "]" + "origin=[0,0]");
						saveAs("Tiff", OUT + NAMES[i]  + "_ALIGNED"); run("Close");
					 	}

					if(colors[2]=="blue_red" && colors[1]=="green_green" && colors[0]=="red_blue"){ 
						selectWindow("TP0_Ch1_Ill0_Ang0");
						run("Red");
						setMinAndMax(a1, b1);
						selectWindow("TP0_Ch2_Ill0_Ang0");
						run("Green");
						setMinAndMax(a2, b2);
						selectWindow("TP0_Ch3_Ill0_Ang0");
						run("Blue");
						setMinAndMax(a3, b3);														
						run("Merge Channels...", "c1=TP0_Ch3_Ill0_Ang0 c2=TP0_Ch2_Ill0_Ang0 c3=TP0_Ch1_Ill0_Ang0 create");
						run("Properties...", "unit=[micron]" + "pixel_width=["+ width +"]" + "pixel_height=[" + height + "]" + "voxel_depth=[" + depth + "]" + "origin=[0,0]");
						saveAs("Tiff", OUT + NAMES[i]  + "_ALIGNED"); run("Close");
					}
					
					if(colors[2]=="blue_red" && colors[0]=="red_green" && colors[1]=="green_blue"){ 
						selectWindow("TP0_Ch1_Ill0_Ang0");
						run("Red");
						setMinAndMax(a1, b1);
						selectWindow("TP0_Ch2_Ill0_Ang0");
						run("Green");
						setMinAndMax(a2, b2);
						selectWindow("TP0_Ch3_Ill0_Ang0");
						run("Blue");
						setMinAndMax(a3, b3);															
						run("Merge Channels...", "c1=TP0_Ch3_Ill0_Ang0 c2=TP0_Ch1_Ill0_Ang0 c3=TP0_Ch2_Ill0_Ang0 create");
						run("Properties...", "unit=[micron]" + "pixel_width=["+ width +"]" + "pixel_height=[" + height + "]" + "voxel_depth=[" + depth + "]" + "origin=[0,0]");
						saveAs("Tiff", OUT + NAMES[i]  + "_ALIGNED"); run("Close");
					}



					if(colors[1]=="green_red" && colors[2]=="blue_green" && colors[0]=="red_blue"){ 
						selectWindow("TP0_Ch1_Ill0_Ang0");
						run("Red");
						setMinAndMax(a1, b1);
						selectWindow("TP0_Ch2_Ill0_Ang0");
						run("Green");
						setMinAndMax(a2, b2);
						selectWindow("TP0_Ch3_Ill0_Ang0");
						run("Blue");
						setMinAndMax(a3, b3);														
						run("Merge Channels...", "c1=TP0_Ch2_Ill0_Ang0 c2=TP0_Ch3_Ill0_Ang0 c3=TP0_Ch1_Ill0_Ang0 create");
						run("Properties...", "unit=[micron]" + "pixel_width=["+ width +"]" + "pixel_height=[" + height + "]" + "voxel_depth=[" + depth + "]" + "origin=[0,0]");
						saveAs("Tiff", OUT + NAMES[i]  + "_ALIGNED"); run("Close");
				
					}
					
						if(colors[1]=="green_red" && colors[0]=="red_green" && colors[2]=="blue_blue"){ 
						selectWindow("TP0_Ch1_Ill0_Ang0");
						run("Red");
						setMinAndMax(a1, b1);
						selectWindow("TP0_Ch2_Ill0_Ang0");
						run("Green");
						setMinAndMax(a2, b2);
						selectWindow("TP0_Ch3_Ill0_Ang0");
						run("Blue");
						setMinAndMax(a3, b3);														
						run("Merge Channels...", "c1=TP0_Ch2_Ill0_Ang0 c2=TP0_Ch1_Ill0_Ang0 c3=TP0_Ch3_Ill0_Ang0 create");
						run("Properties...", "unit=[micron]" + "pixel_width=["+ width +"]" + "pixel_height=[" + height + "]" + "voxel_depth=[" + depth + "]" + "origin=[0,0]");
						saveAs("Tiff", OUT + NAMES[i]  + "_ALIGNED"); run("Close");
						}
				
						
			
	  
  	      File.delete(OUT + "\\C3.tif"); 
	      File.delete(OUT + "\\C2.tif"); 
	      File.delete(OUT + "\\C1.tif");

	   		 
			} 

		// Section 2.3: If number of channels equals 2 do the following	

		if (channels==2){ 

		// Section 2.3.1: Splitting Channels, getting Min and Max, and LUT values of each channel
		
		colors2 = newArray(1);
		colors3 = newArray(1);
		colors4 = newArray(1);
		colors5 = newArray(1);
		colors6 = newArray(1);
		colors7 = newArray(1);
        			
				run("Split Channels"); 
											
				selectWindow("C1-" + NAMES[i]); // same procedure as for channels = 3, only with one channel less
				getMinAndMax(a1, b1);
				getLut(red, green, blue);

				isRed = ! (red[red.length-1] == 0);
				isGreen = ! (green[green.length-1] == 0);
				isBlue = ! (blue[blue.length-1] == 0);

				selectWindow("C2-" + NAMES[i]);
				getMinAndMax(a2, b2);
				getLut(red2, green2, blue2);

				isRed2 = ! (red2[red2.length-1] == 0);
				isGreen2 = ! (green2[green2.length-1] == 0);
				isBlue2 = ! (blue2[blue2.length-1] == 0);
				

					if (isRed==1 && isGreen2==1){					
					selectWindow("C1-" + NAMES[i]);
					saveAs("Tiff", OUT  + File.separator + "C1"); 
					selectWindow("C2-" + NAMES[i]);
					saveAs("Tiff", OUT  + File.separator + "C2"); 
					run("Duplicate...", "duplicate"); saveAs("Tiff", OUT  + "\\C3"); run("Close");
					run("Close");
					colors2[0]="red_green";
					}
					
					else if (isRed==1 && isBlue2==1){					
					selectWindow("C1-" + NAMES[i]);
					saveAs("Tiff", OUT  + File.separator + "C1"); 
					selectWindow("C2-" + NAMES[i]);
					saveAs("Tiff", OUT  + File.separator + "C3"); 
					run("Duplicate...", "duplicate"); saveAs("Tiff", OUT  + "\\C2"); run("Close");
					run("Close");
					colors3[0]="red_blue";
					}
					
					else if (isGreen==1 && isRed2==1){
					selectWindow("C1-" + NAMES[i]);
					saveAs("Tiff", OUT  + File.separator + "C2"); 
					selectWindow("C2-" + NAMES[i]);
					saveAs("Tiff", OUT  + File.separator + "C1"); 
					run("Duplicate...", "duplicate"); saveAs("Tiff", OUT  + "\\C3"); run("Close");
					run("Close");
					colors4[0]="green_red";	
					}

					else if (isGreen==1 && isBlue2==1){
					selectWindow("C1-" + NAMES[i]);
					saveAs("Tiff", OUT  + File.separator + "C2"); 
					selectWindow("C2-" + NAMES[i]);
					saveAs("Tiff", OUT  + File.separator + "C3"); 
					run("Duplicate...", "duplicate"); saveAs("Tiff", OUT  + "\\C1"); run("Close");
					run("Close");
					colors5[0]="green_blue";	
					}

					else if (isBlue==1 && isRed2==1){
					selectWindow("C1-" + NAMES[i]);
					saveAs("Tiff", OUT  + File.separator + "C3"); 
					selectWindow("C2-" + NAMES[i]);
					saveAs("Tiff", OUT  + File.separator + "C1"); 
					run("Duplicate...", "duplicate"); saveAs("Tiff", OUT  + "\\C2"); run("Close");
					run("Close");
					colors6[0]="blue_red";	
					}

					else if (isBlue==1 && isGreen2==1){
					selectWindow("C1-" + NAMES[i]);
					saveAs("Tiff", OUT  + File.separator + "C3"); 
					selectWindow("C2-" + NAMES[i]);
					saveAs("Tiff", OUT  + File.separator + "C2"); 
					run("Duplicate...", "duplicate"); saveAs("Tiff", OUT  + "\\C1"); run("Close");
					run("Close");
					colors7[0]="blue_green";	
					}

			// Section 2.3.2: Multiview Reconstruction														
				    				       	
        	run("Fuse/Deconvolve Dataset",
	    	"browse=[" + OUT + "]"  
	  		+ "select_xml=[" + filepath2 + "]" // selecting XML file
      		+ "type_of_image_fusion=[Weighted-average fusion]"
      		+ "bounding_box=[Define manually]"
      		+ "fused_image=[Display using ImageJ]"
      		+ "minimal_x=[0]" + "minimal_y=[0]" + "minimal_z=[0]"
      		+ "maximal_x=["+ width2-1 +"]" + "maximal_y=["+ height2-1 +"]" + "maximal_z=["+slices2-1+"]"    
      		+ "pixel_type=[16-bit unsigned integer]" 
      		+ "imgLib2_container=[CellImg (large images)]"
  	  		+ "process_views_in_paralell=[All]" 
      		+ "interpolation=[Linear Interpolation]"  
      		+ "output_file_directory=[" + OUT + "]"); 


			// Section 2.3.3: Restores former LUTs of the original image after Multiview Reconstruction 

					if(colors2[0]!=0){ 
						selectWindow("TP0_Ch1_Ill0_Ang0");
						run("Red");
						setMinAndMax(a1, b1);
						selectWindow("TP0_Ch2_Ill0_Ang0");
						run("Green");
						setMinAndMax(a2, b2);														
						run("Merge Channels...", "c1=TP0_Ch1_Ill0_Ang0 c2=TP0_Ch2_Ill0_Ang0 create");
						run("Properties...", "unit=[micron]" + "pixel_width=["+ width +"]" + "pixel_height=[" + height + "]" + "voxel_depth=[" + depth + "]" + "origin=[0,0]");
						saveAs("Tiff", OUT + NAMES[i]  + "_ALIGNED"); run("Close"); 
						selectWindow("TP0_Ch3_Ill0_Ang0"); 
						run("Close");
					}

					if(colors3[0]!=0){ 
						selectWindow("TP0_Ch1_Ill0_Ang0");
						run("Red");
						setMinAndMax(a1, b1);
						selectWindow("TP0_Ch3_Ill0_Ang0");
						run("Blue");
						setMinAndMax(a2, b2);																		
						run("Merge Channels...", "c1=TP0_Ch1_Ill0_Ang0 c2=TP0_Ch3_Ill0_Ang0 create");
						run("Properties...", "unit=[micron]" + "pixel_width=["+ width +"]" + "pixel_height=[" + height + "]" + "voxel_depth=[" + depth + "]" + "origin=[0,0]");
						saveAs("Tiff", OUT + NAMES[i]  + "_ALIGNED"); run("Close");
						selectWindow("TP0_Ch2_Ill0_Ang0"); 
						run("Close");	 
						
					}

					if(colors4[0]!=0){ 
						selectWindow("TP0_Ch1_Ill0_Ang0");
						run("Green");
						setMinAndMax(a1, b1);
						selectWindow("TP0_Ch2_Ill0_Ang0");
						run("Red");
						setMinAndMax(a2, b2);														
						run("Merge Channels...", "c1=TP0_Ch1_Ill0_Ang0 c2=TP0_Ch2_Ill0_Ang0 create");
						run("Properties...", "unit=[micron]" + "pixel_width=["+ width +"]" + "pixel_height=[" + height + "]" + "voxel_depth=[" + depth + "]" + "origin=[0,0]");
						saveAs("Tiff", OUT + NAMES[i]  + "_ALIGNED"); run("Close"); 
						selectWindow("TP0_Ch3_Ill0_Ang0"); 
						run("Close");
					}

					if(colors5[0]!=0){ 
						selectWindow("TP0_Ch2_Ill0_Ang0");
						run("Green");
						setMinAndMax(a1, b1);
						selectWindow("TP0_Ch3_Ill0_Ang0");
						run("Blue");
						setMinAndMax(a2, b2);														
						run("Merge Channels...", "c1=TP0_Ch2_Ill0_Ang0 c2=TP0_Ch3_Ill0_Ang0 create");
						run("Properties...", "unit=[micron]" + "pixel_width=["+ width +"]" + "pixel_height=[" + height + "]" + "voxel_depth=[" + depth + "]" + "origin=[0,0]");
						saveAs("Tiff", OUT + NAMES[i]  + "_ALIGNED"); run("Close"); 
						selectWindow("TP0_Ch1_Ill0_Ang0"); 
						run("Close");
					}

					if(colors6[0]!=0){ 
						selectWindow("TP0_Ch3_Ill0_Ang0");
						run("Blue");
						setMinAndMax(a1, b1);
						selectWindow("TP0_Ch1_Ill0_Ang0");
						run("Red");	
						setMinAndMax(a2, b2);													
						run("Merge Channels...", "c1=TP0_Ch3_Ill0_Ang0 c2=TP0_Ch1_Ill0_Ang0 create");
						run("Properties...", "unit=[micron]" + "pixel_width=["+ width +"]" + "pixel_height=[" + height + "]" + "voxel_depth=[" + depth + "]" + "origin=[0,0]");
						saveAs("Tiff", OUT + NAMES[i]  + "_ALIGNED"); run("Close"); 
						selectWindow("TP0_Ch2_Ill0_Ang0"); 
						run("Close");
					}

					if(colors7[0]!=0){ 
						selectWindow("TP0_Ch3_Ill0_Ang0");
						run("Blue");
						setMinAndMax(a1, b1);
						selectWindow("TP0_Ch2_Ill0_Ang0");
						run("Green");	
						setMinAndMax(a2, b2);													
						run("Merge Channels...", "c1=TP0_Ch3_Ill0_Ang0 c2=TP0_Ch2_Ill0_Ang0 create");
						run("Properties...", "unit=[micron]" + "pixel_width=["+ width +"]" + "pixel_height=[" + height + "]" + "voxel_depth=[" + depth + "]" + "origin=[0,0]");
						saveAs("Tiff", OUT + NAMES[i]  + "_ALIGNED"); run("Close"); 
						selectWindow("TP0_Ch1_Ill0_Ang0"); 
						run("Close");
					}


		 File.delete(OUT + "\\C3.tif");
	     File.delete(OUT + "\\C2.tif"); 
	     File.delete(OUT + "\\C1.tif");			
			

				}
						 
			}
			
		run("Close All"); 	
      	File.delete(OUT + filename + "~1");
      	call("java.lang.System.gc"); // "Garbage collector" to free memory during batch processing  
      	
		}
		 File.delete(OUT + filename); // deletes the copy of the regular XML file 
		 call("java.lang.System.gc");
	}

	
	


