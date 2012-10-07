
require("./networkValues.js");

var app  = require('http').createServer(handler);
var io   = require('socket.io').listen(app);
var fs   = require('fs');
var path = require("path");
var url  = require("url");
app.listen(process.env.PORT || 8001);

function handler(request, response) {
	var uri = url.parse(request.url).pathname;
	var filename = path.join(process.cwd(), uri);

	path.exists(filename, function(exists) {
		if (!exists) {
			response.writeHead(404, {
				"Content-Type" : "text/plain"
			});
			response.write("404 Not Found\n");
			response.end();
			return;
		}

		if (fs.statSync(filename).isDirectory())
			filename += '/index.html';

		fs.readFile(filename, "binary", function(err, file) {
			if (err) {
				response.writeHead(500, {
					"Content-Type" : "text/plain"
				});
				response.write(err + "\n");
				response.end();
				return;
			}

			response.writeHead(200);
			response.write(file, "binary");
			response.end();
		});
	});
	/*
	fs.readFile('index.html', function(err, data) {
		if (err) {
			res.writeHead(500);
			return res.end('Error loading index.html');
		}
		res.writeHead(200, {
			'Content-Type' : 'text/html',
			"Content-Length" : data.length
		});
		res.end(data);
	});
	*/
}

function Client(socket)
{
    this.id = socket.id;
}

function Room(roomName)
{
	this.name = roomName;
	this.state = "none";
	this.getClients = function(){
		return io.sockets.clients(this.name);
	};
	this.getClientsCount = function(){
		return io.sockets.clients(this.name).length;
	};
	this.getReadyClientCount = function(){
		var count = 0;
		var clientList = this.getClients();
		for(var key in clientList)
		{
			if(clientList[key].gameReady)
			{
				count++;
			}
		}
		return count;
	};
	
	this.getClientsNameList = function(){
		var nameList = [];
		var clientList = this.getClients();
		for(var key in clientList){
			if(clientList[key].userName){
				nameList.push(clientList[key].userName);
			}
		}
		return nameList;
	};
	
	this.toJSON = function(){
		return {
			name 		 : this.name,
			state		 : this.state,
			clients		 : this.getClientsNameList(),
			clientsCount : this.getClientsCount(),
		};
	};
}

