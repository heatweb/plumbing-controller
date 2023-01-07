
var SETTINGS = "/home/pi/node-hiu/settings.json"; 

fs = require('fs');
var sdata = "{}";

if (fs.existsSync(SETTINGS)) {   
        
    sdata = fs.readFileSync(SETTINGS, {encoding:'utf8', flag:'r'});
  
    sdat = JSON.parse(sdata);
    var oot = "";
  
    for (var s in sdat) {
     
         oot += '"' + (sdat[s].title || s) + '" "' + sdat[s].value + (sdat[s].units || "") + '"'
    }
    
    console.log(oot);
        
} 
