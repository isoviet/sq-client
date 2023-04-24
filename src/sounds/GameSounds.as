package sounds
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;

	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.cast.BodyDestructor;
	import game.mainGame.entity.simple.Poise;
	import game.mainGame.entity.simple.PoiseInvisible;
	import game.mainGame.entity.simple.PoiseInvisibleRight;
	import game.mainGame.entity.simple.PoiseRight;
	import game.mainGame.entity.simple.PortalBlue;
	import game.mainGame.entity.simple.PortalBlueDirected;
	import game.mainGame.entity.simple.PortalRed;
	import game.mainGame.entity.simple.PortalRedDirected;

	public class GameSounds extends SoundsBase
	{

		static private var _instance:GameSounds;

		private var unrepeatableSounds:Object = {};
		private var unrepeatableSoundsName:Object = {};
		private var repeatable:Object = {};

		public function GameSounds():void
		{
			_instance = this;
		}

		static public function handSoundControll(array:Array, sound:String = SoundConstants.BUTTON_CLICK):void
		{
			for each(var button:InteractiveObject in array)
			{
				button.addEventListener(MouseEvent.CLICK, function(e:Event):void
					{
						GameSounds.play(sound);
					});
			}
		}

		static public function get on():Boolean
		{
			return _instance._on;
		}

		static public function preload(value:Array):void
		{
			_instance.preload(value);
		}

		static public function set on(value:Boolean):void
		{
			_instance._on = value;
		}

		static public function play(name:String, block:Boolean = false):SoundChannel
		{
			return _instance.play(name, block);
		}

		static public function playRepeatable(name:String, timeRepeat:Number):void
		{
			if(_instance.repeatable[name] != null)
				return;

			play(name);

			var timer:Timer = new Timer(timeRepeat, 0);
			timer.addEventListener(TimerEvent.TIMER, playRepeat);
			timer.start();
			_instance.repeatable[name] = timer;
		}

		private static function playRepeat(event:TimerEvent):void
		{
			var timer:Timer = event.currentTarget as Timer;
			for (var name:String in _instance.repeatable)
			{
				if(_instance.repeatable[name] == timer)
				{
					play(name);
					return;
				}
			}
		}

		static public function stopRepeatable(name:String):void
		{
			if(_instance.repeatable[name] == null)
				return;

			var timer:Timer = _instance.repeatable[name] as Timer;
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, playRepeat);
			_instance.repeatable[name] = null;
			delete _instance.repeatable[name];
		}

		static public function playUnrepeatable(name:String, probability:Number = 1):SoundChannel
		{
			if (probability != 1)
			{
				if (probability < 0 || probability > 1)
					return null;

				if (Math.random() > probability)
					return null;
			}

			return _instance.playUnrepeatable(name);
		}

		static public function stop(channel:SoundChannel):void
		{
			_instance.stop(channel);
		}

		static public function stopAll():void
		{
			_instance.stopAll();
		}

		static public function playCasted(castObject:IGameObject):void
		{
			switch (getQualifiedClassName(castObject))
			{
				case getQualifiedClassName(PortalBlue):
				case getQualifiedClassName(PortalBlueDirected):
				case getQualifiedClassName(PortalRed):
				case getQualifiedClassName(PortalRedDirected):
					GameSounds.play("portal_put");
					break;
				case getQualifiedClassName(Poise):
				case getQualifiedClassName(PoiseRight):
				case getQualifiedClassName(PoiseInvisible):
				case getQualifiedClassName(PoiseInvisibleRight):
					GameSounds.play("bomba_fly");
					break;
				case getQualifiedClassName(BodyDestructor):
					GameSounds.play("ubiralka");
					break;
				default:
					GameSounds.play("poyavlenie_object");
					break;
			}
		}

		override protected function stop(channel:SoundChannel):void
		{
			if (channel == null)
				return;

			channel.stop();

			if (channel in this.channels)
				delete this.channels[channel];
			if (channel in this.unrepeatableSoundsName)
			{
				var name:String = this.unrepeatableSoundsName[channel];

				delete this.unrepeatableSoundsName[channel];
				delete this.unrepeatableSounds[name];
			}
		}

		private function playUnrepeatable(name:String):SoundChannel
		{
			Logger.add("sounds.GameSounds.playUnrepeatable");
			if (!this._on)
				return null;

			if (!(name in this.soundObject))
			{
				loadSound(name);
				return null;
			}

			try
			{
				if ((name in this.unrepeatableSounds) && (this.unrepeatableSounds[name] in this.unrepeatableSoundsName))
					return this.unrepeatableSounds[name];

				var channel:SoundChannel = this.soundObject[name].play();

				if (config != null && config.hasOwnProperty(name))
				{
					var transform:SoundTransform = channel.soundTransform;
					transform.volume = Number(config[name].@['volume']);
					channel.soundTransform = transform;
				}

				channel.addEventListener(Event.SOUND_COMPLETE, completeUnrepeatableSound, false, 0, true);

				this.unrepeatableSounds[name] = channel;
				this.unrepeatableSoundsName[channel] = name;

				return this.unrepeatableSounds[name];
			}
			catch (error:Error)
			{
				Logger.add("Failed to play sound: " + error);
			}

			return null;
		}

		private function completeUnrepeatableSound(e:Event):void
		{
			var channel:SoundChannel = e.target as SoundChannel;
			var name:String = this.unrepeatableSoundsName[channel];

			delete this.unrepeatableSoundsName[channel];
			delete this.unrepeatableSounds[name];
		}
	}
}