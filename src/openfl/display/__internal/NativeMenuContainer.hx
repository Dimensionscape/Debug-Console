package openfl.display.__internal;

import openfl.display.NativeMenu;
import openfl.display.NativeMenuItem;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.filters.DropShadowFilter;
import openfl.filters.GlowFilter;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Christopher Speciale
 */
@:access(openfl.display.__internal.NativeMenuItemDisplayObject)
@:access(openfl.display.NativeMenuItem)
class NativeMenuContainer extends Sprite {
	var __background:Shape;
	var __lastHovered:NativeMenuItemDisplayObject;

	public function new() {
		super();

		// __nativeMenu = nativeMenu;

		__background = new Shape();
		// __background.graphics.lineStyle(1, 0xCCCCCC);
		__background.graphics.beginFill(0xEFEFEF);
		__background.graphics.drawRect(0, 0, 2, 2);
		__background.filters = [
			new DropShadowFilter(5, 45, 0, .7, 4, 4),
			new GlowFilter(0x0, 1, 1, 1, 1, 1, true)
		];
		addChild(__background);
	}

	public function add(item:NativeMenuItem):Void {
		var itemDO:NativeMenuItemDisplayObject = item.__nativeItemDO;
		itemDO.x = 2;
		itemDO.y = this.height;

		if (itemDO.width > this.width) {
			addChild(itemDO);
			__updateItems();
		} else {
			addChild(itemDO);
			itemDO.setWidth(this.width - 4);
		}

		__updateBounds();
	}

	public function remove(item:NativeMenuItem):Void {
		removeChild(item.__nativeItemDO);
		__updateItems();
		__updateBounds();
	}

	public function removeAll():Void {
		removeChildren(1);
		__updateItems();
		__updateBounds();
	}

	private function __updateBounds():Void {
		var bounds:Rectangle = new Rectangle();
		for (i in 1...this.numChildren) {
			bounds = bounds.union(this.getChildAt(i).getRect(this));
		}
		__background.width = bounds.width + 4;
		__background.height = bounds.height + 4;
	}

	private function __updateItems():Void {
		for (child in this.__children) {
			if (Std.isOfType(child, NativeMenuItemDisplayObject)) {
				cast(child, NativeMenuItemDisplayObject).setWidth(this.width - 4);
			}
		}
	}
}
