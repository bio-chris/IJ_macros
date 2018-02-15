/*
 * This macro is intented to automatically perform "Define Multi-view-Dataset", "Detect Interest Points for Registration" and two  
 * rounds of "Register Dataset based on Interestpoints" (First round for general registration, second round for timelapse registration)  
 * on SPIM data. The name of each timepoint file needs to contain the position ("Pos"), the timepoint ("TP") and the channel ("Channel"). 
 * 
 */

// Section 1: 

filepath=File.openDialog("Select one timepoint file") // stores the filepath of the image 
filename = File.getName(filepath) // stores the filename from the filepath 
OUT=getDirectory("Select Folder in which all files that need to be processed are stored"); // stores the directory in which the processed file will be stored

//Section 2: Takes name of file, stored in filename, and replaces substrings to match the needed file pattern

Pos = indexOf(filename, "Pos")
TP = indexOf(filename, "TP")
Ch = indexOf(filename, "Channel")

Pos1 = substring(filename, Pos+2, Pos+5)
TP1 = substring(filename, TP+1, TP+4)
Ch1 = substring(filename, Ch+6, Ch+10)

filename1 = replace(filename, Pos1 , "s{a}_") 
filename2 = replace(filename1, TP1, "P{t}_")

// Section 3 - Dialog: Set Number of Channels, Set Number of Timepoints (if Timepoints 0-71 exist, number of timepoints should be set to 72), Set Number of Angles, Set Pixel values 

Dialog.create("Configure your settings");

Dialog.addChoice("Number of Channels:", newArray("1", "2"));
Dialog.addNumber("How many Timepoints:", 50);
Dialog.addNumber("How many Angles:", 3);
Dialog.addNumber("Pixel distance x", 1)
Dialog.addNumber("Pixel distance y", 1)
Dialog.addNumber("Pixel distance z", 1) 

Dialog.show();
 
nChannels = Dialog.getChoice();
nTimepoints = Dialog.getNumber();
nTimepoints2 = nTimepoints-1;
nTimepoints3 = "0-" + nTimepoints2; 
nAngles = Dialog.getNumber();

pixel_x = Dialog.getNumber();
pixel_y = Dialog.getNumber();
pixel_z = Dialog.getNumber()

// Section 4: Depending on Dialog Input, the String inserted for the number of Angles is adjusted to match the needed pattern

if (nAngles != 1){

	nAngles2 = nAngles-1;
	nAngles3 = "0-" + nAngles2; 

	}

if (nAngles == 1){

	nAngles3 = nAngles-1; 
	
	}

// Section 5.1: Defining the Dataset (for 1 channel)
  
if (nChannels == "1"){
 
	run("Define Multi-View Dataset", 
	"type_of_dataset=[Image Stacks (ImageJ Opener)]" + 
	"xml_filename=[dataset.xml]" + 
	"multiple_timepoints=[YES (one file per time-point)]" + 
	"multiple_channels=[NO (one channel)]" + 	
	"multiple_illumination_directions=[NO (one illumination direction)]" +
	"multiple_angles=[YES (one file per angle)]" + 
	"image_file_directory=["+ OUT +"]" + 
	"image_file_pattern=["+ filename2 +"]" + 
	"timepoints_=["+ nTimepoints3 +"]" +  
	"acquisition_angles_=["+ nAngles3 +"]" + 
	"calibration_type=[Same voxel-size for all views]" + 
	"calibration_definition=[Load voxel-size(s) from file(s) and display for verification]" + 
	"imglib2_data_container=[ArrayImg (faster)]" + 
	
	"pixel_distance_x=["+ pixel_x +"]" + 
	"pixel_distance_y=["+ pixel_y +"]" + 
	"pixel_distance_z=["+ pixel_z +"]" +  
	"pixel_unit=pixel");

	run("Detect Interest Points for Registration", 
	"browse=["+ OUT +"]" +
	"select_xml=[" + OUT + "dataset.xml" + "]" + 
	"process_angle=[All angles]" +  
	"process_channel=[All channels]" + 
	"process_illumination=[All illuminations]" + 
	"process_timepoint=[All Timepoints]" + 
	"type_of_interest_point_detection=[Difference-of-Gaussian]" + 
	"label_interest_points=[beads]" + 
	"subpixel_localization=[3-dimensional quadratic fit]" + 
	"interest_point_specification=[Interactive ...]" +
	"compute_on=[GPU approximate (Nvidia CUDA via JNA)]" + 
	"cuda_directory=[/opt/Fiji.app/lib/linux64]" +
	"select_native_library_for_cudaseparableconvolution=[SeparableConvolutionCUDALib.so]" + 
	"device=[GPU 1 of 1: Quadro 4000 (id=0, mem=2047MB (2047MB free), CUDA capability 2.0)]" + 
	"percent_of_gpu_memory_to_use=[90]");


	run("Register Dataset based on Interest Points", 
	"browse=["+ OUT +"]" + 
	"select_xml=["+ OUT + "dataset.xml" +"]" +  
	"process_angle=[All angles]" +
	"process_illumination=[All illuminations]" +
	"process_timepoint=[All Timepoints]" +
	"registration_algorithm=[Fast 3d geometric hashing (rotation invariant)]" +
	"type_of_registration=[Register timepoints individually]" +
	"interest_points_channel_0=[beads]" +
	"fix_tiles=[Fix first tile]" +
	"map_back_tiles=[Do not map back (use this if tiles are fixed)]" +
	"transformation=[Affine] regularize_model model_to_regularize_with=[Rigid] lamba=[0.10] allowed_error_for_ransac=[5] significance=[10] show_timeseries_statistics");

	run("Register Dataset based on Interest Points", 
	"browse=["+ OUT +"]" + 
	"select_xml=["+ OUT + "dataset.xml" +"]" +  
	"process_angle=[All angles]" +
	"process_illumination=[All illuminations]" +
	"process_timepoint=[All Timepoints]" +
	"registration_algorithm=[Fast 3d geometric hashing (rotation invariant)]" +
	"type_of_registration=[All-to-all timepoints matching with range ('reasonable' global optimization)]" +
	"interest_points_channel_1=[beads]" +
	"range=[5] consider_each_timepoint_as_rigid_unit fix_tiles=[Fix first tile] map_back_tiles=[Do not map back (use this if tiles are fixed)]" +
	"transformation=[Rigid] regularize_model model_to_regularize_with=[Rigid] lamba=[0.10] allowed_error_for_ransac=[5] significance=[10] show_timeseries_statistics");
	
 	
 	}

