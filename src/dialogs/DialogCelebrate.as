package dialogs
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import views.ClothesImageSmallLoader;

	import protocol.packages.server.PacketBonuses;

	public class DialogCelebrate extends Dialog
	{
		static public const FORMAT_CAPTION:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 36, 0xFFFFFF, null, null, null, null, null, "center");
		static public const FORMAT_TEXT:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 14, 0x857653, null, null, null, null, null, "center");
		static public const FORMAT_BONUS:TextFormat = new TextFormat(null, 18, 0x724124, true);

		private var lastX:int = 0;
		private var spriteBonus:Sprite = null;

		private var bonuses:PacketBonuses = null;

		public function DialogCelebrate(bonuses:PacketBonuses)
		{
			super("", false, false, null, false);

			this.bonuses = bonuses;

			init();
		}

		private function init():void
		{
			addChild(new DialogCelebrateBack);

			addChild(new GameField(gls("Поздравляем!"), 0, 145, FORMAT_CAPTION, 440));
			addChild(new GameField(gls("День победы в Трагедии Белок!"), 0, 205, FORMAT_TEXT, 440));
			addChild(new GameField(gls("Мы дарим тебе:"), 0, 225, FORMAT_TEXT, 440));

			var button:ButtonBase = new ButtonBase(gls("Ок"));
			button.x = 220 - int(button.width * 0.5);
			button.y = 320;
			button.addEventListener(MouseEvent.CLICK, hide);
			addChild(button);

			fillBonuses();

			place();

			this.graphics.beginFill(0x000000, 0.5);
			this.graphics.drawRect(-this.x, -this.y, Config.GAME_WIDTH, Config.GAME_HEIGHT);
		}

		private function fillBonuses():void
		{
			this.spriteBonus = new Sprite();

			if (this.bonuses.nuts > 0)
				addBonus(this.bonuses.nuts.toString(), new ImageIconNut);
			if (this.bonuses.energy > 0)
				addBonus(this.bonuses.energy.toString(), new ImageIconEnergy);
			if (this.bonuses.mana > 0)
				addBonus(this.bonuses.mana.toString(), new ImageIconMana);
			if (this.bonuses.experience > 0)
				addBonus(this.bonuses.experience.toString(), new ImageIconExp);
			if (this.bonuses.coins > 0)
				addBonus(this.bonuses.coins.toString(), new ImageIconCoins);
			if (this.bonuses.vipDuration > 0)
				addBonus(this.bonuses.vipDuration.toString(), new ImageIconVIP);
			if (this.bonuses.manaRegenerationDuration > 0)
				addBonus(this.bonuses.manaRegenerationDuration.toString(), new ImageIconMana);
			if (this.bonuses.accessories != null)
				for (var i:int = 0; i < this.bonuses.accessories.length; i++)
				{
					var icon:DisplayObject = new ClothesImageSmallLoader(this.bonuses.accessories[i].accessoryId);
					icon.scaleX = icon.scaleY = 0.8;
					icon.y = -9;
					addBonus("", icon);
				}

			this.spriteBonus.scaleX = this.spriteBonus.scaleY = 1.5;
			this.spriteBonus.x = 220 - int(this.spriteBonus.width * 0.5);
			this.spriteBonus.y = 260;
			addChild(this.spriteBonus);
		}

		private function addBonus(count:String, icon:DisplayObject):void
		{
			var fieldBonus:GameField = new GameField(count, this.lastX, 0, FORMAT_BONUS);
			this.spriteBonus.addChild(fieldBonus);

			this.lastX += fieldBonus.width + 2;

			icon.x = this.lastX;
			this.spriteBonus.addChild(icon);

			this.lastX += icon.width + 15;
		}
	}
}