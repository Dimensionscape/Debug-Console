package;

import console.Console;
import debug.Debug;
import openfl.display.Sprite;
import openfl.Lib;
import service.Client;
import view.ConsoleView;

/**
 * ...
 * @author Christopher Speciale
 */
class Main extends Sprite 
{

	public function new() 
	{
		super();
		
		Debug.init();
		
		//For testing only
		//new Client();
	}

}
