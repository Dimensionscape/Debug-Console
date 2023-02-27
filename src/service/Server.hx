package service;
import debug.Debug;
import debug.Session;
import openfl.net.ServerSocket;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.ServerSocketConnectEvent;
import openfl.net.Socket;

/**
 * ...
 * @author Christopher Speciale
 */
class Server
{

	public static inline var LOCAL_HOST:String = "127.0.0.1";
	public static inline var DEFAULT_PORT:Int = 17357;
	private var __serverSocket:ServerSocket;
	
	public function new()
	{
		__serverSocket = new ServerSocket();
		__serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, __onConnect);
		__serverSocket.addEventListener(IOErrorEvent.IO_ERROR, __onError);
		__serverSocket.bind(DEFAULT_PORT, LOCAL_HOST);
		__serverSocket.listen();
	}
	
	private function __onError(e:IOErrorEvent):Void{
		throw "Error binding socket to the localhost at port: " + __serverSocket.localPort;
	}

	 private function __onConnect(event:ServerSocketConnectEvent):Void {
        var sessionSocket:Socket = event.socket;
        Debug.instance.createSession(sessionSocket);
    }
}