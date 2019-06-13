var elasticsearch = require('elasticsearch');
    http = require('http'),
    express = require('express'),
    bodyParser = require('body-parser'),
    mongodb = require('mongodb'),
    USERSMONGO_COLLECTION = 'users',
    REPORTMONGO_COLLECTION = 'reports',
    objectID = mongodb.ObjectID
    
var db;

var app = express();
app.use(bodyParser.json());

var client = new elasticsearch.Client({
    host: 'search-cohesive-elastic-xu6m7b5siaw4emqigrpktxjrfq.us-west-2.es.amazonaws.com'
});
console.log('Connected ELASTICSEARCH Succesfully');

mongodb.MongoClient.connect('mongodb://admin:Serrano1994@ds143717.mlab.com:43717/cohesive', function(error,database){
    if (error) {
        console.error(error);
        process.exit(1);
    }

    db = database;
    console.log('Connected MONGODB Succesfully');

   var server = app.listen(process.env.PORT || 3000,function() {
       var port = server.address().port;
       console.log('Server up and running on port', port);
   });
});

app.get('/:a?/:b?', function(req,res){
  
    var param = req.params;
    var search = req.body.search;

    switch(param.a) {
        case 'user':
            getUser(param.b,USERSMONGO_COLLECTION,function(bool,user){
                switch (bool) {
                    case Error:
                        errorHandler(res,bool.message,"Failed to check for existance of username")
                        break;
                    case false:
                        errorHandler(res,'User does not exists','Cant fetch non-existen user');
                        break;
                    case true:
                        res.status(201).json(user);
                        console.log(user);
                        break;
                };
            })
            break;
        default:
            res.send('<html><body><h1>Hello, everything is ready...(.15)</h1></body></html>');
    }

});


app.post('/:a?', function(req,res) {

    var param = req.params.a;
    var body = req.body;
    var skillsToAnalyze = body.SkillOne + ' ' + body.SkillTwo + ' ' + body.SkillThree

    switch(param) {
        case 'user':
            generateId(12,function(id) {
                indiceAnalysis(skillsToAnalyze,'registration','skill_analyzer',function(err,tokens) {
                    if (err) { errorHandler(res,err.message, 'Failed to analyze skills');}
                    else {
                        registerMongo(USERSMONGO_COLLECTION,body,tokens,new objectID(id),function(err,id){
                            if(err) {
                                res.status(500).json({'Failure':err.message});
                                return;
                            } else {
                                registerElasticSearch(tokens, id, body.username, function(err,tokens){
                                    if(err) {errorHandler(res,err.message, 'Failed to register user in Elastic Search');}
                                    else {
                                        res.status(201).json({'Success': 'Registered user Succesfully'});
                                    }
                                })
                            }
                        })
                    }
                })
            })
            break;
        case 'search':
            search(body.search,body.username,function(err,response){
                if(err) errorHandler(res,err.message,'Failed to fetch any matches'); 
                else {
                    res.status(201).json(response);            
                }
            });
            break;
        case 'report':
        reportMongo(REPORTMONGO_COLLECTION,body,function(err,response){
            if(err) {
                errorHandler(res,err.message, 'Failed to register Report in Mongo');
            } else {
                res.status(201).json({'Success':'Sent report Succesfully'});
            }
        });
            break;
    };
});

app.put('/:a?',function(req,res){

    var param = req.params.a;
    var body = req.body;
    var skillsToAnalyze = body.SkillOne + ' ' + body.SkillTwo + ' ' + body.SkillThree

    switch (param) {
        case 'userUpd':
            updateSkillsElastic(skillsToAnalyze,body.username,function(err,tokens){
                if(err) { errorHandler(res,'Something went wrong','Couldnt update skills (ElasticSearch)');}
                else {
                    updateSkills(USERSMONGO_COLLECTION,body.username,body,tokens,function(err,response){
                        if(err) {errorHandler(res,err.message,'Failed to update skills');}
                        else {
                            res.status(201).json({'Success':'Updated skills Succesfully'});
                            console.log('Updated skills Succesfully');
                        } 
                    })
                 }
            });
            break;
        case 'userUpdPhoto':
        updatePhoto(USERSMONGO_COLLECTION,body.username,body,function(err,response){
            if(err){
                errorHandler(res,err.message,"Failed to update photo path");
            } else {
                res.status(201).json("Updated photo path succesfully");
            }
        })
    }
})

