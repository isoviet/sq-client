package sounds
{
	public class SoundArray
	{
		private var soundArray:Array;
		private var loadedArray:Array = new Array();
		private var base:SoundArray;
		private var needAll:Boolean;

		public function SoundArray(sound:String, base:SoundArray = null, needAll:Boolean = false):void
		{
			this.soundArray = sound.split(",");
			this.base = base;
			this.needAll = needAll;
		}

		public function get loaded():Boolean
		{
			if (this.base != null)
				return this.base.loaded;
			return (this.needAll ? this.allLoaded : (this.loadedArray.length != 0));
		}

		public function get allLoaded():Boolean
		{
			return (this.soundArray.length == 0);
		}

		public function get loadValue():String
		{
			if (this.soundArray.length == 0)
				return "";
			var name:String = this.soundArray.shift();
			this.loadedArray.push(name);
			return name;
		}

		public function get value():String
		{
			if (!this.loaded)
				return "";
			if (this.loadedArray.length == 0)
				return base.value;
			return (this.loadedArray[int(Math.random()*this.loadedArray.length)]);
		}
	}
}