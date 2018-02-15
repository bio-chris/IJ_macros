filepath = File.openDialog("Select lif file"); 
out = getDirectory("Select directory in which lif file is stored"); 

filename = File.getName(filepath); 

Dialog.create("How many series?");

Dialog.addNumber("How many series in existing lif file:", 3);

Dialog.show();

setBatchMode(true); 

n_series = Dialog.getNumber();

series = "";  

for (i=0; i<n_series ; i++){

	series+= "series_" + (i+1) + " " ;
	
}

run("Bio-Formats Importer", "open=["+ filepath +"] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT "+ series +" ");

exists = File.exists(out + File.separator + "Tiff files")

if (exists == 0) {
	 File.makeDirectory(out + File.separator + "Tiff files"); 
}


new_out = out + File.separator + "Tiff files"; 

for (i=0; i<n_series ; i++){

	saveAs("Tiff", new_out + File.separator + filename + "_Part_" + i); run("Close"); 
	
}