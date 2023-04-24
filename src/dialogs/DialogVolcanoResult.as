package dialogs
{
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import fl.containers.ScrollPane;

	import menu.MenuProfile;
	import screens.ScreenGame;

	import utils.DateUtil;
	import utils.FiltersUtil;
	import utils.PlayerUtil;
	import utils.StringUtil;

	public class DialogVolcanoResult extends Dialog
	{
		static private const FORMAT:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 18, 0xADA390, true, null, null, null, null, "center");

		static private const CSS:String = (<![CDATA[
		body {
			font-family: "Droid Sans";
			font-size: 14px;
			color: #A4734B;
			font-weight: bold;
		}
		.self {
			color: #FF873F;
		}
		a {
			text-decoration: none;
		}
		a:hover {
			text-decoration: underline;
		}
		]]>).toString();

		private var style:StyleSheet = null;

		private var fields:Array = [];
		private var images:Array = [];
		private var fieldWaiting:GameField = null;
		private var spiteChangeRoom:Sprite = null;

		private var buttonChangeRoom:SimpleButton = null;

		private var scrollPane:ScrollPane = null;
		private var scrollSource:Sprite = null;

		public function DialogVolcanoResult():void
		{
			super(gls("Результаты раунда"));

			init();
		}

		public function setResults(scores:Object):void
		{
			while (this.fields.length > 0)
				this.scrollSource.removeChild(this.fields.pop());
			while (this.images.length > 0)
				this.scrollSource.removeChild(this.images.pop());

			var times:Object = scores['time'];
			var health:Object = scores['health'];

			toggleChangeRoom(!(Game.selfId in health) || health[Game.selfId] == 0);

			var array:Array = [];
			for (var id:String in times)
				array.push({'id': id, 'health': id in health ? health[id] : 0, 'score': times[id] == 0 ? "-" : DateUtil.formatTime(times[id]), 'sort': times[id] == 0 ? int.MAX_VALUE : times[id]});

			array.sort(sort);

			for (var j:int = 0; j < array.length; j++)
			{
				var field:GameField = new GameField("", 30, 20 * j, this.style);
				field.name = array[j]['id'];

				this.scrollSource.addChild(field);

				if (array[j]['id'] == Game.selfId)
					field.text = "<body><span class='self'>" + StringUtil.formatName(Game.self.name, 150) + "</span></body>";
				else
				{
					PlayerUtil.formatName(field, Game.getPlayer(array[j]['id']), 150, true, true, true);
					field.addEventListener(MouseEvent.MOUSE_UP, onClick);
				}

				this.fields.push(field);

				field = new GameField((j + 1).toString() + ".", 10, 20 * j, new TextFormat(null, 14, 0x5B2200, true));
				this.scrollSource.addChild(field);

				this.fields.push(field);

				if (array[j]['health'] == 0)
				{
					var image:DisplayObject = new IsDeathIcon();
					image.x = 215;
					image.y = 5 + 20 * j;
					this.scrollSource.addChild(image);

					this.images.push(image);
				}
				else
				{
					for (var i:int = 0; i < int((array[j]['health'] + 1) / 2); i++)
					{
						image = (array[j]['health'] - i * 2) == 1 ? new HitPointRedHalf() : new HitPointRed();
						image.x = 220 - 6 * (int(array[j]['health'] / 2) - 1) + 12 * i;
						image.y = 10 + 20 * j;
						this.scrollSource.addChild(image);

						this.images.push(image);
					}
				}

				field = new GameField(array[j]['score'], 0, 20 * j, new TextFormat(null, 14, 0x5B2200, true));
				field.x = 273 - int(field.textWidth * 0.5);
				this.scrollSource.addChild(field);

				this.fields.push(field);
			}
			this.scrollPane.update();
		}

		public function set waiting(value:Boolean):void
		{
			this.fieldWaiting.visible = value;
			this.spiteChangeRoom.visible = !value;
		}

		override protected function get captionFormat():TextFormat
		{
			return new TextFormat(GameField.PLAKAT_FONT, 22, 0xFFCC00, null, null, null, null, null, "center");
		}

		override protected function setDefaultSize():void
		{
			this.topOffset = 12;
			this.rightOffset = 5;
			this.leftOffset = 5;
			this.bottomOffset = 30;
		}

		override protected function initClose():void
		{
			super.initClose();

			if (!this.buttonClose)
				return;
			this.buttonClose.x -= 15;
			this.buttonClose.y -= 5;
		}

		private function init():void
		{
			this.style = new StyleSheet();
			this.style.parseCSS(CSS);

			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(310, 285, Math.PI / 2, 162, 10);

			var sprite:Sprite = new Sprite();
			sprite.graphics.beginGradientFill(GradientType.LINEAR, [0xDDC9AF, 0xFFFFFF, 0xDDC9AF], [0.5, 0.1, 0.5], [0, 100, 255], matrix);
			sprite.graphics.drawRect(0, 0, 310, 285);
			addChild(sprite);

			addChild(new GameField(gls("Имя"), 25, 0, new TextFormat(null, 11, 0x857653, true)));
			addChild(new GameField(gls("Здоровье"), 190, 0, new TextFormat(null, 11, 0xD97E25, true)));
			addChild(new GameField(gls("Время"), 255, 0, new TextFormat(null, 11, 0xD97E25, true)));

			this.scrollPane = new ScrollPane();
			this.scrollPane.x = 0;
			this.scrollPane.y = 20;
			this.scrollPane.setSize(308, 260);
			addChild(this.scrollPane);

			this.scrollSource = new Sprite();
			this.scrollPane.source = this.scrollSource;

			this.fieldWaiting = new GameField(gls("Следующий раунд\nскоро начнется..."), 0, 295, FORMAT);
			this.fieldWaiting.x = 150 - int(this.fieldWaiting.textWidth * 0.5);
			addChild(this.fieldWaiting);

			this.spiteChangeRoom = new Sprite();
			this.spiteChangeRoom.y = 295;
			this.spiteChangeRoom.addChild(new GameField(gls("Перейти в другую\nкомнату"), 15, 0, FORMAT));
			addChild(this.spiteChangeRoom);

			this.buttonChangeRoom = new ButtonChangeRoom();
			this.buttonChangeRoom.x = 295 - this.buttonChangeRoom.width;
			this.buttonChangeRoom.addEventListener(MouseEvent.CLICK, changeRoom);
			this.spiteChangeRoom.addChild(this.buttonChangeRoom);

			place();

			this.height += 15;
			this.fieldCaption.y -= 10;
		}

		private function toggleChangeRoom(value:Boolean):void
		{
			this.buttonChangeRoom.mouseEnabled = value;
			this.buttonChangeRoom.filters = value ? [] : FiltersUtil.GREY_FILTER;
		}

		private function changeRoom(e:MouseEvent):void
		{
			ScreenGame.changeRoom();

			toggleChangeRoom(false);
		}

		private function onClick(e:MouseEvent):void
		{
			MenuProfile.showMenu(e.target.name);
		}

		private function sort(a:Object, b:Object):int
		{
			if (a['sort'] == b['sort'])
				return a['health'] > b['health'] ? -1 : 1;
			return a['sort'] > b['sort'] ? -1 : 1;
		}
	}
}