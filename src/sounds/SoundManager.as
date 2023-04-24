package sounds
{
	import flash.events.Event;
	import flash.media.SoundChannel;

	import events.GameLoadEvent;
	import screens.ScreenGame;
	// НЕПОДКЛЮЧЕНО

	public class SoundManager extends SoundsBase
	{
		//Music
		static public const MISSION0_AMBIENT:SoundArray		= new SoundArray("Mission0Ambient");
		static public const MISSION6_AMBIENT:SoundArray		= new SoundArray("Mission6Ambient");
		static public const MISSION8_AMBIENT:SoundArray		= new SoundArray("Mission8Ambient");
		//Базовые
		static public const SYSTEM:SoundArray			= new SoundArray("InterfaceHealth,InterfaceReload,InterfaceEnergy,InterfaceHeal", null, true);
		static public const SHOT:SoundArray			= new SoundArray("ShotPistol1");
		static public const ATTACK:SoundArray			= new SoundArray("AttackMeleeLight1");
		static public const HIT:SoundArray			= new SoundArray("MeleeHit1");
		static public const DIE:SoundArray			= new SoundArray("HeroDeath");
		static public const BULLET:SoundArray			= new SoundArray("BulletDie1,BulletDie2");
		static public const BLOCK:SoundArray			= new SoundArray("HumanOnBlock");
		//Второй уровень
		static public const SHOT_PISTOL:SoundArray		= new SoundArray("ShotPistol1,ShotPistol2,ShotPistol3", SHOT);
		static public const ATTACK_MELEE:SoundArray		= new SoundArray("AttackMeleeLight1,AttackMeleeLight2", ATTACK);
		static public const HIT_RANGER:SoundArray		= new SoundArray("RangerHit1", HIT);
		static public const HIT_MELEE:SoundArray		= new SoundArray("MeleeHit1,MeleeHit2,MeleeHit3,MeleeHit4,MeleeHit5", HIT);
		static public const DIE_HUMAN:SoundArray		= new SoundArray("HumanDeath1,HumanDeath2,HumanDeath3,HumanDeath4,HumanDeath5", DIE);
		static public const PREPARE_PISTOL:SoundArray		= new SoundArray("PreparePistol1,PreparePistol2");

		static public const PREPARE_AUTOMATE:SoundArray		= new SoundArray("PrepareAutomate1,PrepareAutomate2");
		static public const SHOT_AUTOMATE:SoundArray		= new SoundArray("ShotAutomate1,ShotAutomate2", SHOT);
		static public const DIE_MURDER:SoundArray		= new SoundArray("MurderDeath1,MurderDeath2,MurderDeath3", DIE);

		static private var _instance:SoundManager;
		static private var soundStorage:Array = new Array();
		static private var stopOther:Boolean = true;

		public function SoundManager():void
		{
			super();
			_instance = this;

			addSounds([SHOT, ATTACK, HIT, DIE, SYSTEM, BULLET, BLOCK]);
		}

		static public function turnVolume(value:Boolean):void
		{
			return _instance.turnVolume(value);
		}

		static public function stop(channel:SoundChannel):void
		{
			return _instance.stop(channel);
		}

		static public function stopAll():void
		{
			return _instance.stopAll();
		}

		static public function pauseSounds():void
		{
			return _instance.pauseSounds();
		}

		static public function resumeSounds():void
		{
			return _instance.resumeSounds();
		}

		static public function getChannel(name:String):SoundChannel
		{
			return _instance.channels[name];
		}

		static public function play(name:String, block:Boolean = false, time:Number = 0):SoundChannel
		{
			return _instance.play(name, block, time);
		}

		static public function load(name:String, playAfterload:Boolean = true, onComplete:Function = null):void
		{
			_instance.loadSound(name, playAfterload, onComplete);
		}

		static public function playSounds(name:SoundArray):SoundChannel
		{
			var sound:String = name.value;
			if (sound == "")
				return null;
			return _instance.play(sound);
		}

		static public function addSounds(names:*):void
		{
			if (names == null)
				return;
			names = names is Array ? names : [names];
			for each (var name:SoundArray in names)
				addSound(name);
		}

		static public function addSound(name:SoundArray):void
		{
			if (name == null)
				return;
			if (soundStorage.indexOf(name) != -1)
				return;
			soundStorage.push(name);
		}

		static public function loadSounds(e:Event = null):void
		{
			if (e == null)
				SoundManager.stopOther = true;

			for each (var sound:SoundArray in soundStorage)
				if (!sound.loaded)
				{
					_instance.loadSound((sound as SoundArray).loadValue, false, SoundManager.loadSounds);
					return;
				}

			ScreenGame.stage.dispatchEvent(new GameLoadEvent(GameLoadEvent.SOUNDS_LOAD, 100));
		}

		static public function loadOther(e:Event = null):void
		{
			if (e == null)
				SoundManager.stopOther = false;
			if (SoundManager.stopOther)
				return;

			for each (var sound:SoundArray in soundStorage)
				if (!sound.allLoaded)
				{
					_instance.loadSound((sound as SoundArray).loadValue, false, SoundManager.loadOther);
					return;
				}
		}
	}
}