//MONGODB Functions
//Check for user existance && get user credentials
function getUser(username, collection,callback){
    db.collection(collection).findOne({username: username}, function(err,doc){
        if (err) callback(err);
        if(doc === null) { 
            callback(false);
        } else {
            callback(true,doc);
        }
    })
}

function getUserById(id,queryUsername, collection,callback){
    var mongoId = new objectID(id);
    
    db.collection(collection).findOne({_id: mongoId}, function(err,doc){
        if (err) {callback(true);}
        if(doc === null) { 
            callback(true);
        } else {
            if (doc["username"] === queryUsername) {
                callback(true);
            } else {
                callback(false,doc);
            }
        }
    })
}

//Report Mongo
function reportMongo(collection,report,callback) {
    db.collection(collection).insertOne(report, function(error,doc){
        if (error) {callback(error)}
        else {callback(null);}
    });
}

//Insert user to mongodb at registration
function registerMongo(collection,user,elasticSkills,id,callback) {
    user['SkillsElastic'] = elasticSkills;
    user['_id'] = id;
    db.collection(collection).insertOne(user, function(error,doc){
        if (error) {callback(error)}
        else {callback(null,id);}
    });
}

//Update skills mongo
function updateSkills(collection,username,doc,elasticSkills,callback){
    doc['SkillsElastic'] = elasticSkills
    db.collection(collection).updateOne(
        {username: username},
        {$set: doc},
        function(err,response){
            if(err) callback(err);
            callback(null,response);
        }
    )
}

//Update photo
function updatePhoto(collection,username,doc,callback){
    db.collection(collection).updateOne(
        {username: username},
        {$set: doc},
        function(err,response){
            if(err) callback(err);
            callback(null,response);
        }
    )
}

//ELASTIC Functions
//Update user skills
function updateSkillsElastic(skills,username,callback) {
    indiceAnalysis(skills,'registration','skill_analyzer',function(err,tokens) {
        if (err) {callback(err);}
        else {
            getUser(username,USERSMONGO_COLLECTION,function(err,response){
                
                var old = response.SkillsElastic;
                var newobj = tokens;
                var forUpdate = [];
                var deleteHelp = [];
                var objs = [];
                var update = [];
                var deleteA = [];
                var userId = response._id;
            
                if(!err) {callback(err);}
                else {
                    for(var i=0;i<old.length;i++){
                        if(!contains(newobj,old[i])){
                            deleteHelp.push(old[i]);
                        }
                    }
                    for(var i=0;i<newobj.length;i++){
                        if(!contains(old,newobj[i])){
                            forUpdate.push(newobj[i]);
                        }
                    }
                    for(var i=0;i<forUpdate.length;i++){
                        update.push({index: {_index: forUpdate[i], _type: 'user', _id: userId}});
                        update.push({'search': '', 'id': userId})
                    }
                    for(var i=0;i<deleteHelp.length;i++){
                        deleteA.push({delete: {_index: deleteHelp[i], _type: 'user', _id: userId}});
                    }

                    //Combine both arrays
                    objs = update.concat(deleteA);

                    client.bulk({
                        body: objs
                    },function(err,response){
                        if (!err){
                            console.log(response);
                            callback(null,tokens);
                        } else {
                            callback(err);
                            }
                        })                    
                    }
              })
          }
    })
};

