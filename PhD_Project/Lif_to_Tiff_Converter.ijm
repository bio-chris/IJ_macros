/*
 * New Lif to Tif Converter (last updated on 16/02/18)
 * 
 * Converts every Series of Images / Stacks saved as life file into single tif files in a separate folder for each lif file
 * 
 */


dir = getDirectory("Select directory in which non-tiff files are stored"); 
file_number = getFileList(dir);

setBatchMode(true); 

for (n = 0; n<file_number.length; n++){


	print(dir + File.separator + file_number[n]);
	File.makeDirectory(dir + File.separator + file_number[n] + "_Folder"); 
	
	new_dir = dir + File.separator + file_number[n] + "_Folder"; 
	
	run("Bio-Formats Macro Extensions");
	
	// initializes given id (filename), gets base filename to initialize dataset and then gets number of series in life file 
	Ext.setId(dir + File.separator + file_number[n]);
	Ext.getCurrentFile(file);
	Ext.getSeriesCount(seriesCount);
	
	// iterate through lif series, opening one series at a time and resaving it as tif file 
	for (i=0; i<seriesCount ; i++){
	
		run("Bio-Formats Importer", "open=["+ dir + File.separator + file_number[n] +"] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_"+i);
		name = getTitle();
		saveAs("Tiff", new_dir + File.separator + name);
		
		run("Close"); 
			
	}
	
	run("Collect Garbage");
	
}






