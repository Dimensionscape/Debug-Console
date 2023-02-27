package openfl.display;

import openfl.Lib;
import openfl.display.__internal.NativeApplicationMenuContainer;
import openfl.display.__internal.NativeMenuItemDisplayObject;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
#if !air
import openfl.display.__internal.NativeMenuContainer;
import openfl.events.EventDispatcher;

/**
 * ...
 * @author Christopher Speciale
 */
@:access(openfl.display.__internal.NativeMenuItemDisplayObject)
class NativeMenu extends EventDispatcher {
	public static var isSupported:Bool = #if mobile false #else true #end;

	public var items:Array<NativeMenuItem>;
	public var numItems(default, null):Int = 0;

	private var __stage:Stage;
	private var __isApplicationMenu:Bool = false;

	public var parent(default, null):NativeMenu;

	private var __menuContainer:NativeMenuContainer;
	private var __openMenuIndex:Int = -1;

	public function new() {
		super();
		items = [];
		__menuContainer = new NativeMenuContainer();
	}

	public function addItem(item:NativeMenuItem):NativeMenuItem {
		items.push(item);
		__menuContainer.add(item);
		item.menu = this;
		return item;
	}

	public function addItemAt(item:NativeMenuItem, index:Int):NativeMenuItem {
		items.insert(index, item);
		return item;
	}

	public function addSubmenu(submenu:NativeMenu, label:String):NativeMenuItem {
		var nativeMenuItem:NativeMenuItem = new NativeMenuItem(label);
		nativeMenuItem.submenu = submenu;
		submenu.parent = this;

		return addItem(nativeMenuItem);
	}

	public function addSubmenuAt(submenu:NativeMenu, index:Int, label:String):NativeMenuItem {
		var nativeMenuItem:NativeMenuItem = new NativeMenuItem(label);
		nativeMenuItem.submenu = submenu;
		submenu.parent = this;

		return addItemAt(nativeMenuItem, index);
	}

	public function clone():NativeMenu {
		// todo
		return null;
	}

	public function containsItem(item:NativeMenuItem):Bool {
		return items.indexOf(item) > 0;
	}