//Update search
function updateSearch(search,username,callback) {
    var objs = [];
    getUser(username,USERSMONGO_COLLECTION,function(err,resp){
        if (!err) callback(new Error());
        else {
        syncLoop(resp.SkillsElastic.length,function(loop){
            var i = loop.iterations();

            objs.push({update: {_id: resp._id, _type: 'user', _index: resp.SkillsElastic[i]}});
            objs.push({doc: {search: search, id: resp._id}});

            loop.next();
        },function(){
            client.bulk({
                body: objs
            },function(err,response){
                if(!err){
                    callback(null,resp.SkillsElastic);
                } else {
                    callback(err);
                      }
                  })
             }) 
         }       
    })
};

function search(search,username,callback) {

    var indicesToSearch = [];
    indiceAnalysis(search,'search','search_analyzer',function(err,response) {
        if(err) callback(err);
        else {
        indiceExist(response,function(err,bits){
            if(!err){
                syncLoop(bits.length,function(loop){
                    var i = loop.iterations();
                    if(bits[i] == 1) {
                        indicesToSearch.push(response[i]);
                    }
                    loop.next();
                },function() {
                    updateSearch(search,username,function(err,response){
                        if(err) callback(err);
                            searchElastic(indicesToSearch,response.toString(),function(err,buckets){
                                var usersJson = [];
                                if (err) callback(err);
                                syncLoop(buckets.length,function(loop){ 
                                    var i = loop.iterations();
                                    console.log('This are my matches ' + buckets[i].key);
                                    getUserById(buckets[i].key,username,USERSMONGO_COLLECTION,function(err,doc){
                                        if(err) { 
                                            if(i === buckets.length) {
                                                callback(new Error());
                                            } else {
                                                loop.next();
                                            } 
                                        } else {
                                            usersJson.push(doc);
                                            loop.next();
                                        }
                                    })
                                },function(){
                                    console.log(usersJson);
                                    callback(null,usersJson);
                                })
                         });
                    });
                });
            } else {
                callback(err);
                }
            })
         }
    })
};

function searchElastic(indices,skills,callback){
    
    client.search({
    index: indices,
    explain: true,
        body: {
        "query": {
            "match": {
            "search": {
                "query": skills,
                "operator": "or",
                "fuzziness": "auto"
                }
            }
        }, 
        "aggs": {
            "sample": {
            "sampler": {
                "shard_size": 50
            },
            "aggs": {
                "id_aggregation": {
                "terms": {
                    "field": "id",
                    "size": 50,
                    "collect_mode": "breadth_first"
                            }
                        }
                    }
                }
            }
        }
    }, function(err,response){
        if (!err) {
            callback(null,response.aggregations.sample.id_aggregation.buckets);
        } else {
            callback(err);
        }
    });
}

//registration

function registerElasticSearch(tokens, id, username, callback) {
    indiceExist(tokens,function(error,bits) {
        if(!error) {
            syncLoop(bits.length,function(loop){
                var i = loop.iterations();
                if (bits[i] == 0) {
                    createIndex(tokens[i],function(err,response){
                        if(!err){
                            loop.next();
                        } else {
                            //send 404
                            callback(new Error());
                            loop.break(true);
                            
                        }
                    })
                } else {
                    loop.next();
                }
            }, function() {
                createEntries(tokens,"", id, function(err,response){
                    if(!err){
                        //send 201
                        callback(null,tokens);
                    } else {
                        //send 404
                        callback(err);
                    }
                })
            })
        }
    })
}
    


function indiceAnalysis (skills,index,analyzer,callback) {
    var tokenArray = [];
    client.indices.analyze({
        index: index,
        analyzer: analyzer,
        text: skills
    },function(error,resp){
        if (!error){
            for(var i=0;i<resp.tokens.length;i++){
               tokenArray.push(resp.tokens[i].token);
            }
        } else {
            //send 404
            callback(error);
        }
        callback(null,tokenArray);
    })
}

