// https://stackabuse.com/making-http-requests-in-node-js-with-node-fetch/


const myArgs = process.argv.slice(2);

const fs = require('fs');
const fetch = require('node-fetch');
const { exec } = require('child_process');

//const querystring = require("querystring");
//const { Curl } = require("node-libcurl");

var sdata = "{}";

if (fs.existsSync("composer.json")) {
    
  console.log("loading local composer.json");    
  sdata = fs.readFileSync("composer.json", {encoding:'utf8', flag:'r'}); 
        
} else {

  if (!myArgs[0]) { console.log("require a composer file.");  process.exit(1); }
  console.log("loading " + myArgs[0]);  

  if (fs.existsSync(myArgs[0])) {    
      
    sdata = fs.readFileSync(myArgs[0], {encoding:'utf8', flag:'r'}); 
          
  } else {

    console.log("Composer file " + myArgs[0] + " does not exist.");  process.exit(1); 

  }
}

try { composition = JSON.parse(sdata); } catch { console.log("Invalid JSON data.");  process.exit(1); } 

//console.log(composition);  

var credentials = {};
if (fs.existsSync("/boot/heatweb/credentials.json")) {
    
  console.log("loading credentials.json"); 
  try { credentials = JSON.parse(fs.readFileSync("/boot/heatweb/credentials.json", {encoding:'utf8', flag:'r'}));  } 
  catch { console.log("Invalid credentials data.");  process.exit(1); } 
    
  //console.log(credentials);         
} 
// NEED TO ADD SECTION TO RECOMPILE CREDENTIALS FROM .txt FILES.  OR DITCH credentials.json AND JUST USE .txt FILES 

if (fs.existsSync("/boot/heatweb/credentials/adminPassword.txt")) {
    
  console.log("loading admin password"); 
  try { credentials.adminPassword = fs.readFileSync("/boot/heatweb/credentials/adminPassword.txt", {encoding:'utf8', flag:'r'});  } 
  catch { console.log("Invalid credentials data.");  process.exit(1); } 
         
} 



var config = {};
if (fs.existsSync("/boot/heatweb/config.json")) {
    
  console.log("loading config.json"); 
  try { config = JSON.parse(fs.readFileSync("/boot/heatweb/config.json", {encoding:'utf8', flag:'r'}));  } 
  catch { console.log("Invalid config data.");  process.exit(1); } 
    
  //console.log(config);         
} 

var settings = {};
var changed_settings = false;
if (fs.existsSync("/home/pi/node-hiu/settings.json")) {
    
  console.log("loading settings.json"); 
  try { settings = JSON.parse(fs.readFileSync("/home/pi/node-hiu/settings.json", {encoding:'utf8', flag:'r'}));  } 
  catch { console.log("Invalid settings data.");  process.exit(1); } 
    
  //console.log(settings);         
} 

var fetched=0;
var posted=0;
var auth = {};
var urldata={};



async function postnodered(msg) {

    console.log("fetching...", msg.url);
    
    const res = await fetch(msg.url, {
                method: 'POST',
                body: msg.payload,
                headers: msg.headers
            });

    console.log(res);

    //const json = await res.json();    
    //console.log(ttarg, json.access_token.substr(0,90));

    //auth[ttarg] = json.access_token || "";

    
}

async function fetchtoken(ttarg, url, tdata) {

    console.log("fetching...", url);
    
    const res = await fetch(url, {
                method: 'POST',
                body: JSON.stringify(tdata),
                headers: { 'Content-Type': 'application/json' }
            });

    const json = await res.json();    
    if (json.access_token) { console.log(ttarg, json.access_token.substr(0,90)); }

    auth[ttarg] = json.access_token || "";
    
    if (fetched == composition.length && auth[ftarget]]!=="waiting") { compose(); } 
    
}

