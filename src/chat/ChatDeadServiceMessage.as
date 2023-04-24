package chat
{
	import events.ChatEvent;
	import screens.ScreenGame;

	import com.api.Player;

	public class ChatDeadServiceMessage extends ChatDeadMessage
	{
		private var redraw:Boolean = false;
		private var type:int;
		private var amount:int;

		static public const BLOCK:int = 2;
		static public const SNAPSHOT:int = 3;
		static public const SHAMAN:int = 4;
		static public const FROZEN:int = 5;
		static public const SALUT:int = 6;
		static public const JINGLE_BELLS:int = 7;
		static public const CANDY_SNOW:int = 8;
		static public const BEER_SNOW:int = 9;
		static public const FLOWER_SNOW:int = 10;
		static public const SEA_SNOW:int = 11;
		static public const SEEDS_FROZEN:int = 12;
		static public const MY_FRIENDS:int = 13;
		static public const PLAYING_FRIENDS:int = 14;
		static public const FRIEND_JOIN_WAITING:int = 15;
		static public const FRAG:int = 16;
		static public const KILLER:int = 17;
		static public const REPORT:int = 18;
		static public const KICKED:int = 19;
		static public const NOT_HAVE_CERTIFICATE:int = 20;
		static public const SHAMAN_COMPENSATION:int = 21;
		static public const COLLECTION_ELEMENT:int = 22;
		static public const DRAGON_COMPENSATION:int = 23;
		static public const DIAMONDS_SNOW:int = 26;
		static public const STEAL_NUTS_SUCCESS:int = 27;
		static public const STEAL_NUTS_FAIL:int = 28;
		static public const WOMEN_DAY:int = 29;
		static public const MEDICINE_CHEST:int = 30;
		static public const HIPSTERS_COCKTAIL:int = 31;
		static public const ASSIST:int = 32;
		static public const LEPRECHAUN_GOLD_SACK:int = 33;
		static public const VAMPIRE_PERK:int = 34;
		static public const NO_RATING:int = 35;
		static public const NO_CERTIFICATE:int = 36;
		static public const FREEZE_PERK:int = 40;
		static public const FREEZE_ERROR_PERK:int = 41;
		static public const THIN_ICE_PERK:int = 42;
		static public const ICE_CUBE_PERK:int = 43;
		static public const FRIEND_PERK:int = 44;
		static public const TELEPORT_PERK:int = 45;
		static public const SQUIRREL_HAPPINESS_PERK:int = 46;
		static public const FAVORITE_PERK:int = 47;
		static public const HELPER_PERK:int = 48;
		static public const JOKER_SURPRISE_BOX:int = 49;
		static public const VENDIGO_PERK:int = 50;
		static public const ZOMBIE_MODE:int = 51;

		public function ChatDeadServiceMessage(player:Player, text:String, type:int, amount:int = 0):void
		{
			this.type = type;
			this.amount = amount;
			super(player, text, false, false);
		}

		override public function get isNull():Boolean
		{
			switch (this.type)
			{
				case SHAMAN:
				case MY_FRIENDS:
				case PLAYING_FRIENDS:
				case FRIEND_JOIN_WAITING:
					return false;
				default:
					if (this.player.id == Game.selfId || Game.self['moderator'])
						return false;
			}
			return true;
		}

		override protected function draw(changeMessage:Boolean = true):void
		{
			if (!this.redraw)
			{
				this.text = serviceMessage(this.player, this.text, this.type, this.amount);
				this.redraw = true;
			}

			super.draw(changeMessage);
		}

		override protected function onPlayerLoaded(player:Player):void
		{
			if (!Game.self['moderator'] && player['moderator'] && (this.type == MY_FRIENDS || this.type == FRIEND_JOIN_WAITING || this.type == PLAYING_FRIENDS))
			{
				if (hasEventListener(ChatEvent.REMOVE))
					dispatchEvent(new ChatEvent(this));
				player.removeEventListener(onPlayerLoaded);
				return;
			}

			super.onPlayerLoaded(player);
		}

		override protected function styleMessage(text:String):String
		{
			return "<body><span class='service_message'>" + text + "</span></body>";
		}

		private function serviceMessage(player:Player, text:String, type:int, amount:int):String
		{
			Logger.add('ChatDeadServiceMessage/serviceMessage: ' + type);
			if (!Game.selfId || !player.id || !this.player.name)
			{
				Logger.add('ERROR: ', Game.selfId, player.id, this.player.name);
				return '';
			}

			switch(type)
			{
				case BLOCK:
					return (text);
				case SNAPSHOT:
					return gls("Фотография сохранена в альбом.");
				case FROZEN:
					if (player.id == Game.selfId)
						return gls("Ты вызвал глобальное оледенение.");
					else
						return gls("Игрок {0} вызвал глобальное оледенение.", styleNameLink());
				case SEEDS_FROZEN:
					if (player.id == Game.selfId)
						return gls("Ты превратил всех белок в семечки.");
					else
						return gls("Игрок {0} превратил всех белок в семечки.", styleNameLink());
				case SALUT:
					if (player.id == Game.selfId)
						return gls("Ты запустил праздничный феерверк.");
					else
						return gls("Игрок {0} запустил праздничный феерверк.", styleNameLink());
				case JINGLE_BELLS:
					if (player.id == Game.selfId)
						return gls("Ты включил песню Jingle Bells.");
					else
						return gls("Игрок {0} включил песню Jingle Bells.", styleNameLink());
				case CANDY_SNOW:
					if (player.id == Game.selfId)
						return gls("Ты вызвал новогодний снегопад.");
					else
						return gls("Игрок {0} вызвал новогодний снегопад.", styleNameLink());
				case BEER_SNOW:
					if (player.id == Game.selfId)
						return gls("Ты вызвал пацанский снегопад.");
					else
						return gls("Игрок {0} вызвал пацанский снегопад.", styleNameLink());
				case FLOWER_SNOW:
					if (player.id == Game.selfId)
						return gls("Ты вызвал цветочный дождь.");
					else
						return gls("Игрок {0} вызвал цветочный дождь.", styleNameLink());
				case SEA_SNOW:
					if (player.id == Game.selfId)
						return gls("Ты вызвал морской дождь.");
					else
						return gls("Игрок {0} вызвал морской дождь.", styleNameLink());
				case MY_FRIENDS:
					return gls("Твой друг {0} присоединился к игре.", styleNameLink());
				case SHAMAN:
					if (player.id == Game.selfId)
						return gls("Ты стал шаманом");
					else
						return gls("Игрок {0} стал шаманом.", styleNameLink());
				case PLAYING_FRIENDS:
					return gls("Твой друг {0} в данный момент в игре.", styleNameLink());
				case FRIEND_JOIN_WAITING:
					return gls("Твой друг {0} присоединится к игре.", styleNameLink());
				case FRAG:
					return gls("Ты убил игрока {0}.", styleNameLink());
				case KILLER:
					return gls("Тебя убил игрок {0}.", styleNameLink());
				case ASSIST:
					return gls("Ты помог в убийстве игрока {0}.", styleNameLink());
				case REPORT:
					if (player.id == Game.selfId)
						return gls("На тебя поступила жалоба (не идешь в дупло).");
					else
						return gls("На игрока {0} поступила жалоба (не идет в дупло).", styleNameLink());
				case KICKED:
					if (player.id == Game.selfId)
						return gls("Пять игроков подали жалобу, что ты всех задерживаешь, и выгнали тебя из команды.");
					else
						return gls("Игрок {0} выгнан из игры.", styleNameLink());
				case NOT_HAVE_CERTIFICATE:
					if (player.id == Game.selfId)
						return gls("Ты пришёл первым, но не сможешь стать шаманом, потому что не получил Аттестат в Школе.");
					break;
				case SHAMAN_COMPENSATION:
					if (player.id == Game.selfId)
						return gls("Место шамана у тебя перекупили и ты получаешь {0} орешков в качестве компенсации.", amount);
					break;
				case COLLECTION_ELEMENT:
					if (player.id == Game.selfId)
					{
						if (!Hero.self)
							return "";

						if (Hero.self.shaman)
							return gls("Ты получил элемент коллекции «{0}».", text);

						var message:String = gls("Ты подобрал элемент коллекции «{0}».", text);
						if (Locations.MODES[ScreenGame.mode] != null && Hero.self.isHare || ScreenGame.mode == Locations.BLACK_SHAMAN_MODE)
							message += gls(" Теперь доживи до конца раунда.");
						else if (ScreenGame.location == Locations.BATTLE_ID || ScreenGame.mode == Locations.SNOWMAN_MODE)
							message += gls(" Теперь дождись конца раунда.");
						else
							message += gls(" Теперь дойди до дупла.");
						return message;
					}
					else if (ScreenGame.squirrelShaman(player.id))
						return gls("Игрок {0} получил элемент коллекции «{1}».", styleNameLink(), text);
					else
						return gls("Игрок {0} подобрал элемент коллекции «{1}».", styleNameLink(), text);
				case DRAGON_COMPENSATION:
					if (player.id == Game.selfId)
						return gls("Ты не можешь стать драконом, так как ты стал шаманом. Потраченная сумма возвращена.");
					break;
				case DIAMONDS_SNOW:
					if (player.id == Game.selfId)
						return gls("Ты вызвал дождь из драгоценных камней.");
					else
						return gls("Игрок {0} вызвал дождь из драгоценных камней.", styleNameLink());
				case STEAL_NUTS_SUCCESS:
					if (player.id == Game.selfId)
						return gls("Ты отобрал орех у другой белки.");
					else
						return gls("Игрок {0} отобрал орех у другой белки.",  styleNameLink());
				case STEAL_NUTS_FAIL:
					if (player.id == Game.selfId)
						return gls("У тебя не получилось отобрать орех.");
					else
						return gls("Игроку {0} не удалось отобрать орех.", styleNameLink());
				case WOMEN_DAY:
					if (!Game.self['moderator'])
						return (text);
					break;
				case MEDICINE_CHEST:
					if (player.id == Game.selfId)
						return gls("Ты поднял аптечку.");
					else
						return gls("Игрок {0} поднял аптечку.", styleNameLink());
				case HIPSTERS_COCKTAIL:
					if (player.id == Game.selfId)
						return gls("Ты выпил коктейль.");
					else
						return gls("Игрок {0} выпил коктейль.", styleNameLink());
				case LEPRECHAUN_GOLD_SACK:
					if (player.id == Game.selfId)
						return gls("Ты поднял мешок с золотом и {0}.", text);
					else
						return gls("Игрок {0} поднял мешок с золотом и {1}.", styleNameLink(), text);
				case VAMPIRE_PERK:
					return gls("Не удалось использовать магию, нет свободного предмета коллекции.");
				case NO_RATING:
					if (player.id == Game.selfId)
						return gls("Тебе не хватило чуть-чуть мастерства, чтобы стать Шаманом.");
					break;
				case NO_CERTIFICATE:
					if (player.id == Game.selfId)
						return gls("Ты не можешь стать шаманом, пока не пройдёшь Школу Шаманов.");
					break;
				case FREEZE_PERK:
					if (player.id == Game.selfId)
						return gls("Ты использовал Заморозку. Только обладатели этой магии могут взять предмет.");
					else
						return gls("Игрок {0} использовал Заморозку. Только обладатели этой магии могут взять предмет.", styleNameLink());
				case FREEZE_ERROR_PERK:
					return gls("Не удалось использовать магию, нет свободного предмета коллекции, который ты можешь поднять.");
				case THIN_ICE_PERK:
					if (player.id == Game.selfId)
						return gls("Шаман применил к тебе магию «Тонкий лёд».");
					else
						return gls("Шаман применил к игроку {0} магию «Тонкий лёд».", styleNameLink());
				case ICE_CUBE_PERK:
					if (player.id == Game.selfId)
						return gls("Шаман применил к тебе магию «Ледяной куб».");
					else
						return gls("Шаман применил к игроку {0} магию «Ледяной куб».", styleNameLink());
				case FRIEND_PERK:
					if (player.id == Game.selfId)
						return gls("Шаман применил к тебе магию «Друг шамана».");
					else
						return gls("Шаман применил к игроку {0} магию «Друг шамана».", styleNameLink());
				case TELEPORT_PERK:
					if (player.id == Game.selfId)
						return gls("Шаман применил к тебе магию «Телепорт».");
					else
						return gls("Шаман применил к игроку {0} магию «Телепорт».", styleNameLink());
				case SQUIRREL_HAPPINESS_PERK:
					if (player.id == Game.selfId)
						return gls("Шаман применил к тебе магию «Беличье счастье».");
					else
						return gls("Шаман применил к игроку {0} магию «Беличье счастье».", styleNameLink());
				case FAVORITE_PERK:
					if (player.id == Game.selfId)
						return gls("Шаман применил к тебе магию «Любимчик».");
					else
						return gls("Шаман применил к игроку {0} магию «Любимчик».", styleNameLink());
				case HELPER_PERK:
					if (player.id == Game.selfId)
						return gls("Шаман применил к тебе магию «Помощник».");
					else
						return gls("Шаман применил к игроку {0} магию «Помощник».", styleNameLink());
				case JOKER_SURPRISE_BOX:
					if (player.id == Game.selfId)
						return gls("Ты открыл шкатулку с секретом и {0}.", text);
					else
						return gls("Игрок {0} открыл шкатулку с секретом и {1}.", styleNameLink(), text);
				case VENDIGO_PERK:
					return text;
				case ZOMBIE_MODE:
					return text;
			}
			return "";
		}
	}
}