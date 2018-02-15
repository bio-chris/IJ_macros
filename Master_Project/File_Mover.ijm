/*
 * This macro will seperate Channel 1 and Channel 2 SPIM images in two different folders for automatic concatenation. 
 * 
 */


out = getDirectory("Select Main Folder"); 

File.makeDirectory(out + File.separator + "Channel 1")
File.makeDirectory(out + File.separator + "Channel 2")

out1 = out + File.separator + "Channel 1"; 
out2 = out + File.separator + "Channel 2"; 

names=getFileList(out);

for (i=0; i<names.length; i++){

	if(endsWith(names[i], "Ch1_Ill0_Ang0,1.tif") || endsWith(names[i], "Channel1.ome.tif")){
		File.rename(out + File.separator + names[i], out1 + File.separator + names[i]);
	}

	if (endsWith(names[i], "Ch2_Ill0_Ang0,1.tif") || endsWith(names[i], "Channel2.ome.tif")){
		File.rename(out + File.separator + names[i], out2 + File.separator + names[i]);
	}
	
}


    