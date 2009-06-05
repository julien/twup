package  {
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.EventDispatcher;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	
	import mx.events.DynamicEvent;

	[Event(name="error", type="mx.events.DynamicEvent")]
	[Event(name="result", type="mx.events.DynamicEvent")]

	public class CredentialsManager extends EventDispatcher {

		protected var connection:SQLConnection;

		public function open(reference:Object):void {
			connection.openAsync(reference);
		}

		public function getData():void {
			var s:SQLStatement = new SQLStatement();
			s.sqlConnection = connection;
			s.addEventListener(SQLErrorEvent.ERROR, sqlErrorHandler);
			s.addEventListener(SQLEvent.RESULT, getDataResultHandler);
			s.text = "SELECT * FROM credentials";
			s.execute();
		}

		public function insert(username:String, password:String):void {
			var s:SQLStatement = new SQLStatement();
			s.sqlConnection = connection;
			s.addEventListener(SQLErrorEvent.ERROR, sqlErrorHandler);
			s.addEventListener(SQLEvent.RESULT, insertResultHandler);
			s.text = "INSERT INTO credentials VALUES( NULL, " +
					":username, :password)";
			s.parameters[":username"] = username;
			s.parameters[":password"] = password;
			s.execute();
		}

		public function destroy(id:int):void {
			var s:SQLStatement = new SQLStatement();
			s.sqlConnection = connection;
			s.addEventListener(SQLErrorEvent.ERROR, sqlErrorHandler);
			s.addEventListener(SQLEvent.RESULT, destroyResultHandler);
			s.text = "DELETE FROM credentials WHERE ID = :id";
			s.parameters[":id"] = id;
			s.execute();
		}

		public function update(id:int, username:String, password:String):void {
			var s:SQLStatement = new SQLStatement();
			s.sqlConnection = connection;
			s.addEventListener(SQLErrorEvent.ERROR, sqlErrorHandler);
			s.addEventListener(SQLEvent.RESULT, updateResultHandler);
			s.text = "UPDATE credentials SET " +
					"username = :username, password = :password " +
					"WHERE id = :id";
			s.parameters[":id"] = id;
			s.parameters[":username"] = username;
			s.parameters[":password"] = password;
			s.execute();
		}

		public function CredentialsManager() {
			initializeConnection();
		}

		protected function initializeConnection():void {
			connection = new SQLConnection();
			connection.addEventListener(SQLErrorEvent.ERROR, sqlErrorHandler);
			connection.addEventListener(SQLEvent.OPEN, openHandler);
		}

		protected function checkStructure():void {
			var s:SQLStatement = new SQLStatement();
			s.sqlConnection = connection;
			s.addEventListener(SQLErrorEvent.ERROR, sqlErrorHandler);
			s.addEventListener(SQLEvent.RESULT, checkStructureResultHandler);
			s.text = "CREATE TABLE IF NOT EXISTS credentials (" +
					"id INTEGER PRIMARY KEY AUTOINCREMENT, " +
					"username VARCHAR(255) NULL, " +
					"password VARCHAR(255) NOT NULL, " +
					"UNIQUE(username))";
			s.execute();
		}

		protected function sqlErrorHandler(event:SQLErrorEvent):void {
			var e:DynamicEvent = new DynamicEvent("error");
			e.data = event.error;
			dispatchEvent(e);
		}

		protected function openHandler(event:SQLEvent):void {
			checkStructure();
		}

		protected function checkStructureResultHandler(event:SQLEvent):void {
			var s:SQLStatement = event.currentTarget as SQLStatement;
			var r:SQLResult = s.getResult();
			getData();
		}

		protected function getDataResultHandler(event:SQLEvent):void {
			var s:SQLStatement = event.currentTarget as SQLStatement;
			var r:SQLResult = s.getResult();
			var a:Array = r.data;
			
			var e:DynamicEvent = new DynamicEvent("result");
			if(a != null && a.length > 0) {
				var c:Credentials = new Credentials();
				c.username = a[0]['username'];
				c.password = a[0]['password'];
				e.data = c;
			} 
			dispatchEvent(e);
		}

		protected function insertResultHandler(event:SQLEvent):void {
			var s:SQLStatement = event.currentTarget as SQLStatement;
			var r:SQLResult = s.getResult();
			getData();
		}

		protected function destroyResultHandler(event:SQLEvent):void {
			var s:SQLStatement = event.currentTarget as SQLStatement;
			var r:SQLResult = s.getResult();
			getData();
		}

		protected function updateResultHandler(event:SQLEvent):void {
			var s:SQLStatement = event.currentTarget as SQLStatement;
			var r:SQLResult = s.getResult();
			getData();
		}
	}
}
