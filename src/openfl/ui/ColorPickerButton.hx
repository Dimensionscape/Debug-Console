package openfl.ui;

import feathers.controls.Button;
import feathers.events.TriggerEvent;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Christopher Speciale, Dimensionscape LLC
 */
class ColorPickerButton extends Button {
	private var __colorIndicator:Bitmap;
	private var __colorPicker:ColorPicker;

	public var color(get, set):Int;
	public var hex(get, never):String;

	private function get_color():Int {
		return __colorPicker.color;
	}

	private function set_color(value:Int):Int {
		return __colorPicker.color = value;
	}

	public function setColorFromString(value:String):Void {
		@:privateAccess __colorPicker.__colorInput.text = value;
	}

	private function get_hex():String {
		@:privateAccess return __colorPicker.__colorInput.text;
	}

	public function new() {
		super();

		__colorIndicator = new Bitmap(new BitmapData(20, 20, false, 0xFFFFFF));
		this.width = 26;
		this.height = 26;
		this.icon = __colorIndicator;
		addEventListener(TriggerEvent.TRIGGER, __onTriggered);
		__colorPicker = new ColorPicker();
		__colorPicker.addEventListener(Event.CHANGE, __onColorChange);
		__colorPicker.addEventListener(Event.REMOVED_FROM_STAGE, __onRemovedFromStage);
	}

	private function __onColorChange(e:Event):Void {
		__colorIndicator.bitmapData.fillRect(__colorIndicator.bitmapData.rect, __colorPicker.color);
		__dispatch(new Event(Event.CHANGE));
	}

	private function __onTriggered(e:TriggerEvent):Void {
		var bounds:Rectangle = getBounds(stage);
		var offsetY:Float = 0;
		if (bounds.y - (bounds.height + 262) > 0) {
			offsetY = bounds.height - 262;
		}
		__colorPicker.x = bounds.x - __colorPicker.width;
		__colorPicker.y = bounds.y + offsetY;
		stage.addChild(__colorPicker);
	}

	private function __onRemovedFromStage(e:Event):Void {
		dispatchEvent(new Event(Event.CLOSE));
	}

	override function set_width(value:Float):Float {
		__colorIndicator.width = value - 6;
		return super.set_width(value);
	}

	override function set_height(value:Float):Float {
		__colorIndicator.height = value - 6;
		return super.set_height(value);
	}
}
