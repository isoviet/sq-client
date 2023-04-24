package game.mainGame.entity.cast
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2JointEdge;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2World;

	import game.mainGame.GameMap;
	import game.mainGame.ISerialize;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.simple.GameBody;

	import interfaces.IDispose;

	import utils.FiltersUtil;
	import utils.IndexUtil;
	import utils.starling.IStarlingAdapter;
	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class BodyDestructor extends StarlingAdapterSprite implements IGameObject, ICastTool, IDispose, ISerialize
	{
		private var _destroyObject:GameBody = null;
		private var _game:game.mainGame.SquirrelGame;

		public function BodyDestructor():void
		{
			var cursor: StarlingAdapterMovie = new StarlingAdapterMovie(new Sight);
			cursor.loop = true;
			cursor.play();
			addChildStarling(cursor);
		}

		public function get position():b2Vec2
		{
			return new b2Vec2(this.x / Game.PIXELS_TO_METRE, this.y / Game.PIXELS_TO_METRE);
		}

		public function set position(value:b2Vec2):void
		{
			this.x = value.x * Game.PIXELS_TO_METRE;
			this.y = value.y * Game.PIXELS_TO_METRE;
			if (!this._game)
				return;

			var result:Array = utils.WorldQueryUtil.findBodiesAtPoint(this._game.world, this.position, GameBody);
			var array:Array = [];
			for each (var body:b2Body in result)
			{
				var gameBody:GameBody = body.GetUserData() as GameBody;
				if (gameBody && gameBody.casted && ((Hero.self && Hero.self.shaman) || (gameBody.playerId == Game.selfId)))
					array.push(body.GetUserData());
			}

			this.destroyObject = (IndexUtil.getMaxIndex(array) as GameBody);
		}

		public function get angle():Number
		{
			return 0;
		}

		public function set angle(value:Number):void
		{}

		public function build(world:b2World):void
		{
			var map:GameMap = (world.userData as SquirrelGame).map;

			if (this.destroyObject is GameBody)
			{
				var body:b2Body = (this.destroyObject as GameBody).body;
				var jointList:Array = [];

				if (body != null)
				{
					for (var joints:b2JointEdge = body.GetJointList(); joints != null; joints = joints.next)
					{
						jointList.push(joints.joint);
					}
				}

				for each (var joint:b2Joint in jointList)
				{
					if (joint.GetUserData() is IGameObject)
						map.remove(joint.GetUserData());

					if (joint.GetUserData() is IDispose)
						(joint.GetUserData() as IDispose).dispose();

					world.DestroyJoint(joint);
					joint.SetUserData("destroyed");
				}
			}

			map.remove(this.destroyObject, true);

			this.visible = false;
			map.remove(this);

			dispose();
		}

		public function set game(value:SquirrelGame):void
		{
			this._game = value;
		}

		public function onCastStart():void
		{}

		public function onCastCancel():void
		{}

		public function onCastComplete():void
		{}

		public function dispose():void
		{
			while (this.numChildren > 0)
				removeChildStarlingAt(0);

			this.destroyObject = null;
			this.game = null;

			this.removeFromParent(true);
		}

		public function serialize():*
		{
			var result:Array = [[this.position.x, this.position.y], this.destroyObject.id];
			return result;
		}

		public function deserialize(data:*):void
		{
			this.position = new b2Vec2(data[0][0], data[0][1]);
			this.destroyObject = _game.map.getObject(data[1]) as GameBody;
		}

		public function get destroyObject():GameBody
		{
			return this._destroyObject;
		}

		public function set destroyObject(value:GameBody):void
		{
			if (this._destroyObject == value)
				return;

			if (this._destroyObject && this._destroyObject is IStarlingAdapter)
				(this._destroyObject as StarlingAdapterSprite).filters = [];

			if (value && value is IStarlingAdapter)
				(value as StarlingAdapterSprite).filters = [FiltersUtil.glowRed];

			this._destroyObject = value;
		}
	}
}