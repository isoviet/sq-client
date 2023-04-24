package views
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFormat;

	import events.GameEvent;
	import game.gameData.ProduceManager;
	import screens.ScreenProfile;
	import sounds.GameSounds;
	import statuses.Status;

	import com.greensock.TweenMax;

	public class GoldenCupProfileView extends Sprite
	{
		static protected const FORMAT_TEXT:TextFormat =  new TextFormat(GameField.PLAKAT_FONT, 17, 0xFFFFFF, null, null, null, null, null, "center");

		private var buttonCupFull:SimpleButton = null;
		private var imageCupEmpty:MovieClip = null;
		private var imageCupGet:SimpleButton = null;
		private var fieldCupGet:GameField = null;

		private var status:Status = null;

		public function GoldenCupProfileView():void
		{
			super();

			init();

			ProduceManager.addEventListener(GameEvent.PRODUCE_BONUS_START, onChange);
			ProduceManager.addEventListener(GameEvent.PRODUCE_BONUS_END, onBonusTake);
			ProduceManager.addEventListener(GameEvent.PRODUCE_START, onChange);
			ProduceManager.addEventListener(GameEvent.PRODUCE_END, onChange);
			ProduceManager.addEventListener(GameEvent.PRODUCE_UPDATE, update);
			ScreenProfile.addListener(GameEvent.PROFILE_PLAYER_CHANGED, onChange);

			onChange();
			update(null);
		}

		private function update(event:GameEvent):void
		{
			this.status.setStatus("<body>" + ProduceManager.timeString(ProduceManager.GOLDEN_CUP) + "</body>");
		}

		private function onChange(event:GameEvent=null):void
		{
			if (event && event.data != null && event.data['type'] != ProduceManager.GOLDEN_CUP)
				return;
			this.buttonCupFull.visible = ProduceManager.haveBonus(ProduceManager.GOLDEN_CUP) && ScreenProfile.playerId == Game.selfId;
			this.imageCupEmpty.visible = ProduceManager.haveProducer(ProduceManager.GOLDEN_CUP) && !ProduceManager.haveBonus(ProduceManager.GOLDEN_CUP)
				&& ScreenProfile.playerId == Game.selfId;
			this.fieldCupGet.visible = this.imageCupGet.visible = this.buttonCupFull.visible;

			this.buttonMode = true;
		}

		private function onBonusTake(event:GameEvent):void
		{
			if (event.data['type'] != ProduceManager.GOLDEN_CUP)
				return;
			onChange(null);

			GameSounds.play("golden_cup_bonus");

			for (var i:int = 0; i < ProduceManager.COUNT_GOLD_IN_TIME; i++)
				showAward(ImageIconCoins, new Point(this.x + 40, this.y + 25), i * 0.1);
		}

		private function showAward(imageClass:Class, point:Point, delay:Number):void
		{
			var object:DisplayObject = new imageClass;
			object.x = point.x;
			object.y = point.y;

			TweenMax.to(object, 1.0, {'bezier': [{'x': 600, 'y': 300}, {'x': 285, 'y': 15}], 'delay': delay,
				'onStart': function():void
				{
					Game.gameSprite.addChild(object);
				},
				'onComplete': function():void
				{
					Game.gameSprite.removeChild(object);
				}});
		}

		private function init():void
		{
			this.buttonCupFull = new GoldenCupFull();
			this.buttonCupFull.addEventListener(MouseEvent.CLICK, onClick);
			addChild(this.buttonCupFull);

			this.imageCupGet = new GoldenCupGet();
			this.imageCupGet.x = 50;
			this.imageCupGet.y = 10;
			this.imageCupGet.addEventListener(MouseEvent.CLICK, onClick);
			addChild(this.imageCupGet);

			this.fieldCupGet = new GameField(gls("Забрать"), 0, 0, FORMAT_TEXT);
			this.fieldCupGet.x = 10;
			this.fieldCupGet.y = -this.fieldCupGet.height / 4;
			this.fieldCupGet.mouseEnabled = false;
			addChild(this.fieldCupGet);

			this.imageCupEmpty = new GoldenCupEmpty();
			this.imageCupEmpty.y = this.buttonCupFull.y = 20;
			addChild(this.imageCupEmpty);

			this.status = new Status(this, "", false, true);
		}

		private function onClick(event:MouseEvent):void
		{
			if (ProduceManager.haveBonus(ProduceManager.GOLDEN_CUP))
				ProduceManager.getBonus(ProduceManager.GOLDEN_CUP);
		}
	}
}