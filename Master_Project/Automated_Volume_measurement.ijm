/*
 * This macro facilitates semi-automated single-cell volume measurements after having processed image data using the Pre_Automated_Volume_measurement macro 
 * 
 */



out=getDirectory("Select Folder in which only image files containing divisions are stored");

names=getFileList(out);
Array.sort(names);

// Creates the Excel sheet which will store all volume measurements 
f = File.open(out + File.separator + "Volume_Measurements.xls");

divided = "";

// The for-loop will open every single timepoint image file and let user identify the cell of interest. It will then ask for the object number of that cell and will save the volume to a Excel sheet

for (i=0; i<names.length; i++){

	//Alternative to open(out + names[i]), which does not open images in numeric fashion 
	run("Image Sequence...", "open=["+ out + names[i] +"] number=1 starting=["+ i+1 +"] sort");
	rename("TP" + i);

	run("3D Manager");
	Ext.Manager3D_AddImage(); // adds opened image to the 3D Manager 
	
	waitForUser("...","Identify the Object of Interest"); // Waits for input of User to identify object of interest before continuing

	// Creates dialog for User to enter number of OoI
	Dialog.create("Identify Object of Interest");
	Dialog.addNumber("Enter the object number", 0);
	Dialog.show();
	
	object_number = Dialog.getNumber();

		// If the variable divided is not set to "Yes", the dialog will ask the user if cell has divided. If yes, this dialog will later no longer appear 
		if (divided == "No" || divided == ""){
			Dialog.create("Has cell of interested divided yet?");
			Dialog.addChoice("Did cell divide?:", newArray("No", "Yes"));
			Dialog.show();
			
			divided = Dialog.getChoice();

			/*
			 * Once the cell has divided, every image will open twice so you can identify both cells. The volume measurement for the first image that opens will be stored on the first column in the 
			 * Excel sheet. The second volume measurement will be stored in the second column. Make sure that you assign you always the select the same cell in the first and second window. 
			 */
		}
	
			
	object = object_number-1; // actual object_number will be +1 above the object of interest
	
	Ext.Manager3D_Select(object); // selects object
	Ext.Manager3D_Measure(); // performs 3D Measurement 
	
	Ext.Manager3D_SaveResult("M", out + names[i] + "Results3D.xls"); // results are saved to a temporary Excel file
	
	open(out + "M_"+ names[i] +"Results3D.xls"); // Excel file is opened
	
	vol = getResultString("Vol (pix)", 0); // Volume value is extracted from Excel file and stored in vol
	
  	print (f, vol + "\n"); // Volume value is printed to Volume_Measurement Excel file

	run("Close All"); 

	File.delete(out + "M_"+ names[i] +"Results3D.xls"); // temporary Excel file is deleted 

		// If division has occured, this if-statement will re-open the image to let user select sister cell in the same manner as above

		if (divided == "Yes"){

			//open(out + names[i]);

			run("Image Sequence...", "open=["+ out + names[i] +"] number=1 starting=["+ i+1 +"] sort");
			rename("TP" + i);

			run("3D Manager");
			Ext.Manager3D_AddImage();
								
			waitForUser("...","Identify the other (divided) Object of Interest"); 
		
			
			Dialog.create("Identify Object of Interest");
			Dialog.addNumber("Enter the object number", 0);
			Dialog.show();
			
			object_number = Dialog.getNumber();
			
			object = object_number-1;
			
			Ext.Manager3D_Select(object);		
			Ext.Manager3D_Measure();
			
			Ext.Manager3D_SaveResult("M", out + names[i] + "Results3D.xls");
			
			open(out + "M_"+ names[i] +"Results3D.xls"); 
			
			vol = getResultString("Vol (pix)", 0);
			
		  	print (f, "\t" + vol);
		
			run("Close All"); 
		
			File.delete(out + "M_"+ names[i] +"Results3D.xls");
			
		}


	}

			
	File.close(f); 

	

/*
 * Note: Alternative to open(), based on getFileList is
 * 
 * run("Image Sequence...", "open=["+ out + names[i] +"] number=1 starting=["+ i+1 +"] sort");
 * 
 * This line of code will do the same thing, only it will open every file in numeric fashion 
 * 
 */



