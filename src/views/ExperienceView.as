package views
{
	import flash.display.Sprite;
	import flash.filters.GlowFilter;

	import utils.Bar;
	import utils.FiltersUtil;

	public class ExperienceView extends Sprite
	{
		static private const FILTER:GlowFilter = new GlowFilter(0xFFFF00, 1.0, 3, 3, 1.0);
		static private const FILTER_DOUBLE:GlowFilter = new GlowFilter(0x9900CC, 1.0, 3, 3, 1.0);

		private var levelBar:Bar;

		private var simpleBarImage:ExperienceBarImage = new ExperienceBarImage();
		private var doubleBarImage:ExperienceBarDoubleImage = new ExperienceBarDoubleImage();

		private var isDouble:Boolean = false;
		private var remainedValue:int;

		public function ExperienceView():void
		{
			super();

			init();
		}

		public function set double(value:Boolean):void
		{
			this.isDouble = value;
			this.levelBar.changeActive((value ? this.doubleBarImage : this.simpleBarImage), 0, 0);
		}

		public function get double():Boolean
		{
			return this.isDouble;
		}

		public function updateData():void
		{
			this.remainedValue = Experience.remainedExp;
			this.levelBar.setValues(Experience.getMaxExp(Experience.selfExp) - this.remainedValue, Experience.getMaxExp(Experience.selfExp));
		}

		private function init():void
		{
			var back:ExperienceBarImage = new ExperienceBarImage();
			back.filters = FiltersUtil.BLACK_FILTER;

			this.simpleBarImage.filters = [FILTER];
			this.doubleBarImage.filters = [FILTER_DOUBLE];

			this.levelBar = new Bar([
				{'image': back, 'X': 0, 'Y': 0},
				{'image': this.simpleBarImage, 'X': 0, 'Y': 0}
			], 70, true);
			addChild(this.levelBar);
		}
	}
}