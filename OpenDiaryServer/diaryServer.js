var http 	 = require('http');
var express  = require('express');
var app      = express();
var socketIO = require('socket.io');
var io 		 = null;
var fs   	 = require('fs');
var path 	 = require("path");
var url  	 = require("url");
var net  	 = require("net");
var async    = require('async');
var vm 		 = require('vm');
var facebook = require('facebook-graph');
var DBTemplate = require('./DBTemplate.js');

var includeInThisContext = function(path) {
    var code = fs.readFileSync(path);
    vm.runInThisContext(code, path);
}.bind(this);
includeInThisContext(__dirname+"/macro.js");

function TodaysString() {return (new Date()).format("yyyy-MM-dd");}
function StringToDayString(str) {return (new Date(str)).format("yyyy-MM-dd");}

function initExpressEndSocketIO(){
	app.configure(function() {
		app.set('views', __dirname + '/views');
		app.set('view options', { layout: false });
		app.use(express.methodOverride());
		app.use(express.bodyParser());
		app.use(express.static(__dirname + '/resources'));
		app.use(app.router);
	});
	app.configure('production', function() {
	    app.use(express.logger());
	    app.use(express.errorHandler());      
	});
	app.configure('development', function() {
	    app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
	});
	app.get('/', function(req, res) {
	    res.render('index.html', {});      
	});
	app = http.createServer(app).listen(8001);
	io = socketIO.listen(app);
}




var facebookGraph;
function initFacebook(){
	var accessToken = "AAAFLChojodkBAKCmfxAVPdvFiLyX0YwjNzYm20ZB6UhfICz1leT4dvO9UOfi5IZAoIjVbRvlARU9sSh1lZBZAxAFpp0ODN240I3znmsjLZAYut9hxZBJHHDpjjE3JZBZABYZD";
	facebookGraph = new facebook.GraphAPI(accessToken);
//	facebookGraph.putObject("230449603747777","feed",{message: 'The computerz iz writing on my wallz!1'}, print);
}
function writeMessageToPage(message){
	
	function print(error, data) {
       	 console.log(error || data);
    }
	facebookGraph.putObject("230449603747777","feed",{message : message}, print);
}
initFacebook();





var dbTemplate = new DBTemplate();
initExpressEndSocketIO();

var viewClients = [];
net.createServer(function(socket) {
	console.log("Connected!!!!!");
	viewClients.push(socket);
	dbTemplate.getAllDaysFeeling(function(feelingArray){
		console.log(feelingArray);
		dbTemplate.getAllDaysEvent(function(eventArray){
			calendarInfo = {};
			feelingArray.forEach(function(day){ 
				day.TARGET_DATE = StringToDayString(day.TARGET_DATE);
				calendarInfo[day.TARGET_DATE] = day;
				delete calendarInfo[day.TARGET_DATE].TARGET_DATE;
			});		
			eventArray.forEach(function(event){ 
				event.TARGET_DATE = StringToDayString(event.TARGET_DATE);
				if( ! calendarInfo[event.TARGET_DATE] )
					calendarInfo[event.TARGET_DATE] = {};
				if( ! calendarInfo[event.TARGET_DATE].EVENTS)
					calendarInfo[event.TARGET_DATE].EVENTS = new Array();
				calendarInfo[event.TARGET_DATE].EVENTS.push(event);
			});	
			socket.write(JSON.stringify({
				type : "allCalendar",	
				data : calendarInfo
			})+"\r\n");
			socket.write( JSON.stringify({type:"patternKeyChanged",data : {PATTERN:getControlPassword()}}) +"\r\n" );
		});
	});
	socket.on("end", function() {
		viewClients.remove(socket);
	});
	socket.on("data", function(data) {
		console.log("tcp : "+data);
	});
}).listen(7777, "0.0.0.0");
console.log("listen TCP on 7777")


var diaryUsingTimeout = 60000;
var currentDiaryUser  = null;
var waitingQueue 	  = [];
var diaryEndTimeoutID = null;
var g_controlPassword;

function changeControlPassword() {
	var patternContainer = [
		[1,2,5,6],
		[5,6,9,3,2,1],
		[4,8,6,5,2,1],
		[8,5,7,9],
		[1,5,6,8,2,3],
		[5,2,3,6,4,1],
		[7,2,9,6,3,1],
		[6,1,4,8,3,2,5]
	];
	
	g_controlPassword = patternContainer[ Math.floor(Math.random() * patternContainer.length) ];
	console.log("new password : ",g_controlPassword);
	viewClients.forEach(function(client) {
	    client.write( JSON.stringify({type:"patternKeyChanged",data : {PATTERN:g_controlPassword}}) + "\r\n");
	});	
}
changeControlPassword();

