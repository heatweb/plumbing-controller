// https://stackabuse.com/making-http-requests-in-node-js-with-node-fetch/


const myArgs = process.argv.slice(2);

const fs = require('fs');
const fetch = require('node-fetch');

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

console.log(composition);  

var credentials = {};
if (fs.existsSync("/boot/heatweb/credentials.json")) {
    
  console.log("loading credentials.json"); 

  try { credentials = JSON.parse(fs.readFileSync("/boot/heatweb/credentials.json", {encoding:'utf8', flag:'r'}));  } 
  catch { console.log("Invalid credentials data.");  process.exit(1); } 
    
  console.log(credentials);         
} 


var fetched=0;
var posted=0;
var auth = {};
var urldata={};



async function fetchtoken(ttarg, url, tdata) {

    const res = await fetch(url, {
                method: 'POST',
                body: JSON.stringify(tdata),
                headers: { 'Content-Type': 'application/json' }
            });

    const json = await res.json();    
    console.log(ttarg, json.access_token.substr(0,90));

    auth[ttarg] = json.access_token || "";

    
}

async function fetchdata(item, url) {

    const res = await fetch(url);  
    fetched++;
    const json = await res.json();    
    composition[item].data = json;
    
    console.log("fetched", fetched, "of", composition.length, JSON.stringify(json).substr(0,100));
    if (fetched == composition.length) { compose(); }   

}

for (var item in composition) {

    var msg1={};
    msg1.url = composition[item].dataSource;
    msg1.index = item;

    var msg2 = null;

    var targetPort = composition[item].targetPort || 1880;
    var targetHost = composition[item].targetHost || "localhost";
    //targetHost = targetHost.replace("localhost", "host.docker.internal")

    var targ = targetHost + ":" + targetPort;
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
    console.log(msg1);
    console.log(msg2);
}



function compose() {

  console.log("Composing...");
}
