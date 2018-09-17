filepath = File.openDialog("Select lif file"); 

// getting folder path by splitting filepath and removing filename

lines=split(filepath,"\\"); 

dir = ""

for (i=0; i<lines.length-1; i++){

	dir+=lines[i] + '\\';

}
