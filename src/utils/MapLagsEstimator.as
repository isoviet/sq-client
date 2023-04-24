package utils
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;

	import game.mainGame.ILags;
	import game.mainGame.ISerialize;
	import game.mainGame.entity.EntityFactory;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.ISizeable;
	import game.mainGame.entity.editor.Branch;
	import game.mainGame.entity.editor.HintArrowObject;
	import game.mainGame.entity.editor.IslandBig;
	import game.mainGame.entity.editor.IslandLessSmall;
	import game.mainGame.entity.editor.IslandMedium;
	import game.mainGame.entity.editor.IslandSmall;
	import game.mainGame.entity.editor.Mount;
	import game.mainGame.entity.editor.MountIce;
	import game.mainGame.entity.editor.MountSliced;
	import game.mainGame.entity.editor.PlanetBody;
	import game.mainGame.entity.editor.PlatformAcidBody;
	import game.mainGame.entity.editor.PlatformBlockBody;
	import game.mainGame.entity.editor.PlatformBridgeBody;
	import game.mainGame.entity.editor.PlatformDesertSandBody;
	import game.mainGame.entity.editor.PlatformGroundBody;
	import game.mainGame.entity.editor.PlatformHerbBody;
	import game.mainGame.entity.editor.PlatformLavaBody;
	import game.mainGame.entity.editor.PlatformSandBody;
	import game.mainGame.entity.editor.PlatformSeaShore;
	import game.mainGame.entity.editor.PlatformSpaceShipPiece;
	import game.mainGame.entity.editor.PlatformSpikesBody;
	import game.mainGame.entity.editor.PlatformSwampBody;
	import game.mainGame.entity.editor.Pyramid;
	import game.mainGame.entity.editor.RectGravity;
	import game.mainGame.entity.editor.Ribs;
	import game.mainGame.entity.editor.Stone;
	import game.mainGame.entity.editor.Trunk;
	import game.mainGame.entity.editor.decorations.DecorationAmphora;
	import game.mainGame.entity.editor.decorations.DecorationAppleTree;
	import game.mainGame.entity.editor.decorations.DecorationBush;
	import game.mainGame.entity.editor.decorations.DecorationCactus1;
	import game.mainGame.entity.editor.decorations.DecorationCactus2;
	import game.mainGame.entity.editor.decorations.DecorationCloud;
	import game.mainGame.entity.editor.decorations.DecorationDandelion;
	import game.mainGame.entity.editor.decorations.DecorationDesertCloud1;
	import game.mainGame.entity.editor.decorations.DecorationDesertCloud2;
	import game.mainGame.entity.editor.decorations.DecorationEagle;
	import game.mainGame.entity.editor.decorations.DecorationFern;
	import game.mainGame.entity.editor.decorations.DecorationFirTree;
	import game.mainGame.entity.editor.decorations.DecorationFirTreeSnowed;
	import game.mainGame.entity.editor.decorations.DecorationFountain;
	import game.mainGame.entity.editor.decorations.DecorationHedgehog;
	import game.mainGame.entity.editor.decorations.DecorationMushrooms;
	import game.mainGame.entity.editor.decorations.DecorationOwl;
	import game.mainGame.entity.editor.decorations.DecorationPine;
	import game.mainGame.entity.editor.decorations.DecorationSarcophagus;
	import game.mainGame.entity.editor.decorations.DecorationSingleStone;
	import game.mainGame.entity.editor.decorations.DecorationSkull;
	import game.mainGame.entity.editor.decorations.DecorationStatue;
	import game.mainGame.entity.editor.decorations.DecorationTorch;
	import game.mainGame.entity.editor.decorations.DecorationTwoStones;
	import game.mainGame.entity.editor.decorations.DecorationWoodLog;
	import game.mainGame.entity.editor.decorations.Sea.DecorationOctopus;
	import game.mainGame.entity.editor.decorations.Sea.DecorationPalmTree;
	import game.mainGame.entity.editor.decorations.Sea.DecorationPinguin;
	import game.mainGame.entity.editor.decorations.Sea.DecorationPinkFish;
	import game.mainGame.entity.editor.decorations.Sea.DecorationYellowFish;
	import game.mainGame.entity.editor.decorations.mountains.DecorationFirTreeSnow;
	import game.mainGame.entity.editor.decorations.mountains.DecorationHedgehogIce;
	import game.mainGame.entity.editor.decorations.mountains.DecorationIceTree;
	import game.mainGame.entity.editor.decorations.mountains.DecorationSnowman;
	import game.mainGame.entity.joints.JointDistance;
	import game.mainGame.entity.joints.JointPulley;
	import game.mainGame.entity.joints.JointRope;
	import game.mainGame.entity.joints.JointWeld;
	import game.mainGame.entity.quicksand.Quicksand;
	import game.mainGame.entity.simple.AcornBody;
	import game.mainGame.entity.simple.BalloonBody;
	import game.mainGame.entity.simple.FirCone;
	import game.mainGame.entity.simple.FirConeRight;
	import game.mainGame.entity.simple.HollowBody;
	import game.mainGame.entity.simple.Poise;
	import game.mainGame.entity.simple.PoiseRight;
	import game.mainGame.entity.simple.PortalBlue;
	import game.mainGame.entity.simple.PortalBlueDirected;
	import game.mainGame.entity.simple.PortalRed;
	import game.mainGame.entity.simple.PortalRedDirected;
	import game.mainGame.entity.simple.SeaGrass;
	import game.mainGame.entity.simple.SunflowerBody;
	import game.mainGame.entity.simple.Tornado;
	import game.mainGame.entity.simple.Trampoline;
	import game.mainGame.entity.simple.TreeBody;
	import game.mainGame.entity.simple.WeightBody;
	import game.mainGame.entity.water.Water;
	import game.mainGame.gameEditor.MapData;

	import avmplus.getQualifiedClassName;

	import by.blooddy.crypto.serialization.JSON;

	import interfaces.IDispose;

	public class MapLagsEstimator
	{
		static private const DISPLAY_OBJECT_INDEX:Number = 0.1;
		static private const MOVIECLIP_OBJECT_INDEX:Number = 0.5;
		static private const DISPLAY_REDRAW_OBJECT_INDEX:Number = 0.25;

		static private const RENDERING_WEIGHTS:Object = {
			(getQualifiedClassName(BalloonBody)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(PortalBlue)): MOVIECLIP_OBJECT_INDEX,
			(getQualifiedClassName(PortalRed)): MOVIECLIP_OBJECT_INDEX,
			(getQualifiedClassName(Poise)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(PoiseRight)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(HollowBody)): MOVIECLIP_OBJECT_INDEX,
			(getQualifiedClassName(AcornBody)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(IslandSmall)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(IslandMedium)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(IslandBig)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(PlatformSandBody)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(PlatformHerbBody)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(PlatformGroundBody)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(SunflowerBody)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(TreeBody)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(IslandLessSmall)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(JointDistance)): DISPLAY_REDRAW_OBJECT_INDEX,
			(getQualifiedClassName(JointWeld)): DISPLAY_REDRAW_OBJECT_INDEX + 0.3,
			(getQualifiedClassName(JointPulley)): DISPLAY_REDRAW_OBJECT_INDEX,
			(getQualifiedClassName(WeightBody)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(Mount)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(MountIce)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(MountSliced)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(Stone)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(PortalBlueDirected)): MOVIECLIP_OBJECT_INDEX,
			(getQualifiedClassName(PortalRedDirected)): MOVIECLIP_OBJECT_INDEX,
			(getQualifiedClassName(Branch)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(Trunk)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(Trampoline)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(PlatformBridgeBody)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(PlatformLavaBody)): MOVIECLIP_OBJECT_INDEX,
			(getQualifiedClassName(PlatformSwampBody)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(HintArrowObject)): MOVIECLIP_OBJECT_INDEX,
			(getQualifiedClassName(Water)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationAppleTree)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationBush)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationCloud)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationFirTree)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationFirTreeSnowed)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationMushrooms)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationOwl)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(FirCone)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(FirConeRight)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(PlatformAcidBody)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(PlatformSpikesBody)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(JointRope)): DISPLAY_REDRAW_OBJECT_INDEX,
			(getQualifiedClassName(SeaGrass)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationPinguin)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationYellowFish)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationPinkFish)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationOctopus)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationPalmTree)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(PlatformSeaShore)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(PlanetBody)): MOVIECLIP_OBJECT_INDEX,
			(getQualifiedClassName(RectGravity)): MOVIECLIP_OBJECT_INDEX,
			(getQualifiedClassName(PlatformSpaceShipPiece)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationEagle)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationFern)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationHedgehog)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationHedgehogIce)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationIceTree)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationPine)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationSingleStone)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationFirTreeSnow)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationSnowman)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationDandelion)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationWoodLog)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationTwoStones)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(Tornado)): MOVIECLIP_OBJECT_INDEX,
			(getQualifiedClassName(Quicksand)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationDesertCloud1)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationDesertCloud2)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationCactus1)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationCactus2)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationSkull)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationAmphora)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationStatue)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(PlatformDesertSandBody)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(PlatformBlockBody)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(Pyramid)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(Ribs)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationSarcophagus)): DISPLAY_OBJECT_INDEX,
			(getQualifiedClassName(DecorationTorch)): MOVIECLIP_OBJECT_INDEX,
			(getQualifiedClassName(DecorationFountain)): MOVIECLIP_OBJECT_INDEX
		};

		static private const RASTERIZE_EDGES_WEIGHTS:Object = {
			(getQualifiedClassName(Branch)): 5.5,
			(getQualifiedClassName(PlatformSandBody)): 0.6,
			(getQualifiedClassName(PlatformHerbBody)): 0.6,
			(getQualifiedClassName(PlatformGroundBody)): 0.6,
			(getQualifiedClassName(PlatformBridgeBody)): 0.6,
			(getQualifiedClassName(PlatformLavaBody)): 0.6,
			(getQualifiedClassName(PlatformSwampBody)): 1,
			(getQualifiedClassName(PlatformAcidBody)): 0.6,
			(getQualifiedClassName(PlatformSpikesBody)): 0.6,
			(getQualifiedClassName(PlatformSpaceShipPiece)): 1,
			(getQualifiedClassName(PlatformDesertSandBody)): 0.6,
			(getQualifiedClassName(RectGravity)): 0.8,
			(getQualifiedClassName(BalloonBody)): 1.6
		};

		static public const LAGS_INDEX_TRESHOLD:int = 100;

		static public function estimateLags(mapData:MapData, callBack:Function):void
		{
			callBack.call(null, mapData.number, analyzeMap(mapData));
		}

		static private function analyzeMap(mapData:MapData):int
		{
			var map:Array = deserializeMap(mapData.map);
			var mapObjects:Array = map[1];

			var lagsIndexes:Object = {};
			var mapSize:Point = map[0];

			var sprite:Sprite = new Sprite();
			var background:Shape = new Shape();
			background.graphics.beginFill(0x0000FF);
			background.graphics.drawRect(0, 0, mapSize.x, mapSize.y);
			background.graphics.endFill();
			sprite.addChild(background);

			for each (var mapOject:Object in mapObjects)
			{
				var object:Object = mapOject['object'];
				(object as ISerialize).deserialize(mapOject['data']);

				var className:String = getQualifiedClassName(object);

				if (!(className in lagsIndexes))
					lagsIndexes[className] = 0;

				var scaleFactor:Number = (mapSize.x * mapSize.y) / (Config.GAME_WIDTH * Config.GAME_HEIGHT);

				var bodyWithinMap:Boolean = false;

				if (object is IGameObject)
				{
					sprite.addChild(object as DisplayObject);
					bodyWithinMap = background.hitTestObject(object as DisplayObject);
					sprite.removeChild(object as DisplayObject);
				}

				if (bodyWithinMap)
				{
					if (className in RENDERING_WEIGHTS)
					{
						var index:Number = RENDERING_WEIGHTS[className];

						if (index == DISPLAY_OBJECT_INDEX)
						{
							var width:Number, height:Number;

							if (object is ISizeable)
							{
								switch (className)
								{
									case "Branch":
										width = (object as ISizeable).size.x * Game.PIXELS_TO_METRE;
										height = 20;
										break;
									case "Stone":
										width = (object as ISizeable).size.x * Game.PIXELS_TO_METRE;
										height = (object as ISizeable).size.y * Game.PIXELS_TO_METRE;
										break;
									default:
										width = Math.abs((object as ISizeable).size.x * Game.PIXELS_TO_METRE / 2);
										height = Math.abs((object as ISizeable).size.y * Game.PIXELS_TO_METRE / 2);
										break;
								}
							}
							else
							{
								width = object.width;
								height = object.height;
							}

							var area:Number = Math.min(width, mapSize.x) * Math.min (height, mapSize.y);

							index *= area / (10000);
						}

						lagsIndexes[className] += index / scaleFactor;
					}

					if (className in RASTERIZE_EDGES_WEIGHTS)
					{
						var angle:Number = (object.rotation < 0 ? (360 - Math.abs(object.rotation)) : object.rotation) * Game.D2R;
						var factor:Number = Math.abs(Math.cos(angle) * Math.sin(angle));
						lagsIndexes[className] += factor * RASTERIZE_EDGES_WEIGHTS[className] / scaleFactor;
					}
				}

				if (object is ILags)
					lagsIndexes[className] += (object as ILags).estimateLags();

				if (object is IDispose)
					(object as IDispose).dispose();
			}

			var lags:int = 0;
			for (var name:String in lagsIndexes)
				lags += lagsIndexes[name];

			return lags * 2;
		}

		static private function deserializeMap(data:*):Array
		{
			var input:Array;

			try
			{
				input = by.blooddy.crypto.serialization.JSON.decode(data);
			}
			catch (e:Error)
			{
				Logger.add("Failed to decode JSON map data: " + e, data);
				throw e;
			}

			var size:Point = null;

			if (3 in input)
				size = new Point(input[3][0], input[3][1]);
			else
				size = new Point(Config.GAME_WIDTH, Config.GAME_HEIGHT);

			var objects:Array = input[1];

			var objectsClasses:Array = [];

			for each (var entity:* in objects)
			{
				if (entity == "" || EntityFactory.getEntity(entity[0]) == null)
					continue;

				var object:* = new (EntityFactory.getEntity(entity[0]) as Class)();

				objectsClasses.push({'object': object, 'data': entity[1]});
			}

			return [size, objectsClasses];
		}
	}
}