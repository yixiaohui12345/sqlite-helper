package com.saumya.air 
{
	import flash.events.EventDispatcher;
	
	/**
	 * This is a helper class to run the SQLite commands
	 * 
	 * @author Saumya
	 * @version 1.0
	 */
	public class SQLiteHelper extends EventDispatcher
	{
		import flash.data.*;
		import flash.events.Event;
		import flash.events.SQLEvent;
		import flash.events.SQLUpdateEvent;
		import flash.events.SQLErrorEvent;
		import flash.events.ErrorEvent;
		import flash.filesystem.File;
		
		//Define Database Name
		private static var DB_NAME:String = '';
		//stores the event name
		public static const SQL_CONNECTION_EVENT:String = 'onSQLiteConnectionSuccessEvent';
		public static const SQL_RESULT_EVENT:String = 'onSQLiteQueryResultEvent';
		//stores the connection
		private var conn:SQLConnection = null;
		//stores the query result
		private var _sqlResult:SQLResult = null;
		
		/**
		 * Constructor takes a database string name as a parameter to initiate the object to start talking to the database
		 * @param	dataBaseName  String
		 */
		public function SQLiteHelper(dataBaseName:String='myDB') 
		{
			SQLiteHelper.DB_NAME = dataBaseName + '.db';
			this.initialiseDataBase();
		}
		
		private function initialiseDataBase():void {
			this.conn = new SQLConnection();
			this.conn.addEventListener(SQLEvent.OPEN, onOpenConnection);
			this.conn.addEventListener(SQLErrorEvent.ERROR, onQueryError);
			this.connectToDB();
		}
		
		private function onOpenConnection(e:SQLEvent):void 
		{
			trace(this, ' : onOpenConnection : ', e);
			//Dispatches event
			var sqlConnEvent:Event = new Event(SQLiteHelper.SQL_CONNECTION_EVENT, false, true);
			this.dispatchEvent(sqlConnEvent);
		}
		
		private function connectToDB():void {
			try {
				var dbFile:File = File.applicationDirectory.resolvePath(SQLiteHelper.DB_NAME);
				this.conn.openAsync(dbFile);
			}catch (er:Error) {
				trace(er);
			}
		}
		
		/**
		 * Takes database query as a String parameter and operates in the database
		 * @param	query  String
		 */
		public function runQuery(query:String):void 
		{
			var sqlStatement:SQLStatement = new SQLStatement();
			sqlStatement.sqlConnection = this.conn;
			sqlStatement.text = query;
			sqlStatement.addEventListener(SQLEvent.RESULT, onQueryResult);
			sqlStatement.addEventListener(SQLErrorEvent.ERROR, onQueryError);
			sqlStatement.execute();
		}
		
		private function onQueryError(e:SQLErrorEvent):void 
		{
			trace(' : ------------------------------------------------------ : ');
			trace(' : SQLiteHelper : ',e);
			trace(' : SQLiteHelper : ', e.error.message);
			trace(' : ------------------------------------------------------ : ');
		}
		
		private function onQueryResult(e:SQLEvent):void 
		{
			var sqlStatement:SQLStatement = SQLStatement(e.target);
			var queryResult:SQLResult = sqlStatement.getResult();
			//stores the result before dispatching the event
			this.sqlResult = queryResult;
			//Dispatches event
			var sqlResultEvent:Event = new Event(SQLiteHelper.SQL_RESULT_EVENT, false, true);
			this.dispatchEvent(sqlResultEvent);
		}
		
		/////////////////////////////////////GETTERS & SETTERS////////////////////////////////////////
		
		/**
		 * Result Object
		 */
		public function get sqlResult():SQLResult { return _sqlResult; }
		
		public function set sqlResult(value:SQLResult):void 
		{
			_sqlResult = value;
		}
		
	}
	
}