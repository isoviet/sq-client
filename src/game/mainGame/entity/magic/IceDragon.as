package game.mainGame.entity.magic
{
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import game.mainGame.entity.IPersonalObject;
	import game.mainGame.entity.simple.AcornBody;
	import game.mainGame.entity.simple.CollectionMirageElement;
	import game.mainGame.entity.simple.Element;
	import game.mainGame.entity.simple.InvisibleBody;
	import sensors.events.DetectHeroEvent;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import utils.starling.StarlingAdapterMovie;

	public class IceDragon extends InvisibleBody implements IPersonalObject
	{
		static public const SPEED:int = 150 / Game.PIXELS_TO_METRE;
		static public const RADIUS:int = 35 / Game.PIXELS_TO_METRE;
		static public const ROTATE_SPEED:int = 60;

		static private const NONE:int = 0;
		static private const ACORN:int = 1;
		static private const ELEMENT:int = 2;

		static private var images:Array = null;
		static private var imagesGlow:Array = null;

		public var lifeTime:Number = 0;
		public var canCollection:Boolean = false;
		private var views:Array = [];
		private var viewsOld:Array = [];
		private var moveRotation:Number = 270;
		private var moveLeft:Boolean = false;
		private var moveRight:Boolean = false;

		private var carryId:int = NONE;
		private var carryingElement:Element = null;

		public function IceDragon():void
		{
			if (images == null)
				images = [IceDragonHead, IceDragonBody1, IceDragonBody2, IceDragonBody3, IceDragonBody4, IceDragonBody5, IceDragonBody6, IceDragonTail];
			for (var i:int = 0; i < images.length; i++)
			{
				var viewClass:Class = images[i];
				var view:StarlingAdapterMovie = new StarlingAdapterMovie(new viewClass);
				view.y = i * 15;
				view.loop = true;
				view.play();
				addChildStarling(view);

				this.views.push(view);
				this.viewsOld.push(new Point(view.x, view.y));
			}
		}

		public function get personalId():int
		{
			return this.playerId;
		}

		public function breakContact(playerId:int):Boolean
		{
			return this.personalId != playerId;
		}

		override public function build(world:b2World):void
		{
			super.build(world);

			Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			Game.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			this.moveRotation += ROTATE_SPEED * timeStep * ((this.moveLeft ? -1 : 0) + (this.moveRight ? 1 : 0));
			var moveVector:b2Vec2 = new b2Vec2(timeStep * SPEED * Math.cos(this.moveRotation * Game.D2R), timeStep * SPEED * Math.sin(this.moveRotation * Game.D2R));
			var x:Number = this.position.x + moveVector.x;
			var y:Number = this.position.y + moveVector.y;
			this.position = new b2Vec2(x, y);

			updateViews(moveVector);
			seekObjects();

			if (this.lifeTime <= 0)
				return;
			this.lifeTime -= timeStep;
			var hero:Hero = this.gameInst.squirrels.get(this.playerId);

			if (this.lifeTime <= 0 || !hero|| hero.inHollow || hero.isDead || hero.shaman)
			{
				if (this.carryingElement != null)
				{
					this.carryingElement.position = this.position.Copy();
					this.carryingElement.onCarry = false;
				}
				this.gameInst.map.destroyObjectSync(this, true);
			}
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.playerId, this.moveRotation, this.moveLeft, this.moveRight, this.canCollection, this.lifeTime]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.playerId = data[1][0];
			this.moveRotation = data[1][1];
			this.moveLeft = data[1][2];
			this.moveRight = data[1][3];
			this.canCollection = Boolean(data[1][4]);
			this.lifeTime = data[1][5];
		}

		override public function dispose():void
		{
			Game.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			Game.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			Connection.forget(onPacket, PacketRoundCommand.PACKET_ID);

			var hero:Hero = this.gameInst.squirrels.get(this.playerId);
			if (hero)
			{
				hero.isStoped = false;
				hero.changeView();
			}

			super.dispose();
		}

		private function onKeyDown(e:KeyboardEvent):void
		{
			if (this.personalId != Game.selfId)
				return;
			switch (e.keyCode)
			{
				case Keyboard.A:
				case Keyboard.LEFT:
					this.moveLeft = true;
					break;
				case Keyboard.D:
				case Keyboard.RIGHT:
					this.moveRight = true;
					break;
				default:
					return;
			}
			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'iceDragon': [this.id, this.moveLeft, this.moveRight, this.x, this.y]}));
		}

		private function onKeyUp(e:KeyboardEvent):void
		{
			if (this.personalId != Game.selfId)
				return;
			switch (e.keyCode)
			{
				case Keyboard.A:
				case Keyboard.LEFT:
					this.moveLeft = false;
					break;
				case Keyboard.D:
				case Keyboard.RIGHT:
					this.moveRight = false;
					break;
				default:
					return;
			}
			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'iceDragon': [this.id, this.moveLeft, this.moveRight, this.x, this.y]}));
		}

		private function seekObjects():void
		{
			if (this.playerId != Game.selfId || !this.gameInst || !this.gameInst.squirrels || !this.gameInst.map)
				return;
			var hero:Hero = this.gameInst.squirrels.get(this.playerId);
			if (!hero)
				return;

			if (this.carryId != NONE)
			{
				var point:b2Vec2 = hero.position.Copy();
				point.Subtract(this.position);
				if (point.Length() > RADIUS)
					return;
				switch (this.carryId)
				{
					case ACORN:
						hero.setMode(Hero.NUT_MOD);
						Connection.sendData(PacketClient.ROUND_NUT, PacketClient.NUT_PICK);
						break;
					case ELEMENT:
						if (this.carryingElement == null)
							return;
						this.carryingElement.position = this.position.Copy();
						this.carryingElement.onCarry = false;
						if (!this.gameInst.squirrels.selfCollected)
							this.carryingElement.sensor.dispatchEvent(new DetectHeroEvent(hero));
						this.carryingElement = null;
						break;
				}
				this.lifeTime = 0;
				this.gameInst.map.destroyObjectSync(this, true);
				return;
			}
			var acorns:Array = this.gameInst.map.get(AcornBody);
			if (!hero.hasNut)
				for each (var acorn:AcornBody in acorns)
				{
					point = acorn.position.Copy();
					point.Subtract(this.position);
					if (point.Length() > RADIUS)
						continue;
					this.carryId = ACORN;

					Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'iceDragonCarry': [this.id, -1]}));
					changeView();
					return;
				}

			if (!this.canCollection)
				return;
			for each (var element:Element in this.gameInst.map.elements)
			{
				if (element.sensor == null)
					continue;
				point = element.position.Copy();
				point.Subtract(this.position);
				if (point.Length() > RADIUS)
					continue;
				if (element is CollectionMirageElement)
				{
					element.sensor.dispatchEvent(new DetectHeroEvent(hero));
					continue;
				}
				this.carryingElement = element;
				this.carryingElement.onCarry = true;
				this.carryId = ELEMENT;

				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'iceDragonCarry': [this.id, this.carryingElement.id]}));
				changeView();
				return;
			}
		}

		private function changeView():void
		{
			if (imagesGlow == null)
				imagesGlow = [IceDragonHeadGlow, IceDragonBody1Glow, IceDragonBody2Glow, IceDragonBody3Glow, IceDragonBody4Glow, IceDragonBody5Glow, IceDragonBody6Glow, IceDragonTailGlow];
			for (var i:int = 0; i < this.views.length; i++)
			{
				var viewClass:Class = imagesGlow[i];
				var view:StarlingAdapterMovie = new StarlingAdapterMovie(new viewClass);
				view.x = this.views[i].x;
				view.y = this.views[i].y;
				view.loop = true;
				view.play();
				addChildStarling(view);

				removeChildStarling(this.views[i]);

				this.views[i] = view;
			}
		}

		private function updateViews(moveVector:b2Vec2):void
		{
			this.views[0].x += moveVector.x * Game.PIXELS_TO_METRE;
			this.views[0].y += moveVector.y * Game.PIXELS_TO_METRE;

			for (var i:int = 1; i < this.views.length; i++)
			{
				var a:Point = new Point(this.views[i - 1].x, this.views[i - 1].y);
				var b:Point = new Point(this.views[i].x, this.views[i].y);
				var delta:Point = b.subtract(a);

				var currentLength:Number = delta.length;

				// если точки находятся в одной позиции - чуть чуть растолкнем их, чтобы не делить на 0
				if (currentLength == 0)
				{
					var offset:Number = 0.1;
					a.x -= offset * 0.5;
					b.x += offset * 0.5;
					currentLength = offset;
				}

				delta.normalize((15 - currentLength) * 0.5);

				this.views[i - 1].x -= delta.x;
				this.views[i - 1].y -= delta.y;

				this.views[i].x += delta.x;
				this.views[i].y += delta.y;
			}
			for (i = 0; i < this.views.length; i++)
			{
				var tmpX:Number = this.views[i].x;
				var tmpY:Number = this.views[i].y;

				this.views[i].x += this.views[i].x - this.viewsOld[i].x;
				this.views[i].y += this.views[i].y - this.viewsOld[i].y;

				this.viewsOld[i].x = this.views[i].x - (this.views[i].x - tmpX) * 0.9;
				this.viewsOld[i].y = this.views[i].y - (this.views[i].y - tmpY) * 0.9;

				this.views[i].rotation = getAngle(i) * Game.R2D - 90;

				this.views[i].x -= moveVector.x * Game.PIXELS_TO_METRE;
				this.views[i].y -= moveVector.y * Game.PIXELS_TO_METRE;
				this.viewsOld[i].x -= moveVector.x * Game.PIXELS_TO_METRE;
				this.viewsOld[i].y -= moveVector.y * Game.PIXELS_TO_METRE;
			}

			this.views[0].x = 0;
			this.views[0].y = 0;
			this.viewsOld[0].x = 0;
			this.viewsOld[0].y = 0;
		}

		private function getAngle(index:int):Number
		{
			var point:Point = new Point(this.views[index].x, this.views[index].y);
			var direction:Point = new Point();
			var count:int = 0;
			if (index > 0)
			{
				var prev:Point = new Point(this.views[index - 1].x, this.views[index - 1].y);
				direction.x += (prev.x - point.x);
				direction.y += (prev.y - point.y);
				count++;
			}
			if (index + 1 < this.views.length)
			{
				var next:Point = new Point(this.views[index + 1].x, this.views[index + 1].y);
				direction.x += (point.x - next.x);
				direction.y += (point.y - next.y);
				count++;
			}
			direction.x /= count;
			direction.y /= count;
			direction.normalize(1.0);
			return Math.atan2(direction.y, direction.x);
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			if (this.personalId == Game.selfId)
				return;
			var data:Object = packet.dataJson;
			if ("iceDragon" in data && data['iceDragon'][0] == this.id)
			{
				this.moveLeft = data['iceDragon'][1];
				this.moveRight = data['iceDragon'][2];
				if (Math.abs(this.x - data['iceDragon'][3]) >= 30 || Math.abs(this.y - data['iceDragon'][4]) >= 30)
					{
					this.x = data['iceDragon'][3];
					this.y = data['iceDragon'][4];
				}
			}

			if ("iceDragonCarry" in data && data['iceDragonCarry'][0] == this.id)
			{
				changeView();

				if (data['iceDragonCarry'][1] == -1)
					return;
				var element:Element = this.gameInst.map.getObject(data['iceDragonCarry'][1]) as Element;
				if (element == null)
					return;
				this.carryingElement = element;
				this.carryingElement.onCarry = true;
			}
		}
	}
}