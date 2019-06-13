var admin = require('firebase-admin');
var serviceAccount = require('./credentials.js');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://cohesive-79cd9.firebaseio.com"
});

console.log('Application initiliazed');

var db = admin.database();
var ref = db.ref("Test");
var usersRef = ref.child("users");
    usersRef.set({
  alanisawesome: {
    date_of_birth: "June 23, 1912",
    full_name: "Alan Turing"
  },
  gracehop: {
    date_of_birth: "December 9, 1906",
    full_name: "Grace Hopper"
  },
  MOTHEFUCKINGWORKINGGGDAWGGGG: {
    date_of_birth: "December 9, 1906",
    full_name: "Grace Hopper"
  }
});

