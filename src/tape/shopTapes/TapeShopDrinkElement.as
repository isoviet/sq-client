package tape.shopTapes
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.TextFormat;

	import events.DiscountEvent;
	import events.GameEvent;
	import game.gameData.ExpirationsManager;
	import game.gameData.GameConfig;
	import views.ElementShopInfoDesk;

	import com.greensock.TweenMax;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketBuy;

	import utils.ColorMatrix;
	import utils.FieldUtils;
	import utils.MovieClipUtils;

	public class TapeShopDrinkElement extends TapeShopElement
	{
		private static const ICON_POS:Point = new Point(109, 200);

		static private const FORMAT_TEXT:TextFormat = new TextFormat(null, 12, 0x845B41, true);
		static private const TEXT:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 20, 0xffffff);
		static private const ADD_TEXT:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 13, 0xffffff);

		static public const MODIFY_ICON:Array = [
			{'class': EnergyGlassBigClip,		'offsetX': 23,	'offsetY': 22,	'scale': 1.2, 'font':'green',
				countAnim:1, showIcon:true, goodId:PacketClient.BUY_ENERGY_BIG,
				'color': [0, 0, 0, 0], text: '250 -', 'image': ImageIconEnergy},
			{'class': ManaGlassBigClip,		'offsetX': 23,	'offsetY': 22,	'scale': 1.2, 'font':'blue',
				countAnim:1, showIcon:true, goodId:PacketClient.BUY_MANA_BIG,
				'color': [0, 0, 0, 180], text: '400 -', 'image': ImageIconMana},
			{'class': ManaRegenerationClip,	'offsetX': 34,	'offsetY': 23,	'scale': 1.2, 'font':'blue',
				countAnim:3, showIcon:false, goodId:PacketClient.BUY_MANA_REGENERATION,
				'color': [-20, 0, 0, -108], text: '25 -/' + gls("мин"), 'image': ImageIconMana}
		];

		private var imageInfo:ElementShopInfoDesk = null;
		private var imageRibbon:MovieClip = null;
		private var ribbonImage:MovieClip = null;
		private var containerCountFields:Sprite = null;

		public function TapeShopDrinkElement(itemId:int):void
		{
			super(itemId);

			if (this.id == DrinkItemsData.REGENERATION_ID)
			{
				this.imageInfo = new ElementShopInfoDesk();
				this.imageInfo.x = 20;
				this.imageInfo.y = 225;
				this.imageInfo.text = gls("Активно");
				this.imageInfo.visible = false;
				addChild(this.imageInfo);

				ExpirationsManager.addEventListener(GameEvent.ON_CHANGE, onChange);
			}

			Connection.listen(onBuySuccess, [PacketBuy.PACKET_ID]);

			DiscountManager.addEventListener(DiscountEvent.START, onDiscount);
			DiscountManager.addEventListener(DiscountEvent.END, onDiscountEnd);
		}

		private function onBuySuccess(packet:PacketBuy):void
		{
			var buy:PacketBuy = packet as PacketBuy;
			if(buy.goodId == MODIFY_ICON[this.id]['goodId'])
				onAnimPlay();
		}

		override protected function initImages():void
		{
			super.initImages();

			this.containerCountFields = new Sprite();

			this.image = new this.imageClass;
			this.image.scaleX = this.image.scaleY = MODIFY_ICON[this.id]['scale'];
			this.image.x = int((this.backWidth - this.image.width) * 0.5) + MODIFY_ICON[this.id]['offsetX'];
			this.image.y = int((this.backHeight - this.image.height) * 0.5) + MODIFY_ICON[this.id]['offsetY'];
			(this.image as MovieClip).stop();
			MovieClipUtils.stopAll((this.image as MovieClip), 1);

			addChild(this.image);

			addButton(this.cost, ImageIconCoins, buy);
			if (this.extraCost > 0)
				addButton(this.extraCost, ImageIconCoins, buyExtra);

			this.addChild(this.containerCountFields);

			this.ribbonImage = createRibbon(MODIFY_ICON[this.id]['color'], MODIFY_ICON[this.id]['text'], MODIFY_ICON[this.id]['image']);
			addChild(this.ribbonImage);

			if (this.extraCost == 0)
				return;
			var field:GameField = new GameField(gls("На день"), 10, 245, FORMAT_TEXT);
			field.x = 55 - int(field.textWidth * 0.5);
			addChild(field);

			field = new GameField(gls("На неделю"), 120, 245, FORMAT_TEXT);
			field.x = 145 - int(field.textWidth * 0.5);
			addChild(field);
		}

		private function onAnimPlay(e:Event = null):void
		{
			var movieClip:MovieClip = this.image as MovieClip;
			MovieClipUtils.playOnceAndStop(movieClip, 1, onAnimEnd);

			var meanFrameRate:int = 20;
			var discreteAngle:Number = 0.4;
			var dePosition:Number = discreteAngle * (MODIFY_ICON[this.id]['countAnim']-1)/2;
			var startPoint:Point = new Point(110,200);
			var radius:Number = 160;
			for (var i:int = 0; i < MODIFY_ICON[this.id]['countAnim']; i++)
			{
				var gameContainer:Sprite = getCountContainer();
				gameContainer.x = startPoint.x;
				gameContainer.y = startPoint.y;
				var angle:Number = -1.57 + i*discreteAngle - dePosition;
				var toX:Number = Math.cos(angle)*radius + startPoint.x;
				var toY:Number = Math.sin(angle)*radius + startPoint.y;
				TweenMax.to(gameContainer, 13/meanFrameRate, {x:toX, y:toY});
				TweenMax.to(gameContainer, 4/meanFrameRate, {delay:9/meanFrameRate, alpha:0});
			}

			this.ribbonImage.scaleX = this.ribbonImage.scaleY = 1;
			this.ribbonImage.alpha = 1;

			TweenMax.to(this.ribbonImage, 8/meanFrameRate, {scaleX:0, scaleY:0, alpha:0});
		}

		private function onAnimEnd():void
		{
			(this.image as MovieClip).gotoAndStop(1);
			this.containerCountFields.removeChildren();

			this.ribbonImage.scaleX = this.ribbonImage.scaleY = this.ribbonImage.alpha = 1;
		}

		private function createRibbon(color:Array, text:String, image:Class):MovieClip
		{
			var answer:MovieClip = new MovieClip();
			answer.x = ICON_POS.x;
			answer.y = ICON_POS.y;

			var ribbonImage:RibbonImage = new RibbonImage();
			answer.addChild(ribbonImage);

			var sprite:Sprite = new Sprite();
			answer.addChild(sprite);

			var field:GameField = new GameField(text.split('-')[0] + '-', 0, 0, TEXT);
			sprite.addChild(field);

			var scale:Number = 22 * text.length;
			ribbonImage.width = scale > ribbonImage.width ? scale : ribbonImage.width;

			var colorMatrix:ColorMatrix = new ColorMatrix();
			colorMatrix.adjustColor(color[0], color[1], color[2], color[3]);
			ribbonImage.filters = [new ColorMatrixFilter(colorMatrix)];

			if(text.split('-').length > 1)
			{
				var fieldExtra:GameField = new GameField(text.split('-')[1], 0, 0, ADD_TEXT);
				sprite.addChild(fieldExtra);
			}

			var icon:DisplayObject = FieldUtils.replaceSign(field, "-", image, 1, 1, 1, 1, false, true)[0];

			fieldExtra.x = icon.x + icon.width;
			fieldExtra.y = icon.y + icon.height * 0.5 - fieldExtra.height * 0.5;

			sprite.x = -sprite.width * 0.5;
			sprite.y = -sprite.height * 0.5 + 8;

			return answer;
		}

		protected function getCountContainer():Sprite
		{
			var container:Sprite = new Sprite();
			var inner:Sprite = new Sprite();
			var format:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 20,
				MODIFY_ICON[this.id]['font'] == 'green' ? 0x38CC00 : 0x25B9FF, true);
			var count:String = MODIFY_ICON[this.id]['text'].split("-")[0];
			var gameField:GameField = new GameField(count + (MODIFY_ICON[this.id]['showIcon'] == true ? ' -' : ''),
				0, 0, format);
			gameField.filters = [ new DropShadowFilter(0, 0, 0x3E2604, 1, 4, 4, 10, 1)];
			inner.addChild(gameField);
			if(MODIFY_ICON[this.id]['showIcon'] == true)
				FieldUtils.replaceSign(gameField, "-", MODIFY_ICON[this.id]['image'], 1, 1, 1, 1, false, true)[0];
			inner.x = -inner.width/2;
			inner.y = -inner.height/2;
			container.addChild(inner);
			this.containerCountFields.addChild(container);
			return container;
		}

		override protected function get title():String
		{
			return DrinkItemsData.getTitle(id);
		}

		override protected function get imageClass():Class
		{
			return MODIFY_ICON[this.id]['class'];
		}

		override protected function get cost():int
		{
			switch (this.id)
			{
				case 0:
					return GameConfig.getEnergyCoinsPrice();
				case 1:
					return GameConfig.getManaCoinsPrice();
				case 2:
					return GameConfig.getManaRegenerationCoinsPrice(0);
			}
			return 0;
		}

		override protected function get extraCost():int
		{
			if (this.id == 2)
				return GameConfig.getManaRegenerationCoinsPrice(1);
			return 0;
		}

		protected function buy(e:MouseEvent):void
		{
			Game.buyWithoutPay(DrinkItemsData.getType(this.id), this.cost, 0, Game.selfId);
		}

		protected function buyExtra(e:MouseEvent):void
		{
			Game.buyWithoutPay(DrinkItemsData.getType(this.id), this.extraCost, 0, Game.selfId, 1);
		}

		private function onChange(e:GameEvent):void
		{
			this.imageInfo.visible = ExpirationsManager.haveExpiration(ExpirationsManager.MANA_REGENERATION);
			this.imageInfo.value = ExpirationsManager.getDurationString(ExpirationsManager.MANA_REGENERATION);
		}

		private function onDiscount(e:DiscountEvent):void
		{
			if (e.id != DiscountManager.DOUBLE_MANA_NP || DrinkItemsData.getType(this.id) != PacketClient.BUY_MANA_BIG)
				return;
			if (this.imageRibbon)
				removeChild(this.imageRibbon);
			this.imageRibbon = createRibbon(MODIFY_ICON[1]['color'],"1000 -", MODIFY_ICON[1]['image']);
			addChild(this.imageRibbon);
		}

		private function onDiscountEnd(e:DiscountEvent):void
		{
			if (e.id != DiscountManager.DOUBLE_MANA_NP || DrinkItemsData.getType(this.id) != PacketClient.BUY_MANA_BIG)
				return;
			if (this.imageRibbon)
				removeChild(this.imageRibbon);
			this.imageRibbon = createRibbon(MODIFY_ICON[1]['color'],MODIFY_ICON[1]['text'], MODIFY_ICON[1]['image']);
			addChild(this.imageRibbon);
		}
	}
}