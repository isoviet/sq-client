package landing.game.mainGame.gameLending
{
	import com.greensock.easing.Back;
	import com.greensock.TweenMax;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;

	import events.MovieClipPlayCompleteEvent;
	import events.RescueEvent;

	import landing.game.mainGame.Cast;
	import landing.game.mainGame.entity.simple.BalkCage;
	import landing.game.mainGame.GameMap;
	import landing.game.mainGame.SquirrelGame;


	public class SquirrelGameLending extends SquirrelGame
	{
		private var player:wHero;

		private var messageBackgroundSprite:Sprite;
		private var messageField:GameField;

		private var cageImage:CageImage;

		private var rescued:Boolean = false;
		private var owner:DisplayObject;

		private var buttonTimer:Timer = new Timer(500);

		private var goGameButton:GoGameButton;

		public function SquirrelGameLending():void
		{
			this.map = new GameMap(this);
			this.cast = new Cast(this);
			this.squirrels = new SquirrelCollectionLending(this);

			super();

			init();
		}
d
		private function init():void
		{
			var hostage1:wSpriteHero = new wSpriteHero();
			hostage1.x = 78;
			hostage1.y = 250;
			hostage1.dressItem(0);
			addChild(hostage1);

			var hostage2:wSpriteHero = new wSpriteHero();
			hostage2.x = 133;
			hostage2.y = 250;
			hostage2.dressItem(1);
			addChild(hostage2);

			var hintFormat:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 12, 0x000000, true);

			addChild(new GameField("Управление белкой:", 408, 14, new TextFormat(GameField.DEFAULT_FONT, 12, 0xEFF721, true)));
			addChild(new GameField("Прыжок", 446, 58, hintFormat));
			addChild(new GameField("Бег", 459, 102, hintFormat));

			var logoImage:SquirrelsLogoImage = new SquirrelsLogoImage();
			logoImage.buttonMode = true;
			logoImage.addEventListener(MouseEvent.CLICK, goToGame);
			logoImage.x = 17;
			logoImage.y = 13;
			addChild(logoImage);

			this.goGameButton = new GoGameButton();
			this.goGameButton.x = 441;
			this.goGameButton.y = 370;
			this.goGameButton.addEventListener(MouseEvent.CLICK, goToGame);
			addChild(this.goGameButton);

			this.messageBackgroundSprite = new Sprite();
			this.messageBackgroundSprite.graphics.clear();
			this.messageBackgroundSprite.graphics.lineStyle(2, 0xFFFFFF);
			this.messageBackgroundSprite.graphics.beginFill(0xED8F38);
			this.messageBackgroundSprite.graphics.drawRoundRectComplex(0, 0, 248, 52, 5, 5, 5, 5);
			this.messageBackgroundSprite.graphics.endFill();
			this.messageBackgroundSprite.x = 200;
			this.messageBackgroundSprite.y = 306;
			addChild(this.messageBackgroundSprite);

			var messageFormat:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 15, 0xFFFFFF, true);
			messageFormat.align = TextFormatAlign.CENTER;

			this.messageField = new GameField("ВЫБИРАЙ,\n орехи или спасение белок", 200, 313, messageFormat);
			this.messageField.width = 248;
			this.messageField.autoSize = TextFieldAutoSize.CENTER;
			addChild(this.messageField);

			var mapString:String = "[0,[[48,[[10.6,18.5],0,false]],[14,[[11.4,26.8],0,false,[-1]]],[14,[[32,22.3],0,false,[-1]]],[2,[[53.1,22.5],0,false]],[17,[53.1,22.5]],[10,[32.5,18.3]],[12,[[52.4,20.7],0,false]]],[]]";

			this.map.deserialize(mapString);
			this.simulate = true;

			this.squirrels.add(WallShadow.SELF_ID);
			this.squirrels.add(2);
			this.squirrels.reset();
			this.squirrels.place();
			this.squirrels.get(2).setClothing([2]);
			this.squirrels.get(2).setPosition(109, 181);
			this.squirrels.addEventListener(MovieClipPlayCompleteEvent.DEATH, onDeath, false, 0, true);
			this.squirrels.show();

			addChild(this.squirrels);

			this.cageImage = new CageImage();
			this.cageImage.x = 50;
			this.cageImage.y = 118;
			addChild(this.cageImage);

			addEventListener(Event.ENTER_FRAME, checkRescue);
			addEventListener(RescueEvent.RESCUE, onRescued);

			WallShadow.stage.focus = this;
		}

		
		private function checkRescue(e:Event):void
		{
			if (!this.rescued)
			{
				var playerPosition:Point = this.squirrels.self.getPosition();
				if ((playerPosition.x < 134) || (playerPosition.x < 161 && playerPosition.y > 187))
				{
					dispatchEvent(new RescueEvent(RescueEvent.RESCUE));
					this.rescued = true;
				}
			}
		}

		private function onRescued(e:RescueEvent):void
		{
			removeEventListener(RescueEvent.RESCUE, onRescued);

			var balkCage:BalkCage;
			balkCage = this.map.get(BalkCage)[0];
			this.map.remove(balkCage);
			balkCage.dispose();

			this.squirrels.self.casting = true;

			var timerDance:Timer = new Timer(1000);
			timerDance.addEventListener(TimerEvent.TIMER, onDance);
			timerDance.reset();
			timerDance.start();

			TweenMax.to(this.cageImage, 0.7, { 'y': 412, ease:Back.easeIn, 'onComplete': goToGame} );

			this.messageBackgroundSprite.graphics.clear();
			this.messageBackgroundSprite.graphics.lineStyle(2, 0xFFFFFF);
			this.messageBackgroundSprite.graphics.beginFill(0xED8F38);
			this.messageBackgroundSprite.graphics.drawRoundRectComplex(0, 0, 310, 37, 5, 5, 5, 5);
			this.messageBackgroundSprite.graphics.endFill();
			this.messageBackgroundSprite.x = 169;

			this.messageField.text = "Твое племя ждет тебя, Избранный!"
			this.messageField.y = 313;
		}

		private function onDance(e:TimerEvent):void
		{
			if (e.currentTarget.currentCount % 2 == 0)
			{
				this.squirrels.self.turnLeft();
				return;
			}

			this.squirrels.self.turnRight();
		}

		private function onDeath(e:MovieClipPlayCompleteEvent):void
		{
			removeEventListener(Event.ENTER_FRAME, checkRescue);

			this.messageBackgroundSprite.graphics.clear();
			this.messageBackgroundSprite.graphics.lineStyle(2, 0xFFFFFF);
			this.messageBackgroundSprite.graphics.beginFill(0xED8F38);
			this.messageBackgroundSprite.graphics.drawRoundRectComplex(0, 0, 283, 37, 5, 5, 5, 5);
			this.messageBackgroundSprite.graphics.endFill();
			this.messageBackgroundSprite.x = 185;
			this.messageBackgroundSprite.y = 310;

			this.messageField.text = "Воскреси свою Белку в игре!"
			this.messageField.y = 317;

			goToGame();
		}

		private function goToGame(e:Event = null):void
		{
			activateButton();

			var request:URLRequest = new URLRequest(WallConfig.APPLICATION_URL);
			navigateToURL(request, "_blank");
		}

		private function activateButton():void
		{
			this.buttonTimer.addEventListener(TimerEvent.TIMER, resizeButton);

			this.buttonTimer.reset();
			this.buttonTimer.start();
		}

		private function resizeButton(e:TimerEvent):void
		{
			var dialogX:Number = this.goGameButton.x;
			var dialogY:Number = this.goGameButton.y;

			var button:DisplayObject = this.goGameButton;

			TweenMax.to(button, 0.2, { 'scaleX': 1.1, 'scaleY': 1.1, 'x':dialogX - button.width  * 0.1 / 2, 'y':dialogY - button.height  * 0.1 / 2,  'onComplete':function():void
			{
					TweenMax.to(button, 0.2, { 'scaleX': 1, 'scaleY': 1 , 'x':dialogX , 'y':dialogY } );
			}} );
		}
	}
}