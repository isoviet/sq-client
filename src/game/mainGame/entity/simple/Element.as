package game.mainGame.entity.simple
{
	import flash.display.DisplayObject;
	import flash.events.Event;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.FlyingObjectAnimation;
	import game.mainGame.CollisionGroup;
	import game.mainGame.ISideObject;
	import game.mainGame.SideIconView;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.IPinFree;
	import game.mainGame.perks.clothes.PerkClothesFactory;
	import sensors.HeroDetector;
	import sensors.events.DetectHeroEvent;
	import sounds.GameSounds;

	import protocol.Connection;
	import protocol.packages.server.PacketRoundElement;

	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class Element extends GameBody implements ISideObject, IPinFree
	{
		private var _isVisible: Boolean = false;

		static protected const CATEGORIES_BITS:uint = CollisionGroup.HERO_DETECTOR_CATEGORY;
		static protected const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static protected const SHAPE:b2CircleShape = new b2CircleShape(15 / Game.PIXELS_TO_METRE);
		static protected const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0, false);
		static protected const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		protected var sended:Boolean = false;
		protected var _onCarry:Boolean = false;
		protected var _index:int = 0;

		protected var freezerId:int = -1;
		protected var freezeAnimation:StarlingAdapterMovie;

		public var sensor:HeroDetector;
		public var view:FlyingObjectAnimation = null;

		public function Element(iconClass:Class):void
		{
			var icon:DisplayObject = new iconClass();

			this.view = new FlyingObjectAnimation(icon);
			this.view.x = -15;
			this.view.y = -15;
			this.view.scaleXY(0.5);
			addChildStarling(this.view);

			this.fixed = true;

			Connection.listen(onPacket, this.packets);
		}

		override public function get cacheBitmap():Boolean
		{
			return false;
		}

		override public function get ghost():Boolean
		{
			return false;
		}

		override public function set ghost(value:Boolean):void
		{
			if (value) {/*unused*/}
			super.ghost = false;
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.sensor = new HeroDetector(this.body.CreateFixture(FIXTURE_DEF));
			this.sensor.addEventListener(DetectHeroEvent.DETECTED, onHeroDetected, false, 0, true);
			super.build(world);

			if (this.freezerId == -1)
				this.view.play();

			this.gameInst = world.userData as SquirrelGame;
		}

		override public function dispose():void
		{
			this.view.dispose();

			super.dispose();

			Connection.forget(onPacket, this.packets);

			if (this.freezeAnimation)
			{
				this.freezeAnimation.removeEventListener(Event.CHANGE, onFreezeAnimation);
				this.freezeAnimation.removeFromParent();
			}

			this.freezeAnimation = null;

			if (this.sensor == null)
				return;

			this.sensor.removeEventListener(DetectHeroEvent.DETECTED, onHeroDetected);
			this.sensor = null;
		}

		public function get onCarry():Boolean
		{
			return this._onCarry;
		}

		public function set onCarry(value:Boolean):void
		{
			this._onCarry = value;
			this.visible = !value;
		}

		public function get sideIcon():StarlingAdapterSprite
		{
			return new SideIconView(SideIconView.COLOR_PURPLE, SideIconView.ICON_COLLECTION);
		}

		public function get showIcon():Boolean
		{
			return !this.onCarry;
		}

		public function get isVisible():Boolean
		{
			return _isVisible;
		}

		public function set isVisible(value: Boolean): void {
			_isVisible = false;
		}

		public function get index():int
		{
			return this._index;
		}

		public function freeze(freezerId:int):void
		{
			if (this.freezerId == freezerId)
				return;

			this.freezerId = freezerId;

			if (this.freezeAnimation)
			{
				this.freezeAnimation.removeEventListener(Event.COMPLETE, onFreezeAnimation);
				this.freezeAnimation.removeFromParent();
			}

			this.freezeAnimation = null;

			if (this.freezerId == -1)
				this.view.play();
			else
			{
				this.view.stop();
				this.freezeAnimation = new StarlingAdapterMovie(new FreezerViewCreate());
				this.freezeAnimation.x = -32;
				this.freezeAnimation.y = -32;
				this.freezeAnimation.addEventListener(Event.COMPLETE, onFreezeAnimation);
				this.freezeAnimation.play();
				this.freezeAnimation.loop = false;

				addChildStarling(this.freezeAnimation);
				GameSounds.play("freeze_element");
			}
		}

		protected function onFreezeAnimation(e:Event):void
		{
			if (this.freezerId == -1)
				return;

			if (this.freezeAnimation)
			{
				this.freezeAnimation.removeEventListener(Event.CHANGE, onFreezeAnimation);
				this.freezeAnimation.removeFromParent();
			}
			this.freezeAnimation = new StarlingAdapterMovie(new FreezerView());
			this.freezeAnimation.x = -32;
			this.freezeAnimation.y = -32;
			this.freezeAnimation.play();
			this.freezeAnimation.loop = false;
			addChildStarling(this.freezeAnimation);
		}

		protected function get packets():Array
		{
			return [];
		}

		override protected function get categoriesBits():uint
		{
			return CATEGORIES_BITS;
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.freezerId]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			freeze(data[1][0]);
		}

		protected function onHeroDetected(e:DetectHeroEvent):void
		{}

		protected function onPacket(packet:PacketRoundElement):void
		{}

		protected function get available():Boolean
		{
			if (this.onCarry)
				return false;

			var isWolf:Boolean = Hero.self.perkController.getPerkLevel(PerkClothesFactory.WOLF_FREEZE_COLLECTION) != -1 && Hero.self.isSquirrel;
			return this.freezerId == -1 || isWolf;
		}

		protected function destroy():void
		{
			if (this.gameInst && this.gameInst.map)
				this.gameInst.map.destroyObjectSync(this, true);

			if (this.freezeAnimation)
				this.freezeAnimation.removeFromParent();

			this.freezeAnimation = null;
		}
	}
}