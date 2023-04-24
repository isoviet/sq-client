package views.content
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import game.mainGame.perks.clothes.PerkClothesFactory;
	import statuses.Status;

	import com.greensock.TweenMax;

	public class PerkWidget extends Sprite
	{
		protected var tween:TweenMax = null;
		protected var image:DisplayObject = null;

		public function PerkWidget(id:int = -1)
		{
			super();

			this.image = PerkClothesFactory.getNewImage(id);
			addChild(this.image);

			var text:String = "<body><b>" + PerkClothesFactory.getName(id) + "</b>\n" + PerkClothesFactory.getDescription(id) + "</body>";
			new Status(this, text, false, true);

			addEventListener(MouseEvent.ROLL_OVER, onOver);
			addEventListener(MouseEvent.ROLL_OUT, onOut);
		}

		protected function onOut(e:MouseEvent):void
		{
			if (this.tween)
				this.tween.kill();
			this.tween = TweenMax.to(this.image, 0.2, {'glowFilter': {'color': 0xFFCC33, 'alpha': 1, 'blurX': 0, 'blurY': 0, 'strength': 1}});
		}

		protected function onOver(e:MouseEvent):void
		{
			if (this.tween)
				this.tween.kill();
			this.tween = TweenMax.to(this.image, 0.2, {'glowFilter': {'color': 0xFFCC33, 'alpha': 1, 'blurX': 10, 'blurY': 10, 'strength': 1}});
		}
	}
}