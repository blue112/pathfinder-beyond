import js.lib.Promise;

@:jsRequire("mysql2/promise")
extern class Mysql {
	static public function createConnection(params:{
		host:String,
		user:String,
		database:String,
		password:String
	}):Promise<Mysql>;

	public function execute(query:String, ?params:Array<Dynamic>):Promise<Array<Dynamic>>;
}
