package
{
	import flash.utils.getQualifiedClassName;

	import game.mainGame.entity.EntityFactory;
	import game.mainGame.entity.battle.BouncingPoise;
	import game.mainGame.entity.battle.GhostPoise;
	import game.mainGame.entity.battle.GravityPoise;
	import game.mainGame.entity.battle.GrenadePoise;
	import game.mainGame.entity.battle.SpikePoise;
	import game.mainGame.entity.cast.BodyDestructor;
	import game.mainGame.entity.cast.Hammer;
	import game.mainGame.entity.iceland.IceBlock;
	import game.mainGame.entity.magic.HarpoonBodyBat;
	import game.mainGame.entity.magic.HarpoonBodyCat;
	import game.mainGame.entity.magic.Muffin;
	import game.mainGame.entity.magic.ShadowBomb;
	import game.mainGame.entity.magic.SheepBomb;
	import game.mainGame.entity.magic.SmokeBomb;
	import game.mainGame.entity.magic.StickyBomb;
	import game.mainGame.entity.simple.BalanceWheel;
	import game.mainGame.entity.simple.Balk;
	import game.mainGame.entity.simple.BalkIce;
	import game.mainGame.entity.simple.BalkIceLong;
	import game.mainGame.entity.simple.BalkLong;
	import game.mainGame.entity.simple.BalloonBody;
	import game.mainGame.entity.simple.Box;
	import game.mainGame.entity.simple.BoxBig;
	import game.mainGame.entity.simple.BoxIce;
	import game.mainGame.entity.simple.BoxIceBig;
	import game.mainGame.entity.simple.BurstBody;
	import game.mainGame.entity.simple.Poise;
	import game.mainGame.entity.simple.PoiseRight;
	import game.mainGame.entity.simple.PortalBlue;
	import game.mainGame.entity.simple.PortalBlueDirected;
	import game.mainGame.entity.simple.PortalRed;
	import game.mainGame.entity.simple.PortalRedDirected;
	import game.mainGame.entity.simple.Trampoline;
	import game.mainGame.entity.simple.WeightBody;

	public class CastItemsData
	{
		static private const DATA:Array = [
		/*0*/	{'class': Balk,			'text': gls("С помощью палок ты сможешь построить всё что угодно!\nПерсональный предмет - никто кроме тебя не может его касаться."), 'preview':'Balk'},
		/*1*/	{'class': BalkLong,		'hide': 1},
		/*2*/	{'class': Box,			'text': gls("Ящик послужит тебе ступенькой, также ты сможешь нажать им на кнопку.\nПерсональный предмет - никто кроме тебя не может его касаться."), 'preview':'Box'},
		/*3*/	{'class': BoxBig,		'hide': 1},
		/*4*/	{'class': BalkIce,		'hide': 1},
		/*5*/	{'class': BalkIceLong,		'hide': 1},
		/*6*/	{'class': BoxIce,		'hide': 1},
		/*7*/	{'class': BoxIceBig,		'hide': 1},
		/*8*/	{'class': WeightBody,		'hide': 1},
		/*9*/	{'class': Trampoline,		'text': gls("С его помощью ты сможешь подпрыгнуть намного выше обычного, почти взлететь!\nПерсональный предмет - никто кроме тебя не может его касаться."), 'preview':'Trampoline'},
		/*10*/	{'class': Poise,		'hide': 1},
		/*11*/	{'class': PoiseRight,		'text': gls("Ядром ты можешь толкать других белок, нажимать труднодоступные кнопки и высоко подкидывать самого себя!"), 'preview':'PoiseRight'},
		/*12*/	{'class': PortalBlue,		'hide': 1},
		/*13*/	{'class': PortalRed,		'hide': 1},
		/*14*/	{'class': PortalBlueDirected,	'hide': 1},
		/*15*/	{'class': PortalRedDirected,	'hide': 1},
		/*16*/	{'class': BodyDestructor,	'text': gls("Поможет тебе убрать с карты установленный тобой предмет. Шаман может удалять любые предметы."), 'preview':'BodyDestructor'},
		/*17*/	{'class': SpikePoise,		'hide': 1,	'ammo': true},
		/*18*/	{'class': BalloonBody,		'text': gls("На шарике ты сможешь отправиться куда угодно! Перелететь с одного места на другое теперь проще простого!"), 'preview':'BalloonBody'},
		/*19*/	{'class': BouncingPoise,	'hide': 1,	'ammo': true},
		/*20*/	{'class': GhostPoise,		'hide': 1,	'ammo': true},
		/*21*/	{'class': GravityPoise,		'hide': 1,	'ammo': true},
		/*22*/	{'class': GrenadePoise,		'hide': 1,	'ammo': true},
		/*23*/	{'class': BurstBody,		'hide': 1},
		/*24*/	{'class': HarpoonBodyBat,	'hide': 1},
		/*25*/	{'class': HarpoonBodyCat,	'hide': 1},
		/*26*/	null, // DELETED
		/*27*/	{'class': Hammer,		'hide': 1},
		/*28*/	{'class': BalanceWheel,		'hide': 1},
		/*29*/	{'class': IceBlock,		'hide': 1},
		/*30*/	{'class': StickyBomb,		'hide': 1},
		/*31*/	{'class': SmokeBomb,		'hide': 1},
		/*32*/	{'class': Muffin,		'hide': 1},
		/*33*/	{'class': SheepBomb,		'hide': 1},
		/*34*/	{'class': ShadowBomb,		'hide': 1}
		];

		static private var _items:Array = null;

		static public function get itemsCount():int
		{
			return DATA.length;
		}

		static public function get items():Array
		{
			if (!_items)
			{
				_items = [];
				for (var i:int = 0; i < itemsCount; i++)
				{
					if (DATA[i] == null || !('text' in DATA[i]))
						continue;
					_items.push(i);
				}
			}
			return _items;
		}

		static public function isAmmo(id:int):Boolean
		{
			return id in DATA && DATA[id] && ('ammo' in DATA[id]);
		}

		static public function getPreviewFileName(id:int):String
		{
			return DATA[id]['preview'];
		}

		static public function getClass(id:int):Class
		{
			var item:Object = getItem(id);

			if (!item)
				return null;

			return item['class'];
		}

		static public function getImageClass(id:int):Class
		{
			var item:Object = getItem(id);
			var iconItem:Object = EntityFactory.getItemByClass(item['class']);

			return iconItem['icon'];
		}

		static public function getTitle(id:int):String
		{
			var item:Object = getItem(id);
			var iconItem:Object = EntityFactory.getItemByClass(item['class']);

			return iconItem['title'];
		}

		static public function getText(id:int):String
		{
			return getItem(id)['text'];
		}

		static public function getId(object:*):int
		{
			for (var id:int = 0; id < DATA.length; id++)
			{
				if (!DATA[id])
					continue;

				if ((object is Class) && (object == DATA[id]['class']))
					return id;

				if (getQualifiedClassName(object) == getQualifiedClassName(DATA[id]['class']))
					return id;
			}

			return -1;
		}

		static private function getItem(id:int):Object
		{
			return DATA[id];
		}
	}
}