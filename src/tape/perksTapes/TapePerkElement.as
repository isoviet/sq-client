package tape.perksTapes
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;

	import events.GameEvent;
	import game.gameData.ClothesManager;
	import game.gameData.GameConfig;
	import game.gameData.OutfitData;
	import game.mainGame.perks.clothes.PerkClothesFactory;
	import statuses.Status;
	import tape.TapeObject;

	import com.greensock.TweenMax;

	public class TapePerkElement extends TapeObject
	{
		protected var id:int = -1;
		protected var tween:TweenMax = null;

		protected var image:DisplayObject = null;
		protected var imageLock:DisplayObject = null;

		protected var status:Status = null;

		public function TapePerkElement(id:int = -1)
		{
			super();
			this.id = id;

			this.image = PerkClothesFactory.getNewImage(id);
			this.image.x = 25;
			this.image.y = 25;
			addChild(this.image);

			this.imageLock = new ImageLocationLock();
			this.imageLock.scaleX = this.imageLock.scaleY = 0.35;
			this.imageLock.x = 40;
			this.imageLock.y = 40;
			this.imageLock.filters = [new GlowFilter(0x000000, 1, 4, 4, 8)];
			addChild(this.imageLock);

			var text:String = "<body><b>" + PerkClothesFactory.getName(id) + "</b>\n" + PerkClothesFactory.getDescription(id) + "</body>";
			this.status = new Status(this, text, false, true);

			addEventListener(MouseEvent.ROLL_OVER, onOver);
			addEventListener(MouseEvent.ROLL_OUT, onOut);

			ClothesManager.addEventListener(GameEvent.CLOTHES_STORAGE_CHANGE, update);
			update();
		}

		protected function update(e:GameEvent = null):void
		{
			var packageId:int = OutfitData.perkToPackage(this.id);

			var allow:Boolean = ClothesManager.haveItem(packageId, ClothesManager.KIND_PACKAGES);
			allow = allow && (GameConfig.getPackageSkillLevel(packageId, this.id) <= ClothesManager.getPackagesLevel(packageId));
			this.image.alpha = allow ? 1 : 0.5;
			this.imageLock.visible = !allow;
		}

		protected function onOut(e:MouseEvent):void
		{
			if (this.tween)
				this.tween.kill();
			this.tween = TweenMax.to(this.image, 0.2, {'glowFilter': {'color': 0xFFCC33, 'alpha': 1, 'blurX': 0, 'blurY': 0, 'strength': 1}});
		}

		protected function onOver(e:MouseEvent):void
		{
			if (this.tween)
				this.tween.kill();
			this.tween = TweenMax.to(this.image, 0.2, {'glowFilter': {'color': 0xFFCC33, 'alpha': 1, 'blurX': 10, 'blurY': 10, 'strength': 1}});
		}
	}
}