async function fetchdata(item, url) {

    console.log("fetching...", url);
    
    const res = await fetch(url);  
    
    const json = await res.json();    
    composition[item].data = json;
    fetched++;
    console.log("fetched", fetched, "of", composition.length, JSON.stringify(json).substr(0,100));
    if (fetched == composition.length && auth[ftarget]!=="waiting") { compose(); }   

}

var ftarget = "";

for (var item in composition) {

    var msg1={};
    msg1.url = composition[item].dataSource;
    msg1.index = item;

    var msg2 = null;

    var targetPort = composition[item].targetPort || 1880;
    var targetHost = composition[item].targetHost || "localhost";
    //targetHost = targetHost.replace("localhost", "host.docker.internal")

    var targ = targetHost + ":" + targetPort;
    if (ftarget=="") { ftarget = targetHost + ":" + targetPort; }

    if (!auth[targ]) {         

        auth[targ]="waiting";
        //flow.set("auth",auth);

        msg2 = {}
        msg2.targ = targ;
        msg2.payload = {};
        msg2.payload['client_id'] = "node-red-admin";
        msg2.payload['grant_type'] = "password";
        msg2.payload['scope'] = "*";
        msg2.payload['username'] = "admin";
        msg2.payload['password'] = credentials.adminPassword || "admin";
        msg2.url = "http://" + targ + "/auth/token";
        
        fetchtoken(targ, msg2.url, msg2.payload);

    }


    if (msg1.url) {

      fetchdata(item, msg1.url);

    }


    //node.send([msg1, msg2]);
    //console.log(msg1);
    //console.log(msg2);
}


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


var msggo;

