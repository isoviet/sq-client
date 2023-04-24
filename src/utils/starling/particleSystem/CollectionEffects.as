package utils.starling.particleSystem
{
	import flash.display.Sprite;

	import utils.starling.extensions.FFParticleSystem;
	import utils.starling.extensions.virtualAtlas.AssetManager;
	import utils.starling.particleSystem.ConfigEffects.EffectAidConfig;
	import utils.starling.particleSystem.ConfigEffects.EffectAltroneConfig;
	import utils.starling.particleSystem.ConfigEffects.EffectBearConfig;
	import utils.starling.particleSystem.ConfigEffects.EffectCastShaman;
	import utils.starling.particleSystem.ConfigEffects.EffectDisintegratorConfig;
	import utils.starling.particleSystem.ConfigEffects.EffectDragonFireConfig;
	import utils.starling.particleSystem.ConfigEffects.EffectFireBallConfig;
	import utils.starling.particleSystem.ConfigEffects.EffectLightningConfig;
	import utils.starling.particleSystem.ConfigEffects.EffectMissingNut;
	import utils.starling.particleSystem.ConfigEffects.EffectOrcConfig;
	import utils.starling.particleSystem.ConfigEffects.EffectPlanetGravityConfig;
	import utils.starling.particleSystem.ConfigEffects.EffectSmokeConfig;
	import utils.starling.particleSystem.ConfigEffects.EffectSquirrelFireConfig;
	import utils.starling.particleSystem.ConfigEffects.EffectStitchConfig;
	import utils.starling.particleSystem.ConfigEffects.EffectTimeWarpConfig;
	import utils.starling.particleSystem.ConfigEffects.EffectVaderConfig;
	import utils.starling.particleSystem.ConfigEffects.EffectVolcanoConfig;
	import utils.starling.particleSystem.ConfigEffects.EffectWildWayConfig;
	import utils.starling.particleSystem.ConfigEffects.EffectZombieSmokeConfig;
	import utils.starling.particleSystem.ConfigEffects.EffectZombieTransformConfig;

	public class CollectionEffects
	{
		public static const EFFECTS_DRAGON_FIRE:String = 'dragonFire';
		public static const EFFECTS_SQUIRREL_FIRE:String = 'squirrelFire';
		public static const EFFECTS_SQUIRREL_FIRE_BLUE:String = 'squirrelFireBlue';
		public static const EFFECTS_FIRE_BALL:String = 'fireBall';
		public static const EFFECTS_SMOKE:String = 'smoke';
		public static const EFFECTS_YELLOW_SMOKE:String = 'yellowSmoke';
		public static const EFFECTS_BLACK_SMOKE:String = 'blackSmoke';
		public static const EFFECTS_LIGHTNING:String = 'lightning';
		public static const EFFECTS_LIGHTNING_TAIL:String = 'lightningTail';
		public static const EFFECT_PLANET_GRAVITY:String = 'planetGravity';
		public static const EFFECT_DISINTEGRATOR:String = 'disintegrator';
		public static const EFFECT_MISSING_NUT:String = 'missingNut';

		public static const EFFECT_CAST_SHAMAN:String = 'castShaman';
		public static const EFFECT_CAST_FLOWER_SHAMAN:String = 'castFlowerShaman';

		public static const EFFECT_ZOMBIE_SMOKE:String = 'zombieSmoke';
		public static const EFFECT_ZOMBIE_TRANSFORM:String = 'zombieTransform';
		public static const EFFECT_WILD_WAY:String = 'wildWayEffect';

		public static const EFFECT_VOLCANO_DEACTIVE:String = 'volcanoDeactive';
		public static const EFFECT_VOLCANO_PREPARE:String = 'volcanoPrepare';
		public static const EFFECT_VOLCANO_ACTIVE:String = 'volcanoActive';

		public static const EFFECT_SHEEP_BOMB:String = 'sheepBomb';
		public static const EFFECT_SHADOW_BOMB:String = 'shadowBomb';

		public static const EFFECT_ALTRONE:String = 'altroneFire';
		public static const EFFECT_FAIRY_CAT:String = 'fairyCat';
		public static const EFFECT_BLACK_CAT:String = 'blackCat';
		public static const EFFECT_DEER:String = 'deer';
		public static const EFFECT_TIME_WARP:String = 'timeWarp';

		public static const EFFECT_VADER:String = 'vader';

		public static const EFFECT_BEAR_COFFEE:String = 'bearCoffee';
		public static const EFFECT_BEAR_SWIM:String = 'bearSwim';

		public static const EFFECT_AID:String = 'aidBridge';
		public static const EFFECT_STITCH:String = 'stitchLazer';

		public static const EFFECT_HOLIDAY:String = 'holiday';

		public static const EFFECT_ORC:String = 'orc';

		private var _mapX: Number = 0;
		private var _mapY: Number = 0;

		private var listConfigEffect: Object =
		{
			dragonFire: {
				config: EffectDragonFireConfig.DRAGON_FIRE_CONFIG,
				image: new CircleEffectParticle
			},
			squirrelFire: {
				config: EffectSquirrelFireConfig.SQUIRREL_FIRE_CONFIG,
				image: new CircleEffectParticle
			},
			squirrelFireBlue: {
				config: EffectSquirrelFireConfig.SQUIRREL_FIRE_BLUE_CONFIG,
				image: new CircleEffectParticle
			},
			fireBall: {
				config: EffectFireBallConfig.FIRE_BALL_CONFIG,
				image: new CircleEffectParticle
			},
			smoke: {
				config: EffectSmokeConfig.SMOKE_CONFIG,
				image: new SmokeEffect
			},
			blackSmoke: {
				config: EffectSmokeConfig.BLACK_SMOKE_CONFIG,
				image: new SmokeEffect
			},
			lightning: {
				config: EffectLightningConfig.LIGHTNING_CONFIG,
				image: new LightningEffectParticle
			},
			lightningTail: {
				config: EffectLightningConfig.LIGHTNING_TAIL_CONFIG,
				image: new CircleEffectParticle
			},
			planetGravity: {
				config: EffectPlanetGravityConfig.PLANET_GRAVITY_CONFIG,
				image: new PlanetGravityEffect
			},
			holiday: {
				config: EffectPlanetGravityConfig.HOLIDAY_CONFIG,
				image: new CircleEffectParticle
			},
			disintegrator: {
				config: EffectDisintegratorConfig.DISINTEGRATOR_CONFIG,
				image: new DisintegratorEffect
			},
			missingNut: {
				config: EffectMissingNut.MISSING_NUT_CONFIG,
				image: new PlanetGravityEffect
			},
			castShaman: {
				config: EffectCastShaman.CAST_SHAMAN,
				image: new SphereEffectParticle
			},
			yellowSmoke: {
				config: EffectSmokeConfig.YELLOW_SMOKE_CONFIG,
				image: new SmokeEffect
			},
			castFlowerShaman: {
				config: EffectCastShaman.CAST_FLOWER_SHAMAN,
				image: new FlowerEffectParticle
			},
			zombieSmoke: {
				config: EffectZombieSmokeConfig.ZOMBIE_SMOKE_CONFIG,
				image: new ZombieSmokeEffect
			},
			zombieTransform: {
				config: EffectZombieTransformConfig.ZOMBIE_TRANSFORM_CONFIG,
				image: new ZombieTransformEffect
			},
			wildWayEffect: {
				config: EffectWildWayConfig.WILD_WAY_CONFIG,
				image: new WildWayEffect
			},
			volcanoDeactive: {
				config: EffectVolcanoConfig.DEACTIVE_CONFIG,
				image: new VolcanoSmokeEffect
			},
			volcanoPrepare: {
				config: EffectVolcanoConfig.PREPARE_CONFIG,
				image: new VolcanoSmokeEffect
			},
			volcanoActive: {
				config: EffectVolcanoConfig.ACTIVE_CONFIG,
				image: new VolcanoHotEffect
			},
			sheepBomb: {
				config: EffectSmokeConfig.SHEEP_CONFIG,
				image: new SmokeEffect
			},
			shadowBomb: {
				config: EffectSmokeConfig.SHADOW_CONFIG,
				image: new SmokeEffect
			},
			altroneFire: {
				config: EffectAltroneConfig.FLY_CONFIG,
				image: new CircleEffectParticle
			},
			fairyCat: {
				config: EffectAltroneConfig.CAT_CONFIG,
				image: new CircleEffectParticle
			},
			blackCat: {
				config: EffectAltroneConfig.BLACK_CAT_CONFIG,
				image: new CircleEffectParticle
			},
			deer: {
				config: EffectAltroneConfig.DEER_CONFIG,
				image: new CircleEffectParticle
			},
			timeWarp: {
				config: EffectTimeWarpConfig.TIME_CONFIG,
				image: new CircleEffectParticle
			},
			vader: {
				config: EffectVaderConfig.VADER_CONFIG,
				image: new CircleEffectParticle
			},
			bearCoffee: {
				config: EffectBearConfig.COFFEE_CONFIG,
				image: new CircleEffectParticle
			},
			bearSwim: {
				config: EffectBearConfig.SWIM_CONFIG,
				image: new CircleEffectParticle
			},
			aidBridge: {
				config: EffectAidConfig.AID_CONFIG,
				image: new AidEffect
			},
			stitchLazer: {
				config: EffectStitchConfig.STITCH_CONFIG,
				image: new CircleEffectParticle
			},
			orc: {
				config: EffectOrcConfig.BASE_CONFIG,
				image: new CircleEffectParticle
			}
		};

		private var _collection: Vector.<ParticlesEffect> = new Vector.<ParticlesEffect>();
		private static var _instance: CollectionEffects = null;

		public function CollectionEffects()
		{
			FFParticleSystem.init(4096, false, 4096, 16);
		}

		public function set mapX(value: Number): void {
			_mapX = value;
		}

		public function get mapX(): Number {
			return _mapX;
		}

		public function set mapY(value: Number): void {
			_mapY = value;
		}

		public function get mapY(): Number {
			return _mapY;
		}

		public static function get instance(): CollectionEffects
		{
			if (!_instance)
				_instance = new CollectionEffects();

			return _instance;
		}

		public function getEffectByName(constEffect: String, params:Object = null): ParticlesEffect
		{
			var textureOrBitmap: * = null;
			if (listConfigEffect[constEffect].image is Sprite)
				textureOrBitmap = AssetManager.instance.getTexture(listConfigEffect[constEffect].image);

			if (textureOrBitmap == null)
				textureOrBitmap = listConfigEffect[constEffect].image;

			var _result: ParticlesEffect = new ParticlesEffect(
				textureOrBitmap, listConfigEffect[constEffect].config,
				listConfigEffect[constEffect].atlasXML,
				params
			);
			_collection.push(_result);
			return _result;
		}

		public function removeEffect(obj: ParticlesEffect): void
		{
			if(_collection.indexOf(obj) > -1)
			{
				var _result: Vector.<ParticlesEffect> = _collection.splice(_collection.indexOf(obj), 1);
				_result[0].removeFromParent(true);
			}
		}

		public function dispose(): void
		{
			for(var i: int = 0; i < _collection.length; i++)
			{
				_collection[i].removeFromParent(true);
				_collection[i] = null;
			}
			_collection = null;
		}
	}
}