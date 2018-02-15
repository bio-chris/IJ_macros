// Macro OMX_Aberration_Correction_ by C. Fischer (LMU Faculty of Biology, October/November 2015) 
// To be used before the OMX_Aberration_Correction macro 

/*
 * IMPORTANT NOTE: Only use with RGB 3-channel images. 
 * 
 */

macro "OMX_Aberration_Correction_Calibration" {

// Section 1: Defining variables, opening image and get properties

filepath=File.openDialog("Select a file"); // stores the filepath of the image selected for Calibration 
filename = File.getName(filepath); // stores the filename from the filepath 
filename2 = replace(filename, ".tif", "_CALIBRATION.xml"); // stores new string based on image name, used to later name the XML file 
OUT = replace(filepath, filename, ""); // stores the directory in which the processed file will be stored

setBatchMode(true); // Will hide opened image windows 
open(filepath); 

getVoxelSize(width, height, depth, unit); //measures voxel properties and stores them. Is needed because during MVR original values are lost and can be restored at the end
getDimensions(width2, height2, channels, slices2, frames2);

run("Split Channels"); 
	saveAs("Tiff", OUT  + File.separator + "C3"); run("Close");
	saveAs("Tiff", OUT  + File.separator + "C2"); run("Close");
	saveAs("Tiff", OUT  + File.separator + "C1"); run("Close");

// Section 2: Multiview Reconstruction  

run("Define Multi-View Dataset", 
    "type_of_dataset=[Image Stacks (ImageJ Opener)]"
     + "xml_filename=[" + filename2 + "]" 
     + "multiple_timepoints=[NO (one time-point)]"
     + "multiple_channels=[YES (one file per channel)]" + "multiple_illumination_directions=[NO (one illumination direction)]"
     + "multiple_angles=[NO (one angle)]" 
     + "image_file_directory=[" + OUT + "]" 
     + "image_file_pattern=[C{c}.tif]"
     + "channels_=[1,2,3]" 
     + "calibration_type=[Same voxel-size for all views]" 
     + "calibration_definition=[Load voxel-size(s) from file(s) and display for verification]"
     + "imglib2_data_container=[ArrayImg (faster)]"); 

setBatchMode(false); // deactivates BatchMode in Order to perform Interactive Interest Point Registration 

run("Brightness/Contrast...");

	run("Detect Interest Points for Registration",
	  "browse=[" + OUT + "]"  
	  + "select_xml=[" + OUT + filename2 + "]"
      + "type_ofinterest_points=[Difference-of-Gaussian]" 
     // label interest points is not included as this is only a matter of defintion 
      + "subpixel_localization=[3-dimensional quadratic fit]" 
     // this will successively open three windows which allow interactive interest point specification
     // once right values are determined this step could be skipped 
      + "interest_point_specification_(channel_1)=[Interactive ...]"
      + "interest_point_specification_(channel_2)=[Interactive ...]"
      + "interest_point_specification_(channel_3)=[Interactive ...]"
      + "compute_on=[CPU (Java)]"); 

     
      run("Register Dataset based on Interest Points", 
	    "browse=[" + OUT + "]"  
	  + "select_xml=[" + OUT + filename2 + "]"
      +  "registration_algorithm=[Fast 3d geometric hashing (rotation invariant)]"
      + "type_of_registration=[Register timepoints individually]"
      + "fix_tiles=[Fix first tile]"
      + "map_back_tiles=[Do not map back (use this if tiles are fixed)]"
      + "transformation_model=[Affine]" 
      + "regularize_model=[Off]");

      run("Apply Transformations", 
      // Will reduce number of single images per stack (similar to original file) 
        "browse=[" + OUT + "]" + 
	    "select_xml=[" + OUT + filename2 + "]" +
     	"apply_to_angle=[All angles]" + 
	    "apply_to_channel=[All channels]" +
	    "apply_to_illumination=[All illuminations]" +
	    "apply_to_timepoint=[All Timepoints]" +
	    "transformation=[Affine]" +
	    "apply=[Current view transformations (appends to current transforms)]" +
        "timepoint_0_channel_1_illumination_0_angle_0=[1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, "+ 1/(depth/width) +", 0.0]" + 
        "timepoint_0_channel_2_illumination_0_angle_0=[1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, "+ 1/(depth/width) +", 0.0]" + 
        "timepoint_0_channel_3_illumination_0_angle_0=[1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, "+ 1/(depth/width) +", 0.0]");

        setBatchMode(true); 
 
	run("Fuse/Deconvolve Dataset",
	    "browse=[" + OUT + "]"  
	  + "select_xml=[" + OUT + filename2 + "]" 
      + "type_of_image_fusion=[Weighted-average fusion]"
      + "bounding_box=[Define manually]"
      + "fused_image=[Display using ImageJ]"
      + "minimal_x=[0]" + "minimal_y=[0]" + "minimal_z=[0]" 
      + "maximal_x=["+width2-1+"]" + "maximal_y=["+height2-1+"]" + "maximal_z=["+slices2-1+"]"     
      + "pixel_type=[16-bit unsigned integer]" 
      + "imgLib2_container=[CellImg (large images)]"
  	  + "process_views_in_paralell=[All]" 
      + "interpolation=[Linear Interpolation]"  
      + "output_file_directory=[" + OUT + "]"); 

      
// Section 3: Automatic measurement of Colocalization and adds a txt.file to folder, which allows to check if Alignment was successful 

      run("Colocalization Threshold", "channel_1=TP0_Ch1_Ill0_Ang0 channel_2=TP0_Ch2_Ill0_Ang0 use=None channel=[Red : Green] include");
      run("Colocalization Threshold", "channel_1=TP0_Ch3_Ill0_Ang0 channel_2=TP0_Ch2_Ill0_Ang0 use=None channel=[Green : Blue] include");
      filename3 = replace(filename2, ".xml", "");  
      saveAs("Text", OUT + filename3 + "_COLOC_results.txt");
    
// Section 4: Merge Channels and save file 

      run("Merge Channels...", "c1=TP0_Ch1_Ill0_Ang0 c2=TP0_Ch2_Ill0_Ang0 c3=TP0_Ch3_Ill0_Ang0 create");
	  run("Properties...", "unit=[micron]" + "pixel_width=["+ width +"]" + "pixel_height=[" + height + "]" + "voxel_depth=[" + depth + "]" + "origin=[0,0]");
	  // Applies previous image properties back onto aligned images 
	  saveAs("Tiff", OUT  + File.separator + filename + "_ALIGNED"); run("Close");

	  
  	  File.delete(OUT  + "\\C3.tif"); 
	  File.delete(OUT  + "\\C2.tif"); 
	  File.delete(OUT  + "\\C1.tif");

// Section 5: Renames the interetpoints folder according to the file that was processed 

    NAMES3=getFileList(OUT);

	for (i=0; i<NAMES3.length; i++) { // renames interestpoints folder and gives it a new name based on the image that was processed
	
		if (endsWith(NAMES3[i], "interestpoints/")){
			
            filename4 = replace(filename, ".tif", "");           
            File.rename(OUT + "\\" + "interestpoints", OUT + "\\" + filename4 + "_interestpoints")
	
		}
   
	}

}