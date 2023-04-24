package views
{
	import flash.display.Sprite;
	import flash.filters.GlowFilter;

	import events.DiscountEvent;
	import events.GameEvent;
	import game.gameData.PowerManager;

	import utils.Bar;
	import utils.FiltersUtil;

	public class ManaView extends Sprite
	{
		static private const FILTER:GlowFilter = new GlowFilter(0x0099FF, 1.0, 3, 3, 1.0);

		private var manaBar:Bar;

		public function ManaView():void
		{
			init();

			PowerManager.addEventListener(GameEvent.MANA_CHANGED, update);
			PowerManager.addEventListener(GameEvent.MAX_POWERS_CHANGED, update);
			DiscountManager.addEventListener(DiscountEvent.BONUS_START, onBonus);

			update();
		}

		private function init():void
		{
			var back:ManaBarImage = new ManaBarImage();
			back.filters = FiltersUtil.BLACK_FILTER;

			var active:ManaBarImage = new ManaBarImage();
			active.filters = [FILTER];

			this.manaBar = new Bar([
				{'image': back,		'X': 0,		'Y': 0},
				{'image': active,	'X': 0,		'Y': 0}
			], 75);
			addChild(this.manaBar);
		}

		private function onBonus(e:DiscountEvent):void
		{
			if (e.id != DiscountManager.FREE_MANA_NP)
				return;
			update();
		}

		private function update(e:GameEvent = null):void
		{
			this.manaBar.setValues(PowerManager.currentMana, PowerManager.maxMana);
		}
	}
}