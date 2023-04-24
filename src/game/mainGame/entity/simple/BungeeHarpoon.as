package game.mainGame.entity.simple
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FilterData;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.IMouseEnabled;
	import game.mainGame.gameEditor.SquirrelGameEditor;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import starling.display.Button;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	import utils.starling.StarlingAdapterSprite;
	import utils.starling.utils.StarlingConverter;

	public class BungeeHarpoon extends GameBody implements IMouseEnabled
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE_TRUNK:b2PolygonShape = b2PolygonShape.AsVector(trunkVertices, 0);
		static private const FIXTURE_DEF_TRUNK:b2FixtureDef = new b2FixtureDef(SHAPE_TRUNK, null, 0.8, 0.1, 2, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		static private const SHAPE_STAND:b2PolygonShape = b2PolygonShape.AsVector(standVertices, 0);
		static private const FIXTURE_DEF_STAND:b2FixtureDef = new b2FixtureDef(SHAPE_STAND, null, 0.8, 0.1, 3, CATEGORIES_BITS, MASK_BITS, 0);

		static private const RADIUS:Number = 100 / Game.PIXELS_TO_METRE;

		private var view: StarlingAdapterSprite = null;
		private var viewTrunkLeg: StarlingAdapterSprite = null;

		private var trunk:b2Body = null;

		private var _canAim:Boolean = false;
		private var _canShoot:Boolean = false;

		private var shootSprite:Sprite = null;
		private var aim:StarlingAdapterSprite = null;

		private var _shootDelay:int = 3 * 1000;
		private var shootTime:int = _shootDelay;

		private var joint:b2RevoluteJoint = null;

		private var trunkAngle:Number;
		private var jointLimit:Number = 0;

		private var shootButton: Button;
		private var trunkAimButton: Button;

		public var bungeeLength:int = 5;

		public function BungeeHarpoon():void
		{
			this.view = new StarlingAdapterSprite(new HarpoonBungeeTrunk());
			this.viewTrunkLeg = new StarlingAdapterSprite(new HarpoonBungeePillar());

			shootButton = new Button(StarlingConverter.getTexture(new HarpoonBungeeButton()));
			shootButton.x = -shootButton.width / 2;
			shootButton.y = -shootButton.height / 2;
			shootButton.addEventListener(TouchEvent.TOUCH, commandShoot);

			trunkAimButton = new Button(StarlingConverter.getTexture(new HarpoonTrunkAim()));
			trunkAimButton.x = 0;
			trunkAimButton.y = 0.5;
			trunkAimButton.touchable = true;
			trunkAimButton.downState = StarlingConverter.getTexture(new HarpoonTrunkAim());
			trunkAimButton.useHandCursor = true;
			trunkAimButton.addEventListener(TouchEvent.TOUCH, startDragTrunk);
			trunkAimButton.pivotX = -41;
			trunkAimButton.pivotY = trunkAimButton.height / 2 - 0.5;

			addChildStarling(this.view);
			addChildStarling(this.viewTrunkLeg);
			addChildStarling(shootButton);
			addChildStarling(trunkAimButton);

			this.shootSprite = new Sprite();
			this.shootSprite.x = 70;
			this.shootSprite.graphics.beginFill(0x000000, 0);
			this.shootSprite.graphics.drawCircle(-10, 0, 20);
			this.shootSprite.graphics.endFill();
			this.shootSprite.mouseEnabled = false;
			Game.stage.addEventListener(MouseEvent.MOUSE_UP, stopDragTrunk);

			this.aim = new StarlingAdapterSprite(new AimCursor());
			this.aim.x = 100;
			this.aim.visible = false;

			this.fixed = true;

			this.view.addChildStarling(this.aim);

			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		private function set trunkAnimRotation(value: Number): void {

			trunkAimButton.rotation = value * Math.PI / 180;
		}

		static private function get trunkVertices():Vector.<b2Vec2>
		{
			var vertices:Vector.<b2Vec2> = new Vector.<b2Vec2>();
			vertices.push(new b2Vec2(-2.8, -2.8));
			vertices.push(new b2Vec2(2.6, -2.8));
			vertices.push(new b2Vec2(6.1, -1.8));
			vertices.push(new b2Vec2(2.6, -0.8));
			vertices.push(new b2Vec2(-2.8, -0.8));
			return vertices;
		}

		static private function get standVertices():Vector.<b2Vec2>
		{
			var vertices:Vector.<b2Vec2> = new Vector.<b2Vec2>();
			vertices.push(new b2Vec2(-1.9, 1.4));
			vertices.push(new b2Vec2(0, -1.8));
			vertices.push(new b2Vec2(1.9, 1.4));
			return vertices;
		}

		override public function get cacheBitmap():Boolean
		{
			return false;
		}

		override public function set ghost(value:Boolean):void
		{
			super.ghost = value;

			if (this.trunk == null)
				return;

			setTrunkCategorieBits(value ? this.categoriesBitsGhost : this.categoriesBits);
		}

		override public function set ghostToObject(value:Boolean):void
		{
			super.ghostToObject = value;

			if (this.trunk == null)
				return;

			setTrunkCategorieBits(value ? this.categroiesBitsGhostToObject : this.categoriesBits);
		}

		override public function serialize():*
		{
			var data:Array = super.serialize();
			data.push([this.shootTime, this._shootDelay, this.bungeeLength]);
			if (this.body)
				data[data.length - 1].push([this.trunkAngle, this.joint.GetLowerLimit()]);
			return data;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			var dataPointer:Array = data.pop();

			this.shootTime = dataPointer[0];
			this._shootDelay = dataPointer[1];
			this.bungeeLength = dataPointer[2];
			if (dataPointer.length < 4)
			{
				this.trunkAngle = this.angle;
				return;
			}
			this.trunkAngle = dataPointer[3][0];
			this.jointLimit = dataPointer[3][1];
		}

		override public function build(world:b2World):void
		{
			this.trunk = world.CreateBody(BODY_DEF);
			this.trunk.SetLinearDamping(1.5);
			this.trunk.SetAngularDamping(1.5);
			this.trunk.SetUserData(this);
			this.trunk.CreateFixture(FIXTURE_DEF_TRUNK);
			this.trunk.SetPositionAndAngle(new b2Vec2(this.x / Game.PIXELS_TO_METRE, this.y / Game.PIXELS_TO_METRE), this.trunkAngle);
			this.view.rotation = this.trunkAngle * Game.R2D - this.rotation;
			this.trunkAnimRotation = this.view.rotation;

			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF_STAND);
			this.body.SetFixedRotation(true);
			super.build(world);

			var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			jointDef.Initialize(this.body, this.trunk, b2Math.AddVV(this.body.GetPosition(), this.body.GetWorldVector(new b2Vec2(0, 0))));
			jointDef.lowerAngle = this.jointLimit;
			jointDef.upperAngle = this.jointLimit;
			jointDef.enableLimit = true;
			this.joint = this.body.GetWorld().CreateJoint(jointDef) as b2RevoluteJoint;

			if (this.ghost)
				setTrunkCategorieBits(this.categoriesBitsGhost);

			if (this.ghostToObject)
				setTrunkCategorieBits(this.categroiesBitsGhostToObject);
		}

		override public function dispose():void
		{
			if (this.trunk)
			{
				for (var fixture:b2Fixture = this.trunk.GetFixtureList(); fixture; fixture = fixture.GetNext())
				{
					fixture.SetUserData(null);
				}

				this.trunk.SetUserData(null);
				this.trunk.GetWorld().DestroyBody(this.trunk);

				this.trunk = null;
			}

			if (this.joint)
			{
				this.body.GetWorld().DestroyJoint(this.joint);
				this.joint = null;
			}

			Game.stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragTrunk);
			Game.stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragTrunk);

			trunkAimButton.removeEventListener(Event.TRIGGERED, startDragTrunk);
			shootButton.removeEventListener(Event.TRIGGERED, commandShoot);

			Connection.forget(onPacket, PacketRoundCommand.PACKET_ID);

			super.dispose();
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.shootTime < this._shootDelay)
				this.shootTime += timeStep * 1000;

			var self:Hero = this.gameInst.squirrels.get(Game.selfId);

			this.canAim = Boolean((self && self.shaman) && (b2Math.SubtractVV(this.position, self.position).Length() < RADIUS)) || (this.gameInst is SquirrelGameEditor);
			this.canShoot = (this.shootTime >= this._shootDelay) && this._canAim;
		}

		public function set shootDelay(value:int):void
		{
			this._shootDelay = value;
			this.shootTime = value;
		}

		public function get shootDelay():int
		{
			return this._shootDelay;
		}

		private function set canAim(value:Boolean):void
		{
			if (this._canAim == value)
				return;

			this._canAim = value;
			this.shootSprite.buttonMode = value;
			this.shootSprite.mouseEnabled = value;
		}

		private function set canShoot(value:Boolean):void
		{
			if (this._canShoot == value)
				return;

			shootButton.enabled = value;
			this._canShoot = value;
			shootButton.useHandCursor = value;

			if (value) {
				var spriteFilter: Sprite = new Sprite();
				spriteFilter.graphics.beginFill(0xFF0000, 0.3);
				spriteFilter.graphics.drawCircle(shootButton.width / 2, shootButton.height / 2, shootButton.height / 2);
				spriteFilter.graphics.endFill();
				shootButton.addChild(new StarlingAdapterSprite(spriteFilter).getStarlingView());
			} else {
				while (shootButton.numChildren > 1)
					shootButton.removeChildAt(1);
			}
		}

		private function commandShoot(e: TouchEvent): void {
			var touch:Touch = e.getTouch(shootButton);

			if(!touch || touch.phase != TouchPhase.BEGAN || !this._canShoot) return;

			if (this.gameInst is SquirrelGameEditor)
				shoot();
			else
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'bungeeHarpoonShoot': [this.id]}));
		}

		private function shoot():void
		{
			this.shootTime = 0;

			if (!this.gameInst || !this.gameInst.squirrels.isSynchronizing)
				return;

			var bungeeBullet:BungeeBullet = new BungeeBullet();
			bungeeBullet.angle = this.trunk.GetAngle();
			bungeeBullet.bungeeLength = this.bungeeLength;
			bungeeBullet.position = this.trunk.GetWorldPoint(new b2Vec2(6, 0.6));
			this.gameInst.map.createObjectSync(bungeeBullet, true);
		}

		private function startDragTrunk(e:TouchEvent):void
		{
			var touch:Touch = e.getTouch(trunkAimButton);

			if(!touch || touch.phase != TouchPhase.BEGAN) return;

			if (!this.body)
				return;

			this.aim.visible = true;
			this.joint.EnableLimit(false);

			Game.stage.addEventListener(MouseEvent.MOUSE_MOVE, dragTrunk);
		}

		private function stopDragTrunk(e:MouseEvent):void
		{

			if (!this.body || this.aim.visible != true)
				return;

			this.aim.visible = false;

			Game.stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragTrunk);

			this.joint.EnableLimit(true);

			if (this.gameInst is SquirrelGameEditor)
				return;

			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'bungeeHarpoonAim': [this.id, Game.selfId, this.trunkAngle, this.joint.GetLowerLimit()]}));
		}

		private function dragTrunk(e:MouseEvent):void
		{
			if (!this.body || this.aim.visible != true)
				return;

			var angle:Number = Math.atan2(e.stageY - this.joint.GetAnchorA().y * Game.PIXELS_TO_METRE - this.gameInst.map.y, e.stageX - this.joint.GetAnchorA().x * Game.PIXELS_TO_METRE - this.gameInst.map.x);

			var positiveAngle:Number = (angle <= 0) ? (-angle) : (Math.PI * 2 - angle);
			var standAngle:Number = (this.angle <= 0) ? (-this.angle) : (Math.PI * 2 - this.angle);

			if ((standAngle < Math.PI) ? ((positiveAngle > standAngle + Math.PI) || positiveAngle < standAngle) : ((positiveAngle > standAngle - Math.PI) && (positiveAngle < standAngle)))
				return;

			this.view.rotation = angle * Game.R2D - this.rotation;
			this.trunkAnimRotation = this.view.rotation;

			this.trunk.SetAngle(angle);
			this.trunkAngle = angle;
			var limit:Number = (positiveAngle > standAngle) ? (standAngle - positiveAngle) : (standAngle - (positiveAngle + Math.PI * 2));
			this.joint.SetLimits(limit, limit);
		}

		private function setTrunkCategorieBits(value:int):void
		{
			for (var fixture:b2Fixture = this.trunk.GetFixtureList(); fixture; fixture = fixture.GetNext())
			{
				var filterData:b2FilterData = fixture.GetFilterData();
				filterData.categoryBits = value;
				fixture.SetFilterData(filterData);
			}
		}

		private function aimHarpoon(angle:Number, limit:Number):void
		{
			this.trunkAngle = angle;
			this.joint.EnableLimit(false);
			this.view.rotation = angle * Game.R2D - this.rotation;
			this.trunkAnimRotation = this.view.rotation;
			this.trunk.SetAngle(angle);
			this.joint.SetLimits(limit, limit);
			this.joint.EnableLimit(true);
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var data:Object = packet.dataJson;

			if ('bungeeHarpoonShoot' in data)
			{
				if (data['bungeeHarpoonShoot'][0] != this.id)
					return;

				shoot();
			}

			if ('bungeeHarpoonAim' in data)
			{
				if (data['bungeeHarpoonAim'][0] != this.id)
					return;

				if (data['bungeeHarpoonAim'][1] == Game.selfId)
					return;

				aimHarpoon(data['bungeeHarpoonAim'][2], data['bungeeHarpoonAim'][3]);
			}
		}
	}
}