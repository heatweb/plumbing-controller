// testing

const myArgs = process.argv.slice(2);

const fs = require('fs');
const fetch = require('node-fetch');
const { exec } = require('child_process');


var sdata = "{}";


  if (!myArgs[0]) { console.log("Require an installation code.");  process.exit(1); }
  console.log("loading " + myArgs[0]);  

 var url = "https://heatweb-api.flowforge.cloud/register-device?code=" + myArgs[0];

 fetchdata(url);


async function fetchdata(url) {

    console.log("fetching...", url);
    
    const res = await fetch(url);  
    
    const json = await res.json();    
    //composition[item].data = json;
    //fetched++;
    console.log("fetched", JSON.stringify(json).substr(0,100));
    
    if (!json.data.config) { console.log("Invalid code.");  process.exit(1); }
  
    console.log("Network ID: " + json.data.config.networkId);
    console.log("Node ID: " + json.data.config.nodeId);
  
    fs.writeFile("/home/pi/node-hiu/config.json", JSON.stringify(json.data.config), err => {
      if (err) { console.error(err); } 
      else {
         
          exec('sudo mv /home/pi/node-hiu/config.json /boot/heatweb/config.json', (err, stdout, stderr) => {
              if (err) { console.error(err)  }             
          });          
      }  
    });
  
    
  // 	"https://raw.githubusercontent.com/heatweb/plumbing-controller/main/applications/hydraulic_interface_units/hiu_dhw_novocon/composer.json"
  var composition;
  
  if (json.data.application) {
   
     // ------
  
        var appfile = json.data.application;
        if (appfile.indexOf("/applications/")>-1) { appfile = appfile.split("/applications/")[1] };

        var appfilename = "composer.json";
        var apppath = "/home/pi/plumbing-controller/applications/" + appfile.replace("/"+appfilename,"");

        console.log("Composer path: " + apppath);
        console.log("Composer file: " + appfilename);
    
        exec('node /home/pi/plumbing-controller/scripts/change-setting.js appFile "' + appfilename + '" "Application Composer JSON file"', (err, stdout, stderr) => {
            if (err) { console.error(err);  process.exit(1); }             
        

            exec('node /home/pi/plumbing-controller/scripts/change-setting.js appPath "' + apppath + '" "Application Composer JSON file"', (err, stdout, stderr) => {
              if (err) { console.error(err);  process.exit(1);   }             
          

            exec('sudo rm -r /boot/heatweb/composer', (err, stdout, stderr) => {
               if (err) {   }             


                exec('sudo mkdir /boot/heatweb/composer', (err, stdout, stderr) => {
                   if (err) {   }             


                   exec('sudo cp -r ' + apppath + '/* /boot/heatweb/composer', (err, stdout, stderr) => {

                     if (err) { console.error(err);  process.exit(1);   }      

                     else {

                       console.log("Application files copied.");

                       if (json.data.importFlows[0]) {

                               console.log("Importing additional flows. ");

                               var sdata = fs.readFileSync("/boot/heatweb/composer/composer.json", {encoding:'utf8', flag:'r'}); 
                               try { composition = JSON.parse(sdata); } catch { console.log("Invalid JSON data.");  process.exit(1); } 

                               for (var xf in json.data.importFlows) {




                                    var newflow = {
                                        "dataSource": json.data.importFlows[xf],
                                        "targetHost": "localhost",
                                        "targetPort": 1880,
                                        "action": "flow"
                                    }

                                    composition.push(newflow);

                               }


                               fs.writeFile("/home/pi/node-hiu/composer.json", JSON.stringify(composition), err => {
                                  if (err) { console.error(err); } 
                                  else {

                                      exec('sudo mv /home/pi/node-hiu/composer.json /boot/heatweb/composer/composer.json', (err, stdout, stderr) => {
                                          if (err) { console.error(err)  }             
                                      });          
                                  }  
                                });
                            }

                            if (fs.existsSync("/boot/heatweb/composer/install.sh")) {  
                                exec('bash /boot/heatweb/composer/install.sh', (err, stdout, stderr) => {
                                   if (err) { console.error(err)  }             
                                }); 
                            }       

                     }
           
        }); }); }); }); }); 
    
       // ------
  }
   

        
  
    if (json.data.jfrogxxx) {
  
        var jfrogstr = 'sudo wget -O - "https://connect.jfrog.io/v2/install_connect" | sudo sh -s ' + json.data.jfrog.token + ' ' + json.data.jfrog.project + ' -n=' + json.data.jfrog.name + ' -g=' + json.data.jfrog.group;
      
        exec('sudo rm /etc/connect/service/settings.json', (err, stdout, stderr) => {
            if (err) { console.error(err)  }             
        }); 

        exec(jfrogstr, (err, stdout, stderr) => {
            if (err) { console.error(err)  }             
        }); 
  
    }
  
    if (json.data.credentials) {
  
       for (var cred in json.data.credentials) {
         
         fs.writeFile("/home/pi/node-hiu/"+cred+".tmp", json.data.credentials[cred], err => {
            if (err) { console.error(err); } 
            else {

                exec('sudo mv /home/pi/node-hiu/'+cred+'.tmp /boot/heatweb/credentials/'+cred+'.txt', (err, stdout, stderr) => {
                    if (err) { console.error(err)  }             
                });          
            }  
          });
         
       
       }
  
    }
  
    //console.log("Done.");  // NO MUST FINISH async operations
    //process.exit(0);
  
}

var ftarget = "";



function merge(a, b, prop) {
              var reduced = [];
              for (var i = 0; i < a.length; i++) {
                  var aitem = a[i];
                  var found = false;
                  for (var ii = 0; ii < b.length; ii++) {
                    if (aitem[prop] === b[ii][prop]) {
                        found = true;
                        break;
                    }
                  }
                  if (!found) {
                    reduced.push(aitem);
                  }
              }
              return reduced.concat(b);
}


 



