package menu;

import debug.Session;
import haxe.io.Path;
import openfl.Lib;
import openfl.desktop.NativeApplication;
import openfl.display.NativeMenu;
import openfl.display.NativeMenuItem;
import openfl.display.Stage;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.filesystem.File;
import openfl.net.FileFilter;
import openfl.utils.ByteArray;
import openfl.utils.Function;

/**
 * ...
 * @author Christopher Speciale
 */
class MenuManager 
{
	
	public static inline var SAVE_SESSION_LOGS:String = "Save Session Logs";
	public static inline var CLOSE:String = "Close";
	public static inline var CLOSE_ALL:String = "Close All";
	public static inline var EXIT:String = "Exit";
	public static inline var ABOUT:String = "About";
	
	private static var __nativeMenu:NativeMenu;
	private static var __sessionMenu:NativeMenu;
	
	public static var eventDispatcher:EventDispatcher;
	
	public static function start():Void
	{
		eventDispatcher = new EventDispatcher();
		
		__nativeMenu = new NativeMenu();
		__nativeMenu.addEventListener(Event.SELECT, __onNativeMenuSelect);

		__sessionMenu = new NativeMenu();

		var sessionMenuItem:NativeMenuItem = new NativeMenuItem("Session");

		var saveItem:NativeMenuItem = new NativeMenuItem(SAVE_SESSION_LOGS);
		saveItem.name = saveItem.label;
		var sepItemA:NativeMenuItem = new NativeMenuItem("sepA", true);
		var closeItem:NativeMenuItem = new NativeMenuItem(CLOSE);
		closeItem.name = closeItem.label;
		var closeAllItem:NativeMenuItem = new NativeMenuItem(CLOSE_ALL);
		closeAllItem.name = closeAllItem.label;
		var sepItemB:NativeMenuItem = new NativeMenuItem("sepB", true);
		var exitItem:NativeMenuItem = new NativeMenuItem(EXIT);

		

		__sessionMenu.addItem(saveItem);
		__sessionMenu.addItem(sepItemA);
		__sessionMenu.addItem(closeItem);
		__sessionMenu.addItem(closeAllItem);
		__sessionMenu.addItem(sepItemB);
		__sessionMenu.addItem(exitItem);

		sessionMenuItem.submenu = __sessionMenu;
		__nativeMenu.addItem(sessionMenuItem);
		

		var helpMenuItem:NativeMenuItem = new NativeMenuItem("Help");
		var helpMenu:NativeMenu = new NativeMenu();
		helpMenuItem.submenu = helpMenu;

		var aboutMenuItem:NativeMenuItem = new NativeMenuItem(ABOUT);
		helpMenu.addItem(aboutMenuItem);

		__nativeMenu.addItem(helpMenuItem);
		
		NativeApplication.nativeApplication.menu = __nativeMenu;		
		
		enable(SAVE_SESSION_LOGS, false);
		enable(CLOSE, false);
		enable(CLOSE_ALL, false);
	}
	
	public static function enable(menu:String, value:Bool = true):Void
	{
		__sessionMenu.getItemByName(menu).enabled = value;
	}
	
	
	private static function __onNativeMenuSelect(e:Event):Void{
		var menuItem:NativeMenuItem = cast e.target;
		switch (menuItem.label)
		{
			case SAVE_SESSION_LOGS:
				eventDispatcher.dispatchEvent(new Event(SAVE_SESSION_LOGS));
			case CLOSE:
				eventDispatcher.dispatchEvent(new Event(CLOSE));
			case CLOSE_ALL:
				eventDispatcher.dispatchEvent(new Event(CLOSE_ALL));
			case EXIT:
				Sys.exit(0);
			case ABOUT:
				Lib.application.window.alert("Version: 1.0.0" + "\n Author: Chris@Dimensionscape.com");
		}
	}
}