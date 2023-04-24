package game.mainGame.entity.simple
{
	public class PoiseInvisible extends Poise
	{
		public function PoiseInvisible():void
		{
			super();
			this.view.alpha = 0.3;
		}
	}
}