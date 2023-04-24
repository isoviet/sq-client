package game.mainGame
{
	import flash.events.EventDispatcher;

	import game.mainGame.entity.battle.BouncingPoise;
	import game.mainGame.entity.battle.GhostPoise;
	import game.mainGame.entity.battle.GravityPoise;
	import game.mainGame.entity.battle.GrenadePoise;
	import game.mainGame.entity.battle.SpikePoise;
	import game.mainGame.events.CastItemEvent;

	public class CastItem extends EventDispatcher
	{
		static private const MAX_COUNTS:Array = [
			{'class': SpikePoise,		'count': 20},
			{'class': BouncingPoise,	'count': 10},
			{'class': GhostPoise,		'count': 5},
			{'class': GravityPoise,		'count': 5},
			{'class': GrenadePoise,		'count': 5}
		];

		static public const TYPE_SHAMAN:int = 0;
		static public const TYPE_SQUIRREL:int = 1;
		static public const TYPE_ROUND:int = 2;

		private var _count:int = int.MAX_VALUE;

		public var itemClass:Class = null;
		public var type:int = NaN;

		public function CastItem(castedClass:Class, castingType:int, count:int = int.MAX_VALUE):void
		{
			this.itemClass = castedClass;
			this.type = castingType;
			this._count = count;
		}

		static public function getMax(itemClass:Class):int
		{
			for (var i:int = 0; i < MAX_COUNTS.length; i++)
			{
				if (itemClass != MAX_COUNTS[i]['class'])
					continue;
				return MAX_COUNTS[i]['count'];
			}
			return int.MAX_VALUE;
		}

		public function get count():int
		{
			return _count;
		}

		public function set count(value:int):void
		{
			if (this._count == value)
				return;

			var isIShoot:Boolean = false;
			for (var i:int = 0; i < MAX_COUNTS.length; i++)
			{
				if (this.itemClass != MAX_COUNTS[i]['class'])
					continue;
				isIShoot = true;
				value = Math.min(MAX_COUNTS[i]['count'], value);
			}
			this._count = value;

			if (this._count <= 0 && !isIShoot)
			{
				dispatchEvent(new CastItemEvent(CastItemEvent.ITEM_END, this));
				return;
			}

			dispatchEvent(new CastItemEvent(CastItemEvent.ITEM_CHANGE, this));
		}
	}
}