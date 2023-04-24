package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;

	public class wSpriteHero extends Sprite
	{
		private var clothes:wClothing = null;
		private var viewStand:MovieClip;

		public function wSpriteHero():void
		{
			super();

			init();
		}

		private function init():void
		{
			this.viewStand = new HeroStand();
			this.viewStand.scaleX = -this.viewStand.scaleX;
			addChild(this.viewStand);

			this.clothes = new wClothing();		
			this.clothes.scaleX = -this.clothes.scaleX;
			addChild(this.clothes);
		}

		public function setClothes(data:Array):void
		{
			this.clothes.setItems(data);

			this.clothes.setState(wHero.STATE_REST, this.viewStand.currentFrame);
		}

		public function dressItem(id:int):void
		{
			this.clothes.dress(id);

			this.clothes.setState(wHero.STATE_REST, this.viewStand.currentFrame);
		}

		public function clearClothes():void
		{
			this.clothes.clear();
			
			this.clothes.setState(wHero.STATE_REST, this.viewStand.currentFrame);
		}
	}
}