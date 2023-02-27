package console ;

import feathers.controls.TextArea;
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
	
	private var __textArea:TextArea;
	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, __onInit);		
	}
	
	private function __onInit(e:Event):Void{
		
		removeEventListener(Event.ADDED_TO_STAGE, __onInit);
		__textArea = new TextArea();
		__textArea.wordWrap = false;
		__textArea.width = stage.stageWidth;
		__textArea.height = stage.stageHeight - 52;
		__textArea.x = 0;
		__textArea.y = 0;
		__textArea.text = DEFAULT_TEXT;
		addChild(__textArea);
		
	}
	
	private function __doMaxScroll():Void{
		__textArea.scrollY = __textArea.maxScrollY;
	}
	public function addText(text:String):Void{
		__textArea.text += '$text\n';
		__textArea.validateNow();
		__doMaxScroll();
	}
	
	public function setText(text:String):Void{
		__textArea.text = text;
		__textArea.validateNow();
		__doMaxScroll();
	}
	
	public function validate():Void{
		__textArea.width = stage.stageWidth;
		__textArea.height = stage.stageHeight - 52;
	}
}