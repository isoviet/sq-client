package landing.game.mainGame.entity.cast
{
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2JointEdge;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2World;

	import landing.game.mainGame.GameMap;
	import landing.game.mainGame.IDispose;
	import landing.game.mainGame.SquirrelGame;
	import landing.game.mainGame.entity.simple.GameBody;

	import utils.IndexUtil;
	import landing.game.mainGame.entity.IGameObject

	public class BodyDestructor extends Sprite implements IGameObject, ICastTool, IDispose
	{
		private static const FILTER:ColorMatrixFilter = new ColorMatrixFilter([1, 0, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 0, 1, 0]);
		private var _destroyObject:IGameObject = null;
		private var _game:landing.game.mainGame.SquirrelGame;
		public var destroyObjectId:int = -1;

		public function BodyDestructor()
		{
			addChild(new Sight());
		}

		public function get position():b2Vec2
		{
			return new b2Vec2(this.x / WallShadow.PIXELS_TO_METRE, this.y / WallShadow.PIXELS_TO_METRE);
		}

		public function set position(value:b2Vec2):void
		{
			this.x = value.x * WallShadow.PIXELS_TO_METRE;
			this.y = value.y * WallShadow.PIXELS_TO_METRE;
			if (!this._game)
				return;

			var result:Array = utils.WorldQueryUtil.findBodiesAtPoint(this._game.world, this.position, IGameObject);
			var array:Array = new Array();
			for each (var body:b2Body in result)
				if ((body.GetUserData() is GameBody) && (body.GetUserData() as GameBody).casted)
					array.push(body.GetUserData());

			this.destroyObject = (IndexUtil.getMaxIndex(array) as landing.game.mainGame.entity.IGameObject);
		}

		public function get angle():Number
		{
			return 0;
		}

		public function set angle(value:Number):void
		{
		}

		public function build(world:b2World):void
		{
			var map:GameMap = (world.userData as SquirrelGame).map;
			this.destroyObjectId = map.getID(this.destroyObject);

			if (destroyObject is GameBody)
			{
				var body:b2Body = (destroyObject as GameBody).body;
				var joints:b2JointEdge = body.GetJointList();
				for (; joints && joints.joint; joints = joints.next)
				{
					var joint:* = joints.joint.GetUserData();
					if (joint is IGameObject)
						map.remove(joint);

					if (joint is IDispose)
						(joint as IDispose).dispose();
				}
			}

			if (destroyObject is GameBody)
			{
				destroyObject.position = new b2Vec2(0, 200);
			}
			else
				map.remove(this.destroyObject);

			if (this.destroyObject is IDispose)
				(this.destroyObject as IDispose).dispose();

			this.visible = false;
			map.remove(this);
			this.dispose();
		}

		public function set game(value:SquirrelGame):void
		{
			_game = value;
		}

		public function onCastStart():void
		{

		}

		public function onCastCancel():void
		{

		}

		public function onCastComplete():void
		{

		}

		public function dispose():void
		{
			while (this.numChildren > 0)
				removeChildAt(0);

			this.destroyObject = null;
			this.game = null;

			if (this.parent)
				this.parent.removeChild(this);
		}

		public function get destroyObject():IGameObject
		{
			return this._destroyObject;
		}

		public function set destroyObject(value:IGameObject):void
		{
			if (_destroyObject == value)
				return;

			if (_destroyObject && _destroyObject is Sprite)
				(_destroyObject as Sprite).filters = [];

			if (value && value is Sprite)
				(value as Sprite).filters = [FILTER];

			_destroyObject = value;
		}
	}
}