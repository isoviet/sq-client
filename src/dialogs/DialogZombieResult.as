package dialogs
{
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import fl.containers.ScrollPane;

	import menu.MenuProfile;

	import utils.PlayerUtil;
	import utils.StringUtil;

	public class DialogZombieResult extends Dialog
	{
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
		private var fieldWaiting:GameField = null;

		private var scrolls:Vector.<ScrollPane> = new <ScrollPane>[];
		private var scrollsSource:Vector.<Sprite> = new <Sprite>[];

		public function DialogZombieResult():void
		{
			super(gls("Результаты раунда"));

			init();
		}

		public function setResults(scores:Array):void
		{
			while (this.fields.length > 0)
			{
				var obj:GameField = this.fields.pop();
				obj.parent.removeChild(obj);
			}

			for (var i:int = 0; i < scores.length; i++)
			{
				var array:Array = [];
				for (var id:String in scores[i])
					array.push({'id': id, 'score': scores[i][id]});

				array.sortOn("score", Array.NUMERIC | Array.DESCENDING);

				for (var j:int = 0; j < array.length; j++)
				{
					var field:GameField = new GameField("", 30, 20 * j, this.style);
					field.name = array[j]['id'];

					this.scrollsSource[i].addChild(field);

					if (array[j]['id'] == Game.selfId)
						field.text = "<body><span class='self'>" + StringUtil.formatName(Game.self.name, 150) + "</span></body>";
					else
					{
						PlayerUtil.formatName(field, Game.getPlayer(array[j]['id']), 150, true, true, true);
						field.addEventListener(MouseEvent.MOUSE_UP, onClick);
					}

					this.fields.push(field);

					field = new GameField((j + 1).toString() + ".", 10, 20 * j, new TextFormat(null, 14, 0x5B2200, true));
					this.scrollsSource[i].addChild(field);

					this.fields.push(field);

					field = new GameField(array[j]['score'], 210, 20 * j, new TextFormat(null, 14, 0x5B2200, true));
					this.scrollsSource[i].addChild(field);

					this.fields.push(field);
				}
				this.scrolls[i].update();
			}
		}

		public function set waiting(value:Boolean):void
		{
			this.fieldWaiting.visible = value;
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

			var format:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 16, 0x857653);
			addChild(new GameField(gls("Лучшие белки"), 85, 0, format));
			var image:DisplayObject = new ImageIconSquirrel();
			image.x = 45;
			image.y = -5;
			addChild(image);

			addChild(new GameField(gls("Лучшие зомби"), 335, 0, format));
			image = new ImageIconZombie();
			image.x = 295;
			image.y = -5;
			addChild(image);

			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(500, 245, Math.PI / 2, 162, 10);

			var sprite:Sprite = new Sprite();
			sprite.graphics.beginGradientFill(GradientType.LINEAR, [0xDDC9AF, 0xFFFFFF, 0xDDC9AF], [0.5, 0.1, 0.5], [0, 100, 255], matrix);
			sprite.graphics.drawRect(0, 35, 500, 245);
			sprite.graphics.lineStyle(1, 0xEDE1CB);
			sprite.graphics.moveTo(250, 0);
			sprite.graphics.lineTo(250, 280);
			addChild(sprite);

			addChild(new GameField(gls("Имя"), 25, 35, new TextFormat(null, 11, 0x857653, true)));
			addChild(new GameField(gls("Имя"), 275, 35, new TextFormat(null, 11, 0x857653, true)));
			addChild(new GameField(gls("Продержался"), 170, 35, new TextFormat(null, 11, 0xD97E25, true)));
			addChild(new GameField(gls("Заразил"), 445, 35, new TextFormat(null, 11, 0x487B2E, true)));

			for (var i:int = 0; i < 2; i++)
			{
				var scrollPane:ScrollPane = new ScrollPane();
				scrollPane.x = 250 * i;
				scrollPane.y = 55;
				scrollPane.setSize(248, 220);
				addChild(scrollPane);

				sprite = new Sprite();
				scrollPane.source = sprite;

				this.scrolls.push(scrollPane);
				this.scrollsSource.push(sprite);
			}

			this.fieldWaiting = new GameField(gls("следующий раунд скоро начнется... "), 0, 290, new TextFormat(GameField.PLAKAT_FONT, 16, 0xADA390));
			this.fieldWaiting.x = 250 - int(this.fieldWaiting.textWidth * 0.5);
			addChild(this.fieldWaiting);

			place();

			this.height += 15;
			this.fieldCaption.y -= 10;
		}

		private function onClick(e:MouseEvent):void
		{
			MenuProfile.showMenu(e.target.name);
		}
	}
}