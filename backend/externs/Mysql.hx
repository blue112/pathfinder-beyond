import js.lib.Promise;

@:jsRequire("mysql2/promise")
extern class Mysql {
	static public function createPool(params:{
		connectionLimit:Int,
		host:String,
		user:String,
		database:String,
		password:String
	}):Mysql;

	public function execute(query:String, ?params:Array<Dynamic>):Promise<Array<Dynamic>>;
}
