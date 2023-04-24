package sounds
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	import interfaces.IPlay;

	public class SoundsBase implements IPlay
	{
		protected var soundObject:Object = {};
		protected var channels:Dictionary = new Dictionary();
		protected var loadQueue:Dictionary = new Dictionary();
		protected var currentPlay:Dictionary = new Dictionary();

		public static var config:XML = null;

		public var _on:Boolean = true;

		public function play(name:String, block:Boolean = false):SoundChannel
		{
			if (!this._on)
				return null;

			if (!(name in this.soundObject))
			{
				loadSound(name);
				return null;
			}

			if (this.soundObject[name] == null)
				return null;

			try
			{
				if (block)
				{
					for each (var channel:SoundChannel in this.channels)
						stop(channel);
				}

				if (SoundMixer.soundTransform.volume != 1)
					SoundMixer.soundTransform = new SoundTransform(1, 0);

				channel = this.soundObject[name].play();
				this.currentPlay[channel] = name;

				this.channels[channel] = channel;

				if (config != null && config.hasOwnProperty(name))
				{
					var transform:SoundTransform = channel.soundTransform;
					transform.volume = Number(config[name].@['volume']);
					channel.soundTransform = transform;
				}
				channel.addEventListener(Event.SOUND_COMPLETE, completeSound, false, 0, true);

				this.channels[channel] = channel;

				return this.channels[channel];
			}
			catch (error:Error)
			{
				Logger.add("Failed to play sound: " + error);
			}

			return null;
		}

		public function isPlaying(name:String):Boolean
		{
			for each(var channel:String in this.currentPlay)
				if (channel == name) return true;
			return false;
		}

		protected function stop(channel:SoundChannel):void
		{
			if (channel == null)
				return;

			channel.stop();

			if (channel in this.channels)
			{
				delete this.currentPlay[channel];
				delete this.channels[channel];
			}
		}

		protected function stopAll():void
		{
			for each (var channel:SoundChannel in this.channels)
				stop(channel);
		}

		protected function completeSound(e:Event):void
		{
			var channel:SoundChannel = e.target as SoundChannel;
			delete this.channels[channel];
			delete this.currentPlay[channel];
		}

		protected function loadSound(name:String, playAfterload:Boolean = true):void
		{
			try
			{
				if (name == "")
					throw new Error("Load empty .mp3");
			}
			catch (e:Error)
			{
				Logger.add(e.getStackTrace());
			}

			if (name in this.loadQueue)
				return;

			this.loadQueue[name] = playAfterload;

			var sound:Sound = new Sound();

			sound.addEventListener(Event.COMPLETE, onLoadSuccess);
			sound.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			sound.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);

			var url:String = Config.SOUNDS_URL + name + ".mp3";
			if(config != null && config.hasOwnProperty(name))
				url += "?v=" + config[name].@['version'].toString();

			Logger.add("Loading sound:" + url);
			sound.load(new URLRequest(url));
		}

		public function preload(value:Array):void
		{
			for each(var name:String in value)
				if (!(name in this.soundObject)) loadSound(name, false);
		}

		private function onLoadSuccess(e:Event):void
		{
			var sound:Sound = e.target as Sound;
			var name:String = (sound.url.split('?')[0]).replace(Config.SOUNDS_URL, "").replace(".mp3", "");

			Logger.add("Sound " + name + " loaded");

			this.soundObject[name] = sound;

			if (this.loadQueue[name])
				play(name);

			delete this.loadQueue[name];
		}

		private function onLoadError(e:Event):void
		{
			Logger.add("Failed to load sound: " + e);

			var sound:Sound = e.target as Sound;
			var name:String = sound && sound.url ?
				(sound.url.split('?')[0]).replace(Config.SOUNDS_URL, "").replace(".mp3", "") : "";

			this.soundObject[name] = null;
		}
	}
}