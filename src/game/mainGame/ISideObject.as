package game.mainGame
{
	import utils.starling.StarlingAdapterSprite;

	public interface ISideObject
	{
		function get sideIcon(): StarlingAdapterSprite;
		function get showIcon():Boolean;
		function get isVisible():Boolean;
		function set isVisible(value: Boolean): void;
	}
}