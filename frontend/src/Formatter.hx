class Formatter {
	public static function asMod(n:Int, ?withSpace:Bool) {
		if (n > 0)
			return if (withSpace) '+ $n' else '+$n';
		if (n < 0)
			return if (withSpace) '- ${- n}' else '$n';

		return if (withSpace) '+ 0' else '+0';
	}

	static public function dicerollToString(roll:PublicDiceRoll) {
		if (roll.mod != null && roll.mod != 0) {
			var mod = ' ${roll.mod.asMod(true)}';
			return '1d${roll.faces}$mod : (<strong>${roll.result}</strong>$mod) = <strong>${roll.result + roll.mod}</strong>';
		}

		return '1d${roll.faces} : <strong>${roll.result}</strong>';
	}
}
