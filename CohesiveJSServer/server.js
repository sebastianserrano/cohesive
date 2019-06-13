var http = require('http'),
    bodyParser = require('body-parser'),
    express = require('express'),
    path = require('path');

FirebaseDriver = require('./firebaseDriver').FirebaseDriver;
firebaseDriver = new FirebaseDriver();

var app = express();
app.set('port',process.env.PORT || 3000);
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended:true}));

app.get('/', function(req,res){
  res.send('<html><body><h1>Hello!</h1></body></html>');
});

app.get('/:a?/:b?', function(req,res){
    var params = req.params;
    firebaseDriver.get(params.a,params.b,function(err,objs){
        if (err) {res.status(400).send(err)}
        else {res.status(201).send(objs)};
        //console.log(Object.values(objs));
        for(obj in objs) {
          var value = objs[obj]
        };
    });
});

app.post('/:node?/:child?', function(req,res){
    var params = req.params;
    var info = req.body;
    var node = params.node;
    var child = params.child;

    firebaseDriver.set(node,child,info,function(callback){
      if (callback) {res.status(201).send(callback)}
      else (res.status(400).send(callback));
    });
});

app.put('/:node?/:child?', function(req,res){
    var params = req.params;
    var info = req.body;
    var node = params.node;
    var child = params.child;

    firebaseDriver.update(node,child,info,function(callback){
      if (callback) {res.status(201).send(callback)}
      else (res.status(400).send(callback));
    });
});

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});
