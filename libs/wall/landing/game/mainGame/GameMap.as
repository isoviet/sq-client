package landing.game.mainGame
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import landing.game.Backgrounds;
	import landing.game.mainGame.IDispose;
	import landing.game.mainGame.ISerialize;
	import landing.game.mainGame.IUpdate;
	import landing.game.mainGame.Portals;
	import landing.game.mainGame.entity.EntityFactory;
	import landing.game.mainGame.entity.IComplexEditorObject;
	import landing.game.mainGame.entity.IGameObject;
	import landing.game.mainGame.entity.editor.ShamanBody;
	import landing.game.mainGame.entity.editor.SquirrelBody;
	import landing.game.mainGame.entity.joints.IJoint;
	import landing.game.mainGame.entity.simple.AcornBody;
	import landing.game.mainGame.entity.simple.HollowBody;
	import landing.game.mainGame.events.SquirrelEvent;

	import utils.IndexUtil;

	import by.blooddy.crypto.serialization.JSON;

	public class GameMap extends Sprite implements IUpdate, IDispose, ISerialize
	{
		private var background:DisplayObject = null;
		private var _backgroundId:int = -1;

		protected var game:SquirrelGame = null;
		public var objects:Array = new Array();

		public var shamanTools:Array = new Array();
		public var portals:Portals = new Portals();
		public var objectSprite:Sprite = new Sprite();

		public function GameMap(game:SquirrelGame):void
		{
			super();

			this.game = game;
			this.backgroundId = 0;

			addChild(this.objectSprite);
		}

		override public function addChild(child:DisplayObject):DisplayObject
		{
			if (child is IGameObject)
				return this.objectSprite.addChild(child);

			return super.addChild(child);
		}

		override public function removeChild(child:DisplayObject):DisplayObject
		{
			if (child is IGameObject && child.parent == this.objectSprite)
				return this.objectSprite.removeChild(child);

			if (child.parent == this)
				return super.removeChild(child);
			return child;
		}

		public function add(object:*):void
		{
			this.objects.push(object);

			if (object is DisplayObject && object.parent == null)
				addChild(object);

			if (object is IComplexEditorObject)
				(object as IComplexEditorObject).onAddedToMap(this);
		}

		public function getID(object:IGameObject):int
		{
			return this.objects.indexOf(object);
		}

		public function getObject(id:int):IGameObject
		{
			if (id in this.objects)
				return this.objects[id];
			return null;
		}

		public function remove(object:*):void
		{
			if (object == null)
				return;

			if (object is int)
			{
				if (this.objects[object] == null)
					return;

				if (contains(this.objects[object]))
					removeChild(this.objects[object]);

				if (this.objects[object] is IComplexEditorObject)
					(this.objects[object] as IComplexEditorObject).onRemovedFromMap(this);

				this.objects.splice(object, 1);
			}
			else
			{
				for (var id:String in this.objects)
				{
					if (this.objects[id] != object)
						continue;

					if (contains(this.objects[id]))
						removeChild(this.objects[id]);

					if (this.objects[id] is IComplexEditorObject)
						(this.objects[id] as IComplexEditorObject).onRemovedFromMap(this);

					this.objects.splice(id, 1);
					break;
				}
			}

		}

		public function get backgroundId():int
		{
			return this._backgroundId;
		}

		public function set backgroundId(id:int):void
		{
			if (this._backgroundId == id)
				return;
			this._backgroundId = id;

			var backgroundNew:DisplayObject = Backgrounds.getImage(id);
			addChild(backgroundNew);

			if (this.background == null)
			{
				this.background = backgroundNew;
				return;
			}

			swapChildren(backgroundNew, this.background);
			removeChild(this.background);

			this.background = backgroundNew;
		}

		public function deserialize(data:*):void
		{
			clear();

			var input:Array;
			try
			{
				input = JSON.decode(data);
			}
			catch (e:Error)
			{
				trace("Failed to decode JSON map data: " + e, data);
				throw e;
			}

			this.backgroundId = input[0];
			var objects:Array = input[1];

			for each (var entity:* in objects)
			{
				var object:IGameObject = new (EntityFactory.getEntity(entity[0]) as Class)();

				if (object is ISerialize)
					(object as ISerialize).deserialize(entity[1]);

				add(object);
			}

			if (2 in input)
				this.shamanTools = input[2];
			else
				this.shamanTools = new Array();
		}

		public function resort():void
		{
			var sorted:Array = IndexUtil.sortByIndex(this.objects, Array.DESCENDING);
			this.objects = sorted;
		}

		public function serialize():*
		{
			var result:Array = new Array();

			result.push(this.backgroundId);

			var objects:Array = new Array();

			for each (var object:* in this.objects)
			{
				if (object is ISerialize)
					objects.push([EntityFactory.getId(object), (object as ISerialize).serialize()]);
			}

			result.push(objects);

			return JSON.encode(result);
		}

		public function get squirrelsPosition():Vector.<b2Vec2>
		{
			var players:Array = get(SquirrelBody);

			var positions:Vector.<b2Vec2> = new Vector.<b2Vec2>();
			for each (var player:IGameObject in players)
				positions.push(player.position);

			return positions;
		}

		public function get shamansPosition():Vector.<b2Vec2>
		{
			var players:Array = get(ShamanBody);

			var positions:Vector.<b2Vec2> = new Vector.<b2Vec2>();
			for each (var player:IGameObject in players)
				positions.push(player.position);

			return positions;
		}

		public function get(className:Class):Array
		{
			var result:Array = new Array();

			for each (var object:* in this.objects)
			{
				if (object is className)
					result.push(object);
			}

			return result;
		}

		public function has(className:Class):Boolean
		{
			for each (var object:* in this.objects)
			{
				if (object is className)
					return true;
			}

			return false;
		}

		public function getSquirrelsCount():int
		{
			var players:Array = get(SquirrelBody).concat(get(ShamanBody));
			return players.length;
		}

		public function build(world:b2World):void
		{
			for each (var object:* in this.objects)
			{
				if (object is IGameObject && !(object is IJoint))
					object.build(world);
			}

			for each (object in this.objects)
			{
				if (object is IGameObject && (object is IJoint))
					object.build(world);

				if (object is HollowBody)
				{
					object.game = this.game;
					object.addEventListener(SquirrelEvent.HOLLOW, onHollow, false, 0, true);
				}

				if (object is AcornBody)
					object.addEventListener(SquirrelEvent.ACORN, onAcorn, false, 0, true);
			}
		}

		public function update(timeStep:Number = 0):void
		{
			for each (var object:* in this.objects)
			{
				if (object is IUpdate)
					object.update(timeStep);
			}
			this.portals.doTeleport();
		}

		public function clear():void
		{
			if (this.portals)
				this.portals.reset();

			for each (var object:* in this.objects)
			{
				if (object is IDispose)
					object.dispose();
			}

			this.objects = new Array();
		}

		public function dispose():void
		{
			clear();

			this.game = null;
			this.portals = null;

			while (this.numChildren > 0)
				removeChildAt(0);
		}

		protected function onHollow(e:SquirrelEvent):void
		{}

		protected function onAcorn(e:SquirrelEvent):void
		{}
	}
}