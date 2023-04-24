package tape
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonDouble;
	import tape.events.TapeElementEvent;

	import com.api.Friend;
	import com.api.FriendEvent;
	import com.api.Services;

	import utils.PhotoLoader;

	public class TapeInviteFriendObject extends TapeObject
	{
		public var id:String;

		private var buttonDouble:ButtonDouble = null;

		private var _selected:Boolean = true;

		private var nameField:GameField;

		private var photo:PhotoLoader;

		public function TapeInviteFriendObject(id:String, mini:Boolean = false):void
		{
			super();

			this.id = id;

			var friend:Friend = Services.friends.getFriend(id);
			friend.addEventListener(FriendEvent.INFO_LOADED, onLoadInfo);

			if (!mini)
			{
				var backgroundImage:DisplayObject = new ButtonBankShort().upState;
				backgroundImage.height = 50;
				addChild(backgroundImage);
			}

			var whiteSprite:Sprite = new Sprite();
			whiteSprite.graphics.beginFill(0xffffff, 1.0);
			whiteSprite.graphics.drawRect(0, 0, 50, 50);
			whiteSprite.x = 4;
			whiteSprite.y = 0;
			addChild(whiteSprite);

			this.photo = new PhotoLoader("", 4, 0, 50, 50);
			addChild(this.photo);

			var friendPhoto:InviteFriendPhoto = new InviteFriendPhoto();
			friendPhoto.y = -4;
			addChild(friendPhoto);

			if (!mini)
			{
				this.nameField = new GameField("", friendPhoto.x + friendPhoto.width + 4, 12, new TextFormat(null, 16, 0x63421B, true));
				this.nameField.maxChars = 15;
				addChild(this.nameField);
			}

			if (!mini)
			{
				var checkBox:InviteFriendCheckBox = new InviteFriendCheckBox();
				checkBox.x = backgroundImage.width - 40;
				checkBox.y = 9;
				addChild(checkBox);
			}

			var buttonSend:SetDecorationButton = new SetDecorationButton();
			buttonSend.x = 12;
			buttonSend.y = -5;
			buttonSend.scaleX = buttonSend.scaleY = 2.0;
			buttonSend.addEventListener(MouseEvent.CLICK, switchState);

			var buttonReject:HideDecorationButton = new HideDecorationButton();
			buttonReject.x = 5;
			buttonReject.scaleX = buttonReject.scaleY = 2.0;
			buttonReject.addEventListener(MouseEvent.CLICK, switchState);

			if (!mini)
			{
				this.buttonDouble = new ButtonDouble(buttonSend, buttonReject, true);
				this.buttonDouble.x = backgroundImage.width - 50;
				this.buttonDouble.y = 9;
				this.buttonDouble.setState(true);
				addChild(this.buttonDouble);
			}
		}

		public function get selected():Boolean
		{
			return this._selected;
		}

		public function set selected(value:Boolean):void
		{
			this._selected = value;

			if (this.buttonDouble)
				this.buttonDouble.setState(this._selected);
		}

		private function switchState(e:MouseEvent):void
		{
			this.selected = !this.selected;
		}

		private function onLoadInfo(e:FriendEvent):void
		{
			if (this.nameField)
				this.nameField.text = e.friend.name;
			this.photo.load(e.friend.photoUrl);

			dispatchEvent(new TapeElementEvent(this, TapeElementEvent.CHANGED));
		}
	}
}