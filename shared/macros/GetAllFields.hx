package macros;

import haxe.macro.Context;
import haxe.macro.Expr;

class GetAllFields {
	macro static public function getNames(e:Expr) {
		var type = switch (e.expr) {
			case EConst(CIdent(d)):
				var t = Context.getType(d);
				if (t == null) {
					Context.error("Unknown typedef " + e, Context.currentPos());
					return null;
				}
				t;
			default:
				Context.error("Unknown typedef " + e, Context.currentPos());
				return null;
		}
		var names = switch (type) {
			case TType(t, params):
				switch (t.get().type) {
					case TAnonymous(k):
						k.get().fields.map(n -> n.name);
					default:
						Context.error("Invalid typedef " + type, Context.currentPos());
						return null;
				}
			default:
				Context.error("Invalid typedef " + type, Context.currentPos());
				return null;
		}

		return macro $v{names};
	}
}
