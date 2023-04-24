package dialogs
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonBase;

	import utils.FieldUtils;

	public class DialogSaveMap extends Dialog
	{
		static private const ACORNS_COST:int = 200;

		private var onCancelFunction:Function;
		private var onSuccessFunction:Function;
		private var content:GameField = null;
		private var awardSprite:Sprite = null;

		public function DialogSaveMap(onCancelFunction:Function, onSuccessFunction:Function):void
		{
			super(gls("Сохранение карты"), true, false);

			this.onCancelFunction = onCancelFunction;
			this.onSuccessFunction = onSuccessFunction;

			this.awardSprite = new Sprite();
			addChild(awardSprite);

			this.content = new GameField("", 10, 0, new TextFormat(null, 14, 0x1f1f1f));
			this.awardSprite.addChild(this.content);

			var buttonSend:ButtonBase = new ButtonBase(gls("Отправить"));
			buttonSend.addEventListener(MouseEvent.CLICK, send, false, 0, true);

			var buttonCancel:ButtonBase = new ButtonBase(gls("Отмена"));
			buttonCancel.addEventListener(MouseEvent.CLICK, onCancel, false, 0, true);

			place(buttonSend, buttonCancel);

			FieldUtils.replaceSign(this.content, "#Ac", ImageIconNut, 0.6, 0.6, -10, 0, false);
		}

		override public function show():void
		{
			this.content.text = gls("Отправление карты на модерацию стоит {0} #Ac.{1}", ACORNS_COST, (Locations.getLocation(DialogMapInfo.location).award > 0 ? gls("\nВ случае её одобрения модератором,\nвы получите {0} #Ac.", Locations.getLocation(DialogMapInfo.location).award) : ""));

			while (this.awardSprite.numChildren > 0)
				this.awardSprite.removeChildAt(0);

			this.awardSprite.addChild(this.content);
			FieldUtils.replaceSign(this.content, "#Ac", ImageIconNut, 0.6, 0.6, -10, 0, false);

			this.width = this.content.width + 50;
			this.height = this.content.height + 80;
			super.show();
		}

		private function onCancel(e:MouseEvent = null):void
		{
			super.hide();

			this.onCancelFunction();
		}

		private function send(e:MouseEvent):void
		{
			if (Game.self.nuts < ACORNS_COST)
				return;

			this.onSuccessFunction();

			hide();
		}
	}
}