function getControlPassword(){ 
	return g_controlPassword;
}


var stopUsingDiary;
function startUsingDiary(socket){
	currentDiaryUser = socket;
	console.log("strat Using Controll " ,socket.id,currentDiaryUser.id);
	
	stopUsingDiary = function(){
		clearTimeout(diaryEndTimeoutID);
	
		socket.emit("controlEnd",{});
		currentDiaryUser = waitingQueue.shift();
		viewClients.forEach(function(client) {
	    	client.write( JSON.stringify({type:"controllEnd"}) +"\r\n");
	    });
	};
	
	diaryEndTimeoutID = setTimeout(function(){stopUsingDiary();},diaryUsingTimeout);
}


io.sockets.on('connection', function (socket) {
	socket.on('message', function (data) {
        console.info(data);
       // socket.send("[ECHO] ",data);
    });
	socket.on('disconnect', function () {
	   	if(socket == currentDiaryUser){
		   	//diaryEndTimeoutID를 취소
		   	currentDiaryUser = waitingQueue.shift();
		   	viewClients.forEach(function(client) {
	    		client.write( JSON.stringify({type:"controllEnd"}) +"\r\n");
	    	});
	   	}
	});
	socket.on("useDiary",function(){
		//대기중인 사람이 아무도 없는경우
		if(waitingQueue.length <= 0){
			startUsingDiary(socket);
		}
		else{
			waitingQueue.push(socket);
		}
	});
	socket.on("deviceMotion",function(data){
	    //모든 클라이언트 들에게 디바이스 모션 정보를 전송
		viewClients.forEach(function(client) {
			client.write(JSON.stringify(data));
	   	});
	});
	
	socket.on("showMonth",function(data){
		console.log(data);
		if(socket == currentDiaryUser){
			console.log("SENDING MONTH");
			viewClients.forEach(function(client) {
	    		client.write( JSON.stringify({type:"showMonth",data : data})+ "\r\n");
	    	});	
		}
		else {
			console.log(socket , currentDiaryUser);
		}
	});
	socket.on("showDay",function(data){
		console.log(data);
		if(socket == currentDiaryUser){
			viewClients.forEach(function(client) {
	    		client.write( JSON.stringify({type:"showDay",data : data})+ "\r\n");
	    	});	
		}
		else {
		}
	});
	socket.on("showDate",function(data){
		console.log(data);
		if(socket == currentDiaryUser){
			viewClients.forEach(function(client) {
	    		client.write( JSON.stringify({type:"showDate",data : data})+ "\r\n");
	    	});	
		}
		else {
		
		}
	});
	socket.on("newFeeling",function(feeling){
		console.log("new Feeling : ",feeling);
		feeling.TARGET_DATE  = TodaysString(); //오늘 날짜를 삽입
	
		dbTemplate.insertFeeling(feeling);
		dbTemplate.getDaysFeeling( TodaysString() ,function(result){
			viewClients.forEach(function(client) {
				result.TARGET_DATE = StringToDayString(result.TARGET_DATE);
		   		feeling.AVG_FEELING = result.FEELING;
		   		client.write(JSON.stringify({
		   			type:"feelingUpdate",
		   			data : feeling
		   		}) + "\r\n");
	    	});	
		});
	});
	socket.on("newEvent",function(event){
		for(var key in event){
			console.log(event[key]);
		}
		event.TARGET_DATE = StringToDayString(event.TARGET_DATE);
		dbTemplate.insertEvent(event);
		viewClients.forEach(function(client) {
	    	client.write( JSON.stringify({type:"newEvent",data : event}) +"\r\n");
	    });
	    

	    setTimeout(function(){
			writeMessageToPage(event.TARGET_DATE + " : " + event.TEXT);
	    },1);
	});
	socket.on("startControl",function(data){
		console.log(data);
		if(JSON.stringify(getControlPassword()) == JSON.stringify(data.password))
		{
			socket.emit("controlSuccess",{});
			startUsingDiary(socket);
			viewClients.forEach(function(client) {
	    		client.write( JSON.stringify({type:"controllStart"}) + "\r\n");
	    	});
	    	changeControlPassword();
	    }
		else 
		{
			socket.emit("controlFail",{});
		}
	});
	socket.on("stopControl",function(){
		stopUsingDiary();
	});
});



