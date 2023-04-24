package game.mainGame.gameBattleNet.achieves
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import com.greensock.TweenMax;

	import utils.Rotator;

	public class AchievementMessageAnimation extends Sprite
	{
		private var messageField:GameField = null;

		private var tween:TweenMax = null;

		public function AchievementMessageAnimation(message:String, owner:DisplayObjectContainer, x:int, y:int):void
		{
			this.x = x;
			this.y = y;

			var format:TextFormat = new TextFormat(null, 20, 0xF84700, true);
			format.leading = -4;
			format.align = TextFormatAlign.CENTER;

			this.messageField = new GameField(message, 0, 0, format);
			this.messageField.width = 180;
			this.messageField.wordWrap = true;
			this.messageField.multiline = true;
			this.messageField.filters = [new GlowFilter(0xFFFF99, 1, 2, 2, 2)];
			this.messageField.x = -90;
			addChild(this.messageField);

			var rot:Rotator = new Rotator(this.messageField, new Point(90, this.messageField.textHeight));
			rot.rotation = 20;

			owner.addChild(this);

			var dstX:int = this.messageField.x + 30;
			var dstY:int = this.messageField.y - 50;

			this.tween = TweenMax.to(this.messageField, 0.9, {'x': dstX, 'y': dstY, 'onComplete': function():void
			{
				tween = TweenMax.to(messageField, 0.5, {'alpha': 0, 'onComplete': dispose});
			}});
		}

		public function dispose():void
		{
			if (this.tween != null)
				this.tween.kill();

			this.tween = null;

			if (this.parent != null)
				this.parent.removeChild(this);
		}
	}
}