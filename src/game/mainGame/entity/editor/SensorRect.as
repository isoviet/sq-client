package game.mainGame.entity.editor
{
	import game.mainGame.entity.INetHidden;

	public class SensorRect extends Sensor implements INetHidden
	{
		public function SensorRect():void
		{
			super();
			this.rect = true;
		}
	}
}