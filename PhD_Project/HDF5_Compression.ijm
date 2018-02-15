out=getDirectory("Select folder in which all images that should be compressed are stored");

names=getFileList(out);

setBatchMode(true); 

for (i = 0; i<names.length; i++){

	if(endsWith(names[i], ".tif")){ 
	
		open(out + names[i]);
		getDimensions(width, height, channels, slices, frames);
		
		f = File.open(out + File.separator + names[i] + "_dimensions.txt");
			print (f, "c" + channels + "h");
			print (f, "s" + slices + "l");
			print (f, "f" + frames + "r");
		File.close(f); 
			
		run("Scriptable save HDF5 (new or replace)...", "save=["+ out + File.separator + names[i] + ".h5" +"] dsetnametemplate=/t{t}/channel{c} formattime=%d formatchannel=%d compressionlevel=9");
		run("Close All");	
	}
		
}

 