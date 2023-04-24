package game.mainGame.behaviours
{
	import game.mainGame.IUpdate;

	public class Behaviour implements IUpdate
	{
		public var hero:Hero;

		public function Behaviour()
		{}

		public function update(timeStep:Number = 0):void
		{}

		public function remove():void
		{}

		public function init():void
		{}
	}
}