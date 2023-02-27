package openfl.desktop;

import openfl.display.NativeMenu;
import openfl.Lib;
import openfl.display.NativeMenuItem;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.display.__internal.NativeMenuContainer;

/**
 * ...
 * @author Christopher Speciale
 */
class NativeApplication {
	public static var nativeApplication:NativeApplication = new NativeApplication();

	public var menu(get, set):NativeMenu;

	private var _menu:NativeMenu;
	private var _background:Shape;
	private var _menuContainer:NativeMenuContainer;
	private var _surface:Sprite;

	private function new() {}

	private function get_menu():NativeMenu {
		return _menu;
	}

	private function set_menu(value:NativeMenu):NativeMenu {
		return _setupMenu(value);
	}

	private function _setupMenu(menu:NativeMenu):NativeMenu {
		@:privateAccess menu._setAsApplicationMenu();

		return menu;
	}
}
