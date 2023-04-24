package tape.perksTapes
{
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;

	import dialogs.DialogExtraPerk;
	import events.GameEvent;
	import game.gameData.ClothesManager;
	import game.mainGame.perks.clothes.PerkClothesFactory;
	import statuses.Status;

	public class TapePerkExtraElement extends TapePerkElement
	{
		protected var packageId:int = -1;
		protected var buttonSlot:SimpleButton = null;

		public function TapePerkExtraElement(packageId:int = -1)
		{
			this.packageId = packageId;

			this.buttonSlot = new ButtonPerkExtraSlot();
			this.buttonSlot.x = 25;
			this.buttonSlot.y = 25;
			addChild(this.buttonSlot);

			super(ClothesManager.getPackageExtraSkill(packageId));

			ClothesManager.addEventListener(GameEvent.CLOTHES_STORAGE_CHANGE, onChange);
			ClothesManager.addEventListener(GameEvent.CLOTHES_STORAGE_CHANGE_MAGIC, onChange);

			addEventListener(MouseEvent.CLICK, showDialog);
		}

		override protected function update(e:GameEvent = null):void
		{
			super.update();

			if (this.id == 0)
				this.imageLock.visible = false;
		}

		private function onChange(e:GameEvent):void
		{
			if (this.id == ClothesManager.getPackageExtraSkill(this.packageId))
				return;
			if (this.image)
				removeChild(this.image);

			this.id = ClothesManager.getPackageExtraSkill(this.packageId);

			this.image = PerkClothesFactory.getNewImage(this.id);
			this.image.x = 25;
			this.image.y = 25;
			addChild(this.image);

			if (this.status)
				this.status.remove();
			var text:String = "<body><b>" + PerkClothesFactory.getName(id) + "</b>\n" + PerkClothesFactory.getDescription(id) + "</body>";
			this.status = new Status(this, text, false, true);

			update();
		}

		private function showDialog(e:MouseEvent):void
		{
			DialogExtraPerk.show(this.packageId);
		}
	}
}