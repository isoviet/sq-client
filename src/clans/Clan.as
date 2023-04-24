package clans
{
	import flash.display.Bitmap;
	import flash.utils.Dictionary;

	import views.BlackListView;

	import protocol.Connection;
	import protocol.PacketClient;

	import utils.ImageUtil;
	import utils.StringUtil;

	public class Clan
	{
		static private const CACHE_EXPIRE_TIME:int = 5 * 60 * 1000;

		static public const DUTY_NONE:int = 0;
		static public const DUTY_LEADER:int = 1;
		static public const DUTY_SUBLEADER:int = 2;

		private var loaded:uint = 0;
		private var loadedTime:Number = 0;

		private var loading:uint = 0;
		private var loadStarted:Boolean = false;

		private var listeners:Dictionary = new Dictionary(false);

		public var exp:int = 0;
		public var maxExp:int = 0;
		public var dailyExp:int = 0;
		public var level:int = 0;
		public var levelLimiter:int = 0;

		public var id:int;
		public var leaderId:int = NaN;
		public var size:int = NaN;
		public var places:int = NaN;
		public var state:int = NaN;
		public var ratingPlace:int = NaN;
		public var weeklyPlace:int = NaN;

		public var dailyRatings:Array = null;
		public var blacklist:Array = null;

		public var emblemLink:String = null;
		public var name:String = null;
		public var photoLink:String = null;
		public var news:String = null;

		public var photo:Bitmap = null;

		public var acorns:int = 0;
		public var coins:int = 0;

		public var totems:Totems = new Totems();
		public var totemsSlot:TotemSlots = new TotemSlots();
		public var boosterExpires:int = 0;

		public function Clan(id:int):void
		{
			super();

			this.id = id;
		}

		public function setLoading(type:int):void
		{
			this.loading |= type;
			this.loadStarted = true;
		}

		public function isLoading(type:uint = 0):Boolean
		{
			if (type == 0)
				return (this.loaded != 0);
			return this.loadStarted && (this.loading & type) == type;
		}

		public function checkExpired(nocache:Boolean):void
		{
			if (this.loadedTime == 0)
				return;
			if (!nocache && (new Date().getTime() - this.loadedTime <= CACHE_EXPIRE_TIME))
				return;
			reset();
		}

		public function loadData(data:Object):void
		{
			if ("rating" in data)
			{
				this.ratingPlace = data['rating_place'];
				this.weeklyPlace = data['weekly_place'];
			}

			if ("rank" in data)
			{
				this.level = data['rank'][0];
				this.exp = data['rank'][1];
				this.dailyExp = data['rank'][2];
			}

			if ("state" in data)
				this.state = data['state'];

			if ("info" in data)
			{
				this.name = data['name'];
				this.photoLink = data['photo'];
				this.emblemLink = data['emblem'];
			}

			if ("news" in data)
			{
				this.news = data['news'];
				this.news = StringUtil.removeHtmlTags(this.news);
			}

			if ("leader_id" in data)
			{
				if (!isNaN(this.leaderId) && this.leaderId != data['leader_id'])
					Connection.sendData(PacketClient.CLAN_GET_MEMBERS, this.id);
				this.leaderId = data['leader_id'];
			}

			if ("size" in data)
				this.size = data['size'];

			if ("places" in data)
				this.places = data['places'];

			if ("rank_range" in data)
				this.maxExp = data['rank_range'];

			if ("totems" in data)
			{
				this.totemsSlot.parseTotems(data['totems'][0]);
				this.boosterExpires = data['totems'][1];
			}

			if ("totems_rangs" in data)
				this.totems.parseTotemsRangs(data['totems_rangs']);

			if ("totems_bonuses" in data)
				this.totems.parseTotemsBonuses(data['totems_bonuses']);

			if ("statistics" in data)
				this.dailyRatings = data['statistics'];

			if ("blacklist" in data)
			{
				this.blacklist = data['blacklist'];
				BlackListView.update();
			}

			if ("level_limiter" in data)
				this.levelLimiter = data['level_limiter'] & 0xFF;
		}

		public function setLoaded(type:uint):void
		{
			this.loaded |= type;
			this.loading &= ~type;
			this.loadedTime = new Date().getTime();
		}

		public function isLoaded(type:uint = 0):Boolean
		{
			if (type == 0)
				return (this.loaded != 0);
			return ((this.loaded & type) == type);
		}

		public function isComplete():Boolean
		{
			return this.loading == 0;
		}

		public function getImage(width:int, height:int, x:int, y:int):Bitmap
		{
			var img:Bitmap;

			if (this.photo == null)
			{
				img = ImageUtil.convertToRastrImage(new NonPhotoImage(), width, height);
				img.x = x;
				img.y = y;
				return img;
			}

			img = this.photo;

			return ImageUtil.scale(img, width, height);
		}

		public function save():void
		{
			Logger.add("Clan Save: Clan.photoLink, Clan.emblemLink,\n", this.photoLink, this.emblemLink);
			Connection.sendData(PacketClient.CLAN_INFO, this.photoLink, this.emblemLink);
		}

		public function removeEventListener(listener:Function):void
		{
			delete this.listeners[listener];
		}

		public function addEventListener(type:uint, listener:Function):void
		{
			if (listener in this.listeners)
				this.listeners[listener] |= type;
			else
				this.listeners[listener] = type;
		}

		public function dispatchEvent(type:uint):void
		{
			var duplicate:Dictionary = new Dictionary(false);

			for (var listener:* in this.listeners)
				duplicate[listener] = this.listeners[listener];

			for (listener in duplicate)
			{
				var l:uint = (duplicate[listener] & this.loaded);
				if (l == duplicate[listener])
					listener(this, type);
			}
		}

		private function reset():void
		{
			this.loaded = 0;
			this.loadedTime = 0;
			this.loadStarted = false;
		}
	}
}