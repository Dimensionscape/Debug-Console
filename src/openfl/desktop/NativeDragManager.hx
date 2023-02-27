package openfl.desktop;

import openfl.display.InteractiveObject;

/**
 * ...
 * @author Christopher Speciale
 */
class NativeDragManager {
	public static var dragInitiator(get, null):InteractiveObject;
	public static var dropAction(get, null):String;
	public static var isDragging(get, null):Bool;
	public static var isSupported(get, null):Bool;
}
