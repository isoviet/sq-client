package views
{
	import flash.display.Sprite;
	import flash.filters.GlowFilter;

	import events.GameEvent;
	import game.gameData.PowerManager;

	import utils.Bar;
	import utils.FiltersUtil;

	public class EnergyView extends Sprite
	{
		static private const FILTER:GlowFilter = new GlowFilter(0x66FF00, 1.0, 3, 3, 1.0);

		private var energyBar:Bar = null;

		public function EnergyView():void
		{
			init();

			PowerManager.addEventListener(GameEvent.ENERGY_CHANGED, update);
			PowerManager.addEventListener(GameEvent.MAX_POWERS_CHANGED, update);

			update();
		}

		private function init():void
		{
			var back:EnergyBarImage = new EnergyBarImage();
			back.filters = FiltersUtil.BLACK_FILTER;

			var active:EnergyBarImage = new EnergyBarImage();
			active.filters = [FILTER];

			this.energyBar = new Bar([
				{'image': back,		'X': 0,		'Y': 0},
				{'image': active,	'X': 0,		'Y': 0}
			], 75);
			addChild(this.energyBar);
		}

		private function update(e:GameEvent = null):void
		{
			this.energyBar.setValues(PowerManager.currentEnergy, PowerManager.maxEnergy);
		}
	}
}