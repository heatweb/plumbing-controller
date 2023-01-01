const myArgs = process.argv.slice(2);
if (!myArgs[0]) { console.log("require a password. Quitting.");  process.exit(1); }

fs = require('fs')
fs.readFile('/home/pi/.node-red/settings.js', 'utf8', function (err,data) {
  if (err) {
    return console.log(err);
  }

  
  var timenow = new Date().getTime();
  fs.writeFile('/home/pi/.node-red/settings_'+timenow+'.js', payload, err => {
      if (err) {
        console.error(err);
      }
      // file written successfully
    });

    var pos1 = data.indexOf("adminAuth:")
    var str1 = data.substr(0,pos1);
    var str2 = data.substr(pos1);

    var pos2 = str2.indexOf("},") +2;
    var str2 = str2.substr(pos2);

    var str3 =  'adminAuth: {\n';
    str3 +=  '     type: "credentials",\n';
    str3 +=  '         users: [{\n';
    str3 +=  '             username: "admin",\n';
    str3 +=  '             password: "' + myArgs[0] + '",\n';
    str3 +=  '             permissions: "*"\n';
    str3 +=  '         }]\n';
    str3 +=  ' },\n';

    var payload = str1 + "\n" + str3 + "\n" + str2;

      console.log(payload);

    fs.writeFile('/home/pi/.node-red/settings.js', payload, err => {
      if (err) {
        console.error(err);
      }
      // file written successfully
    });

});
