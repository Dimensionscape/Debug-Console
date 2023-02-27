package view;
import console.Console;
import debug.ISessionTabData;
import debug.Session;
import feathers.controls.Button;
import feathers.controls.TabBar;
import feathers.controls.ToggleButton;
import feathers.controls.ToggleButtonState;
import feathers.data.ArrayCollection;
import feathers.data.TabBarItemState;
import feathers.layout.RelativePosition;
import feathers.utils.DisplayObjectRecycler;
import haxe.Timer;
import menu.MenuManager;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.display.SimpleButton;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.utils.Object;

/**
 * ...
 * @author Christopher Speciale
 */
class ConsoleView extends Sprite
{
	public var console(get, null):Console;

	private var __console:Console;
	private var __sessionTabs:TabBar;

	private var __xIcon:BitmapData;

	public function new()
	{
		super();

		__createXIcon();

		addEventListener(Event.ADDED_TO_STAGE, __onInit);
	}

	private function get_console():Console
	{
		return __console;
	}
	private function __createXIcon():Void
	{
		var shape:Shape = new Shape();
		shape.graphics.lineStyle(1, 0xFF0000, 1);
		shape.graphics.moveTo(0, 0);
		shape.graphics.lineTo(12, 12);
		shape.graphics.moveTo(0, 12);
		shape.graphics.lineTo(12, 0);

		__xIcon = new BitmapData(12, 12,true,0x00FFFFFF);
		__xIcon.draw(shape, null, null, null, null, true);
	}

	private function __onInit(e:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, __onInit);

		__console = new Console();
		__console.x = 0;
		__console.y = 52;
		addChild(__console);

		__sessionTabs = new TabBar();
		__sessionTabs.x = 0;
		__sessionTabs.y = 26;
		__sessionTabs.width = stage.stageHeight;
		__sessionTabs.height = 26;
		__sessionTabs.dataProvider = new ArrayCollection([]);
		__sessionTabs.itemToText = (item:ISessionTabData)->{
			return item.title;
		}
		__sessionTabs.tabRecycler = DisplayObjectRecycler.withFunction(__createTab, __updateTab);
		__sessionTabs.addEventListener(Event.CHANGE, __onSessionTabsChanged);
		addChild(__sessionTabs);

		stage.addEventListener(Event.RESIZE, __onResize);
	}

	private function __onSessionTabsChanged(e:Event):Void
	{
		if (__sessionTabs.selectedIndex == -1)
		{
			console.setText(Console.DEFAULT_TEXT);
			__enableSessionMenus(false);
			return;
		}
		var sessionTabData:ISessionTabData = __sessionTabs.selectedItem;
		var session:Session = sessionTabData.session;
		session.hasForeground = true;
		__enableSessionMenus(true);
	}

	private function __enableSessionMenus(value:Bool):Void
	{
		MenuManager.enable(MenuManager.SAVE_SESSION_LOGS, value);
		MenuManager.enable(MenuManager.CLOSE, value);
		MenuManager.enable(MenuManager.CLOSE_ALL, value);
	}

	public function createTab(session:Session):Void
	{

		var sessionTabData:ISessionTabData = new Object();
		sessionTabData.timestamp = session.date.getTime();
		sessionTabData.title = session.date.toString();
		sessionTabData.session = session;
		sessionTabData.tab = null;

		__sessionTabs.dataProvider.add(sessionTabData);
		__sessionTabs.selectedIndex = __sessionTabs.maxSelectedIndex;
	}

	private function __onResize(e:Event):Void
	{
		__sessionTabs.width = stage.stageWidth;
		__console.validate();
	}

	private function __createTab():ToggleButton
	{
		var closeButton:Button = new Button();
		closeButton.width = 12;
		closeButton.height = 12;
		closeButton.backgroundSkin = new Bitmap(__xIcon, null, true);

		var tab:ToggleButton = new ToggleButton();
		tab.mouseChildren = true;
		tab.icon = closeButton;
		tab.iconPosition = RelativePosition.RIGHT;

		function onClose(e:MouseEvent)
		{
			removeTab(tab);
			closeButton.removeEventListener(MouseEvent.CLICK, onClose);
		}

		closeButton.addEventListener(MouseEvent.CLICK, onClose);
		return tab;
	}

	public function removeTab(tab:ToggleButton):Void
	{
		var tabs:Array<Dynamic> = cast(__sessionTabs.dataProvider, ArrayCollection<Dynamic>).array;

		for (i in 0...tabs.length)
		{
			if (tabs[i].tab == tab)
			{
				var item:ISessionTabData = __sessionTabs.dataProvider.get(i);
				item.session.close();
				__sessionTabs.dataProvider.removeAt(i);
				__setDefaultConsoleText();
				return;
			}
		}
	}

	private function __setDefaultConsoleText():Void
	{
		console.setText(Console.DEFAULT_TEXT);
	}

	public function __updateTab(tab:ToggleButton, state:TabBarItemState):Void
	{
		state.data.tab = tab;
		tab.text = state.text;
	}

	public function saveCurrentSession():Void
	{
		var sessionTabData:ISessionTabData = __sessionTabs.selectedItem;
		sessionTabData.session.save();
	}

	public function closeAllSessions():Void
	{
		var iterator:Iterator<Dynamic> = __sessionTabs.dataProvider.iterator();
		for (item in iterator)
		{
			item.session.close();
		}
		__sessionTabs.dataProvider.removeAll();
		__setDefaultConsoleText();
	}

	public function closeCurrentSession():Void
	{
		var sessionTabData:ISessionTabData = __sessionTabs.selectedItem;
		sessionTabData.session.close();
		__sessionTabs.dataProvider.remove(sessionTabData);
	}

}