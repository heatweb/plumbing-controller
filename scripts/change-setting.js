const myArgs = process.argv.slice(2);
if (!myArgs[0]) { console.log("require a setting id.");  process.exit(1); }
if (!myArgs[1]) { console.log("require a setting value.");  process.exit(1); }

var SETTINGS = "/home/pi/node-hiu/settings.json"; 
var SETTING = myArgs[0]; 

fs = require('fs');
var sdata = "{}";

if (fs.existsSync(SETTINGS)) {
    
    console.log("loading existing settings.");
    
    fs.readFile(SETTINGS, 'utf8', function (err,sdata) {
      if (err) {
        console.log(err);
        //data = "{}";
      }
      console.log(sdata);
        
    });
        
} 

console.log(sdata);
                
  var timenow = new Date().getTime();
  fs.writeFile(SETTINGS.replace(".json","_"+timenow+".json"), sdata, err => {
      if (err) {
        console.error(err);
      }
      // file written successfully
    });

    try {  
               
      var SETTINGS_DATA = JSON.parse(sdata);

      SETTINGS_DATA[SETTING] = { "value":myArgs[1], "timestamp":timenow };

      if (myArgs[2]) { SETTINGS_DATA[SETTING].title = myArgs[2]; }
      if (myArgs[3]) { SETTINGS_DATA[SETTING].units = myArgs[3]; }                     
        
      var payload = JSON.stringify(SETTINGS_DATA);
        
        //console.log(payload);

      fs.writeFile(SETTINGS, payload, err => {
        if (err) {
          console.error(err);
        }
        // file written successfully
      });
  
  } catch { console.log("Failed to update settings."); }


