package debug;
import feathers.controls.ToggleButton;

/**
 * @author Christopher Speciale
 */
interface ISessionTabData 
{
	public var timestamp:Float;
	public var title:String;
	public var tab:ToggleButton;
	public var session:Session;
}