package service;
import openfl.events.Event;
import openfl.net.Socket;
import openfl.utils.ByteArray;
import openfl.utils.Object;

/**
 * ...
 * @author Christopher Speciale
 */
class Client 
{

	private var __socket:Socket;
	
	public function new() 
	{
		__socket = new Socket();
		__socket.endian = LITTLE_ENDIAN;
		__socket.addEventListener(Event.CONNECT, __onConnect);
		__socket.connect("127.0.0.1", 17357);
		
	}
	
	private function __onConnect(e:Event):Void
	{
		
		var msg:IMessage = new Object();
		msg.type = "trace";
		msg.data = "Hello World";
		
		var bytes:ByteArray = new ByteArray();
		bytes.endian = LITTLE_ENDIAN;
		bytes.writeObject(msg);
		bytes.position = 0;
				
		__socket.writeUnsignedInt(bytes.length);
		__socket.writeBytes(bytes);
		__socket.flush();
	}
	
}