	public function display(stage:Stage, stageX:Float, stageY:Float):Void {
		__stage = stage;
		stage.addChild(__menuContainer);
		
		if (__menuContainer.width + stageX > stage.stageWidth){
			stageX -= ((__menuContainer.width + stageX) - stage.stageWidth);
		}
		
		if (__menuContainer.height + stageY > stage.stageHeight){
			stageY -= ((__menuContainer.height + stageY) - stage.stageHeight);
		}
		__menuContainer.x = stageX;
		__menuContainer.y = stageY;

		__menuContainer.addEventListener(MouseEvent.MOUSE_OVER, __menuContainer_onMouseOver);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_onMouseMove);
		stage.addEventListener(Event.MOUSE_LEAVE, window_onMouseLeave);
		stage.addEventListener(Event.DEACTIVATE, window_onDeactivate);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_onMouseDown);
		stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, stage_onMouseDown);
		__menuContainer.addEventListener(MouseEvent.CLICK, __menuContainer_onClick);
	}

	public function getItemAt(index:Int):NativeMenuItem {
		return items[index];
	}

	public function getItemByName(name:String):NativeMenuItem {
		for (i in 0...items.length) {
			var item = items[i];
			if (item.name == name) {
				return item;
			}
		}
		return null;
	}

	public function getItemIndex(item:NativeMenuItem):Int {
		return items.indexOf(item);
	}

	public function removeAllItems():Void {
		items = [];
		__menuContainer.removeAll();
	}

	public function removeItem(nativeMenuItem:NativeMenuItem):NativeMenuItem {
		items.remove(nativeMenuItem);
		__menuContainer.remove(nativeMenuItem);
		return nativeMenuItem;
	}

	public function removeItemAt(nativeMenuItem:NativeMenuItem, index:Int):NativeMenuItem {
		return items.splice(index, 1)[0];
	}

	public function setItemIndex(nativeMenuItem:NativeMenuItem, index:Int):Void {
		var item:NativeMenuItem = items.splice(getItemIndex(nativeMenuItem), 1)[0];
		items.insert(index, item);
	}

	private var __lastHovered:NativeMenuItemDisplayObject;

	private function _setAsApplicationMenu():Void {
		__isApplicationMenu = true;
		__menuContainer = new NativeApplicationMenuContainer();
		for (item in items) {
			__menuContainer.add(item);
		}
		display(Lib.current.stage, 0, 0);
		Lib.current.stage.window.onResize.add((x, y) -> {
			@:privateAccess __menuContainer.__updateBounds();
		});
	}

	private function __menuContainer_onMouseOver(e:MouseEvent):Void {
		Lib.clearTimeout(timeoutIndex);
		var target:DisplayObject = e.target;
		if (Std.isOfType(target, NativeMenuItemDisplayObject)) {
			if (__lastHovered != null) {
				__lastHovered.hover(false);
			}
			if (cast(target, NativeMenuItemDisplayObject).__nativeMenuItem.enabled == false)
				return;

			__lastHovered = cast target;
			__lastHovered.hover(true);

			if (cast(target, NativeMenuItemDisplayObject).__nativeMenuItem.submenu != null) {
				timeoutIndex = Lib.setTimeout(function() {
					target.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
				}, 500);
			} else {
				if (__openMenuIndex > -1) {
					timeoutIndex = Lib.setTimeout(function() {
						__closeAll(true, getItemAt(__openMenuIndex).submenu);
					}, 500);
				}
			}
		}
	}

	private function stage_onMouseMove(e:MouseEvent):Void {
		if (!__mouseWithinBounds() || e == null) {
			Lib.clearTimeout(timeoutIndex);

			if (__lastHovered != null) {
				__lastHovered.hover(false);
				__lastHovered = null;
			}
		}
	}

	private function window_onMouseLeave(e:Event):Void {
		stage_onMouseMove(null);
	}

	private function window_onDeactivate(e:Event):Void {
		__close();
	}

	private function stage_onMouseDown(e:MouseEvent):Void {
		var target:DisplayObject = e.target;

		if (!Std.isOfType(target, NativeMenuItemDisplayObject) && !Std.isOfType(target, NativeMenuContainer)) {
			if (!__mouseWithinBounds()) {
				__close();
			}
		}
	}

	private function __menuContainer_onClick(e:MouseEvent):Void {
		var target:DisplayObject = e.target;

		if (Std.isOfType(target, NativeMenuItemDisplayObject)) {
			var nativeMenuItem:NativeMenuItem = cast(target, NativeMenuItemDisplayObject).__nativeMenuItem;

			if (nativeMenuItem.enabled == false)
				return;
			if (nativeMenuItem.submenu != null) {
				if (__openMenuIndex != getItemIndex(nativeMenuItem)) {
					var globalPoint:Point = target.parent.localToGlobal(new Point(target.x, target.y));
					if (__isApplicationMenu) {
						nativeMenuItem.submenu.display(__stage, globalPoint.x - 2, globalPoint.y + __menuContainer.height - 4);
					} else {
						nativeMenuItem.submenu.display(__stage, globalPoint.x + __menuContainer.width - 2, globalPoint.y - 2);
					}
					if (__openMenuIndex > -1) {
						var openMenu:NativeMenu = getItemAt(__openMenuIndex).submenu;
						if (nativeMenuItem.submenu != openMenu) {
							openMenu.__closeAll(true, openMenu);
						}
					} else {
						nativeMenuItem.dispatchEvent(new Event(Event.SELECT, false, false));

						__bubbleDispatchEvent(new Event(Event.SELECT), nativeMenuItem);
					}
					__openMenuIndex = getItemIndex(nativeMenuItem);
				}
			} else {
				nativeMenuItem.dispatchEvent(new Event(Event.SELECT, false, false));

				__bubbleDispatchEvent(new Event(Event.SELECT), nativeMenuItem);

				nativeMenuItem.menu.__closeAll();
			}
		}
	}

	private function __bubbleDispatchEvent(event:Event, nativeMenuItem:NativeMenuItem):Void {
		__targetDispatcher = nativeMenuItem;

		this.dispatchEvent(new Event(Event.SELECT));

		if (this.parent != null) {
			this.parent.__bubbleDispatchEvent(event, nativeMenuItem);
		}
	}

	private var timeoutIndex:Int;

	// private function __menuContainer_onMouseOver(e:MouseEvent):Void
	// {
	// }

	private function __closeAll(down:Bool = true, until:NativeMenu = null):Void {
		if (__openMenuIndex != -1 && down) {
			getItemAt(__openMenuIndex).submenu.__closeAll(true, until);
		} else {
			if ((parent != null && until != null && parent != until.parent) || parent != null && until == null) {
				parent.__closeAll(false, until);
			}
			__close();
		}
	}

	private function __close():Void {
		if (__stage == null)
			return;
		Lib.clearTimeout(timeoutIndex);
		stage_onMouseMove(null);
		if (!__isApplicationMenu) {
			__menuContainer.removeEventListener(MouseEvent.MOUSE_OVER, __menuContainer_onMouseOver);
			__stage.removeEventListener(MouseEvent.MOUSE_OUT, stage_onMouseMove);
			__stage.removeEventListener(Event.DEACTIVATE, window_onDeactivate);
			__stage.removeEventListener(MouseEvent.MOUSE_DOWN, stage_onMouseDown);
			__stage.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, stage_onMouseDown);
			removeEventListener(MouseEvent.CLICK, __menuContainer_onClick);

			__stage.removeChild(__menuContainer);
			__stage = null;
		}
		__openMenuIndex = -1;
		if (parent != null) {
			parent.__openMenuIndex = -1;
		}
		dispatchEvent(new Event(Event.CLOSE));
	}

	private function __mouseWithinBounds():Bool {
		return !(__menuContainer.mouseX <= 0
			|| __menuContainer.mouseX >= __menuContainer.width
			|| __menuContainer.mouseY <= 0
			|| __menuContainer.mouseY >= __menuContainer.height);
	}
}
#else
typedef NativeMenu = flash.display.NativeMenu;
#end
