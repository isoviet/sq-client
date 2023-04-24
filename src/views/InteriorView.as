package views
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import utils.FiltersUtil;

	public class InteriorView extends Sprite
	{
		static private const FURNITURE_DATA:Array = [
			{'z': 0,	'coordX': 0,	'coordY': 0},
			{'z': 1,	'coordX': 0,	'coordY': 479},
			{'z': 2,	'coordX': 682,	'coordY': 325},
			{'z': 3,	'coordX': 262,	'coordY': 241},
			{'z': 4,	'coordX': 249,	'coordY': 357},
			{'z': 5,	'coordX': 481,	'coordY': 188},
			{'z': 6,	'coordX': 838,	'coordY': 185},
			{'z': 7,	'coordX': 486,	'coordY': 536},
			{'z': 8,	'coordX': 66,	'coordY': 539},
			{'z': 9,	'coordX': 66,	'coordY': 456},
			{'z': 10,	'coordX': 168,	'coordY': 521},
			{'z': 11,	'coordX': 312,	'coordY': 400},
			{'z': 12,	'coordX': 321,	'coordY': 219}
		];

		private var currentInterior:Object = null;
		private var currentTypes:Array = null;

		private var onlyBack:Boolean;

		public function InteriorView(interiorIds:Array, onlyBack:Boolean = false):void
		{
			super();

			InteriorManager.loadSelf();

			this.onlyBack = onlyBack;

			this.currentInterior = {};

			var type:int;
			var item:DisplayObject;

			this.currentTypes = [];

			for (var i:int = 0; i < interiorIds.length; i++)
			{
				type = InteriorData.getType(interiorIds[i]);

				if (this.onlyBack && type != InteriorData.WALLPAPER && type != InteriorData.FLOOR)
					continue;

				item = new (InteriorData.getClass(interiorIds[i]))();
				item.x = FURNITURE_DATA[type]['coordX'];
				item.y = FURNITURE_DATA[type]['coordY'];

				if (this.currentTypes.indexOf(type) == -1)
					this.currentTypes.push(type);

				this.currentInterior[type] = ({'item': item, 'id': interiorIds[i]});
			}

			this.currentTypes.sort(sortByZ);

			for (i = 0; i < this.currentTypes.length; i++)
				addChildAt(this.currentInterior[this.currentTypes[i]]['item'], i);
		}

		public function load(newInteriorIds:Array):void
		{
			var type:int;
			var item:DisplayObject;

			if (InteriorManager.previewId != -1)
				newInteriorIds = newInteriorIds.concat(InteriorManager.previewId);

			var newTypes:Array = [];
			for (var i:int = 0; i < newInteriorIds.length; i++)
			{
				type = InteriorData.getType(newInteriorIds[i]);

				if (this.onlyBack && type != InteriorData.WALLPAPER && type != InteriorData.FLOOR)
					continue;

				if (newTypes.indexOf(type) == -1)
					newTypes.push(type);
			}

			for (i = 0; i < this.currentTypes.length; i++)
			{
				if (newTypes.indexOf(this.currentTypes[i]) != -1)
					continue;

				removeChild(this.currentInterior[this.currentTypes[i]]['item']);
				this.currentInterior[this.currentTypes[i]] = null;
			}

			this.currentTypes = newTypes;
			this.currentTypes.sort(sortByZ);

			for (i = 0; i < newInteriorIds.length; i++)
			{
				type = InteriorData.getType(newInteriorIds[i]);

				if (this.onlyBack && type != InteriorData.WALLPAPER && type != InteriorData.FLOOR)
					continue;

				if (this.currentInterior[type] && this.currentInterior[type]['id'] == newInteriorIds[i])
				{
					this.currentInterior[type]['item'].alpha = 1;
					this.currentInterior[type]['item'].filters = [];
					continue;
				}

				if (this.currentInterior[type] && this.currentInterior[type]['item'] && contains(this.currentInterior[type]['item']))
					removeChild(this.currentInterior[type]['item']);

				item = new (InteriorData.getClass(newInteriorIds[i]))();
				item.x = FURNITURE_DATA[type]['coordX'];
				item.y = FURNITURE_DATA[type]['coordY'];
				var isPreview:Boolean = (newInteriorIds[i] == InteriorManager.previewId && type != InteriorData.WALLPAPER && type != InteriorData.FLOOR);
				item.alpha = isPreview ? 0.35 : 1;
				item.filters = isPreview ? FiltersUtil.GLOW_FILTER : [];

				this.currentInterior[type] = ({'item': item, 'id': newInteriorIds[i]});
			}

			for (i = 0; i < this.currentTypes.length; i++)
				addChildAt(this.currentInterior[this.currentTypes[i]]['item'] , i);
		}

		private function sortByZ(a:int, b:int):int
		{
			return (FURNITURE_DATA[a]['z'] > FURNITURE_DATA[b]['z'] ? 1 : -1);
		}
	}
}