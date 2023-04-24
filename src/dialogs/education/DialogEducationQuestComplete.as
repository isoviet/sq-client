package dialogs.education
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;

	import dialogs.Dialog;
	import game.gameData.EducationQuestManager;
	import views.LoadGameAnimation;

	public class DialogEducationQuestComplete extends Dialog
	{
		static private const TIME_SHOW:Number = 0.5;
		static private const TIME_SHADOW:Number = 1.0;
		static private const TIME_VISIBLE:Number = 4.5;
		static private const TIME_HIDE:Number = 5.5;

		static private const FILTER:GlowFilter = new GlowFilter(0x171C3F, 1, 5, 5);
		static private const FILTER_SHADOW:GlowFilter = new GlowFilter(0x000000, 1, 250, 125, 2, 3);

		private var id:int = -1;

		private var time:Number = 0.0;

		static public function show(id:int):void
		{
			new DialogEducationQuestComplete(id).show();
		}

		public function DialogEducationQuestComplete(id:int):void
		{
			super(null, false, false, null, false);

			this.id = id;

			init();
		}

		override public function show():void
		{
			super.show();
			this.y = 330;

			EnterFrameManager.addListener(onTime);
			onTime(0);
		}

		override public function hide(e:MouseEvent = null):void
		{
			super.hide();

			EnterFrameManager.removeListener(onTime);
		}

		private function init():void
		{
			addChild(new EducationQuestCompleteBack);

			var quest:Object = EducationQuestManager.getQuest(this.id);

			var icon:DisplayObject = new quest['icon'];
			icon.width = icon.height = 58;
			icon.x = 132;
			icon.y = 25;
			addChild(icon);

			var field:GameField = new GameField(gls("Выполнено задание:"), 0, 100, new TextFormat(null, 14, 0xFFFA83, true));
			field.x = 160 - int(field.textWidth * 0.5);
			addChild(field);

			field = new GameField(quest['name'], 0, 130, new TextFormat(GameField.PLAKAT_FONT, 18, 0xFFFFFF));
			field.x = 160 - int(field.textWidth * 0.5);
			field.filters = [FILTER];
			addChild(field);

			place();
		}

		private function onTime(delay:Number = -1):void
		{
			if (delay == -1 && !LoadGameAnimation.instance.isOpened)
				return;
			this.time += delay == -1 ? EnterFrameManager.delay : delay;

			if (this.time <= TIME_SHOW)
			{
				var delta:Number = this.time / TIME_SHOW;
				var deltaC:int = 255 * (1 - delta);
				this.filters = [new ColorMatrixFilter([1, 0, 0, 0, deltaC,
								0, 1, 0, 0, deltaC,
								0, 0, 1, 0, deltaC,
								0, 0, 0, Math.max(1, 2 * delta), 0])];
			}
			else if (this.time <= TIME_SHADOW)
				this.filters = [new GlowFilter(0x000000, 1, int(250 * (this.time / TIME_SHADOW)), int(125 * (this.time / TIME_SHADOW)), 2, 3)];
			if (this.time > TIME_SHADOW)
				this.filters = [FILTER_SHADOW];
			if (this.time >= TIME_VISIBLE)
				this.alpha = Math.max(0, TIME_HIDE - this.time);
			if (this.time >= TIME_HIDE)
				hide();
		}
	}
}