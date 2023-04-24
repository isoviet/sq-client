package views
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	import com.api.Player;

	public class ProfilePhoto extends Sprite
	{
		private var photoWidth:int;
		private var smooth:Boolean;

		private var bg:DisplayObject = null;
		private var photo:Loader = new Loader();
		private var player:Player = null;

		private var urlLoader:URLLoader;

		public function ProfilePhoto(width:int, smooth:Boolean = true):void
		{
			this.photoWidth = width;
			this.smooth = smooth;

			var sprite:Sprite = new Sprite();
			addChild(sprite);

			this.bg = new NonPhotoImage();
			this.bg.width = width;
			this.bg.scaleY = this.bg.scaleX;
			sprite.addChild(this.bg);

			this.photo.contentLoaderInfo.addEventListener(Event.COMPLETE, onPhotoLoaded);
			this.photo.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			this.photo.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			sprite.addChild(this.photo);

			var mask:Sprite = new Sprite();
			mask.graphics.beginFill(0x000000);
			mask.graphics.drawRoundRect(0, 0, width, width, int(width * 0.3), int(width * 0.3));
			sprite.mask = mask;
			addChild(mask);
		}

		public function setPlayer(player:Player):void
		{
			if (player == this.player)
				return;

			this.bg.visible = true;
			this.photo.unload();

			if (this.player)
				this.player.removeEventListener(onPlayerLoaded);

			this.player = player;

			if (!("photo_big" in this.player))
			{
				this.player.addEventListener(PlayerInfoParser.PHOTO, onPlayerLoaded);
				Game.request(this.player['id'], PlayerInfoParser.PHOTO, false);
				return;
			}

			try
			{
				loadPhoto(this.player['photo_big']);
			}
			catch (e:Error)
			{
				Logger.add("Failed to loadPhoto:" + e.errorID + " " + e.message);
			}
		}

		public function onPlayerLoaded(player:Player):void
		{
			var context:LoaderContext = new LoaderContext();
			context.checkPolicyFile = true;

			loadPhoto(player['photo_big']);

			player.removeEventListener(onPlayerLoaded);
		}

		private function loadPhoto(url:String):void
		{
			this.urlLoader = new URLLoader();
			this.urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			this.urlLoader.addEventListener(Event.COMPLETE, onLoaded);
			this.urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			this.urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			this.urlLoader.load(new URLRequest(url));
		}

		private function onLoaded(e:Event):void
		{
			if ((e.currentTarget as URLLoader).data.length == 0)
				return;

			var context:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			this.photo.loadBytes((e.currentTarget as URLLoader).data, context);
		}

		private function onPhotoLoaded(e:Event):void
		{
			this.photo.width = this.photoWidth;
			this.photo.height = this.photoWidth;
			this.photo.scaleY = this.photo.scaleX = Math.max(this.photo.scaleY, this.photo.scaleX);
			this.photo.x = int((this.photoWidth - this.photo.width) * 0.5);
			this.photo.y = int((this.photoWidth - this.photo.height) * 0.5);

			this.bg.visible = false;
		}

		private function onError(e:Event):void
		{
			if (this.player.id == Game.selfId)
			{
				Game.self['photoBig'] = "";
				Game.saveSelf({
					'name': Game.self['name'],
					'sex': Game.self['sex']
				});
			}

			Logger.add("Failed to load Photo[Event]:" + e.toString());
		}
	}
}