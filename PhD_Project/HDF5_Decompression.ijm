/*
 * This macro performs automated conversion of compressed HDF5 files into uncompressed TIFF files. Use only, if you used the HDF5_Compression.ijm macro on your dataset. 
 * 
 * Every single image file needs an appendant text file containing the number of frames, slices and channels in order for this macro to work!
 * 
 */

out=getDirectory("Select folder in which all images that should be decompressed are stored");

names=getFileList(out);

setBatchMode(true); 

// First for-loop goes through entire folder

for (i = 0; i<names.length; i++){


		// First if-statement checks if file is .h5 and if yes, proceeds to second for-loop
		if(endsWith(names[i], ".h5")){ 

			// Second for-loop goes through entire folder again, to now select appendant text file containing the hyperstakc information
			for (i1 = 0; i1<names.length; i1++){	

				// Second if-statement checks if file is .txt and if yes, proceeds
				if(endsWith(names[i1], "_dimensions.txt")){
	

				// Opens text file as string				
				text_file = File.openAsString(out + names[i1]); 
					
				// Locates 
				f1 = indexOf(text_file, "f");
				f2 = indexOf(text_file, "r");
				
				s1 = indexOf(text_file, "s");
				s2 = indexOf(text_file, "l");
				
				c1 = indexOf(text_file, "c");
				c2 = indexOf(text_file, "h");
				
				
				frames = substring(text_file, f1+1, f2);
				slices = substring(text_file, s1+1, s2);
				channels = substring(text_file, c1+1, c2);
				
				frames = parseInt(frames);
				slices = parseInt(slices);
				channels = parseInt(channels);
		
				datasetnames = "";
		
					if (channels == 1){
					
					
						for(i2=0; i2<frames; i2++) {
						
							datasetnames += "/t" + i2 + "/channel0,";
							
						}
			
					}
					
					if (channels == 2){
		
				
					for(i2=0; i2<frames; i2++) {
			
						datasetnames += "/t" + i2 + "/channel0," + "/t" + i2 + "/channel1,";
				
						}
		
					}
			
			
			
				run("Scriptable load HDF5...", "load=["+ out + File.separator + names[i] +"] datasetnames=["+ datasetnames +"] nframes=["+ frames +"] nchannels=["+ channels +"]");
		
				saveAs("Tiff", out + File.separator + names[i]);
				
				run("Close All");

				}

			}
	}
		
}