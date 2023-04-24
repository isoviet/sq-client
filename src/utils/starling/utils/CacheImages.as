package utils.starling.utils
{
	import utils.starling.StarlingAdapterMovie;
	import utils.starling.collections.DisplayObjectManager;
	import utils.starling.extensions.virtualAtlas.AssetManager;

	public class CacheImages
	{
		private static var instance: CacheImages = null;

		private var forCache: Array = [
			AcornEffectLight, AcornContactMovie, AcornsVector, Bubble, BombExplode, BombPrepere, BubbleBurst,
			ImmortalityBubble, ActiveAura, HollowContactMovie, HollowWow, HollowEyes
		];

		public function CacheImages(): void
		{
			if (!instance)
			{
				for (var i:int = 0, j:int = forCache.length; i < j; i++)
				{
					var mc:StarlingAdapterMovie = new StarlingAdapterMovie(new forCache[i], false);
					mc.removeFromParent(false);
				}
				DisplayObjectManager.getInstance().reservedOffset = DisplayObjectManager.getInstance().length;
			}

			instance = this;

			//TODO generate atlas
			/*var imagesClass: Vector.<Class> = new <Class>[
				Island4, Island3, Island2, Island1, Box1, Box2, Balk1, Balk2,
				Herb, HollowDoor, PlatformGround, BridgeLeft, BridgeMiddle, BridgeRight,
				JointDot, PinLimited, PinUnlimited, MotorIcon, BalloonColor, BalloonOver,
				Hollow, PoiseL, SquirrellLighting, RopeSegmentView, Dandelion, Weight, GunPoiseImg,
				HammerView, FirConeView, WoodenBlock,
				// snow mount
				IceBalk1, IceBalk2, IceBox1, IceBox2, Ice, IceGroundLeft, IceGroundMiddle,
				IceGroundRight, HedgehogIce, FirTreeSnow, FirTreeSnowed, IceTree, Snowman,
				//Marsh
				SeaGrassView, HolesView, PinguinDec, FishYellowDec, FishPinkDec, OctopusDec, Acid, VineSegment,
				//desert
				Sand, Sand1, Block, RibsView, NetIcon, BungeeBalkImg,
				//anomalous zone
				Spikes, SpaceShipPieceView, Lava, GlassBlock, MetalBlock, GlassBalkSmall, GlassBalkBig,
				GlassBox, Beam, BeamEmitterImg, SteelBoxView, SteelBoxBigView, SteelBalkView,
				SteelBalkLongView, HomingGunImg, BubbleEmitterImg,

				//decoration
				PalmDec, ScrapMetal, Crystal1, Crystal2, Crystal3, GlassTree, GlassUnicorn,Cactus1,
				Cactus2, Skull, DesertCloud1, DesertCloud2, Amphora, Sarcophagus, Statue, AppleTree,
				Mushrooms, Cloud, Bush, FirTree, Owl, Tree, Sunflower, Pine, WoodLog, Eagle,
				SingleStone, TwoStones, Fern, Hedgehog, Robot
			];

			AssetManager.instance.createAtlas(imagesClass);*/
		}
	}
}