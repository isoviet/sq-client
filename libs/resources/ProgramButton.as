package
{
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;

	public class ProgramButton extends SimpleButton 
	{
		public function ProgramButton() 
		{
			super();

			addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			addEventListener(MouseEvent.ROLL_OVER, onOver);
		}
		
		private function onDown(e:MouseEvent):void
		{
			GameSoundsLib.play("click");
		}
		
		private function onOver(e:MouseEvent):void
		{

		}
	}
}