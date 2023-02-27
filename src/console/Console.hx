package console ;

import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.events.Event;

/**
 * ...
 * @author Christopher Speciale
 */
class Console extends Sprite
{
	
	public static inline var DEFAULT_TEXT:String = "Waiting for incoming session...";
	
	private var __textArea:TextField;
	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, __onInit);		
	}
	
	private function __onInit(e:Event):Void{
		
		removeEventListener(Event.ADDED_TO_STAGE, __onInit);
		__textArea = new TextField();
		__textArea.wordWrap = false;
		__textArea.multiline = true;
		__textArea.width = stage.stageWidth;
		__textArea.height = stage.stageHeight - 26;
		__textArea.x = 0;
		__textArea.y = 0;
		__textArea.background = false;
		__textArea.border = true;
		__textArea.textColor = 0x0;
		__textArea.text = DEFAULT_TEXT;
		addChild(__textArea);
		
	}
	
	public function addText(text:String):Void{
		__textArea.text += '$text\n';
		__textArea.scrollV = __textArea.maxScrollV;
	}
	
	public function setText(text:String):Void{
		__textArea.text = text;
		__textArea.scrollV = __textArea.maxScrollV;
	}
	
	public function validate():Void{
		__textArea.width = stage.stageWidth;
		__textArea.height = stage.stageHeight - 26;
	}
}