package openfl.ui;

import feathers.controls.TextInput;
import feathers.controls.VSlider;
import lime.math.ColorMatrix;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.filters.GlowFilter;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.ui.Mouse;

/**
 * ...
 * @author Christopher Speciale, Dimensionscape LLC
 */
class ColorPicker extends Sprite {
	private var __spectrumBitmap:Bitmap;
	private var __pallete:Bitmap;
	private var __shadeBitmap:Bitmap;
	private var __brightnessSlider:VSlider;

	private var __mouseCursor:Shape;

	private var __palleteCursor:Shape;

	public var color:Int;

	private var __colorX:Float = 0;
	private var __colorY:Float = 0;
	private var __mouseDown:Bool = false;

	private var __colorInput:TextInput;
	private var __caretIndex:Int = 0;

	public function new() {
		super();

		__mouseCursor = new Shape();
		__mouseCursor.graphics.lineStyle(2);
		__mouseCursor.graphics.drawCircle(0, 0, 8);
		__mouseCursor.filters = [new GlowFilter(0xFFFFFF)];

		var spectrumBitmapData:BitmapData = Assets.getBitmapData("img/color_spectrum.png");

		__spectrumBitmap = new Bitmap(spectrumBitmapData);
		addChild(__spectrumBitmap);

		__pallete = new Bitmap(new BitmapData(32, 22, false, 0xffffff));
		__pallete.x = __spectrumBitmap.width;
		__pallete.y = __spectrumBitmap.height;
		addChild(__pallete);

		__palleteCursor = new Shape();
		__palleteCursor.graphics.lineStyle(2, 0xFFFFFF);
		__palleteCursor.graphics.drawCircle(0, 0, 4.5);
		__palleteCursor.filters = [new GlowFilter(0x0, 1, 4, 4)];
		__palleteCursor.x = 0;
		__palleteCursor.y = 0;
		addChild(__palleteCursor);

		__shadeBitmap = new Bitmap(new BitmapData(32, Std.int(__spectrumBitmap.height), false, 0xFFFFFF), null, true);
		__shadeBitmap.x = __spectrumBitmap.width;
		addChild(__shadeBitmap);

		__brightnessSlider = new VSlider();
		__brightnessSlider.height = __shadeBitmap.height;
		__brightnessSlider.x = __shadeBitmap.x + __shadeBitmap.width - 16;
		__brightnessSlider.maximum = 239;
		__brightnessSlider.minimum = 0;
		__brightnessSlider.step = 1;
		__brightnessSlider.value = 0;
		__brightnessSlider.addEventListener(Event.CHANGE, __onBrightnessChanged);
		addChild(__brightnessSlider);
		__brightnessSlider.validateNow();

		__colorInput = new TextInput();
		__colorInput.x = __spectrumBitmap.width - 80;
		__colorInput.y = __pallete.y;
		__colorInput.width = 80;
		__colorInput.height = 22;
		__colorInput.textFormat = new TextFormat("_sans", 14);
		__colorInput.paddingTop = 2;
		__colorInput.restrict = "0-9a-fA-F";
		__colorInput.maxChars = 8;
		addChild(__colorInput);
		__colorInput.validateNow();

		__colorInput.addEventListener(Event.CHANGE, __onColorInputChanged);
		__colorInput.text = "FFFFFF";

		Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, __onMouseDown);
		addEventListener(MouseEvent.MOUSE_OVER, __onMouseOver);
		addEventListener(MouseEvent.MOUSE_OUT, __onMouseOut);
	}

	private function __onColorInputChanged(e:Event):Void {
		__caretIndex = cast(__colorInput.stageFocusTarget, TextField).caretIndex;
		__colorInput.removeEventListener(Event.CHANGE, __onColorInputChanged);
		cast(__colorInput.stageFocusTarget, TextField).text = __colorInput.text.toUpperCase();
		__colorInput.addEventListener(Event.CHANGE, __onColorInputChanged);
		__colorInput.selectRange(__caretIndex, __caretIndex);

		var inputColor:Int = Std.parseInt("0x" + cast(__colorInput.stageFocusTarget, TextField).text);
		for (c in 0...__spectrumBitmap.bitmapData.width) {
			for (r in 0...__spectrumBitmap.bitmapData.height) {
				var spectrumColor:Int = __spectrumBitmap.bitmapData.getPixel(Std.int(c), Std.int(r));
				if (inputColor == spectrumColor) {
					__colorX = c;
					__colorY = r;
					__fillPallete(inputColor, true, false);
					return;
				} else {
					var colorMatrixA:ColorMatrix = new ColorMatrix();
					colorMatrixA.color = spectrumColor;

					var colorMatrixB:ColorMatrix = new ColorMatrix();
					colorMatrixB.color = inputColor;

					var rDiff:Int = Std.int(Math.abs(colorMatrixA.redOffset - colorMatrixB.redOffset));
					var gDiff:Int = Std.int(Math.abs(colorMatrixA.greenOffset - colorMatrixB.greenOffset));
					var bDiff:Int = Std.int(Math.abs(colorMatrixA.blueOffset - colorMatrixB.blueOffset));

					var totalDiff:Int = rDiff + gDiff + bDiff;

					var percent = (totalDiff / 765) * 100;
					if (percent < 3) {
						__colorX = c;
						__colorY = r;
						__fillPallete(inputColor, true, false);
						return;
					}
				}
			}
		}
	}

	private function __onMouseOver(e:MouseEvent):Void {
		if (stage.focus != __colorInput.stageFocusTarget || !__mouseDown) {
			var mouseLoc:Point = new Point(mouseX, mouseY);
			var bounds:Rectangle = __spectrumBitmap.getBounds(this);
			if (bounds.containsPoint(mouseLoc)) {
				Mouse.hide();
				__mouseCursor.x = mouseX;
				__mouseCursor.y = mouseY;
				addChild(__mouseCursor);
			}
			addEventListener(Event.ENTER_FRAME, __onFrameUpdate);
		}
	}

	private function __onMouseOut(e:MouseEvent):Void {
		removeEventListener(Event.ENTER_FRAME, __onFrameUpdate);
		Mouse.show();
		if (__mouseCursor.stage != null)
			removeChild(__mouseCursor);
	}

	private function __onFrameUpdate(e:Event):Void {
		__mouseCursor.x = mouseX;
		__mouseCursor.y = mouseY;

		var mouseLoc:Point = new Point(mouseX, mouseY);
		var bounds:Rectangle = __spectrumBitmap.getBounds(this);

		if (bounds.containsPoint(mouseLoc)) {
			Mouse.hide();
			addChild(__mouseCursor);
		} else {
			Mouse.show();
			removeChild(__mouseCursor);
		}
	}

	private function __onBrightnessChanged(e:Event):Void {
		__fillPallete(__shadeBitmap.bitmapData.getPixel(0, Std.int(239 - __brightnessSlider.value)), false);
	}

	private function __onMouseDown(e:MouseEvent):Void {
		if (stage == null) {
			return;
		}

		if (e.target != __brightnessSlider.thumbSkin) {
			var mouseLoc:Point = new Point(mouseX, mouseY);
			var bounds:Rectangle = getBounds(this);

			if (bounds.containsPoint(mouseLoc)) {
				__mouseDown = true;
				__setColorPallete();
				if (stage != null)
					stage.addEventListener(MouseEvent.MOUSE_UP, __onMouseUp);
			} else {
				removeEventListener(Event.ENTER_FRAME, __onFrameUpdate);
				if (stage != null)
					stage.removeChild(this);
			}
		}
	}

	private function __onMouseUp(e:MouseEvent):Void {
		__mouseDown = false;
		__onMouseOver(null);
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, __onMouseMove);
		stage.removeEventListener(MouseEvent.MOUSE_UP, __onMouseUp);
	}

	private function __onMouseMove(e:MouseEvent):Void {
		__setColorPallete(true);
	}

	private function __setBrightnessSlider():Void {
		__brightnessSlider.value = 239 - mouseY;
	}

	private function __setColorPallete(moving:Bool = false):Void {
		var mouseLoc:Point = new Point(mouseX, mouseY);
		var bounds:Rectangle = __spectrumBitmap.getBounds(this);

		if (bounds.containsPoint(mouseLoc)) {
			if (moving == false) {
				stage.addEventListener(MouseEvent.MOUSE_MOVE, __onMouseMove);
			}
			__colorX = mouseX;
			__colorY = mouseY;
			__fillPallete(__spectrumBitmap.bitmapData.getPixel(Std.int(__colorX), Std.int(__colorY)));
			return;
		}
		if (moving) {
			if (mouseY > bounds.height) {
				__colorY = 240;
				__fillPallete(0x000000);
			} else if (mouseY < 0) {
				__colorY = 0;
				__fillPallete(0xffffff);
			}
		} else {
			bounds = __shadeBitmap.getBounds(this);

			if (bounds.containsPoint(mouseLoc)) {
				__setBrightnessSlider();
			}
		}
	}

	private function __movePalleteCursor():Void {
		__palleteCursor.x = __colorX;
		__palleteCursor.y = __colorY;
	}

	private function __fillPallete(color:Int, fillShadeBitmap:Bool = true, changeText:Bool = true):Void {
		if (color != this.color) {
			this.color = color;

			if (changeText) {
				__colorInput.removeEventListener(Event.CHANGE, __onColorInputChanged);
				__colorInput.text = StringTools.hex(color, 6);
				__colorInput.addEventListener(Event.CHANGE, __onColorInputChanged);
			}

			__pallete.bitmapData.fillRect(new Rectangle(0, 0, 32, 32), color);
			__movePalleteCursor();

			if (fillShadeBitmap) {
				var level:Float = 1;
				var inc:Float = 2 / 240;
				var current:Int = 0;
				for (i in 0...240) {
					var shade:Int = __shadeColor(color, level);
					level -= inc;
					if (shade == color)
						current = i;
					__shadeBitmap.bitmapData.fillRect(new Rectangle(0, i, __shadeBitmap.width, 1), shade);
				}
				__brightnessSlider.removeEventListener(Event.CHANGE, __onBrightnessChanged);
				__brightnessSlider.value = (color == 0x000000) ? 119 : 239 - current;
				__brightnessSlider.addEventListener(Event.CHANGE, __onBrightnessChanged);
			}
			dispatchEvent(new Event(Event.CHANGE, false));
		}
	}

	private function __shadeColor(color:Int, brightness:Float):Int {
		brightness *= 100;

		var colorMatrix:ColorMatrix = new ColorMatrix();
		colorMatrix.color = color;

		colorMatrix.redOffset = colorMatrix.redOffset * (100 + brightness) / 100;
		colorMatrix.greenOffset = colorMatrix.greenOffset * (100 + brightness) / 100;
		colorMatrix.blueOffset = colorMatrix.blueOffset * (100 + brightness) / 100;

		colorMatrix.redOffset = Math.max(Math.min(255, colorMatrix.redOffset), 0);
		colorMatrix.greenOffset = Math.max(Math.min(255, colorMatrix.greenOffset), 0);
		colorMatrix.blueOffset = Math.max(Math.min(255, colorMatrix.blueOffset), 0);

		return colorMatrix.color;
	}
}
