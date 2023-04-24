package sounds
{
	import flash.events.Event;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;

	import events.LocationEvent;
	import widgets.GeneralSettings;
	// НЕПОДКЛЮЧЕНО

	public class MissionAmbient implements IDispose
	{
		static private var ambients:Array = new Array();
		static private var volume:int = 1;
		private var sound:SoundArray;
		private var channel:SoundChannel = null;
		private var onPlay:Boolean = false;

		public function MissionAmbient(sound:SoundArray):void
		{
			ambients.push(this);
			this.sound = sound;
			GameSession.addEventListener(LocationEvent.START_MISSION, onStart);
			GameSession.addEventListener(LocationEvent.COMPLETE_MISSION, onComplete);
		}

		static public function set switchVolume(value:Boolean):void
		{
			volume = (value && GeneralSettings.soundOn ? 1 : 0);
			for each (var ambient:MissionAmbient in ambients)
				if (ambient.channel != null)
					ambient.channel.soundTransform = new SoundTransform(volume);
		}

		public function dispose():void
		{
			ambients.splice(ambients.indexOf(this));
			GameSession.removeEventListener(LocationEvent.START_MISSION, onStart);
			GameSession.removeEventListener(LocationEvent.COMPLETE_MISSION, onComplete);
		}

		private function onStart(e:LocationEvent):void
		{
			this.onPlay = true;
			play();
		}

		private function play():void
		{
			this.channel = GameSounds.play(this.sound);
			this.channel.soundTransform = new SoundTransform(volume);
			this.channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		}

		private function onSoundComplete(e:Event):void
		{
			if (!this.onPlay)
				return;
			play();
		}

		private function onComplete(e:LocationEvent):void
		{
			dispose();
			this.onPlay = false;
			if (this.channel != null)
				this.channel.stop();
		}
	}
}