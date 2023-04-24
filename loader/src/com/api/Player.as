package com.api
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;

	import utils.ImageUtil;
	import utils.PlayerUtil;

	dynamic public class Player
	{
		static private const CACHE_EXPIRE_TIME:int = 300 * 1000;

		static public const LOAD_DATA:int = 1;
		static public const LOAD_PHOTO:int = 2;
		static public const LOAD_PROFILE:int = 4;

		private var loaded:int = 0;
		private var loadedTime:Number = 0;

		private var loading:int = 0;
		private var loadStarted:Boolean = false;

		public function Player(id:int):void
		{
			super();

			this.id = id;
			this.age = -1;
		}

		public function setLoading(type:int):void
		{
			this.loading |= type;
			this.loadStarted = true;
		}

		public function isLoading():Boolean
		{
			if (this.loaded != 0)
				return true;
			return this.loadStarted;
		}

		public function checkExpired(nocache:Boolean):void
		{
			if (this.loadedTime == 0)
				return;
			if (!nocache && new Date().getTime() - this.loadedTime <= CACHE_EXPIRE_TIME)
				return;
			reset();
		}

		public function setLoaded(type:int):void
		{
			this.loaded |= type;
			this.loading |= type;
			this.loadedTime = new Date().getTime();
		}

		public function isLoaded(type:int = 0):Boolean
		{
			if (type == 0)
				return (this.loaded != 0);
			return ((this.loaded & type) == type);
		}

		public function isComplete():Boolean
		{
			return (this.loaded == this.loading);
		}

		public function needLoad(type:int):Boolean
		{
			if (isLoaded(type))
				return false;
			return ((this.loading & type) == type);
		}

		public function loadData(data:Object):void
		{
			for (var key:String in data)
				this[key] = data[key];
		}

		public function get photoBig():String
		{
			return this.photo_big;
		}

		public function set name(value:String):void
		{
			this._name = value;
		}

		public function get name():String
		{
			var stripped:String = PlayerUtil.stripName(this._name);
			if (stripped != "")
				return stripped;

			return "Без имени";
		}

		public function get nameOrig():String
		{
			return this._name;
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

			return ImageUtil.scale(img, width, height, x, y);
		}

		public function getImageFullSize():Bitmap
		{
			if (this.photo != null)
				return this.photo;

			var vectorImage:DisplayObject = new NonPhotoImage();
			return ImageUtil.convertToRastrImage(vectorImage, vectorImage.width, vectorImage.height);
		}

		private function reset():void
		{
			this.loaded = 0;
			this.loadedTime = 0;
			this.loadStarted = false;
		}
	}
}