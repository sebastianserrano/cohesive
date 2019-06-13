var admin = require('firebase-admin');
var serviceAccount = require('./credentials.js');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://cohesive-79cd9.firebaseio.com"
});

console.log('Connected Succesfully.')
var db = admin.database();

FirebaseDriver = function(){};

FirebaseDriver.prototype.set = function(refName,child,info,callback) {
  db.ref(refName).child(child).set(info, function(error){
    if (error) {callback(error)}
    else (callback(true));
  })
};

FirebaseDriver.prototype.update = function(refName,child,info,callback) {
  db.ref(refName).child(child).update(info,function(error){
    if (error) {callback(error)}
    else {callback(true)};
  })
};

FirebaseDriver.prototype.get = function(refName,child,callback) {
  var success = false;
  db.ref(refName).child(child).on("value", function(snapshot) {
        callback(null,snapshot.val());
    }, function (errorObject) {
        callback(errorObject.code,null);
    });
};

exports.FirebaseDriver = FirebaseDriver;

