package com.api
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;

	import utils.ImageUtil;

	public class Friend extends EventDispatcher
	{
		static private const NONE_PHOTO:NonPhotoImage = new NonPhotoImage();
		static private const NO_PHOTO:Bitmap = ImageUtil.convertToRastrImage(NONE_PHOTO, NONE_PHOTO.width, NONE_PHOTO.height);

		private var photoRequested:Boolean = false;

		public var photo:Bitmap = NO_PHOTO;
		public var photoUrl:String = "";
		public var appUser:Boolean;
		public var id:String;

		public function Friend():void
		{}

		public function requestInfo():void
		{
			dispatchEvent(new FriendEvent(FriendEvent.REQUEST_INFO, this));
		}

		public function updatePhoto():void
		{
			if (this.photo != NO_PHOTO || this.photoUrl == "" || this.photoRequested)
				return;

			this.photoRequested = true;
			ImageUtil.load(this.photoUrl, null, loadPhoto);
		}

		public function riseInfoEvent():void
		{
			dispatchEvent(new FriendEvent(FriendEvent.INFO_LOADED, this));
		}

		public function getImage(size:int, x:int, y:int, onlineShow:Boolean = false, rank:Boolean = false, scaleRank:Number = 0.4):Sprite
		{
			var img:Sprite = new Sprite();
			img.x = 0;
			img.y = 0;
			img.addChild(this.photo);

			if (img.width > img.height)
			{
				img.height = size;
				img.scaleX = img.scaleY;
			}
			else
			{
				img.width = size;
				img.scaleY = img.scaleX;
			}

			var photoFrame:Sprite = new Sprite();
			photoFrame.x = 0;
			photoFrame.y = 0;
			photoFrame.width = size;
			photoFrame.height = size;

			var sprite:Sprite = new Sprite();
			sprite.x = x;
			sprite.y = y;
			sprite.addChild(img);
			sprite.addChild(photoFrame);

			return sprite;
		}

		private function loadPhoto(photo:Bitmap, data:Object):void
		{
			if (photo == null)
				return;

			this.photo.bitmapData = photo.bitmapData;
			this.photoRequested = false;

			dispatchEvent(new FriendEvent(FriendEvent.PHOTO_LOADED, this));
		}
	}
}