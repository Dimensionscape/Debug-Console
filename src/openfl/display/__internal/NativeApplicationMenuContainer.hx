package openfl.display.__internal;

import openfl.display.NativeMenuItem;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Christopher Speciale
 */
class NativeApplicationMenuContainer extends NativeMenuContainer {
	public function new() {
		super();
	}

	override public function add(item:NativeMenuItem):Void {
		var w:Float = 0;
		for (i in 1...this.numChildren) {
			w += this.getChildAt(i).width;
		}

		var itemDO:NativeMenuItemDisplayObject = @:privateAccess item.__nativeItemDO;
		itemDO.x = w + 2;
		itemDO.y = 0;
		addChild(itemDO);
		__updateBounds();
	}

	override function __updateBounds():Void {
		__background.width = Lib.current.stage.stageWidth;
		__background.height = 28;
	}

	private function __validateItems():Void {
		var w:Float = 0;
		for (i in 1...this.numChildren) {
			this.getChildAt(i).x = w + 2;
			w += this.getChildAt(i).width;
		}
	}
}
