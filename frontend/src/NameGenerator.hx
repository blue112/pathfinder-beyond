class NameGenerator {
	static final STARTS = ["Ar", "Bel", "Cor", "Dal", "Eld", "Fae", "Gar", "Hal", "Jor", "Kel", "Lor", "Mar", "Nar", "Or", "Ran", "Sel", "Tor", "Val", "Zar"];
	static final MIDS = ["", "", "an", "en", "ar", "al", "el", "il", "or"];
	static final ENDS = ["ath", "eth", "on", "en", "el", "iel", "ir", "or", "as", "is", "ia", "ora", "ius", "us"];

	static function pick(arr:Array<String>):String {
		return arr[Std.random(arr.length)];
	}

	static public function characterName():String {
		return pick(STARTS) + pick(MIDS) + pick(ENDS);
	}
}
