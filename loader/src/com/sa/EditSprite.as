package com.sa
{
	import flash.display.Loader;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.LoaderContext;

	import fl.data.DataProvider;

	public class EditSprite extends EditDialog
	{
		static private const MONTHS:Array = ["Января", "Февраля", "Марта", "Апреля", "Мая", "Июня", "Июля", "Августа", "Сентября", "Октября", "Ноября", "Декабря"];

		private var photoLoader:Loader = new Loader();
		private var fileReference:FileReference = new FileReference();
		private var playerData:*;

		public function EditSprite()
		{
			this.visible = false;
			Processor.execute("getProfiles", null, onUserInfo);
			this.photoLoader.x = this.photoFrame.x;
			this.photoLoader.y = this.photoFrame.y;
			this.addChild(photoLoader);

			var dayProvider:DataProvider = new DataProvider();
			for (var i:int = 1; i <= 31; i++)
				dayProvider.addItem({'label': i, 'value': i});

			var monthProvider:DataProvider = new DataProvider();
			for (i = 0; i < MONTHS.length; i++)
				monthProvider.addItem({'label': MONTHS[i], 'value': i});

			var currentYear:int = new Date().getFullYear();
			var yearProvider:DataProvider = new DataProvider();
			for (i = currentYear; i >= 1900; i--)
				yearProvider.addItem({'label': i, 'value': i});

			this.comboDay.dataProvider = dayProvider;
			this.comboMonth.dataProvider = monthProvider;
			this.comboYear.dataProvider = yearProvider;

			this.uploadPhotoButton.addEventListener(MouseEvent.CLICK, onSelectFile);

			this.playButton.addEventListener(MouseEvent.CLICK, onSave);
		}

		private function onUserInfo(data:*):void
		{
			Main._instance.loginSprite.visible = false;
			data = data[0];

			this.playerData = data;
			if (data['first_name'] != "")
			{
				Main.start();
				return;
			}

			this.photoLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onPhotoLoaded);
			this.visible = true;

			if (OAuth.profile != null)
			{
				this.fieldName.text = OAuth.profile['name'];
				this.comboSex.selectedIndex = OAuth.profile['sex'];

				if (OAuth.profile['bdate'] != 0)
				{
					var bdate:Date = new Date(OAuth.profile['bdate'] * 1000);
					this.comboDay.selectedIndex = bdate.getDate() - 1;
					this.comboMonth.selectedIndex = bdate.getMonth();
					this.comboYear.selectedIndex = new Date().getFullYear() - bdate.getFullYear();
				}
	
				this.photoLoader.load(new URLRequest(OAuth.profile['image']));
			}
		}

		private function onSave(e:MouseEvent):void
		{
			var bdate:Date = new Date(this.comboYear.selectedItem['value'], this.comboMonth.selectedItem['value'], this.comboDay.selectedItem['value']);
			Processor.execute("setUserInfo", {'fName': this.fieldName.text, 'sName': "", 'photoUrl': this.photoLoader.contentLoaderInfo.url, 'gender': this.comboSex.selectedItem['data'], 'birthDate': int(bdate.getTime() / 1000)}, onInfoSaved);
		}

		private function onInfoSaved(data:*):void
		{
			if (parent)
				this.parent.removeChild(this);

			this.visible = false;
			Main.start();
		}

		private function onSelectFile(e:Event = null):void
		{
			this.fileReference.browse([new FileFilter("Фото","*.jpg;*.gif;*.png;*.bmp")]);
			this.fileReference.addEventListener(Event.SELECT, onUpload);
			this.fileReference.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadCompleted);
		}

		private function onUpload(e:Event):void
		{
			if (this.fileReference.size > 12 * 1024 * 1024)
				return;

			var variables:URLVariables = new URLVariables();
			variables['uid'] = Services.userId;
			variables['type'] = 32;

			var urlRequest:URLRequest = new URLRequest();
			urlRequest.url = Config.PHOTO_UPLOAD_URL;
			urlRequest.method = URLRequestMethod.POST;
			urlRequest.data = variables;

			this.fileReference.upload(urlRequest, "photo");
		}

		private function onUploadCompleted(e:DataEvent):void
		{
			var context:LoaderContext = new LoaderContext();
			context.checkPolicyFile = true;
			this.photoLoader.load(new URLRequest(e.data), context);
		}

		private function onPhotoLoaded(e:Event):void
		{
			this.photoLoader.width = this.photoFrame.width - 2;
			this.photoLoader.height = this.photoFrame.height - 2;
			this.photoLoader.scaleX = this.photoLoader.scaleY = Math.min(this.photoLoader.scaleX, this.photoLoader.scaleY);
			this.photoLoader.x = photoFrame.x + (this.photoFrame.width - this.photoLoader.width) / 2;
			this.photoLoader.y = photoFrame.y + (this.photoFrame.height - this.photoLoader.height) / 2;
		}
	}
}