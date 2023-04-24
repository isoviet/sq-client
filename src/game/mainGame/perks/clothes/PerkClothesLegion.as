package game.mainGame.perks.clothes
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;

	import clans.ClanManager;
	import views.ClanPhotoLoader;

	public class PerkClothesLegion extends PerkClothes
	{
		private var view:MovieClip = null;

		public function PerkClothesLegion(hero:Hero):void
		{
			super(hero);
			this.activateSound = SOUND_APPEARANCE;
			this.soundOnlyHimself = true;
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get canTurnOff():Boolean
		{
			return false;
		}

		override public function get totalCooldown():Number
		{
			return 5;
		}

		override public function get activeTime():Number
		{
			return 15;
		}

		override protected function activate():void
		{
			super.activate();

			if (!this.hero.game)
				return;

			this.view = new LegionPerkView;
			var position:Point = this.hero.getPosition();
			this.view.x = position.x;
			this.view.y = position.y + Hero.Y_POSITION_COEF;
			this.view.rotation = this.hero.rotation;
			this.hero.game.map.objectSprite.addChild(this.view);

			this.view.addEventListener(Event.ENTER_FRAME, onFrame);
			this.view.play();
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (this.view && this.view.parent)
			{
				this.view.parent.removeChild(this.view);
				this.view.removeEventListener(Event.ENTER_FRAME, onFrame);
				this.view.stop();
			}
		}

		private function onFrame(e:Event):void
		{
			if (!this.hero || !this.hero.game || !this.hero.game.map)
				return;
			if (!this.view)
				return;
			if (this.view.currentFrame < this.view.totalFrames - 1)
				return;
			this.view.removeEventListener(Event.ENTER_FRAME, onFrame);
			this.view.stop();
			setIcon();
		}

		private function setIcon():void
		{
			if (this.hero.player['clan_id'] > 0 && ClanManager.getClan(this.hero.player['clan_id']).photoLink != "")
			{
				var photoLoader:ClanPhotoLoader = new ClanPhotoLoader("", 0, 0, 30);
				photoLoader.load(ClanManager.getClan(this.hero.player['clan_id']).photoLink);
				photoLoader.x = -photoLoader.width * 0.5 + 1;
				photoLoader.y = -70 - photoLoader.height * 0.5;

				this.view.addChild(photoLoader);
			}
			else
			{
				var image:LegionPerkBaseIcon = new LegionPerkBaseIcon();
				image.y = -65;
				this.view.addChild(image);
			}
		}
	}
}