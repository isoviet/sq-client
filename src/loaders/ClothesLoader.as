package loaders
{
	import flash.events.Event;
	import flash.utils.Dictionary;

	import dragonBones.factorys.BaseFactory;
	import dragonBones.factorys.NativeFactory;
	import dragonBones.factorys.StarlingFactory;

	public class ClothesLoader extends LibLoader
	{
		static private var starlingFactoryData:Dictionary = new Dictionary();
		static private var nativeFactoryData:Dictionary = new Dictionary();

		private var loadedCount:int = 0;
		private var len:uint = 0;

		static public function getFactory(clothesId:int, forStarling:Boolean = true):BaseFactory
		{
			return forStarling ? starlingFactoryData[ClothesAssets.getClassById(clothesId)] : nativeFactoryData[ClothesAssets.getClassById(clothesId)];
		}

		override protected function onComplete(e:Event):void
		{
			initFactoryData();
		}

		private function initFactoryData():void
		{
			var starlingFactory:StarlingFactory;
			var nativeFactory:NativeFactory;

			var data:Array = ClothesAssets.DATA;
			this.len = data.length;

			for (var i:int = 0; i < this.len; i++)
			{
				starlingFactory = new StarlingFactory();
				nativeFactory = new NativeFactory();

				starlingFactory.scaleForTexture = 2;
				starlingFactory.optimizeForRenderToTexture = true;
				starlingFactory.addEventListener(Event.COMPLETE, onParseComplete);
				starlingFactory.parseData(new data[i]);

				nativeFactory.addEventListener(Event.COMPLETE, onParseComplete);
				nativeFactory.parseData(new data[i]);

				starlingFactoryData[data[i]] = starlingFactory;
				nativeFactoryData[data[i]] = nativeFactory;
			}
		}

		private function onParseComplete(e:Event):void
		{
			if (++this.loadedCount == this.len * 2)
				super.onComplete(e);
		}
	}
}