package loaders
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.utils.ByteArray;

	import dragonBones.Slot;
	import dragonBones.display.NativeDisplayBridge;
	import dragonBones.display.StarlingDisplayBridge;
	import dragonBones.factorys.BaseFactory;
	import dragonBones.factorys.NativeFactory;
	import dragonBones.factorys.StarlingFactory;

	public class HeroLoader extends LibLoader
	{
		static public const SQUIRREL:String = "Squirrel";
		static public const SCRAT:String = "Scrat";
		static public const SCRATTY:String = "Scratty";
		static public const DRAGON:String = "Dragon";
		static public const HARE:String = "Hare";
		static public const SNOW_LEOPARD:String = "SnowLeopard";

		static private var _starlingFactory:StarlingFactory;
		static private var _nativeFactory:NativeFactory;

		static private var _data:ByteArray = null;

		static public function getFactory(forStarling:Boolean = true):BaseFactory
		{
			return forStarling ? starlingFactory : nativeFactory;
		}

		static public function buildSlot(forStarling:Boolean = true):Slot
		{
			return new Slot(forStarling ? new StarlingDisplayBridge() : new NativeDisplayBridge());
		}

		static private function get starlingFactory():StarlingFactory
		{
			if (_starlingFactory)
				return _starlingFactory;

			_starlingFactory = new StarlingFactory();
			_starlingFactory.scaleForTexture = 2;
			_starlingFactory.optimizeForRenderToTexture = true;

			return _starlingFactory;
		}

		static private function get nativeFactory():NativeFactory
		{
			if (!_nativeFactory)
				_nativeFactory = new NativeFactory();

			return _nativeFactory;
		}

		override public function loadBytes(dataClass:Class):void
		{
			_data = new dataClass();
			onComplete(null);
		}

		override protected function onLoaded(e:Event):void
		{
			_data = (e.currentTarget as URLLoader).data;
			onComplete(e);
		}

		static public function parseDataHero():void
		{
			if (!_data)
				return;

			starlingFactory.parseData(_data);
			nativeFactory.parseData(_data);
		}
	}
}