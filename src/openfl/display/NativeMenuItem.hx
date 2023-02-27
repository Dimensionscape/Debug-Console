package openfl.display;

#if !air
import openfl.display.__internal.NativeMenuItemDisplayObject;
import openfl.events.EventDispatcher;

/**
 * ...
 * @author Christopher Speciale
 */
class NativeMenuItem extends EventDispatcher {
	public var checked:Bool;
	public var data:Dynamic;
	public var enabled(default, set):Bool = true;
	public var isSeperator(default, null):Bool;
	public var keyEquivalent:String;
	public var keyEquivalentModifiers:Array<String>;
	public var label:String;
	public var menu(default, set):NativeMenu;
	public var mnemnicIndex:Int;
	public var name:String;
	public var submenu(default, set):NativeMenu;

	private var __nativeItemDO:NativeMenuItemDisplayObject;

	public function new(label:String, isSeperator:Bool = false) {
		super();

		this.isSeperator = isSeperator;
		this.label = label;

		__nativeItemDO = new NativeMenuItemDisplayObject(this);
	}

	private function set_submenu(value:NativeMenu):NativeMenu {
		@:privateAccess value.parent = menu;
		return submenu = value;
	}

	private function set_menu(value:NativeMenu):NativeMenu {
		@:privateAccess if (submenu != null)
			submenu.parent = value;
		return menu = value;
	}

	private function set_enabled(value:Bool):Bool {
		if (value && !enabled) {
			@:privateAccess __nativeItemDO.__enable();
		} else if (!value && enabled) {
			@:privateAccess __nativeItemDO.__disable();
		}

		return enabled = value;
	}
}
#else
typedef NativeMenuItem = flash.display.NativeMenuItem;
#end
