package tape.shopTapes
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import buttons.ButtonBase;
	import events.GameEvent;
	import game.gameData.EmotionManager;
	import game.gameData.GameConfig;
	import tape.TapeData;
	import tape.TapeSelectableObject;
	import tape.TapeSelectableView;
	import views.EmotionBarView;

	import protocol.PacketClient;

	import utils.FieldUtils;

	public class TapeShopEmotions extends TapeSelectableView
	{
		static public const FILTERS:Array = [new GlowFilter(0x33FF00, 1, 2, 2, 8)];

		static private var _instance:TapeShopEmotions = null;

		public var fieldName:GameField = null;
		public var fieldInfo:GameField = null;

		private var buttonBuy:ButtonBase = null;

		private var currentId:int = 0;

		private var spriteExamples:Sprite = null;
		private var movieExample:MovieClip = null;

		private var lastSelected:DisplayObject = null;

		static public function update():void
		{
			if (_instance)
				_instance.updateInfo(_instance.lastSticked);
		}

		public function TapeShopEmotions():void
		{
			super(4, 3, 30, 70, 15, 15, 110, 115, true, true, false);

			_instance = this;
		}

		override public function setData(data:TapeData):void
		{
			super.setData(data);

			if (data.objects.length != 0)
				select(data.objects[0] as TapeSelectableObject);
			else
				select(null);
		}

		override protected function init():void
		{
			super.init();

			addChildAt(new ImageShopSmilesBack(), 0);

			this.buttonBuy = new ButtonBase("");
			this.buttonBuy.x = 693;
			this.buttonBuy.y = 438;
			this.buttonBuy.addEventListener(MouseEvent.CLICK, buy);
			addChild(this.buttonBuy);

			this.fieldName = new GameField("", 580, 51, new TextFormat(GameField.DEFAULT_FONT, 19, 0x663300, false, null, null, null, null, TextFormatAlign.CENTER), 302);
			addChild(this.fieldName);

			this.fieldInfo = new GameField("", 580, 293, new TextFormat(GameField.DEFAULT_FONT, 12, 0x68361B, false), 302);
			addChild(this.fieldInfo);

			this.spriteExamples = new Sprite();
			this.spriteExamples.x = 580;
			this.spriteExamples.y = 335;
			addChild(this.spriteExamples);

			EmotionManager.addEventListener(GameEvent.SMILES_CHANGED, onChange);
		}

		private function onChange(e:GameEvent):void
		{
			this.buttonBuy.visible = !EmotionBarView.isBoughtPack(this.currentId);
		}

		protected function get coins():int
		{
			return GameConfig.getSmilesCoinsPrice(this.currentId);
		}

		private function buy(e:Event):void
		{
			Game.buyWithoutPay(PacketClient.BUY_MISC, this.coins, 0, Game.selfId, this.currentId);
		}

		override protected function updateInfo(selected:TapeSelectableObject):void
		{
			if (selected == null)
				return;
			this.currentId = selected.id;

			this.buttonBuy.field.text = this.coins.toString() + " - ";
			this.buttonBuy.clear();
			this.buttonBuy.redraw();
			FieldUtils.replaceSign(this.buttonBuy.field, "-", ImageIconCoins, 0.7, 0.7, -this.buttonBuy.field.x, -3, false, true);
			this.buttonBuy.visible = !EmotionBarView.isBoughtPack(selected.id);

			this.fieldName.text = EmotionManager.PACKS_NAME[selected.id];
			this.fieldInfo.text = EmotionManager.PACKS_TEXT[selected.id];

			while (this.spriteExamples.numChildren > 0)
				this.spriteExamples.removeChildAt(0);
			var smiles:Array = GameConfig.getSmilesElements(selected.id);
			for (var i:int = 0; i < smiles.length; i++)
			{
				var id:int = smiles[i];

				var example:Sprite = new Sprite();
				example.buttonMode = true;
				example.x = (i % 7) * 42;
				example.y = int(i / 7) * 44;
				example.name = id.toString();
				example.addEventListener(MouseEvent.CLICK, onSelect);

				var back:ElementPackageBack = new ElementPackageBack();
				back.width = 40;
				back.height = 42;
				example.addChild(back);

				var movie:MovieClip;
				if("image" in EmotionBarView.emotionButtons[id])
				{
					movie = new EmotionBarView.emotionButtons[id]['image'];
					movie.stop();
				}
				else
				{
					movie = new EmotionBarView.emotionButtons[id]['btn'];
					movie.gotoAndStop(EmotionBarView.emotionButtons[id]['frame']);
				}
				movie.width = 40;
				movie.height = 42;
				movie.scaleX = movie.scaleY = Math.min(movie.scaleX, movie.scaleY);
				movie.x = 20;
				movie.y = 21;
				example.addChild(movie);

				this.spriteExamples.addChild(example);
			}

			if (this.lastSelected)
				this.lastSelected.filters = [];
			this.lastSelected = this.spriteExamples.getChildAt(0);
			this.lastSelected.filters = FILTERS;

			updateSmileMovie(smiles[0]);
		}

		private function onSelect(e:MouseEvent):void
		{
			if (this.lastSelected)
				this.lastSelected.filters = [];
			this.lastSelected = e.currentTarget as DisplayObject;
			this.lastSelected.filters = FILTERS;
			updateSmileMovie(int(e.currentTarget.name));
		}

		private function updateSmileMovie(id:int):void
		{
			if (this.movieExample)
				removeChild(this.movieExample);
			this.movieExample = new EmotionBarView.emotionButtons[id]['btn'];
			this.movieExample.scaleX = this.movieExample.scaleY = 3;
			this.movieExample.x = 725;
			this.movieExample.y = 190;
			addChild(this.movieExample);
		}
	}
}