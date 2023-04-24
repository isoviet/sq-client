package game.mainGame.perks.clothes
{
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import com.greensock.TweenMax;

	import utils.Rotator;

	public class PerkClothesSpartan extends PerkClothes
	{
		static private const MIN_SPEED_BONUS:int = 15;
		static private const HERO_SPEED_FACTOR:int = 3;

		private var _highSpeed:Boolean = false;
		private var bonus:Number;

		public function PerkClothesSpartan(hero:Hero):void
		{
			super(hero);

			this.activateSound = "sparta";
		}

		override public function get totalCooldown():Number
		{
			return 10;
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get activeTime():Number
		{
			return 15.0;
		}

		override protected function activate():void
		{
			super.activate();

			this.highSpeed = true;
			showPerkAnimation();
		}

		override protected function deactivate():void
		{
			super.deactivate();

			this.highSpeed = false;

			if (this.hero && this.hero.isSelf)
				this.hero.heroView.hidePerkAnimationPermanent();
		}

		private function set highSpeed(value:Boolean):void
		{
			if (this._highSpeed == value)
				return;
			this._highSpeed = value;

			if (value)
			{
				var spartansCount:int = 0;
				for each (var hero:Hero in this.hero.game.squirrels.players)
					if (hero.perkController.getPerkLevel(this.code) != -1 && !hero.isSelf && !hero.shaman && !hero.isDragon && !hero.isHare && !hero.isScrat)
						spartansCount++;

				this.bonus = this.hero.runSpeed * (MIN_SPEED_BONUS + HERO_SPEED_FACTOR * spartansCount) / 100;
			}

			this.hero.runSpeed += this.bonus * (value ? 1 : -1);
		}

		private function showPerkAnimation():void
		{
			if (!this.hero)
				return;

			if (this.hero.isSelf)
				this.hero.heroView.showPerkAnimationPermanent(new HighSpeedButton);
			showSparta();
		}

		private function showSparta():void
		{
			var sparta:Sprite = new Sprite();
			sparta.x = this.hero.x + 15;
			sparta.y = this.hero.y - 42;

			var format:TextFormat = new TextFormat(null, 20, 0xF84700, true);
			format.leading = -4;
			format.align = TextFormatAlign.CENTER;

			var messageField:GameField = new GameField(gls("ЭТО СПАРТА!"), 0, 0, format);
			messageField.width = 180;
			messageField.wordWrap = true;
			messageField.multiline = true;
			messageField.filters = [new GlowFilter(0xFFFF99, 1, 2, 2, 2)];
			messageField.x = -90;
			sparta.addChild(messageField);

			var rot:Rotator = new Rotator(messageField, new Point(90, messageField.textHeight));
			rot.rotation = 20;

			this.hero.game.squirrels.addChild(sparta);

			var dstX:int = messageField.x + 30;
			var dstY:int = messageField.y - 50;

			TweenMax.to(messageField, 0.9, {'x': dstX, 'y': dstY, 'onComplete': function():void
			{
				TweenMax.to(messageField, 0.5, {'delay': 0.5, 'alpha': 0, 'onComplete': function():void{
					if (sparta.parent != null)
						sparta.parent.removeChild(sparta);
				}});
			}});
		}
	}
}