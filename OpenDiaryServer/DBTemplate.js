
var mysql 	 = require('mysql');
var util 	 = require('util');

function DBTemplate(){
	var outerThis = this;
	this.client = mysql.createClient({
		host : "dasan.skku.edu",
	    user : 'inmunskku',
	    password : '1278'
	});
	this.client.query('USE inmunskku', function(error, results){
	    if(error) {
	        console.log("database connect error: " + error);
	        return;
	    }
	    console.log("database Connected");
	});
}

DBTemplate.prototype.insertTemplate = function(query,values,callback){
	(function(client){
	   	client.query(query, values,
	   			function(error, results){
	    			if(error) {
	    	            console.log("database insert fail " + error);
	    	            client.end();
	    	            return;
	    	        }
	    	        console.log("inserted_id", results.insertId);
	    	        if(callback)
	    	        	callback();
	    	    });
	})(this.client);
};
DBTemplate.prototype.insertFeeling = function(data){
	console.log("insertFeeling");
	this.insertTemplate("INSERT INTO DIARY_FEELING SET TARGET_DATE = ?, FEELING=?",[data.TARGET_DATE,data.FEELING],function(){console.log("feeling inserted")});
};
DBTemplate.prototype.insertEvent = function(event){
	console.log("insertEvent");
	this.insertTemplate("INSERT INTO DIARY_EVENT SET TARGET_DATE = ?, WRITTER=?, TEXT=?",
						[event.TARGET_DATE,event.WRITTER,event.TEXT],
						function(){ console.log("event inserted")});
};
DBTemplate.prototype.getAllDaysEvent = function(callback){
	(function(client){
		var strQuery = "SELECT * FROM DIARY_EVENT ORDER BY TARGET_DATE"
		client.query(strQuery,
			function(error, results, fields) {
				if (error) {
					console.log("database error : " , error);
					client.end();
					return;
				}
				callback(results);
			});
	})(this.client);
};
DBTemplate.prototype.getAllDaysFeeling = function(callback){
	(function(client){
		var strQuery = " SELECT TARGET_DATE AS TARGET_DATE, AVG(FEELING) AS FEELING " + 
					   " FROM DIARY_FEELING " + 
					   " GROUP BY TARGET_DATE ORDER BY TARGET_DATE ";
		client.query(strQuery,
			function(error, results, fields) {
				if (error) {
					console.log("데이터베이스 조회 실패: " , error);
					client.end();
					return;
				}
				console.log(util.inspect(results));

				callback(results);
			});
	})(this.client);
};
DBTemplate.prototype.getDaysFeeling = function(date,callback){
	(function(client){
		var strQuery = "SELECT TARGET_DATE AS TARGET_DATE, AVG(FEELING) AS FEELING" + 
		" FROM DIARY_FEELING " + 
		" WHERE TARGET_DATE = ? " + 
		" GROUP BY TARGET_DATE";
		var values = [date];
		client.query(strQuery,values,
			function(error, results, fields) {
				if (error) {
					console.log("데이터베이스 조회 실패: " , error);
					client.end();
					return;
				}
				console.log(util.inspect(results));

				if (results.length > 0) {
					var firstResult = results[0];
					callback(firstResult);
				}
			});
	})(this.client);
};
module.exports = DBTemplate;
