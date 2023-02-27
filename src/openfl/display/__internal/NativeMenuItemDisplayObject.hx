package openfl.display.__internal;

import openfl.events.Event;
#if !air
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.NativeMenuItem;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * ...
 * @author Christopher Speciale
 */
class NativeMenuItemDisplayObject extends Sprite {
	private var __labelField:TextField;
	private var __background:Bitmap;
	private var __hoverSkin:BitmapData;
	private var __backgroundSkin:BitmapData;
	private var __nativeMenuItem:NativeMenuItem;
	private var __submenuIcon:Shape;

	public function new(nativeMenuItem:NativeMenuItem) {
		super();
		__nativeMenuItem = nativeMenuItem;

		if (__nativeMenuItem.isSeperator) {
			this.mouseEnabled = false;

			var shape:Shape = new Shape();
			shape.graphics.beginFill(0xEFEFEF);
			shape.graphics.drawRect(0, 0, 4, 4);
			shape.graphics.lineStyle(1, 0xCCCCCC);
			shape.graphics.moveTo(0, 2);
			shape.graphics.lineTo(4, 2);

			__backgroundSkin = new BitmapData(4, 4);
			__backgroundSkin.draw(shape);

			__background = new Bitmap(__backgroundSkin);
			__background.x = 32;
			addChild(__background);
		} else {
			this.mouseChildren = false;
			__labelField = new TextField();
			__labelField.text = nativeMenuItem.label;
			__labelField.autoSize = LEFT;
			__labelField.defaultTextFormat = new TextFormat("_sans", 13, 0x0);
			__labelField.selectable = false;
			__labelField.x = 32;
			__labelField.y = 2;

			var width:Float = Math.max(__labelField.width + __labelField.x + 38, 104);

			var shape:Shape = new Shape();
			shape.graphics.beginFill(0xEFEFEF);
			shape.graphics.drawRect(0, 0, width + 4, __labelField.height + 4);

			__backgroundSkin = new BitmapData(Std.int(shape.width), Std.int(shape.height));
			__backgroundSkin.draw(shape);

			shape.graphics.beginFill(0x91C9F7);
			shape.graphics.drawRect(0, 0, width + 4, __labelField.height + 4);
			// TODO: get rid of shape here why do we need it?
			__hoverSkin = new BitmapData(Std.int(shape.width), Std.int(shape.height));
			__hoverSkin.draw(shape);

			__background = new Bitmap(__backgroundSkin);
			addChild(__background);

			addChild(__labelField);

			addEventListener(Event.ADDED_TO_STAGE, this_onAddedToStage);
		}
	}

	private function this_onAddedToStage(e:Event):Void {
		removeEventListener(Event.ADDED_TO_STAGE, this_onAddedToStage);

		@:privateAccess if (__nativeMenuItem.menu.__isApplicationMenu) {
			setWidth(__labelField.width + 12);
			__labelField.x = 6;
			@:privateAccess var menuContainer:NativeApplicationMenuContainer = cast __nativeMenuItem.menu.__menuContainer;
			menuContainer.__validateItems();
		}

		if (__nativeMenuItem.submenu != null) {
			@:privateAccess if (!__nativeMenuItem.menu.__isApplicationMenu) {
				__submenuIcon = new Shape();
				__submenuIcon.graphics.lineStyle(1, __nativeMenuItem.enabled ? 0x0 : 0x808080, 1, true, NORMAL, null, MITER);
				// __submenuIcon.graphics.beginFill(0x0);
				__submenuIcon.graphics.moveTo(0, 0);
				__submenuIcon.graphics.lineTo(3, 2.5);
				__submenuIcon.graphics.lineTo(0, 5);
				// __submenuIcon.graphics.lineTo(0,0);
				// __submenuIcon.graphics.endFill();
				__submenuIcon.x = __background.width - 14;
				__submenuIcon.y = 8;
				addChild(__submenuIcon);
			} else {
				y += 4;
			}
		}
	}

	public function hover(value:Bool = true):Void {
		if (value) {
			__background.bitmapData = __hoverSkin;
		} else {
			__background.bitmapData = __backgroundSkin;
		}
	}

	public function out():Void {
		__background.bitmapData = __backgroundSkin;
	}

	public function setWidth(value:Float):Void {
		if (__nativeMenuItem.isSeperator) {
			value -= 32;
		}

		__background.width = value;

		if (__submenuIcon != null) {
			__submenuIcon.x = __background.width - 14;
		}
	}

	private function __enable():Void {
		__labelField.textColor = 0x000000;
	}

	private function __disable():Void {
		__labelField.textColor = 0x808080;
	}
}
#end