function indiceExist(tokens,callback) {
    var bits = [];
    syncLoop(tokens.length, function(loop){
        var i = loop.iterations();
        client.indices.exists({
            index: tokens[i]
        }, function(err,response){
            if (!err){
                if (response === false) {
                    bits.push("0");
                } else {
                    bits.push("1");
                } 
                loop.next();
            }
        })
    }, function() { 
        callback(false,bits);
    })
}

  function createIndex(index,callback) {
    client.indices.create({
                index: index,
                body: {
                "settings": {
                    "analysis": {
                        "analyzer": {
                            "search_analyzer": {
                            "type": "custom",
                                "tokenizer": "punctuation",
                                "filter":  ["lowercase","apostrophe","asciifolding","stop_analyzer","kstem"]
                            }
                        },
                        "tokenizer": {
                            "punctuation": {
                                "type": "pattern",
                                "pattern": "[ .,!?+&@=-]"
                            }
                        },
                        "filter": {
                            "stop_analyzer": {
                                "type": "stop"
                            }
                        }
                    }
                },
                "mappings": {
                        "users": {
                            "properties": {
                                "skills": {
                                    "type": "string",
                                    "analyzer": "search_analyzer",
                                    "norms": { "enabled": false }
                                },
                                "id": {
                                    "type": "string",
                                    "norms": { "enabled": false },
                                    "index": "not_analyzed"
                                }
                            }
                        }
                    }
                }
            }, function(err,result){
                if (!err) {
                    callback(false,result);
                } else {
                    callback(true);
                }
        });
};

function createEntries(entries,search,id,callback) {
    var objs = [];
    //change id for ids from mongo
    for(var i=0;i<entries.length;i++){
        objs.push({index: {_index: entries[i], _type: 'user', _id: id}});
        objs.push({'search': search, 'id': id})
    }
    client.bulk({
        body: objs
    },function(err,response){
        if (!err){
            callback(false,response);
        } else {
            callback(true);
        }
    })
};



//Helper Functions
function syncLoop(iterations, process, exit) {
    var index = 0,
        done = false,
        shouldExit = false;
    var loop = {
        next:function() {
            if(done) {
                if(shouldExit && exit){
                    return exit();
                }
            }
            if (index < iterations){
                index++;
                process(loop);
            } else {
                done = true;
                if(exit) exit();
            }
        },
        iterations:function(){
            return index - 1;
        },
        break:function(end){
            done = true;
            shouldExit = end;
        }
    };
    loop.next();
};

function errorHandler(res,reason,message,code) {
    console.log('ERROR : ' + reason);
    res.status(code || 500).json({'error':message});
};

function diff(a1, a2) {
  return a1.concat(a2).filter(function(val, index, arr){
    return arr.indexOf(val) === arr.lastIndexOf(val);
  });
}

function contains(a,obj){
    for(var i=0;i<a.length;i++){
        if(a[i] === obj){
            return true;
        }
    }
    return false;
}

Array.prototype.remove = function (v){
    if(this.indexOf(v) != -1){
        this.splice(this.indexOf(v),1);
        return true;
    }
    return false;
}

function generateId(count,k){
    var _sym = 'abcdefghijklmnopqrstuvwxyz1234567890';
    var str = '';

    for(var i=0;i<count;i++){
        str += _sym[parseInt(Math.random() * (_sym.length))];
    }
    
    return k(str);
};

function mapSkills(skills,callback){
    var str = '';
    for(var i=0;i<skills.length;i++){
        str += Object.values(skills[i]) + ',';
    }
    return callback(str);
}

function getByteLen(normal_val) {
    // Force string type
    normal_val = String(normal_val);

    var byteLen = 0;
    for (var i = 0; i < normal_val.length; i++) {
        var c = normal_val.charCodeAt(i);
        byteLen += c < (1 <<  7) ? 1 :
                   c < (1 << 11) ? 2 :
                   c < (1 << 16) ? 3 :
                   c < (1 << 21) ? 4 :
                   c < (1 << 26) ? 5 :
                   c < (1 << 31) ? 6 : Number.NaN;
    }
    return byteLen;
}
