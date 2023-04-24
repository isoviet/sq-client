package game.mainGame.entity.simple
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.ui.Keyboard;

	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import game.mainGame.GameMap;
	import game.mainGame.IEditorDebugDraw;
	import game.mainGame.ISerialize;
	import game.mainGame.IUpdate;
	import game.mainGame.entity.IComplexEditorObject;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.IUnselectable;
	import game.mainGame.gameEditor.Selection;
	import sounds.GameSounds;

	import interfaces.IDispose;

	import utils.starling.StarlingAdapterSprite;

	public class Holes extends StarlingAdapterSprite implements IComplexEditorObject, IGameObject, ISerialize, IDispose, IUpdate, IUnselectable, IEditorDebugDraw
	{
		static private const TRIGGER_DISTANCE:Number = 50 / Game.PIXELS_TO_METRE;

		private var hole0:HolePoint = null;
		private var hole1:HolePoint = null;

		private var world:b2World = null;
		private var _debugDraw:Boolean = false;
		private var view:StarlingAdapterSprite = new StarlingAdapterSprite(new HolesView());
		private var debugView: StarlingAdapterSprite = new StarlingAdapterSprite();

		private var heroDetected:Boolean = false;

		public function Holes():void
		{
			addChildStarling(debugView);
			addChildStarling(this.view);

			this.hole0 = new HolePoint(this);
			this.hole1 = new HolePoint(this);
		}

		override public function get rotation():Number
		{
			return 0;
		}

		override public function set rotation(value:Number):void
		{
			if (value) {/*unused*/}
			super.rotation = 0;
		}

		public function onAddedToMap(map:GameMap):void
		{
			while (this.numChildren > 0)
				removeChildStarlingAt(0);

			addChildStarling(debugView);

			map.add(this.hole0);
			map.add(this.hole1);

			if (this.hole0.position.x != 0 || this.hole0.position.y != 0)
				return;

			var pos:b2Vec2 = this.position.Copy();

			pos.Add(new b2Vec2(-16.15 / Game.PIXELS_TO_METRE, 0));
			this.hole0.position = pos;

			pos.Add(new b2Vec2(16.15 * 2/ Game.PIXELS_TO_METRE, 0));
			this.hole1.position = pos;
			this.hole1.angle = Math.PI;

			this.showDebug = false;
			update();
		}

		public function onRemovedFromMap(map:GameMap):void
		{
			while (debugView.numChildren > 0)
				debugView.removeChildStarlingAt(0);
			debugView.removeFromParent();

			map.remove(this.hole0);
			this.hole0.dispose();

			map.remove(this.hole1);
			this.hole1.dispose();
		}

		public function get position():b2Vec2
		{
			return new b2Vec2(this.x / Game.PIXELS_TO_METRE, this.y / Game.PIXELS_TO_METRE);
		}

		public function set position(value:b2Vec2):void
		{
			this.x = value.x * Game.PIXELS_TO_METRE;
			this.y = value.y * Game.PIXELS_TO_METRE;
		}

		public function get angle():Number
		{
			return 0;
		}

		public function set angle(value:Number):void
		{}

		public function build(world:b2World):void
		{
			this.world = world;
			this.showDebug = false;
		}

		public function serialize():*
		{
			var result:Array = [];

			result.push([this.hole0.position.x, this.hole0.position.y]);
			result.push(this.hole0.angle);
			result.push([this.hole1.position.x, this.hole1.position.y]);
			result.push(this.hole1.angle);

			return result;
		}

		public function deserialize(data:*):void
		{
			this.hole0.position = new b2Vec2(data[0][0], data[0][1]);
			this.hole0.angle = data[1];
			this.hole1.position = new b2Vec2(data[2][0], data[2][1]);
			this.hole1.angle = data[3];
		}

		public function dispose():void
		{
			this.graphics.clear();

			while (debugView.numChildren > 0)
				debugView.removeChildStarlingAt(0);
			debugView.removeFromParent();

			if (this.parentStarling != null)
				this.parentStarling.removeChildStarling(this);

			if (this.hole0 != null)
				this.hole0.dispose();
			this.hole0 = null;

			if (this.hole1 != null)
				this.hole1.dispose();
			this.hole1 = null;
		}

		public function update(timeStep:Number = 0):void
		{
			this.graphics.clear();
			if (this.visible)
			{
				this.rotation = 0;

				var start:b2Vec2 = this.hole0.position;
				start.Multiply(Game.PIXELS_TO_METRE);

				var end:b2Vec2 = this.hole1.position;
				end.Multiply(Game.PIXELS_TO_METRE);

				var center:b2Vec2 = new b2Vec2((start.x + end.x) / 2, (start.y + end.y) / 2);
				this.x = center.x;
				this.y = center.y;

				start.Subtract(center);
				end.Subtract(center);

				if (!this._debugDraw)
					return;

				var shapeLine: Shape = new Shape();
				shapeLine.graphics.lineStyle(3, 0x808000);
				shapeLine.graphics.moveTo(start.x, start.y);
				shapeLine.graphics.lineTo(end.x, end.y);

				while (debugView.numChildren > 0)
					debugView.removeChildStarlingAt(0);

				debugView.addChildStarling(new StarlingAdapterSprite(shapeLine));
				return;
			}

			if (!this.world || !Hero.self)
				return;

			var selfDirection:b2Vec2 = Hero.self.velocity.Copy();
			selfDirection.Normalize();

			var pos:b2Vec2 = Hero.self.position.Copy();
			pos.Subtract(this.hole0.position);
			if (pos.Length() < TRIGGER_DISTANCE)
			{
				if (b2Math.Dot(selfDirection, hole0.direction) < 0)
					movePlayer(Hero.self, this.hole1);
				return;
			}

			pos = Hero.self.position.Copy();
			pos.Subtract(this.hole1.position);
			if (pos.Length() < TRIGGER_DISTANCE)
			{
				if (b2Math.Dot(selfDirection, hole1.direction) < 0)
					movePlayer(Hero.self, this.hole0);
				return;
			}

			this.heroDetected = false;
		}

		public function onSelect(selection:Selection):void
		{
			selection.add(this.hole0);
			selection.add(this.hole1);
		}

		public function set showDebug(value:Boolean):void
		{
			this._debugDraw = value;
			this.visible = value;
			this.hole0.arrow.visible = value;
			this.hole1.arrow.visible = value;
			update();
		}

		private function movePlayer(self:Hero, hole:HolePoint):void
		{
			if (heroDetected)
				return;

			heroDetected = true;

			var velocityLength:Number = self.velocity.Length();
			self.velocity = hole.direction;
			self.velocity.Multiply(velocityLength);
			self.position = hole.triggerPosition;
			self.sendLocation(Keyboard.UP);
			self.dispatchEvent(new Event(Hero.EVENT_BREAK_JOINT));
			if (self.id == Game.selfId || self.id == -1)
				GameSounds.play("hole");
		}
	}
}