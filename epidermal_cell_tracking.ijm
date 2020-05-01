/*
  ImageJ macro for 2D Epidermal Cell tracking
  Step 3 procedure in "Bioimage Data Analysis (2016)" Chapt. 7 
  based on example generate_stack.ijm
  Kota Miura (2020)
 */

// General global vars
RESULTSPATH = "/output/";
BATCHMODE = "true";
libmacro = "/apeerlib.ijm";

// Read JSON Variables
WFE_JSON = runMacro( libmacro , "captureWFE_JSON");

// Read JSON WFE Parameters
JSON_READER = "/JSON_Read.js";
runMacro( libmacro , "checkJSON_ReadExists;" + JSON_READER);

// Get WFE Json values as global vars
call("CallLog.shout", "Reading JSON Parameters");
INPUTFILES = runMacro(JSON_READER, "settings.input_files[0]");
INPUTSTACK = runMacro(JSON_READER, "settings.input_files[0]");
PREFIX = runMacro(JSON_READER, "settings.prefix");
STACKNAME = runMacro(JSON_READER, "settings.labelstack_name");
OUTTRACKSTACKNAME = runMacro(JSON_READER, "settings.trackstack_name");
RESULTSNAME = runMacro(JSON_READER, "settings.results_filename");
WFEOUTPUT = runMacro(JSON_READER, "settings.WFE_output_params_file");

// Getting input file path from WFE input_files
path_substring = lastIndexOf(INPUTFILES, "/");
IMAGEDIR_WFE = substring(INPUTFILES, 0, path_substring+1);

main();

function main() {
	tt = runMacro( libmacro , "currentTime");
	call("CallLog.shout", "Starting opening files, time: " + tt);
	
	if (BATCHMODE=="true") {
		setBatchMode(true);
	}
	call("CallLog.shout", "ImageJ version: " + getVersion());
 	importData();
 	
	orgID = getImageID();
	hh = getHeight();
	ww = getWidth();
	dd = nSlices;
	run("Duplicate...", "title=tracked.tif duplicate");
	dupID = getImageID();
	//run("Options...", "iterations=1 count=1 black do=Nothing");
	setOption("BlackBackground", true);
	run("Dilate", "stack");
	run("Invert LUT");
	run("Set Measurements...", "area centroid mean stack redirect=None decimal=2");
	run("Analyze Particles...", "size=10-Infinity show=Nothing display exclude clear stack");
	call("CallLog.shout", "Initial 2D analysis done...");

	newImage("centroids", "8-bit black", ww, hh, dd);
	centID = getImageID();
	//setColor( 255 );
	for (i = 0; i < nResults; i++){
		selectImage( centID );
		cx = getResult("X", i);
		cy = getResult("Y", i);	
		cf = getResult("Slice", i);
		setSlice( cf );
		setPixel(cx, cy, 255);
	}
	run("Dilate", "stack");
	run("Dilate", "stack");
	saveAs("Tiff", "/output/centroids.tif");
    run("3D OC Options", "centroid dots_size=5 font_size=10 redirect_to=none");    
	OCpara = "threshold=128 slice=3 min.=100 max.=718536 objects statistics";
	run("3D Objects Counter", OCpara);
	nTracks = nResults;
	run("glasbey inverted");
	labelID = getImageID();
	saveAs("Tiff", "/output/3Dobjects.tif");
	call("CallLog.shout", "3D objects acquired...");
	setThreshold(1, 255);
	//run("Set Measurements...", "centroid mean stack redirect=None decimal=2");
	call("CallLog.shout", "Threshold set for the labeled image...");
	run("Analyze Particles...", "size=10-Infinity show=Nothing display exclude clear stack");
	call("CallLog.shout", "labeled image analyzed...");
	call("CallLog.shout", "Sorting " + Table.title);
	Table.sort("Mean"); // need ij 1.52a
    Table.update;
	call("CallLog.shout", "Table sorting done...");
	selectImage( centID );
	close();
	selectImage( labelID );
	close();
	call("CallLog.shout", "Tracking Done... preparing labeled stack...");
	selectImage( dupID );
	for (i = 0; i < nResults; i++){
		cx = getResult("X", i);
		cy = getResult("Y", i);	
		cf = getResult("Slice", i);
		label = getResult("Mean", i);
		setSlice( cf );
		setColor( label );
		floodFill( cx, cy );
	}
	run("glasbey inverted");
 	savingStack( STACKNAME );

	call("CallLog.shout", "Plotting Tracks...:" + OUTTRACKSTACKNAME);
	// plotting tracks
	selectImage( orgID );
	if (nResults > 0){
		overlayTracks( orgID, "yellow" );
	} else {
		print("no track data");
		call("CallLog.shout", "no track data");
	}
	saveAs("Tiff", "/output/" + OUTTRACKSTACKNAME + ".tif");
	close();

	call("CallLog.shout", "Saving results as CSV..."); 
	//saveAs("Results", "/Users/miura/Downloads/Results.csv");	 	
 	savingResults( RESULTSNAME );
 	jsonOut();

	tt = runMacro( libmacro , "currentTime");
	call("CallLog.shout", "Starting opening files, time: " + tt);
	run("Close All");
	call("CallLog.shout", "Closed");
	//shout("test print");
	eval("script", "System.exit(0);");
    print(" TEST from macro print command ");
    IJ.log(" TEST from macro ij.log command ");
}

