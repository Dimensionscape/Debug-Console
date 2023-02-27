package openfl.utils;

/**
 * ...
 * @author Christopher Speciale
 */
class ArrayUtil {
	public static inline var NUMERIC:UInt = 16;

	public static function sortOn(array:Array<Dynamic>, name:Dynamic, options:Dynamic = 0, ...param):Void {
		if (options == NUMERIC) {
			__sortOnNumeric(array, name);
		}
	}

	private static function __sortOnNumeric(array:Array<Dynamic>, name:Dynamic):Void {
		function sort(a:Dynamic, b:Dynamic):Int {
			var aField:Dynamic = Reflect.getProperty(a, name);
			var bField:Dynamic = Reflect.getProperty(b, name);

			return Std.int(aField - bField);
		}
		array.sort(sort);
	}

	public static function sort(array:Array<Dynamic>, ...param):Void {
		if (param.length == 0) {
			__sortAlphabetically(array);
		}
	}

	private static function __sortAlphabetically(array:Array<Dynamic>):Void {
		array.sort((a:String, b:String) -> {
			a = a.toUpperCase();
			b = b.toUpperCase();

			if (a < b) {
				return -1;
			} else if (a > b) {
				return 1;
			} else {
				return 0;
			}
		});
	}
}
