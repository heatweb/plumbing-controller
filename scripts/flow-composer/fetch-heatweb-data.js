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
  
    if (json.data.jfrog) {
  
        var jfrogstr = 'sudo wget -O - "https://connect.jfrog.io/v2/install_connect" | sudo sh -s ' + json.data.jfrog.token + ' ' + json.data.jfrog.project + ' -n=' + json.data.jfrog.name + ' -g=' + json.data.jfrog.group;
      
        exec('sudo rm /etc/connect/service/settings.json', (err, stdout, stderr) => {
            if (err) { console.error(err)  }             
        }); 

        exec(jfrogstr, (err, stdout, stderr) => {
            if (err) { console.error(err)  }             
        }); 
  
    }
  
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


 