function ClientManager()
{
    var outerThis = this;
    this.roomList = {
    		room1 : new Room("room1"),
    		room2 : new Room("room2"),
    		room3 : new Room("room3")
    };
    
    this.getUserList = function(){
    	var userList = [];
    	for(var socketId in io.sockets.sockets)
    	{
    		var socket = io.sockets.sockets[socketId];
    		if(!socket.disconnected && socket.userName)
    			userList.push(socket.userName);
    	}
    	return userList;
    };
    this.getRoomList = function(){
    	var rooms = [];
    	for(var index in this.roomList)
    	{
    		rooms.push(this.roomList[index].toJSON());
       	}
    	return rooms;
    };
    
    this.onClientConnected = function(socket)
    {
        socket.on('message', function (data) {
            console.info(data);
            socket.send("[ECHO] "+data);
        });
        
        socket.on('disconnect', function () {
        	//사용자가 방에 있었던 경우 
        	if(socket.roomName)
        	{
        		var room = outerThis.roomList[socket.roomName];
        		//일단 브로드캐스트로 나갔다는 사실을 전송
        		/*
        		socket.broadcast.to(socket.roomName).emit("currentRoomInfo",{
    				room : room.toJSON()
    			});
    			*/
        		//게임중이였던 경우
        		if(room.state == "play")
        		{
        			socket.leave(socket.roomName);
        			
        			var roomClients = room.getClients();
        			
        			//레디를 푼다.
        			for(var key in roomClients)
        			{
        				delete roomClients[key].gameReady;
        			}
        			
        			socket.broadcast.to(socket.roomName).emit("gameTerminated",{
        				reason 	 : GameTerminateReason.USER_QUIT, //플레이어중 하나가 나감
        				userName : socket.userName, //나간사람
        				room 	 : room.toJSON()
        			});
        			room.state = "none";
        		}
        		else //게임중이 아니였던 경우
        		{
        			
        		}
        	}
        	else //로비에 있었던 경우
        	{
        		console.log(socket);
        		//사용자가 없어진 상태로 전송
        		io.sockets.emit("userList",outerThis.getUserList());
        	}
        });
        
        socket.on("login",function(data){

            socket.userName = data.name;
            socket.emit("login result",{
            	result : "success",
            	userName : data.name
            });
            socket.emit("roomList",outerThis.getRoomList());
            io.sockets.emit("userList",outerThis.getUserList());
        	//Send public userList;
        });
        
        socket.on('userList',function(){
            socket.emit("userList",outerThis.getUserList());
        });
        
        socket.on("roomList",function(){
        	socket.emit("roomList",outerThis.getRoomList());
        });
        socket.on("roomCreate",function(data){
        	var roomName = data.roomName;
        	if(outerThis.roomList[roomName])
        	{
        		socket.emit("roomCreate Result",{result:"fail",reason:"room already exist"});
        	}
        	else
        	{
        		socket.join(roomName);
        		outerThis.roomList[roomName] = new Room(roomName);
        		io.sockets.emit("roomList",outerThis.getRoomList());
        	}
        });
        
        socket.on("joinRoom",function(data){
        	var room = outerThis.roomList[data.roomName];
        	if(room)
        	{
        		if(room.getClientsCount() < 3)
        		{
        			socket.join(data.roomName);
        			
        			socket.roomName = data.roomName;
        			
        			socket.emit("joinRoom result",{
            			result : "success",
            			room : room.toJSON()
            		});
        			socket.broadcast.to(data.roomName).emit("currentRoomInfo",{
        				room : room.toJSON()
        			});
        		}
        		else{
        			socket.emit("joinRoom result",{
            			result : "fail",
            			reason : "room is full"
            		});
        		}
        	}
        	else
        	{
        		socket.emit("joinRoom result",{
        			result : "fail",
        			reason : "not exist room"
        		});
        	}
        });
        
        socket.on("startGame",function(){
        	var result = {result:"fail",reason:"unknown"};
        	if(socket.roomName)
        	{
        		var room = outerThis.roomList[socket.roomName];
        		socket.gameReady = true;
        		
        		var readyUserCount = room.getReadyClientCount();
        		console.log("ready : " +readyUserCount);
        		if(readyUserCount >= 3)
        		{
        			room.state = "play";
        			
        			result.result = "success";
        			result.room	  = room.toJSON();
        			
        			io.sockets.in(socket.roomName).emit("startGame result",result);
        			//socket.emit("startGame result",result);
        		}
        		else 
        		{
        			result.result = "success";
        			result.room	  = room.toJSON();
        			socket.emit("startGame result",result);
        		}
        	}
        	else
        	{
        		result.reason = "not in room";
        		socket.emit("startGame result",result);
        	}
        });
		socket.on("answerChanged",function(data){
			console.log(socket.userName + " : "+data.answer);
			socket.broadcast.to(socket.roomName).emit("otherUserAnswerChanged",{
				userName : socket.userName,
				answer	 : data.answer
			});
		});
		socket.on("roomChatingMessage",function(data){
			socket.broadcast.to(socket.roomName).emit("roomChatingMessage",data);
		});
        socket.on("lobbyChatingMessage",function(data){
        	socket.broadcast.emit("lobbyChatingMessage",data);
        });
        socket.on("quitRoom",function(){
        	var roomName = socket.roomName;
        	
        	if(roomName)
        	{
        		var room = outerThis.roomList[roomName];
        		if(room)
        		{
        			socket.leave(roomName);	
        			socket.broadcast.to(roomName).emit("currentRoomInfo",{
        				room : room.toJSON()
        			});
        			delete socket.roomName;
        			
            		socket.emit("quitRoom result",{result:"success"});
        		}
        		else{
            		socket.emit("quitRoom result",{result:"fail",reason:"room not exist"});
        		}
        	}
        	else{
        		socket.emit("quitRoom result",{result:"fail",reason:"not in room"});
        	}
        });
    };
}
var clientManager = new ClientManager();

//On ListenSocket Received Connection;
io.sockets.on('connection', function (socket) {
    clientManager.onClientConnected(socket);
});