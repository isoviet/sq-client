package tape
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import tape.events.TapeElementEvent;
	import views.PlayerPlaceClan;
	import views.PlayerPlaceReturn;
	import views.PlayerPlaceSocial;

	import com.api.Player;

	public class TapePlayer extends TapeObject
	{
		static public const TYPE_FRIEND:int = 0;
		static public const TYPE_CLAN:int = 1;
		static public const TYPE_RETURN:int = 2;

		static private const COMMON_MASK:uint = PlayerInfoParser.NAME | PlayerInfoParser.PHOTO;

		private var requested:Boolean = false;
		private var _friendsRatingPlace:int = -1;
		private var friendsRatingTip:FriendsRatingTips = null;
		private var type:int = -1;

		private var requestMask:uint = 0;

		protected var playerPlace:ITapePlayerPlace;

		public var player:Player = null;
		public var playerId:int;

		public function TapePlayer(playerId:int, type:int = TapePlayer.TYPE_FRIEND):void
		{
			super();

			this.playerId = playerId;
			this.type = type;
			this.player = Game.getPlayer(this.playerId);

			switch(this.type)
			{
				case TYPE_FRIEND:
					if (playerId == Game.selfId)
						this.playerPlace = new PlayerPlaceSocial(new TopSelfFrame);
					else
						this.playerPlace = new PlayerPlaceSocial(new TopFrame);
					this.friendsRatingTip = new FriendsRatingTips(this, "", "", "");
					this.requestMask = TapeAllFriendData.REQUEST_FOR_SORT_MASK;
					break;
				case TYPE_CLAN:
					this.playerPlace = new PlayerPlaceClan();
					this.requestMask = TapeClanData.REQUEST_FOR_SORT_MASK;
					break;
				case TYPE_RETURN:
					this.playerPlace = new PlayerPlaceReturn(new TopFrame);
					this.requestMask = PlayerInfoParser.ONLINE;
					break;
			}

			this.player.addEventListener(this.requestMask, onPlayerLoaded);
			this.player.addEventListener(COMMON_MASK, onPlayerLoaded);

			(this.playerPlace as Sprite).addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 100);
			addChild(this.playerPlace as Sprite);
		}

		override public function get loaded():Boolean
		{
			return (this.player != null);
		}

		override public function onShow():void
		{
			if (this.requested)
				return;

			this.requested = true;

			Game.request(this.playerId, COMMON_MASK);
		}

		public function setTopPlaceFrame(place:int):void
		{
			if (this.type != TYPE_FRIEND)
				return;

			switch (place)
			{
				case 1:
					(this.playerPlace as PlayerPlaceSocial).setButton(new TopGoldenFrame);
					break;
				case 2:
					(this.playerPlace as PlayerPlaceSocial).setButton(new TopSilverFrame);
					break;
				case 3:
					(this.playerPlace as PlayerPlaceSocial).setButton(new TopBronzeFrame);
					break;
				case -1:
					if (playerId == Game.selfId)
						(this.playerPlace as PlayerPlaceSocial).setButton(new TopSelfFrame);
					else
						(this.playerPlace as PlayerPlaceSocial).setButton(new TopFrame);
					break;
			}
		}

		public function set friendsRatingPlace(value:int):void
		{
			if (this.type != TYPE_FRIEND)
				return;
			this._friendsRatingPlace = value;
		}

		protected function onPlayerLoaded(player:Player):void
		{
			if (this.requested)
				this.playerPlace.setPhoto(player);

			if (!(this.playerPlace.isPlayerChanged(this.player)))
				return;

			Logger.add("TapePlayer.setPlayer for player id " + this.playerId);

			this.playerPlace.setPlayer(this.player);
			dispatchEvent(new TapeElementEvent(this, TapeElementEvent.CHANGED));
		}

		private function onMouseOver(e:MouseEvent):void
		{

			this.parent.setChildIndex(this, parent.numChildren - 1);

			if (this.player == null)
				return;

			if (this.type != TYPE_FRIEND || this.player['exp'] == null)
				return;

			if (!('name' in this.player))
				this.player.name = "";

			this.friendsRatingTip.load(this.player.name, this.player['exp'].toString(), this._friendsRatingPlace.toString());
		}
	}
}