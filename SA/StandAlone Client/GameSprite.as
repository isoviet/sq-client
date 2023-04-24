package  
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class GameSprite extends Sprite 
	{
		private var nameField:TextField = new TextField();
		private var descriptionField:TextField = new TextField();
		private var swfUrl:String = null;
		private var over:Boolean = false;
		private var appId:int = -1;

		private var image:Loader = new Loader();

		public function GameSprite(appId:int) 
		{
			Security.allowDomain("*");
			this.appId = appId;
			SAMain.execute("getAppInfo", { 'id': appId }, onInfo);
			
			this.image.x = 20;
			this.image.y = 20;
			addChild(this.image);

			this.nameField.x = 76 + 40;
			this.nameField.y = 0;
			this.nameField.width = 289 + (760 - 400);
			this.nameField.height = 36;
			this.nameField.selectable = false;
			this.nameField.defaultTextFormat = new TextFormat("Arial", 30, null, true, null, null, null, null, TextFormatAlign.CENTER);
			addChild(this.nameField);

			this.descriptionField.x = 76 + 40;
			this.descriptionField.y = 40;
			this.descriptionField.width = 760 - 76 - 40;
			this.descriptionField.height = (76 + 40) - 20 - 40;
			this.descriptionField.defaultTextFormat = new TextFormat("Arial", 14, null, null, null, null, null, null, TextFormatAlign.CENTER);
			this.descriptionField.multiline = true;
			this.descriptionField.wordWrap = true;
			this.descriptionField.selectable = false;
			addChild(this.descriptionField);
			draw();

			this.useHandCursor = true;
			this.buttonMode = true;
			this.mouseChildren = false;
			addEventListener(MouseEvent.MOUSE_OVER, onOver);
			addEventListener(MouseEvent.MOUSE_OUT, onOut);
			addEventListener(MouseEvent.CLICK, onClick);
		}

		private function onClick(e:Event):void 
		{
			SAMain.load(this.swfUrl, this.appId);
		}

		private function onOut(e:Event):void 
		{
			this.over = false;
			draw();
		}

		private function onOver(e:Event):void 
		{
			this.over = true;
			draw();
		}

		private function onInfo(data:*):void 
		{
			//'id', 'name', 'thumbURL', 'description', 'swfURL'
			this.nameField.text = data['name'];
			this.image.load(new URLRequest(data['thumbURL']));
			this.descriptionField.text = data['description'];
			this.swfUrl = data['swfURL'];
		}

		private function draw():void
		{
			this.graphics.clear();
			this.graphics.beginFill(0x8080C0, this.over ? 1 : 0.5);
			this.graphics.drawRoundRectComplex(0, 0, 760, 76 + 40, 20, 20, 20, 20);
		}
	}
}