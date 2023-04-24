package game.mainGame.entity.magic
{
	import flash.events.Event;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.gameData.OutfitData;
	import game.mainGame.CollisionGroup;
	import game.mainGame.behaviours.StateBearCoffee;
	import game.mainGame.behaviours.StateBearFish;
	import game.mainGame.behaviours.StateBearHoney;
	import game.mainGame.behaviours.StateContused;
	import game.mainGame.behaviours.StateRedress;
	import game.mainGame.entity.joints.JointHoney;
	import game.mainGame.entity.simple.GameBody;

	import protocol.Connection;
	import protocol.PacketClient;

	import utils.starling.StarlingAdapterMovie;

	public class BearBag extends GameBody
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsOrientedBox(20 / Game.PIXELS_TO_METRE, 18 / Game.PIXELS_TO_METRE, new b2Vec2());
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		static public const COFFEE:int = 0;
		static public const BERRY:int = 1;
		static public const NUT:int = 3;
		static public const HONEY:int = 2;
		static public const FISH:int = 4;

		static public const HONEY_RADIUS:Number = 120 / Game.PIXELS_TO_METRE;

		static public var types:Array = null;

		public var type:int = -1;

		protected var view:StarlingAdapterMovie = null;
		protected var viewStick:StarlingAdapterMovie = null;

		public function BearBag()
		{
			this.fixed = true;
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF).SetUserData(this);
			super.build(world);

			this.view = new StarlingAdapterMovie(new this.imageClass());
			this.view.x = -72;
			this.view.y = -133;
			this.view.addEventListener(Event.ENTER_FRAME, onFrame);
			this.view.play();
			addChildStarling(this.view);
		}

		protected function get imageClass():Class
		{
			if (!types)
				types = [BearPerkView0, BearPerkView1, BearPerkView2, BearPerkView3, BearPerkView4];
			return types[this.type];
		}

		override public function dispose():void
		{
			if (this.view)
				this.view.removeEventListener(Event.ENTER_FRAME, onFrame);
			this.view = null;
			super.dispose();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.type, this.playerId]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.type = data[1][0];
			this.playerId = data[1][1];
		}

		protected function onFrame(e:Event):void
		{
			if (!this.view)
				return;
			if (this.view.currentFrame < this.view.totalFrames - 1)
				return;
			this.view.stop();
			this.view.removeEventListener(Event.ENTER_FRAME, onFrame);
			this.view.visible = false;

			onEffect();
		}

		private function onEffect():void
		{
			var self:Hero = this.gameInst.squirrels.get(this.playerId);
			var count:int = 0;

			for each (var hero:Hero in this.gameInst.squirrels.players)
			{
				var pos:b2Vec2 = hero.position.Copy();
				pos.Subtract(this.position);

				if (pos.Length() > HONEY_RADIUS || pos.Length() == 0 || hero.id == this.playerId || hero.isDead || hero.inHollow)
					continue;

				count++;
				switch (this.type)
				{
					case HONEY:
						var joint:JointHoney = new JointHoney();
						joint.damping = 0.05;
						joint.frequency = 0.75;
						joint.body = this;
						joint.hero = hero;
						this.gameInst.map.createObjectSync(joint, true);
						break;
					case FISH:
						hero.behaviourController.addState(new StateContused(15));
						break;
					case BERRY:
						if (hero.isSquirrel)
							hero.behaviourController.addState(new StateRedress(5, [OutfitData.BEAR], true));
						break;
					case COFFEE:
						hero.behaviourController.addState(new StateBearCoffee(10, 0.15));
						break;
					case NUT:
						if (hero.isSelf)
						{
							Connection.sendData(PacketClient.ROUND_NUT, PacketClient.NUT_PICK);
							hero.setMode(Hero.NUT_MOD);
						}
						break;
				}
			}

			switch (this.type)
			{
				case HONEY:
					this.viewStick = new StarlingAdapterMovie(new HunnyStart());
					addChildStarling(this.viewStick);

					if (self)
						self.behaviourController.addState(new StateBearHoney(10, 8));
					break;
				case FISH:
					if (self)
						self.behaviourController.addState(new StateBearFish(15, 0.2 + 0.03 * count));
					break;
				case BERRY:
					break;
				case COFFEE:
					if (self)
						self.behaviourController.addState(new StateBearCoffee(10, 0.2 + 0.03 * count));
					break;
				case NUT:
					if (self && self.isSelf)
					{
						self.setMode(Hero.NUT_MOD);
						Connection.sendData(PacketClient.ROUND_NUT, PacketClient.NUT_PICK);
					}
					break;
			}
		}
	}
}