function compose() {

  console.log("Composing...");

  var fullflow = [];


  for (var item in composition) {

      var msg={};
      msg.payload = composition[item];

            if (msg.payload.config) { 
              
              for (var cf in msg.payload.config) {  config[cf] =  msg.payload.config[cf];     }
              
              //XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
              //node.send([null, null, msg, null]);
              

            }
            if (msg.payload.credentials) {

              for (var cf in msg.payload.credentials) { credentials[cf] = msg.payload.credentials[cf]; }

              //XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
              //node.send([null, null, null, msg]);
              

            }



            

            if (msg.payload.wiring && msg.payload.wiring.terminals) {

              var curio = [];
                
              if (settings.io) { curio = JSON.parse(settings.io.value || "[]"); }
              
              var newio = merge(curio, msg.payload.wiring.terminals, "portId");

              //XXXXX
                
              if (!settings.io) { settings.io = { "title":"Terminal assignment" }; }
              settings.io.value = JSON.stringify(newio);


              var msg5={}
              msg5.payload = JSON.stringify(settings);
              msg5.filename = "/home/pi/node-hiu/settings.json";


              //XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
              //node.send([null, null, null, null, msg5]);


            }


            if (msg.payload.settings) {

              for (var cf in msg.payload.settings) { settings[cf] = msg.payload.settings[cf]; }

              var msg6 = {}
              msg6.payload = JSON.stringify(settings);
              msg6.filename = "/home/pi/node-hiu/settings.json";

              //XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
              //node.send([null, null, null, null, msg6]);

            }

            if (!msg.payload.action) { continue; }



            var targetPort = msg.payload.targetPort || 1880;
            var targetHost = msg.payload.targetHost || "localhost";
            //targetHost = targetHost.replace("localhost","host.docker.internal")
            var targ = targetHost + ":" + targetPort;

            msg.headers = {};
            msg.headers.Authorization = "Bearer " + auth[targ];
            msg.headers['Content-type'] = "application/json";
            msg.headers['Node-RED-Deployment-Type'] = "full";


            msg.url = "http://" + targ + "/" + (msg.payload.action||"flow");

          
            var ff = msg.payload.data;

            if (msg.payload.replacements) {

              var ffstr = JSON.stringify(ff);

              var reps = msg.payload.replacements;
              for (var rep in reps) {

                  ffstr = ffstr.replaceAll(reps[rep][0], reps[rep][1]);
              }

              ff = JSON.parse(ffstr);
            }


            function checkTab(nodeitem) {
              return nodeitem.type == "tab";
            }

            function filterTab(nodeitem) {
              return nodeitem.type != "tab";
            }

            function filterMqttBroker(nodeitem) {
              return nodeitem.type != "mqtt-broker";
            }

            if (msg.payload.action == "xxxxxxflow") {   // individual flows can't contain tabs, and do not want to overwrite mqtt broker

              var tabf = ff.filter(checkTab)[0];
              tabf.nodes = ff.filter(filterTab).filter(filterMqttBroker);
              ff = tabf;

            }


            for (var part in ff) {

              if (ff[part].type == "heatwebConfig") { 
                  
                  ff[part].name = config.name ; 
                  ff[part].description = config.description;
                  ff[part].nodeId = config.nodeId;
                  ff[part].networkId = config.networkId; 

              }
              

              if (credentials.localMqttPassword) {

                  //if (ff[part].type == "mqtt-broker" && (ff[part].broker == "mqtt" || ff[part].broker == "localhost")) { ff[part].credentials = { "user": "admin", "password": credentials.localMqttPassword }; }
                
              }

              if (credentials.adminPassword) {

                  if (ff[part].type == "mqtt-broker" && (ff[part].broker == "mqtt" || ff[part].broker == "localhost")) { ff[part].credentials = { "user": "admin", "password": credentials.adminPassword }; }
                
                  if (ff[part].type == "MySQLdatabase" && ff[part].host == "mysql") { ff[part].credentials = { "user": "root", "password": credentials.adminPassword }; }

              }

              if (credentials.localInfluxToken) {

                  if (ff[part].type == "influxdb" && ff[part].name == "local") { ff[part].credentials = { "token": credentials.localInfluxToken }; }

              }
              if (credentials.remoteInfluxToken) {

                  if (ff[part].type == "influxdb" && ff[part].name == "heatweb") { ff[part].credentials = { "token": credentials.remoteInfluxToken }; }

              }

              if (credentials.emailPassword && credentials.emailUser) {

                  if (ff[part].type == "e-mail") { ff[part].credentials = { "userid": credentials.emailUser, "password": credentials.emailPassword }; }

              }

              


            }

            fullflow = merge(fullflow,ff,"id");
            msg.payload = JSON.stringify(ff);

            //XXXXXXX
            //return [null, msg, null, null];
            
            //postnodered(msg);
            msggo = msg;

            //console.log(msg);







  }

  fs.writeFile("/home/pi/node-hiu/settings.json", JSON.stringify(settings), err => {
        if (err) {
          console.error(err);
        }
        // file written successfully
        console.log("Settings saved");
      });  

  //console.log(fullflow);


  msggo.url = "http://" + ftarget + "/flows";
  msggo.payload = JSON.stringify(fullflow)

      fs.writeFile("/home/pi/node-hiu/flows_last_composer.json", msggo.payload, err => {
        if (err) {
          console.error(err);
        }
        // file written successfully           
      });  
  
  
  var gowriteflow = true;  
  if (gowriteflow ||(settings.composer_writeFile && settings.composer_writeFile.value)) {
      
     fs.writeFile("/home/pi/.node-red/flows_ihiu.json", msggo.payload, err => {
        if (err) {
          console.error(err);
        }
        // file written successfully     
         
         
            exec('node-red-restart', (err, stdout, stderr) => {
              if (err) {
                //some err occurred
                console.error(err)
              } else {
               // the *entire* stdout and stderr (buffered)
               //console.log(`stdout: ${stdout}`);
               //console.log(`stderr: ${stderr}`);
               postnodered(msggo);   
              }
            });
      });  
      
  } else {
    
    postnodered(msggo);
      
  }  
  console.log("Finished.");
    
}


