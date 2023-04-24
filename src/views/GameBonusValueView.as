package views
{
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;

	import com.greensock.TweenMax;

	public class GameBonusValueView extends Sprite
	{
		public function GameBonusValueView(value:*, fromX:int, fromY:int, format:TextFormat = null, time:Number = 0.7):void
		{
			super();

			var valueFormat:TextFormat = format ? format : new TextFormat(GameField.DEFAULT_FONT, 18, 0xFFF52C, true);

			var valueField:GameField = new GameField("+" + value, 0, 0, valueFormat);
			valueField.filters = [new DropShadowFilter(0, 0, 0x003584, 1, 2, 2, 12.5)];
			addChild(valueField);

			this.x = fromX;
			this.y = fromY;

			var _localInstanse:GameBonusValueView = this;
			TweenMax.to(_localInstanse, time, {'y': _localInstanse.y - 100, 'onComplete': function():void
			{
				TweenMax.to(_localInstanse, 1, {'alpha': 0, 'onComplete': function():void
				{
					if (_localInstanse.parent == null)
						return;
					if (!_localInstanse.parent.contains(_localInstanse))
						return;
					_localInstanse.parent.removeChild(_localInstanse);
				}});
			}});
		}
	}
}