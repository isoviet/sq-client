package tape
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import statuses.Status;

	public class TapeViralityQuestObject extends TapeObject
	{
		private var checkView:CheckViewImage;
		private var button:ButtonBase;

		public var typeQuest:uint;

		public function TapeViralityQuestObject(text:String, typeQuest:uint, index:int)
		{
			super();

			this.typeQuest = typeQuest;

			if (this.typeQuest == ViralityQuestManager.QUEST_INVITE)
				new Status(this, gls("Приглашенный друг должен достичь {0} уровень", Game.LEVEL_TO_FRIEND_INVITE));

			var backgroundImage:DisplayObject = new ViralityQuestTapeImage();
			addChild(backgroundImage);

			var textField:GameField = new GameField((index+1).toString() + '.', -24, 13, new TextFormat(GameField.PLAKAT_FONT, 19, 0xFE9D09, true));
			textField.filters = [new DropShadowFilter(0, 0, 0xF7F4EC, 1, 6, 6, 19, 1)];
			addChild(textField);

			this.checkView = new CheckViewImage();
			this.checkView.scaleX = this.checkView.scaleY = 1.5;
			this.checkView.x = 324;
			this.checkView.y = 12;
			addChild(this.checkView);

			textField = new GameField(text, 7, 15, new TextFormat(null, 13, 0x63421B));
			addChild(textField);

			this.button = new ButtonBase(gls("Выполнить").toUpperCase(), 90, 12);
			this.button.x = 262;
			this.button.y = 11;
			this.button.scaleX = this.button.scaleY = 1.05;
			this.button.addEventListener(MouseEvent.CLICK, onButtonClick);

			if (this.typeQuest != ViralityQuestManager.QUEST_LEVEL)
				addChild(this.button);
		}

		private function onButtonClick(e:MouseEvent):void
		{
			ViralityQuestManager.showQuest(this.typeQuest);
		}

		public function get selected():Boolean
		{
			return this.checkView.visible;
		}

		public function set selected(value:Boolean):void
		{
			this.button.visible = !value;
			this.checkView.visible = value;
		}
	}
}