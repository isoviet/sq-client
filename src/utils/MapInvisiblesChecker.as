package utils
{
	import flash.display.DisplayObject;

	import game.mainGame.entity.EntityFactory;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.gameEditor.MapData;

	import by.blooddy.crypto.serialization.JSON;

	public class MapInvisiblesChecker
	{
		static private const OBJECTS_TO_FIND:Array = ["Орехи", "Дупло", "Сенсор", "Кнопка", "Кнопка-сенсор", "Квадратный сенсор"];

		static public function findInvisible(mapData:MapData, callBack:Function):void
		{
			callBack.call(null, mapData.number, analyzeMap(mapData.map));
		}

		static public function checkInvisible(alpha:Number):Boolean
		{
			return alpha < 0.2 && alpha >= 0;
		}

		static private function analyzeMap(data:*):int
		{
			var input:Array;

			try
			{
				input = by.blooddy.crypto.serialization.JSON.decode(data);
			}
			catch (e:Error)
			{
				Logger.add("Failed to decode JSON map data: " + e, data);
				throw e;
			}

			var objects:Array = input[1];

			var alphaCount:int = 0;

			for each (var entity:* in objects)
			{
				if (entity == "" || EntityFactory.getEntity(entity[0]) == null)
					continue;

				var object:IGameObject = new (EntityFactory.getEntity(entity[0]) as Class)();

				if ((OBJECTS_TO_FIND.indexOf(EntityFactory.getName(object)) != -1) && (object is DisplayObject) && (entity.length == 3) && checkInvisible(entity[2][1]))
					alphaCount++;
			}

			return alphaCount;
		}
	}
}