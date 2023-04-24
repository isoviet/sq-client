package sounds
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Timer;

	import events.ScreenEvent;
	import screens.Screen;
	import screens.ScreenDisconnected;
	import screens.ScreenGame;
	import screens.ScreenSchool;
	import screens.Screens;
	import sounds.SoundsBase;

	public class GameMusic extends SoundsBase
	{
		static private const PRIVILEGED:Array = [
			"jingle_bells", "catwomen1", "catwomen2"
		];

		static public const GAME_SOUNDS:Array = [
			"theme_ingame", "theme_ingame_2", "theme_ingame_3", "theme_ingame_4", "theme_ingame_5"
		];

		static private const VOL_BORDER:Number = 0.5;
		static private const VOL_FADE_SPEED:Number = 0.01;

		static private var _instance:GameMusic;

		private var oldScreen:Screen;

		private var currentChannel:SoundChannel = null;
		private var offChannel:SoundChannel = null;

		private var offSoundTransform:SoundTransform = new SoundTransform();

		private var offVolume:Number = 0;

		private var timerVolFader:Timer = new Timer(10);

		private var currentMusic:String = "";

		public function GameMusic():void
		{
			_instance = this;
		}

		static public function get on():Boolean
		{
			return _instance._on;
		}

		static public function set on(value:Boolean):void
		{
			if (_instance._on == value)
				return;

			_instance._on = value;

			if (value)
				_instance.playNext();
			else
				_instance.stopMusic();
		}

		static public function addListener():void
		{
			Screens.instance.addEventListener(ScreenEvent.SHOW, _instance.onScreenChanged);
		}

		static public function playOn(name:String, priveleged:Boolean = false):SoundChannel
		{
			_instance._on = true;

			return _instance.play(name, priveleged);
		}

		static public function play(name:String, priveleged:Boolean = false):SoundChannel
		{
			return _instance.play(name, priveleged);
		}

		static public function playNext():void
		{
			_instance.playNext();
		}

		static public function get current():String
		{
			return _instance.currentMusic;
		}

		override public function play(name:String, priveleged:Boolean = false):SoundChannel
		{
			Logger.add("sounds.GameMusic.play");
			if ((!this._on && !priveleged))
				return null;

			if (!(name in this.soundObject))
			{
				loadSound(name);
				return null;
			}

			try
			{
				if (inPriveleged(name) && (this.currentMusic == name))
					return this.currentChannel;

				this.currentMusic = name;

				var soundVolume:SoundTransform = new SoundTransform();
				soundVolume.volume = VOL_BORDER;

				var channel:SoundChannel = this.soundObject[name].play();
				channel.soundTransform = soundVolume;
				channel.addEventListener(Event.SOUND_COMPLETE, completeSound, false, 0, true);

				this.channels[channel] = channel;

				this.offVolume = VOL_BORDER;

				if (this.offChannel != null)
					this.stop(this.offChannel);

				this.offChannel = this.currentChannel;
				this.currentChannel = channel;
				this.currentChannel.addEventListener(Event.SOUND_COMPLETE, playNext, false, 0, true);

				if (!this.timerVolFader.running)
				{
					this.timerVolFader.addEventListener(TimerEvent.TIMER, onTimerVolume, false, 0, true);
					this.timerVolFader.reset();
					this.timerVolFader.start();
				}

				return this.channels[channel];
			}
			catch (error:Error)
			{
				Logger.add("Failed to play sound: " + error);
			}

			return null;
		}

		private function inPriveleged(music:String):Boolean
		{
			for (var i:int = 0; i < PRIVILEGED.length; i++)
			{
				if (PRIVILEGED[i] == music)
					return true;
			}

			return false;
		}

		private function onScreenChanged(e:ScreenEvent):void
		{
			if (!this._on)
				return;

			if (e.screen is ScreenDisconnected)
			{
				on = false;
				return;
			}

			if (e.screen is ScreenGame || e.screen is ScreenSchool)
			{
				playRandomGameMusic();
				this.oldScreen = e.screen;
				return;
			}

			if ((this.oldScreen != null) && (this.currentChannel != null) && !(this.oldScreen is ScreenGame || this.oldScreen is ScreenSchool))
				return;

			this.oldScreen = e.screen;

			play("belki_game_islands_ambient");
		}

		private function playRandomGameMusic():void
		{
			var index:int = (Math.random() * (GameMusic.GAME_SOUNDS.length));

			Logger.add("play", GameMusic.GAME_SOUNDS[index]);

			play(GameMusic.GAME_SOUNDS[index]);
		}

		private function playNext(e:Event = null):void
		{
			if (Screens.active is ScreenGame || Screens.active is ScreenSchool)
			{
				playRandomGameMusic();
				return;
			}

			play("belki_game_islands_ambient");
		}

		private function stopMusic():void
		{
			for each (var channel:SoundChannel in this.channels)
				stop(channel);

			this.currentMusic = "";
		}

		private function onTimerVolume(event:TimerEvent):void
		{
			if (this.offChannel != null)
			{
				if (this.offVolume > 0)
					this.offVolume -= VOL_FADE_SPEED;
				else
					this.offVolume = 0;

				this.offSoundTransform.volume = this.offVolume;
				this.offChannel.soundTransform = this.offSoundTransform;
			}

			if (this.offVolume == 0)
			{
				if (this.offChannel != null)
				{
					this.stop(this.offChannel);
					this.offChannel = null;
				}

				this.timerVolFader.stop();
				this.timerVolFader.removeEventListener(TimerEvent.TIMER, onTimerVolume);
			}
		}
	}
}