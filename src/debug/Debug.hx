package debug;
import openfl.events.Event;
import menu.MenuManager;
import openfl.Lib;
import openfl.display.Stage;
import openfl.net.Socket;
import service.Server;
import view.ConsoleView;

/**
 * ...
 * @author Christopher Speciale
 */
class Debug 
{
	public static var instance:Debug;
	public static inline function init():Void{
		instance = new Debug();
	}
	
	private var __stage:Stage;
	private var __server:Server;
	private var __consoleView:ConsoleView;
	
	private function new (){
		
		MenuManager.start();
		MenuManager.eventDispatcher.addEventListener(MenuManager.SAVE_SESSION_LOGS, __onSaveSessionLogs);
		MenuManager.eventDispatcher.addEventListener(MenuManager.CLOSE, __onClose);
		MenuManager.eventDispatcher.addEventListener(MenuManager.CLOSE_ALL, __onCloseAll);
		
		__stage = Lib.current.stage;
		__consoleView = new ConsoleView();
		__stage.addChild(__consoleView);		
		
		__server = new Server();
		
	}
	
	private function __onCloseAll(e:Event):Void{
		__consoleView.closeCurrentSession();
	}
	
	private function __onClose(e:Event):Void{
		__consoleView.closeAllSessions();
	}
	
	private function __onSaveSessionLogs(e:Event):Void{
		__consoleView.saveCurrentSession();
	}
	
	public function createSession(socket:Socket):Void{
		var session:Session = new Session(socket);
		__consoleView.createTab(session);
	}
	
	public function updateConsoleText(text:String):Void{
		__consoleView.console.setText(text);
	}
	
	public function addConsoleText(text:String):Void{
		__consoleView.console.addText(text);
	}
}