function importData() {
	call("CallLog.shout", "Importing Data");
	
	if (PREFIX == "no-filter") {
		call("CallLog.shout", "opening image stack in: "+ IMAGEDIR_WFE + " with no filter");
		//run("Image Sequence...", "open=" +IMAGEDIR_WFE +"  sort use");
		open( INPUTSTACK );
	}
	else {
		call("CallLog.shout", "opening  image stack in: "+ IMAGEDIR_WFE + " with filter: " + PREFIX);
		//run("Image Sequence...", "open=" +IMAGEDIR_WFE +" file="+ PREFIX +" sort use");
		open( INPUTSTACK );
	}
}

function savingStack( outstack_name ) {
	if (outstack_name=="output") {
		call("CallLog.shout", "writing tif stack with default name: output.tif");
		saveAs("Tiff", "/output/output.tif");
	}
	else {
		call("CallLog.shout", "writing tif stack with user name: " + outstack_name + ".tif");
		saveAs("Tiff", "/output/" + outstack_name + ".tif");
	}
}

// save results as csv file
function savingResults( resultsname ) {
	call("CallLog.shout", "writing Results table to a file: " + resultsname);
	saveAs("Results", "/output/" + resultsname);
}

function overlayTracks( tracksID, trackcolor ){
	selectImage(tracksID);
	//ww = getWidth();
	//hh = getHeight();
	//newImage("Tracks", "8-bit black", ww, hh, 1);
	allx = newArray( nResults );
	ally = newArray( nResults );
	allID = newArray( nResults );
	allFrame = newArray( nResults );
	for ( i = 0; i < nResults; i++){
		allx[i] = getResult("X", i);
		ally[i] = getResult("Y", i);
		allID[i] = getResult("Mean", i);
		allFrame[i] = getResult("Slice", i);
	}
	Array.getStatistics(allID, minID, maxID, mean, stdDev);
	timepointsA = newArray( maxID );
	call("CallLog.shout", "parsed track data... tracks:" + maxID);
	for ( i = 0; i < maxID; i++ ){
		counter = 0;
		for ( j = 0; j < nResults; j++ ){
			if (allID[j] == i + 1){
				counter++;	
			}
		}
		timepointsA[i] = counter;
	}
	//Array.print(timepointsA);
	call("CallLog.shout", "scanning time points done...");	
	Overlay.remove;
	for (i = 0; i < maxID; i++){
		timepoints = timepointsA[i];
		xA = newArray( timepoints );
		yA = newArray( timepoints );
		idA = newArray( timepoints );
		frameA = newArray( timepoints );
		counter = 0;
		for (j = 0; j < nResults; j++){
			if (allID[j] == i + 1){
				xA[counter] = allx[j];
				yA[counter] = ally[j];
				counter++;
			}
		}
		print("id:", i+1);
		//Array.print(xA); Array.print(yA);	
		makeSelection(6 , xA, yA);
		Overlay.addSelection( trackcolor );
	}
}


// Generate output.json for WFE
function jsonOut() {
	call("CallLog.shout", "Starting JSON Output");
	jsonout = File.open(RESULTSPATH + "json_out.txt");
	call("CallLog.shout", "File open: JSON Output");
	
	print(jsonout,"{");
	print(jsonout,"\"RESULTSDATA\": [");

	if (STACKNAME=="output") {
		print(jsonout,"\t\"/output/output.tif\"");
	}
	else {
		print(jsonout,"\t\"/output/"+ STACKNAME + ".tif\"");
	}
	print(jsonout,"\t]");
	print(jsonout,"}");
	File.close(jsonout);
	File.rename(RESULTSPATH + "json_out.txt", RESULTSPATH + WFEOUTPUT);
	
	call("CallLog.shout", "Done with JSON Output");
}