// Section 5.2: Defining the Dataset (fore more than one channel) 

else if (nChannels == "2"){

	filename3 = replace(filename2, Ch1, "l{c}.o");

		if (nChannels == "2"){
	
	 	nChannels2 = "1,2"; 
	 	
	 	}
	 	
	run("Define Multi-View Dataset", 
	"type_of_dataset=[Image Stacks (ImageJ Opener)]" + 
	"xml_filename=[dataset.xml]" + 
	"multiple_timepoints=[YES (one file per time-point)]" + 
	"multiple_channels=[YES (one file per channel)]" + 	
	"multiple_illumination_directions=[NO (one illumination direction)]" + 
	"multiple_angles=[YES (one file per angle)]" + 
	"image_file_directory=["+ OUT +"]" + 
	"image_file_pattern=["+ filename3 +"]" + 
	"timepoints_=["+ nTimepoints3 +"]" + 
	"channels_=["+ nChannels2 +"]" + 
	"acquisition_angles_=["+ nAngles3 +"]" + 
	"calibration_type=[Same voxel-size for all views]" + 
	"calibration_definition=[Load voxel-size(s) from file(s) and display for verification]" + 
	"imglib2_data_container=[ArrayImg (faster)]" + 
	
	"pixel_distance_x=["+ pixel_x +"]" + 
	"pixel_distance_y=["+ pixel_y +"]" + 
	"pixel_distance_z=["+ pixel_z +"]" +  
	"pixel_unit=pixel");

	run("Detect Interest Points for Registration", 
	"browse=["+ OUT +"]" +
	"select_xml=[" + OUT + "dataset.xml" + "]" + 
	"process_angle=[All angles]" +  
	"process_channel=[All channels]" + 
	"process_illumination=[All illuminations]" + 
	"process_timepoint=[All Timepoints]" + 
	"type_of_interest_point_detection=[Difference-of-Gaussian]" + 
	"label_interest_points=[beads]" + 
	"subpixel_localization=[3-dimensional quadratic fit]" + 
	"interest_point_specification_(channel_1)=[Interactive ...]" +
	"interest_point_specification_(channel_2)=[Interactive ...]" +
	"compute_on=[GPU approximate (Nvidia CUDA via JNA)]" + 
	"cuda_directory=[/opt/Fiji.app/lib/linux64]" +
	"select_native_library_for_cudaseparableconvolution=[SeparableConvolutionCUDALib.so]" + 
	"device=[GPU 1 of 1: Quadro 4000 (id=0, mem=2047MB (2047MB free), CUDA capability 2.0)]" + 
	"percent_of_gpu_memory_to_use=[90]");

	run("Register Dataset based on Interest Points", 
	"browse=["+ OUT +"]" + 
	"select_xml=["+ OUT + "dataset.xml" +"]" +  
	"process_angle=[All angles]" +
	"process_illumination=[All illuminations]" +
	"process_timepoint=[All Timepoints]" +
	"registration_algorithm=[Fast 3d geometric hashing (rotation invariant)]" +
	"type_of_registration=[Register timepoints individually]" +
	"interest_points_channel_1=[beads]" +
	"interest_points_channel_2=[beads]" +
	"fix_tiles=[Fix first tile]" +
	"map_back_tiles=[Do not map back (use this if tiles are fixed)]" +
	"transformation=[Affine] regularize_model model_to_regularize_with=[Rigid] lamba=[0.10] allowed_error_for_ransac=[5] significance=[10] show_timeseries_statistics");


	run("Register Dataset based on Interest Points", 
	"browse=["+ OUT +"]" + 
	"select_xml=["+ OUT + "dataset.xml" +"]" +  
	"process_angle=[All angles]" +
	"process_illumination=[All illuminations]" +
	"process_timepoint=[All Timepoints]" +
	"registration_algorithm=[Fast 3d geometric hashing (rotation invariant)]" +
	"type_of_registration=[All-to-all timepoints matching with range ('reasonable' global optimization)]" +
	"interest_points_channel_1=[beads]" +
	"interest_points_channel_2=[beads]" +
	"range=[5] consider_each_timepoint_as_rigid_unit fix_tiles=[Fix first tile] map_back_tiles=[Do not map back (use this if tiles are fixed)]" +
	"transformation=[Rigid] regularize_model model_to_regularize_with=[Rigid] lamba=[0.10] allowed_error_for_ransac=[5] significance=[10] show_timeseries_statistics");

	
	}




 


 



