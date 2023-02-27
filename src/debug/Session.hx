package debug;
import haxe.io.Path;
import openfl.events.Event;
import openfl.filesystem.File;
import openfl.net.Socket;
import openfl.events.ProgressEvent;
import openfl.utils.ByteArray;
import service.IMessage;
import sys.FileSystem;
import openfl.utils.Object;

/**
 * ...
 * @author Christopher Speciale
 */
class Session 
{
	private static inline var HANDSHAKE:String = "handshake";
	private static inline var TRACE:String = "trace";
	
	public var date(default, null):Date;
	public var socket(default, null):Socket;
	public var hasForeground(get, set):Bool;
	private var __messageLength:Int = 0;
	private var __text:String = "";
	private var __hasForeground:Bool = false;
	
	private function get_hasForeground():Bool{
		return __hasForeground;
	}
	
	private function set_hasForeground(value:Bool):Bool{
		__hasForeground = value;
		Debug.instance.updateConsoleText(__text);
		return value;
	}
	public function new(socket:Socket) 
	{
		newLine("<-------- New session started -------->");
		
		date = Date.now();
		socket.endian = LITTLE_ENDIAN;
		socket.objectEncoding = AMF3;
		socket.addEventListener(ProgressEvent.SOCKET_DATA, __onData);
		socket.addEventListener(Event.CLOSE, __onClose);
		this.socket = socket;
	}
	
	public function newLine(text:String):Void{
		__text += '$text\n';
		
		if (hasForeground){
			Debug.instance.addConsoleText(text);
		}
	}
	
	private function __onData(e:ProgressEvent):Void{
		while (socket.bytesAvailable > 4){
			if (__messageLength == 0){
				__messageLength = socket.readUnsignedInt();
			}
			if (socket.bytesAvailable >= __messageLength){
				var bytes:ByteArray = new ByteArray(__messageLength);
				bytes.objectEncoding = AMF3;
				socket.readBytes(bytes, 0, __messageLength);
				
				var messageObject:IMessage = bytes.readObject();
				__parseMessage(messageObject);
				__messageLength = 0;
			} else {
				break;
			}
		}
	}
	
	private function __parseMessage(message:IMessage):Void{
		switch(message.type){
			case HANDSHAKE:
				__doHandshake();
			case TRACE:
				var arr:Array<Dynamic> = message.data;
				var log:String = arr.join(", ");
				var info = message.info;
				newLine('$info - $log');
		}
	}
	
	private function __doHandshake():Void{
		//todo
	}
	
	private function __onClose(e:Event):Void{
		newLine("--------> This session has ended. <--------");
	}
	
	public function close():Void{
		if (socket.connected){
			socket.close();
		}
	}
	
	public function save():Void{
		var file:File = new File('${File.documentsDirectory.nativePath}\\${date.getTime()}.txt');
		file.addEventListener(Event.SELECT, _onSaveSelect);
		file.browseForSave("Save As..");
	} 
	

	private function _onSaveSelect(e:Event):Void
	{
		var file:File = cast e.target;
		file.removeEventListener(Event.SELECT, _onSaveSelect);
		var path:String = file.nativePath;
		
		sys.io.File.saveContent(path, __text);
		
	}
}