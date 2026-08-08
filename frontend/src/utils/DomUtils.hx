package utils;

import js.html.DOMTokenList;

class DomUtils {
	static public inline function addIf(list:DOMTokenList, clsName:String, cond:Bool) {
		if (cond) {
			list.add(clsName);
		}
	}
}
