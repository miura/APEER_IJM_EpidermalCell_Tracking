arg = getArgument();

args = split(arg, ";");
command = args[0];
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


