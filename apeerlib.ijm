arg = getArgument();

args = split(arg, ";");
command = args[0];
//if the lenght of args is >1, then it has arguments for that command. 
//in this case, arg[1] can have multiple arguments separated by comma
// and these arguments are checkd inside each function
  
para = "";
if (args.length > 1)
	para = args[1];

out = "";
if (command == "test"){
	out = test( para );
} else if (command == "currentTime"){
	out = currentTime();
} else if (command == "captureWFE_JSON"){
	out = captureWFE_JSON();
} else if (command == "checkJSON_ReadExists"){
	out = checkJSON_ReadExists( para ); // out is null ""
} else if (command == "JSON_OUT"){
	out = jsonOutV5( para ); // para should be comma separated values. see function for more details. 
}
return out;


function test( para ){
	print(para);
	p2 = para + " ... added by external function";
	return p2;
}

// Read JSON Variables
function captureWFE_JSON(){

	call("CallLog.shout", "capturing WFE_JSON");
	WFE_file = "/params/WFE_input_params.json";
	if (!File.exists(WFE_file)) {
    	call("CallLog.shout", "WFE_JSON loading from Environmental variable...");
    	WFE_JSON = eval("js", "java.lang.System.getenv()['WFE_INPUT_JSON']");		
		//call("CallLog.shout", "WFE_input_params.json does not exist... exiting...");
		//eval("script", "System.exit(0);");
	} else {
		call("CallLog.shout", "[Local Mode] WFE_input_params.json found... reading file...");
		WFE_JSON = File.openAsString(WFE_file);
	}
		
	call("CallLog.shout", "WFE_JSON contents: " + WFE_JSON);
	return WFE_JSON;	
}

// check if JSON_Read.js exists
function checkJSON_ReadExists( JSON_READER ){
	//JSON_READER = "/JSON_Read.js"
	if (!File.exists(JSON_READER)) {
			call("CallLog.shout", "JSON_Read.js does not exist... exiting...");
			eval("script", "System.exit(0);");
		} 
		else {
			call("CallLog.shout", "JSON_Read.js found... reading file...");
		}
	return "";
}

// Get SystemTimer
 function currentTime() {
     MonthNames = newArray("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
     DayNames = newArray("Sun", "Mon","Tue","Wed","Thu","Fri","Sat");

     getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);

     timeString = DayNames[dayOfWeek]+" ";

     if (dayOfMonth<10) {timeString = timeString + "0";}
     timeString = timeString+dayOfMonth+"-"+MonthNames[month]+"-"+year+" @ ";

     if (hour<10) {timeString = timeString + "0";}
     timeString = timeString+hour+":";

     if (minute<10) {timeString = timeString + "0";}
     timeString = timeString+minute+":";

     if (second<10) {timeString = timeString + "0";}
     timeString = timeString+second;

     return timeString;
}

//parameters
// index 0: output folder path
// index 1 - : filenames with extensions. 
// the single item is square bracketted - meaning that the out put is suppose to be a list of file. 
function jsonOutV2( parameters ) {
	pA = split(parameters, ",");
	RESULTSPATH = pA[0];
	call("CallLog.shout", "... results path:" + RESULTSPATH);	
	jsonout = File.open(RESULTSPATH + "json_out.txt");
	
	print(jsonout,"{");
	print(jsonout,"\"RESULTSDATA\": [");
	for (i = 1; i < pA.length; i++){
		if (i == pA.length -1)
			print(jsonout,"\t\"/output/" + pA[i] + "\"");
		else 
			print(jsonout,"\t\"/output/" + pA[i] + "\",");
	}	
	print(jsonout,"\t]");
	print(jsonout,"}");
	File.close(jsonout);
	
	WFEOUTPUT = getWFEOUTPUT();
	call("CallLog.shout", "... WFEOUTPUT: " + WFEOUTPUT);
	if (WFEOUTPUT != "none"){
		File.rename(RESULTSPATH + "json_out.txt", RESULTSPATH + WFEOUTPUT);
		//call("CallLog.shout", "... renamed");
		return "renamed";
	}
	return "not renamed";
} 
//parameters
// index 0: output folder path
// index 1 - : filenames with extensions. 
// without brackets. no lists. 
function jsonOutV4( parameters ) {
	pA = split(parameters, ",");
	RESULTSPATH = pA[0];
	call("CallLog.shout", "... results path:" + RESULTSPATH);	
	jsonout = File.open(RESULTSPATH + "json_out.txt");
	
	print(jsonout,"{");
	for (i = 1; i < pA.length; i++){
		//print(jsonout,"\"RESULTSDATA\"" + i + ": [");
		if (i == pA.length -1)
			print(jsonout,"\"RESULTSDATA" + i + "\": \"/output/" + pA[i] + "\"");
			//print(jsonout,"\t]");
		else 
			print(jsonout,"\"RESULTSDATA" + i + "\": \"/output/" + pA[i] + "\", ");
			//print(jsonout,"\t],");
	}
	print(jsonout,"}");
	File.close(jsonout);
	
	WFEOUTPUT = getWFEOUTPUT();
	call("CallLog.shout", "... WFEOUTPUT: " + WFEOUTPUT);
	if (WFEOUTPUT != "none"){
		File.rename(RESULTSPATH + "json_out.txt", RESULTSPATH + WFEOUTPUT);
		//call("CallLog.shout", "... renamed");
		return "renamed";
	}
	return "not renamed";
} 

//parameters
// index 0: output folder path
// index 1 - : filenames with extensions. 
// without brackets. no lists. in one line, no new lines.  
function jsonOutV5( parameters ) {
	pA = split(parameters, ",");
	RESULTSPATH = pA[0];
	call("CallLog.shout", "... results path:" + RESULTSPATH);	
	jsonout = File.open(RESULTSPATH + "json_out.txt");
	outtext = "{";
	for (i = 1; i < pA.length; i++){
		if (i == pA.length -1) {
			outtext = outtext + "\"RESULTSDATA" + i + "\": \"" + RESULTSPATH + pA[i] + "\"";
		} else {
			outtext = outtext + "\"RESULTSDATA" + i + "\": \"" + RESULTSPATH + pA[i] + "\",";
		}
	}
	outtext = outtext + "}";
	print(jsonout, outtext);
	File.close(jsonout);
	
	WFEOUTPUT = getWFEOUTPUT();
	call("CallLog.shout", "... WFEOUTPUT: " + WFEOUTPUT);
	if (WFEOUTPUT != "none"){
		File.rename(RESULTSPATH + "json_out.txt", RESULTSPATH + WFEOUTPUT);
		//call("CallLog.shout", "... renamed");
		return "renamed";
	}
	return "not renamed";
} 


function getWFEOUTPUT(){
	JSON_READER = "/JSON_Read.js";
	if (File.exists(JSON_READER)) {	
		WFEOUTPUT = runMacro(JSON_READER, "settings.WFE_output_params_file");
	} else {
		WFEOUTPUT = "none";
	}
	return WFEOUTPUT;
}

