package views.shamanTree
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import events.GameEvent;
	import game.gameData.VIPManager;
	import statuses.StatusShamanExp;

	import utils.BarScale;

	public class ShamanExperienceView extends Sprite
	{

		private var levelBar:BarScale;

		private var isDouble:Boolean = false;
		private var remainedValue:int;

		private var status:StatusShamanExp;

		private var percentField:GameField;

		public function ShamanExperienceView():void
		{
			super();

			init();
		}

		public function setData(exp:int):void
		{
			var rank:int = ShamanExperience.getLevel(exp);
			var remaind:int = ShamanExperience.getRemindExp(exp);
			var max:int;

			if (rank > 1)
				max = ShamanExperience.get(rank) - ShamanExperience.get(rank - 1);
			else
				max = ShamanExperience.get(rank);

			this.levelBar.setValues(max - remaind, max);

			this.remainedValue = ShamanExperience.get(rank) - exp;

			this.status.setExpirience(this.remainedValue);

			this.percentField.text = String(Math.floor(Number(max - remaind) * 100 / max)) + "%";
		}

		private function init():void
		{
			this.levelBar = new BarScale([
				{'image': new ShamanBarBackground, 'X': 0, 'Y': 0},
				{'image': new ShamanBarOrange, 'X': 2, 'Y': 2, 'width': 680},
				{'image': new ShamanBarViolet, 'X': 2, 'Y': 2, 'width': 680}
			], false);
			addChild(this.levelBar);

			this.status = new StatusShamanExp(this.levelBar);

			var percentFormat:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 18, 0xFFFFFF, true);
			percentFormat.align = TextFormatAlign.CENTER;

			this.percentField = new GameField("0%", 292, -1, percentFormat);
			this.percentField.width = 100;
			this.percentField.autoSize = TextFieldAutoSize.CENTER;
			this.percentField.antiAliasType = AntiAliasType.NORMAL;
			this.percentField.filters = [new DropShadowFilter(0, 0, 0x000000, 1, 2, 2, 1)];
			this.percentField.mouseEnabled = false;
			addChild(this.percentField);

			this.doubleWithoutAnimation = VIPManager.haveVIP;
			setData(Game.self['shaman_exp']);

			VIPManager.addEventListener(GameEvent.VIP_START, onVIP);
			VIPManager.addEventListener(GameEvent.VIP_END, onVIP);
		}

		private function glowEnd(e:Event):void
		{
			removeChild(e.target as MovieClip);

			var lightning:ShamanBarLightning = new ShamanBarLightning();
			lightning.x = 695;
			lightning.addEventListener(Event.CHANGE, lightningEnd);
			addChild(lightning);
		}

		private function lightningEnd(e:Event):void
		{
			removeChild(e.target as MovieClip);
		}

		private function set doubleWithoutAnimation(value:Boolean):void
		{
			this.isDouble = value;
			this.levelBar.changeSuper(value);

			this.status.setExpirience(this.remainedValue);
		}

		private function set double(value:Boolean):void
		{
			if (this.isDouble == value)
				return;
			var oldWidth:int = this.levelBar.getWidth();

			doubleWithoutAnimation = value;

			if (!value)
				return;

			var glow:ShamanBarGlow = new ShamanBarGlow();
			glow.movieMask.width = oldWidth;
			glow.movieMask.x = -width;
			glow.x = oldWidth;
			glow.addEventListener(Event.CHANGE, glowEnd);
			addChild(glow);
		}

		private function onVIP(e:GameEvent):void
		{
			this.double = VIPManager.haveVIP;
		}
	}
}