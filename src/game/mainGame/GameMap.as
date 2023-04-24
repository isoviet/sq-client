package game.mainGame
{
	import flash.display.Shape;
	import flash.events.Event;

	import game.mainGame.entity.INetHidden;
	import game.mainGame.entity.editor.RespawnPoint;
	import game.mainGame.gameLearning.SquirrelGameLearning;
	import screens.ScreenGame;

	import interfaces.IDispose;

	import protocol.packages.server.PacketRoomRound;
	import protocol.packages.server.structs.PacketRoundElementsItems;

	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.QuadBatch;

	import utils.starling.collections.DisplayObjectManager;
	import utils.starling.collections.TextureCollection;
	import utils.starling.particleSystem.CollectionEffects;
	import utils.starling.utils.StarlingConverter;

	CONFIG::mobile
	{
		import flash.display.Screen;
	}

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import by.blooddy.crypto.serialization.JSON;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;

	import game.mainGame.entity.EntityFactory;
	import game.mainGame.entity.ICache;
	import game.mainGame.entity.IComplexEditorObject;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.IPostDeserialize;
	import game.mainGame.entity.editor.ShamanBody;
	import game.mainGame.entity.editor.SquirrelBody;
	import game.mainGame.entity.joints.IJoint;
	import game.mainGame.entity.simple.AcornBody;
	import game.mainGame.entity.simple.CollectionElement;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.entity.simple.HollowBody;
	import game.mainGame.events.HollowEvent;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.gameQuests.IQuestObject;

	import particles.Explode;
	import particles.ParticleEngine;

	import screens.ScreenStarling;

	import starling.display.BlendMode;

	import utils.InstanceCounter;
	import utils.starling.IStarlingAdapter;
	import utils.starling.StarlingAdapterSprite;

	public class GameMap extends StarlingAdapterSprite implements IUpdate, IDispose, ISerialize
	{
		static private var _instance:GameMap = null;

		private var background:StarlingAdapterSprite = null;
		protected var drawSprite:Shape = new Shape();
		private var _backgroundId:int = -1;

		private var _size:Point = new Point(Config.GAME_WIDTH, Config.GAME_HEIGHT);

		private var backgroundLayer0: Image = null;
		private var backgroundLayer1: Image = null;

		private var bgLayer: StarlingAdapterSprite = new StarlingAdapterSprite();
		private var backgroundLayerQuad:QuadBatch;
		private var collectionEffects: CollectionEffects = CollectionEffects.instance;

		protected var maskLayer:Sprite = new Sprite();
		protected var maskBorders:Sprite = new Sprite();

		protected var objects:Array = [];
		protected var objectsQuest:Array = [];

		protected var acornPosition:b2Vec2 = null;

		protected var collectionItems:Vector.<PacketRoundElementsItems> = new <PacketRoundElementsItems>[];
		protected var collectionItemsCreated:Boolean = true;

		public var game:SquirrelGame = null;

		protected var drawAllMap: Boolean = false;

		public var shamanTools:Array = [];
		public var portals:Portals = new Portals();
		public var objectSprite:StarlingAdapterSprite = new StarlingAdapterSprite();
		public var _foregroundObjects:StarlingAdapterSprite = new StarlingAdapterSprite();
		public var _particles:ParticleEngine = null;
		public var userBottomSprite:Sprite = new Sprite();
		public var userUpperSprite:Sprite = new Sprite();

		public var elements:Object = {};

		public var cachePool:CachePool = new CachePool();

		public var lastEditor:int = 0;

		public var respawnPosition:b2Vec2 = null;
		public static var gameScreenWidth: int = Config.GAME_WIDTH;
		public static var gameScreenHeight: int = Config.GAME_HEIGHT;

		static public function get instance():GameMap
		{
			return _instance;
		}

		public function GameMap(game:SquirrelGame):void
		{
			_instance = this;

			Logger.add("GameMap.GameMap");
			InstanceCounter.onCreate(this);
			super();

			Logger.add("GameMap.GameMap init ParticleEngine");
			this._particles = new ParticleEngine();
			Explode.particleEngine = this._particles;

			this.game = game;

			this.drawAllMap = (this.game is SquirrelGameLearning);

			Logger.add("GameMap.GameMap init background");
			this.backgroundId = 0;
			ScreenStarling.instance.addChildAt(this.bgLayer.getStarlingView(), 0);
			ScreenStarling.groundLayer.addChild(this.getStarlingView());

			Logger.add("GameMap.GameMap adding sprites");
			addChild(this.userBottomSprite);
			addChildStarling(this.objectSprite);
			addChild(this.objectSprite);
			addChildStarling(this._particles);
			addChild(this.userUpperSprite);
			resizeMobile();

			Logger.add("GameMap.GameMap set frameRate");
			Starling.current.nativeStage.frameRate = 60;

			CONFIG::mobile {
				Starling.current.nativeStage.frameRate = 30;
			}
			Logger.add("GameMap.GameMap FullScreenManager");
			FullScreenManager.instance().addEventListener(FullScreenManager.CHANGE_FULLSCREEN, onChangeScreenSize);
			Logger.add("GameMap.GameMap Finish");
			this._foregroundObjects.touchable = false;

			addChild(this.drawSprite);
		}

		private function onChangeScreenSize(e: flash.events.Event): void
		{
			if (background)
			{
				background.getStarlingView().width = GameMap.gameScreenWidth;
				background.getStarlingView().height = GameMap.gameScreenHeight;
			}

			if (backgroundLayer0) {
				backgroundLayer0.scaleX = Game.starling.stage.stageWidth / Config.GAME_WIDTH;
				backgroundLayer0.scaleY = Game.starling.stage.stageHeight / Config.GAME_HEIGHT;
				if (this.backgroundLayerQuad)
				{
					this.backgroundLayerQuad.scaleX = this.backgroundLayer0.scaleX;
					this.backgroundLayerQuad.scaleY = this.backgroundLayer0.scaleY;
				}
			}
		}

		private function resizeMobile():void
		{
			CONFIG::mobile
			{
				var thisScreen:Screen = Screen.mainScreen;
				var newScaleX:Number = thisScreen.visibleBounds.width / Config.GAME_WIDTH;
				var newScaleY:Number = thisScreen.visibleBounds.height / Config.GAME_HEIGHT;
				var newScale:Number = Math.min(newScaleX, newScaleY);

				ScreenStarling.instance.scaleX = newScale;
				ScreenStarling.instance.scaleY = newScale;
				ScreenStarling.instance.x = (thisScreen.visibleBounds.width - (Config.GAME_WIDTH * newScale)) / 2;
			}
		}

		public function gameObjects():Array
		{
			return objects;
		}

		public function round(packet:PacketRoomRound):void
		{
		}

		public function get gravity():b2Vec2
		{
			return this.game.gravity;
		}

		public function set gravity(value:b2Vec2):void
		{
			this.game.gravity = value;
		}

		public function set shift(value:Point):void
		{
			this.x = int(value.x);
			this.y = int(value.y);
		}

		override public function set x(value:Number):void
		{
			collectionEffects.mapX = value;
			super.x = value;

			backgroundPos(this.x, this.y);

			if (!this.background)
				return;

			this.background.x = -value;
			this.maskBorders.x = -value;
			this.maskLayer.x = -value;

		}

		override public function set y(value:Number):void
		{
			collectionEffects.mapY = value;
			super.y = value;

			backgroundPos(this.x, this.y);

			if (!this.background)
				return;

			this.background.y = -value;
			this.maskBorders.y = -value;
			this.maskLayer.y = -value;
		}

		public function isEmpty():Boolean
		{
			return this.objects.length == 0;
		}

		public function get foregroundObjects(): StarlingAdapterSprite
		{
			return this._foregroundObjects;
		}

		override public function addChildStarling(child:*):*
		{
			if (child is IGameObject)
			{
				child.parentStarling = this.objectSprite;
				this.objectSprite.addChildStarling(child as StarlingAdapterSprite);
				return child;
			}

			return super.addChildStarling(child);
		}

		public function drawVisibleObjects(redactor:Boolean = false, refresh:Boolean = false):void
		{
			var camera:Point = new Point(-x, -y);
			var objs:Vector.<StarlingAdapterSprite> = new Vector.<StarlingAdapterSprite>();
			var itemObj:StarlingAdapterSprite = null;
			var lastChildIndex:int = 0;
			var item: StarlingAdapterSprite;
			var rect: Rectangle;
			var gameBody: GameBody;

			for (var i:int = 0, j:int = this.objects.length; i < j; i++)
			{
				item = this.objects[i];
				if (item == null)
					continue;

				if (!item || !(item is IStarlingAdapter))
				{
					if (!(item is IForegroundObject))
						continue;
				}

				if (item.parentStarling != this.objectSprite)
				{
					if (item.realAlpha <= 0)
						item.showSprite();
						continue;
				}

				rect = item.boundsStarling();

				if (rect.right < camera.x || rect.bottom < camera.y || rect.left > camera.x + gameScreenWidth || rect.top > camera.y + gameScreenHeight)
				{
					if (item.realAlpha > 0)
						item.hideSprite();
				}
				else
				{
					if (item is IForegroundObject)
						objs.push(item);

					if (item.realAlpha <= 0)
						item.showSprite();
				}
			}

			for (i = 0, j = objs.length; i < j; i++)
			{
				itemObj = objs[i];

				if (itemObj is IForegroundObject && !redactor && !this._foregroundObjects.containsStarling(itemObj) && !refresh)
				{
					this._foregroundObjects.addChildStarling(itemObj);
				}
				else if (!this.objectSprite.containsStarling(itemObj) && !this._foregroundObjects.containsStarling(itemObj) || refresh)
				{
					this.objectSprite.addChildStarling(itemObj);
				}
			}
			gameBody = null;
			itemObj = null;
			objs = null;
			camera = null;
			item = null;
			rect = null;
		}

		override public function addChild(child:DisplayObject):DisplayObject
		{
			if (child is IGameObject)
				return this.objectSprite.addChild(child);

			return super.addChild(child);
		}

		override public function removeChildStarling(child:*, dispose:Boolean = true):void
		{
			if (child.parentStarling == this.objectSprite)
			{
				this.objectSprite.removeChildStarling(child, dispose);
			}

			if (child.parentStarling == this)
				super.removeChildStarling(child, dispose);
		}

		override public function removeChild(child:DisplayObject):DisplayObject
		{
			if (child is IGameObject && child.parent == this.objectSprite)
				return this.objectSprite.removeChild(child);

			if (child.parent == this)
				return super.removeChild(child);
			return child;
		}

		public function createObjectSync(object:IGameObject, build:Boolean):void
		{
			add(object);
			if (build)
				object.build(this.game.world);
		}

		public function destroyObjectSync(object:IGameObject, dispose:Boolean):void
		{
			remove(object, dispose);
		}

		public function add(object:* = null):void
		{
			InstanceCounter.onCreate(object);

			if (object is IQuestObject)
				this.objectsQuest.push(object);
			else
				this.objects.push(object);

			if (object is IStarlingAdapter && object.parentStarling == null)
			{
				(object as StarlingAdapterSprite).lastIndex = this.objects.length;
				addChildStarling(object);
				if ((object as StarlingAdapterSprite).numberOfChildSprite())
				{
					addChild(object);
				}
			}
			else if (object is DisplayObject && object.parent == null)
			{
				addChild(object);
			}

			//if ((object is ICache) && (object as ICache).cacheBitmap)
			//	this.cachePool.add(object);

			if (object is IComplexEditorObject)
				(object as IComplexEditorObject).onAddedToMap(this);
			if (object is ISideObject)
				this.game.sideIcons.register(object as ISideObject);
			if (object is INetHidden)
				(object as INetHidden).visible = false;
		}

		public function getByName(name:String):IGameObject
		{
			for each (var object:* in this.objects)
			{
				if (object == null)
					continue;
				if (object.name != name)
					continue;
				return object;
			}
			return null;
		}

		public function getID(object:IGameObject):int
		{
			if (object == null)
				return -1;
			return this.objects.indexOf(object);
		}

		public function getObject(id:int):IGameObject
		{
			if (id in this.objects)
				return this.objects[id];
			return null;
		}

		public function remove(object:*, doDispose:Boolean = false):void
		{
			if (object == null)
				return;

			if (object is int)
			{
				if (this.objects[object] == null)
					return;

				if (this.objects[object] is ICache)
					this.cachePool.remove(this.objects[object]);

				if (contains(this.objects[object]))
					removeChild(this.objects[object]);

				if (containsStarling(this.objects[object]) && this.objects[object] is IStarlingAdapter)
					removeChildStarling(this.objects[object], doDispose);

				var objectInstance:* = this.objects[object];

				this.objects[object] = null;

				if (objectInstance is IComplexEditorObject)
					(objectInstance as IComplexEditorObject).onRemovedFromMap(this);

				if (doDispose && objectInstance is IDispose)
					objectInstance.dispose();

				if (objectInstance is ISideObject)
					this.game.sideIcons.remove(objectInstance);

				InstanceCounter.onDispose(objectInstance);
			}
			else
			{
				for (var id:String in this.objects)
				{
					if (this.objects[id] != object)
						continue;

					if (this.objects[id] is ICache && !(this.objects[id] is IStarlingAdapter))
						this.cachePool.remove(this.objects[id]);

					if (contains(this.objects[id]))
					{
						removeChild(this.objects[id]);
					}
					else if (containsStarling(this.objects[id]) && this.objects[id] is IStarlingAdapter)
					{
						removeChildStarling(this.objects[id], doDispose);
					}

					this.objects[id] = null;

					if (object is IComplexEditorObject)
						(object as IComplexEditorObject).onRemovedFromMap(this);

					if (object is ISideObject)
						this.game.sideIcons.remove(object);

					if (doDispose && object is IDispose)
						object.dispose();

					InstanceCounter.onDispose(object);
					break;
				}
			}
		}

		private function backgroundPos(x: Number, y: Number): void
		{
			if(backgroundLayerQuad)
			{
				backgroundLayerQuad.x =(backgroundLayerQuad.width * 0.5) * (x / size.x);
				backgroundLayerQuad.y = (backgroundLayerQuad.height * 0.5) * (y / size.y);
			}
		}

		public function get backgroundId():int
		{
			return this._backgroundId;
		}

		protected function createDynamicBackground(): void
		{
			var availableBg:Array = Backgrounds.getParallaxBackground(ScreenGame.location);

			if (!this.backgroundLayer0 && availableBg)
			{
				if (this.backgroundLayerQuad)
					this.backgroundLayerQuad.removeFromParent(true);

				if (availableBg.length > 1)
				{
					this.backgroundLayerQuad = new QuadBatch();
					this.backgroundLayer0 = StarlingConverter.convertToImage(new availableBg[0]());
					this.backgroundLayer1 = StarlingConverter.convertToImage(new availableBg[1]());
					this.backgroundLayer0.scaleX = Game.starling.stage.stageWidth / Config.GAME_WIDTH;
					this.backgroundLayer0.scaleY = Game.starling.stage.stageHeight / Config.GAME_HEIGHT;
					this.backgroundLayer1.scaleX = 1;
					this.backgroundLayer1.scaleY = 1;
					this.backgroundLayer0.x = 0;
					this.backgroundLayer1.y = Config.GAME_HEIGHT / 2;
					this.backgroundLayerQuad.addImage(this.backgroundLayer1);
					this.backgroundLayer1.x = Config.GAME_WIDTH;
					this.backgroundLayerQuad.addImage(this.backgroundLayer1);
					this.backgroundLayerQuad.scaleX = this.backgroundLayer0.scaleX;
					this.backgroundLayerQuad.scaleY = this.backgroundLayer0.scaleY;
				}
			}

			if (this.backgroundLayer0 && this.backgroundLayerQuad)
			{
				if (this.background)
					this.background.visible = false;
				this.bgLayer.addChildStarling(this.backgroundLayer0);
				this.bgLayer.addChildStarling(this.backgroundLayerQuad);
				this.bgLayer.blandMode = BlendMode.NONE;
			}
		}

		public function set backgroundId(id:int):void
		{
			if (this._backgroundId == id)
				return;

			this._backgroundId = id;

			var backgroundNew:StarlingAdapterSprite = new StarlingAdapterSprite(Backgrounds.getImage(id));
			backgroundNew.getStarlingView().width = GameMap.gameScreenWidth;
			backgroundNew.getStarlingView().height = GameMap.gameScreenHeight;

			backgroundNew.blandMode = BlendMode.NONE;
			addChildStarlingAt(backgroundNew, 0);

			if (this.background == null)
			{
				this.background = backgroundNew;
				createDynamicBackground();

				return;
			}

			//swapChildren(backgroundNew, this.background);
			removeChildStarling(this.background);

			this.background = backgroundNew;

			createDynamicBackground();

			this.background.x = -this.x;
			this.background.y = -this.y;
		}

		public function deserialize(data:*):void
		{
			clear();

			var input:Array;
			try
			{
				input = by.blooddy.crypto.serialization.JSON.decode(data);
			}
			catch (e:Error)
			{
				Logger.add("Failed to decode JSON map data: " + e, data);
				return;
			}

			this.backgroundId = input[0];
			var objects:Array = input[1];

			this.deserializeObjects(objects);

			if (2 in input)
				this.shamanTools = input[2];
			else
				this.shamanTools = [];

			if (3 in input)
				this.size = new Point(input[3][0], input[3][1]);
			else
				this.size = new Point(Config.GAME_WIDTH, Config.GAME_HEIGHT);

			if (4 in input)
				this.gravity = new b2Vec2(input[4][0], input[4][1]);
			else
				this.gravity = SquirrelGame.DEFAULT_GRAVITY;

			if (5 in input)
				this.lastEditor = input[5];
			else
				this.lastEditor = 0;
		}

		public function deserializeObjects(objects:Array):void
		{
			for (var i:int = 0, j:int = objects.length; i < j; i++)
			{
				var entity:* = objects[i];
				if (entity == "" || EntityFactory.getEntity(entity[0]) == null)
				{
					add(null);
					continue;
				}

				var object:IGameObject = new (EntityFactory.getEntity(entity[0]) as Class)();

				if (object is ISerialize)
					(object as ISerialize).deserialize(entity[1]);

				if (object is IStarlingAdapter && entity.length == 3)
				{
					(object as IStarlingAdapter).name = entity[2][0];
					(object as IStarlingAdapter).alpha = entity[2][1];
				}

				add(object);

				if (object is CollectionElement)
					this.elements[(object as CollectionElement).index] = object;
			}

			for each (object in this.objects)
			{
				if (!(object is IPostDeserialize))
					continue;
				(object as IPostDeserialize).OnPostDeserialize(this);
			}

			drawVisibleObjects();
		}

		public function removeObject(object:*):void
		{
			if (object is int)
				setTimeout(remove, 0, this.objects[object], true);

			if (object is String)
				setTimeout(remove, 0, getByName(object), true);

			if (object is IGameObject)
				setTimeout(remove, 0, object, true);
		}

		public function addObject(id:*, posX:Number, posY:Number, angle:Number, build:Boolean = true):IGameObject
		{
			if (id is Class)
				id = EntityFactory.getId(id);
			if (id is String)
				id = EntityFactory.getIdByName(id);

			var object:IGameObject = new (EntityFactory.getEntity(id))();
			object.position = new b2Vec2(posX / Game.PIXELS_TO_METRE, posY / Game.PIXELS_TO_METRE);
			object.angle = angle * Game.D2R;
			add(object);

			if (object is HollowBody)
			{
				(object as HollowBody).game = this.game;
				(object as HollowBody).addEventListener(HollowEvent.HOLLOW, onHollow, false, 0, true);
			}

			if (object is AcornBody)
				(object as AcornBody).addEventListener(SquirrelEvent.ACORN, onAcorn, false, 0, true);

			otherCheck(object);

			if (build && object)
				setTimeout(buildObject, 0, object);

			return object;
		}

		public function serialize():*
		{
			var result:Array = [];

			result.push(this.backgroundId);

			var objects:Array = [];
			for (var i:int = 0, j:int = this.objects.length; i < j; i++)
			{
				var object:StarlingAdapterSprite = this.objects[i];
				if (object is ISerialize)
					objects.push([EntityFactory.getId(object), (object as ISerialize).serialize(), ((object is IStarlingAdapter) ? [object.name, object.alpha] : [])]);

				if (object == null)
					objects.push("");
			}

			result.push(objects);
			result.push(this.shamanTools);
			result.push([this.size.x, this.size.y]);
			result.push([this.gravity.x, this.gravity.y]);
			result.push(this.lastEditor);

			var outPut:String = by.blooddy.crypto.serialization.JSON.encode(result);
			try
			{
				by.blooddy.crypto.serialization.JSON.decode(outPut);
				return outPut;
			}
			catch (e:Error)
			{
				return serialize();
			}
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

		public function get size():Point
		{
			return _size;
		}

		public function set size(value:Point):void
		{
			_size = value;

			if (this.drawSprite)
			{
				this.drawSprite.graphics.clear();
				this.drawSprite.graphics.lineStyle(5, 0xFFCC33, 0.5);
				this.drawSprite.graphics.drawRect(0, Config.GAME_HEIGHT, this.size.x, -this.size.y);
			}
		}

		public function get(className:Class, baseClass:Boolean = false):Array
		{
			var result:Array = [];

			for each (var object:* in this.objects)
				if ((!baseClass && (getQualifiedClassName(object) == getQualifiedClassName(className))) || (baseClass && (object is className)))
					result.push(object);

			return result;
		}

		public function has(className:Class):Boolean
		{
			for each (var object:* in this.objects)
			{
				if (getQualifiedClassName(object) == getQualifiedClassName(className))
					return true;
			}

			return false;
		}

		public function getSquirrelsCount():int
		{
			return get(SquirrelBody).concat(get(ShamanBody)).length;
		}

		public function build(world:b2World):void
		{
			Logger.setTag("GameMap.build");
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
					object.addEventListener(HollowEvent.HOLLOW, onHollow, false, 0, true);
				}

				if (object is AcornBody)
				{
					object.addEventListener(SquirrelEvent.ACORN, onAcorn, false, 0, true);
					this.acornPosition = object.position;
				}

				if (object is RespawnPoint)
				{
					object.addEventListener(SquirrelEvent.RESPAWN_POINT, onRespawnPoint, false, 0, true);
				}

				otherCheck(object);
			}
			Logger.closeTag("GameMap.build");
		}

		public function update(timeStep:Number = 0):void
		{
			for each (var object:* in this.objects.concat(this.objectsQuest))
			{
				if (object is IUpdate)
					object.update(timeStep);
			}

			drawVisibleObjects();
			this.portals.doTeleport();
			this.cachePool.update();
			this._particles.updateAll(timeStep);
		}

		public function clear():void
		{
			//TextureCollection.getInstance().disposeAllShapeTextures();

			if (this.portals)
				this.portals.reset();

			this.elements = {};

			while (this.objects.length > 0)
			{
				var object:* = this.objects.pop();
				if (object is ISideObject)
					this.game.sideIcons.remove(object);

				if (object is IDispose)
					object.dispose();
				InstanceCounter.onDispose(object);
			}
			while (this.objectsQuest.length > 0)
			{
				object = this.objectsQuest.pop();
				if (object is IDispose)
					object.dispose();
			}

			this.cachePool.cacheAsBitmap = false;
			this.cachePool.clear();

			while (this.userBottomSprite.numChildren > 0)
				this.userBottomSprite.removeChildAt(0);

			while (this.userUpperSprite.numChildren > 0)
				this.userUpperSprite.removeChildAt(0);

			this.objects = [];

			this.respawnPosition = null;

			this._particles.clear();
		}

		public function dispose():void
		{
			FullScreenManager.instance().removeEventListener(FullScreenManager.CHANGE_FULLSCREEN, onChangeScreenSize);
			TextureCollection.getInstance().disposeAllShapeTextures();
			TextureCollection.getInstance().disposeAllUniqTextures();

			if (backgroundLayerQuad)
				backgroundLayerQuad.removeFromParent(true);

			DisplayObjectManager.getInstance().remove(backgroundLayer0);

			if (backgroundLayer0)
				backgroundLayer0.removeFromParent(true);

			DisplayObjectManager.getInstance().remove(backgroundLayer1);

			if (backgroundLayer1)
				backgroundLayer1.removeFromParent(true);

			while (objectSprite.numChildren > 0)
				objectSprite.removeChildStarlingAt(0, true);

			while (_foregroundObjects.numChildren > 0)
				_foregroundObjects.removeChildStarlingAt(0, true);

			while (this.userBottomSprite.numChildren > 0)
				this.userBottomSprite.removeChildAt(0);

			while (this.userUpperSprite.numChildren > 0)
				this.userUpperSprite.removeChildAt(0);

			while (bgLayer.numChildren > 0)
				bgLayer.removeChildStarlingAt(0);

			backgroundLayer0 = null;
			backgroundLayer1 = null;
			backgroundLayerQuad = null;

			Starling.current.nativeStage.frameRate = 30;
			Logger.add("GameMap.dispose");
			InstanceCounter.onDispose(this);

			clear();

			this.game = null;
			this.portals = null;
			this.cachePool = null;
			this._particles = null;

			while (this.numChildren > 0)
				removeChildStarlingAt(0);

			_instance = null;
		}

		protected function otherCheck(object:*):void
		{
		}

		protected function onHollow(e:HollowEvent):void
		{
			if (e.target is HollowBody)
				return;

			Logger.add("GameMap.onHollow --> e.target is not HollowBody");
		}

		protected function onAcorn(e:SquirrelEvent):void
		{
		}

		protected function onRespawnPoint(e:SquirrelEvent):void
		{
			this.respawnPosition = e.player.position.Copy();
		}

		public function get isBrokenWorld():Boolean
		{
			var objects:Array = get(HollowBody, true).concat(get(AcornBody));
			if (objects.length < 2)
				return false;

			var delta:Number = 0;
			for (var i:int = 0; i < objects.length - 1; i++)
				for (var j:int = i + 1; j < objects.length; j++)
				{
					var pos:b2Vec2 = (objects[i] as GameBody).position.Copy();
					pos.Subtract((objects[j] as GameBody).position);
					delta += pos.Length();
				}
			delta = delta / (objects.length * (objects.length - 1) / 2);
			Logger.add("isBrokenWorld", delta);

			return isNaN(delta);
		}

		private function buildObject(object:IGameObject):void
		{
			if (object && this && this.game && this.game.world)
				object.build(this.game.world);
		}
	}
}