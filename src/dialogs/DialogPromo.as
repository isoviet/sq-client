package dialogs
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import views.PackageImageLoader;

	public class DialogPromo extends Dialog
	{
		static private const FORMAT:TextFormat = new TextFormat(null, 12, 0x673401, true, null, null, null, null, "center");

		static public const SUCCESS:int = 0;
		static public const FAIL:int = 1;
		static public const USED:int = 2;

		static public const VIP:int = 0;
		static public const PACKAGE:int = 1;

		private var state:int = 0;
		private var type:int = 0;
		private var data:int = 0;

		private var image:DisplayObject = null;
		private var field:GameField = null;
		private var fieldValue:GameField = null;

		public function DialogPromo(state:int, type:int = 0, data:int = 0):void
		{
			super(gls("Промо-акция"));

			this.state = state;
			this.type = type;
			this.data = data;

			switch (state)
			{
				case SUCCESS:
					this.field = new GameField(gls("Ты получил награду за участие в промо-акции!\nОставайся с нами и получай ещё больше бонусов!"), 0, 0, FORMAT);
					addChild(this.field);

					switch (type)
					{
						case VIP:
							this.image = new VIPShopSmallImage();
							this.image.scaleX = this.image.scaleY = 1.3;
							this.image.y = this.field.textHeight + 15;
							addChild(this.image);

							this.fieldValue = new GameField(gls("VIP-статус на час"), 0, 0, FORMAT);
							addChild(this.fieldValue);
							break;
						case PACKAGE:
							this.image = new PackageImageLoader(this.data);
							this.image.y = this.field.textHeight - 25;
							addChild(this.image);

							this.fieldValue = new GameField(ClothesData.getPackageTitleById(this.data) + gls(" на час"), 0, 0, FORMAT);
							addChild(this.fieldValue);
							break;
					}

					this.image.x = (this.field.textWidth - this.image.width) * 0.5;

					this.fieldValue.x = (this.field.textWidth - this.fieldValue.width) * 0.5;
					this.fieldValue.y = this.image.y + this.image.height + 5;
					break;
				case FAIL:
					this.field = new GameField(gls("Все подарки уже разобрали! Будь начеку,\nи в следующий раз тебе обязательно повезёт!"), 0, 0, FORMAT);
					addChild(this.field);
					break;
				case USED:
					this.field = new GameField(gls("Ты уже получил награду за участие в промо-акции!\nОставайся с нами и получай ещё больше бонусов!"), 0, 0, FORMAT);
					addChild(this.field);
					break;
			}

			var button:ButtonBase = new ButtonBase(gls("Ок"));
			button.addEventListener(MouseEvent.CLICK, hide);
			button.x = (this.field.textWidth - button.width) * 0.5;
			button.y = state == SUCCESS ? this.fieldValue.y + this.fieldValue.textHeight + 5 : this.field.y + this.field.textHeight + 5;
			addChild(button);

			place();

			this.height = button.y + button.height + 45;
		}
	}
}