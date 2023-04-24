package game.mainGame.gameDesertNet
{
	import flash.geom.Point;

	import Box2D.Dynamics.b2World;

	import game.mainGame.SquirrelGame;
	import game.mainGame.perks.clothes.PerkClothesFactory;

	import com.api.Player;

	import utils.starling.StarlingAdapterSprite;

	public class HeroDesert extends Hero
	{
		static private const HERO_THIRST_TIME:int = 30 * 1000;
		static private const DRAGON_THIRST_TIME:int = 35 * 1000;
		static private const PERSIAN_THIRST_TIME:int = 45 * 1000;

		public var halfThirst:Boolean = false;
		public var leaveAura:Boolean = false;

		private var _thirst:int = 0;

		private var thirstBar:ThirstBar = null;
		private var waterAura:StarlingAdapterSprite = null;

		private var persianWeared:Boolean = false;

		public function HeroDesert(playerId:int, world:b2World, x:int = 0, y:int = 0):void
		{
			this.thirstBar = new ThirstBar();
			this.thirstBar.x = -24;
			this.thirstBar.y = -70;

			this.waterAura = new StarlingAdapterSprite(new WaterAura());
			this.waterAura.touchable = false;
			this.waterAura.visible = false;

			super(playerId, world, x, y);

			this.heroView.animationOffset = 0;

			addChildStarling(this.thirstBar);
			(this.world.userData as SquirrelGame).addChildStarling(this.waterAura);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			this.thirstBar.scaleX = this.scale > 0 ? 1 : -1;
		}

		override public function remove():void
		{
			if (this.waterAura.parentStarling)
				this.waterAura.removeChildStarling(this.waterAura);

			super.remove();
		}

		override public function reset():void
		{
			super.reset();

			this.thirsty = false;
			this.halfThirst = false;
			this.leaveAura = false;
		}

		override public function respawn(withAnimation:int = RESPAWN_NONE):void
		{
			super.respawn(withAnimation);

			this.thirsty = false;
			this.halfThirst = false;
			this.leaveAura = false;
		}

		override public function set shaman(value:Boolean):void
		{
			super.shaman = value;

			updateGraphics();
		}

		override public function set dead(value:Boolean):void
		{
			super.dead = value;

			updateGraphics();
		}

		override public function show():void
		{
			super.show();

			updateGraphics();
		}

		override public function hide():void
		{
			super.hide();

			updateGraphics();
		}

		public function set thirsty(value:Boolean):void
		{
			this._thirst = value ? Math.max(0, this._thirst - 1) : this.thirstTime;
			if (this._thirst <= this.thirstTime / 2)
				this.halfThirst = true;
			if (!value)
				this.leaveAura = true;

			if (this._thirst == 0)
			{
				this.dieReason = Hero.DIE_THIRST;
				this.dead = true;
			}
			else
			{
				this.thirstBar.y = this.heroView.topCoords;
				this.thirstBar.update(this._thirst, this.thirstTime);
			}
		}

		override protected function updateCirclePosition():void
		{
			super.updateCirclePosition();

			if (!this.waterAuraVisible)
				return;

			var circleCoords:Point = (this.world.userData as SquirrelGame).globalToLocal(this.localToGlobal(new Point(-240, this.heroView.y - 250)));
			this.waterAura.x = circleCoords.x;
			this.waterAura.y = circleCoords.y;
			this.waterAura.rotation = this.rotation;
			this.waterAura.cacheAsBitmap = (this.rotation == 0);
		}

		override protected function onPlayerLoad(player:Player):void
		{
			super.onPlayerLoad(player);

			if (!player.weared)
				return;

			this.persianWeared = false;
			this.persianWeared = this.persianWeared || this.perkController.getPerkLevel(PerkClothesFactory.PHARAON_WOMAN) != -1;
		}

		private function get thirstTime():int
		{
			if (this.isDragon)
				return DRAGON_THIRST_TIME / ThirstController.UPDATE_RATE;
			else if (this.persianWeared && this.isSquirrel)
				return PERSIAN_THIRST_TIME / ThirstController.UPDATE_RATE;
			else
				return HERO_THIRST_TIME / ThirstController.UPDATE_RATE;
		}

		private function get thirstBarVisible():Boolean
		{
			return !this.shaman && this.heroView.visible && !this.isDead && this.isSelf && !this.isHare;
		}

		private function get waterAuraVisible():Boolean
		{
			return this.shaman && this.heroView.visible && !this.isDead;
		}

		private function updateGraphics():void
		{
			this.thirstBar.visible = this.thirstBarVisible;
			this.waterAura.visible = this.waterAuraVisible;
		}
	}
}