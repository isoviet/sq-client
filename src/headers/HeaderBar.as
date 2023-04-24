package headers
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import dialogs.DialogMail;
	import dialogs.clan.DialogClanCreate;
	import game.gameData.NotificationManager;
	import loaders.RuntimeLoader;
	import loaders.ScreensLoader;
	import screens.ScreenAward;
	import screens.ScreenClan;
	import screens.ScreenCollection;
	import screens.ScreenProfile;
	import screens.ScreenShamanTree;
	import screens.ScreenWardrobe;
	import sounds.GameSounds;
	import sounds.SoundConstants;
	import statuses.Status;
	import views.NotificationView;

	import com.greensock.TweenMax;

	import utils.FiltersUtil;

	public class HeaderBar extends Sprite
	{
		private var tween:TweenMax;

		private var buttonClan:SimpleButton;
		private var statusClan:Status;

		private var lock:Boolean = false;

		private var timer:Timer = new Timer(1000, 1);

		public function HeaderBar():void
		{
			super();

			init();

			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, hide);
			this.addEventListener(MouseEvent.ROLL_OVER, onOver);
			this.addEventListener(MouseEvent.ROLL_OUT, onOut);
		}

		public function update(lock:Boolean):void
		{
			this.lock = lock;
			this.lock ? show() : hideInstant();

			var openClans:Boolean = (Game.self['clan_id'] != 0);

			this.buttonClan.mouseEnabled = Experience.selfLevel >= Game.LEVEL_TO_OPEN_CLANS;
			this.buttonClan.filters = Experience.selfLevel >= Game.LEVEL_TO_OPEN_CLANS ? [] : FiltersUtil.GREY_FILTER;
			this.statusClan.setStatus(openClans ? gls("Клан") : (Experience.selfLevel >= Game.LEVEL_TO_OPEN_CLANS ? gls("Создать клан") : gls("Доступно с 7 уровня")));
		}

		public function show():void
		{
			this.visible = true;
			this.tween = TweenMax.to(this, 0.2, {'y': 60, 'alpha': 1.0});

			this.timer.stop();
		}

		public function hideInstant():void
		{
			this.visible = false;
			this.alpha = 0;
			this.y = 0;
		}

		public function hideAfterTime():void
		{
			if (this.lock)
				return;
			this.timer.reset();
			this.timer.start();
		}

		public function hide(e:TimerEvent = null):void
		{
			if (this.tween)
				tween.kill();
			this.tween = TweenMax.to(this, 0.2, {'y': 0, 'alpha': 0.0, 'onComplete': hideInstant});
		}

		private function init():void
		{
			var buttonArray:Array = [new ButtonProfileWardrobe, new ButtonProfileMail, new ButtonProfileShaman, new ButtonProfileCollection, new ButtonProfileAward, new ButtonProfileClan];
			var texts:Array = [gls("Гардероб"), gls("Почта"), gls("Навыки шамана"), gls("Коллекции"), gls("Достижения"), gls("Клан")];
			var handlers:Array = [showWardrobe, showMail, showShaman, showCollection, showAward, showClan];
			for (var i:int = 0; i < buttonArray.length; i++)
				addButton(buttonArray[i], texts[i], handlers[i], i);
		}

		private function addButton(button:SimpleButton, text:String, handler:Function, index:int):void
		{
			button.x = 52 * index + (26 - int(button.width * 0.5));
			button.y = 43 - int(button.height * 0.5);
			button.addEventListener(MouseEvent.CLICK, handler);
			addChild(button);

			var status:Status = new Status(button, text);

			if (button is ButtonProfileClan)
			{
				var sprite:Sprite = new Sprite();
				sprite.addChild(button);
				sprite.buttonMode = true;
				addChild(sprite);

				this.buttonClan = button;
				this.statusClan = new Status(sprite, text);

				status.remove();
			}

			if (button is ButtonProfileMail)
				NotificationManager.instance.register(NotificationManager.MAIL, new NotificationView(button, 30, 20));

			if (button is ButtonProfileCollection)
				NotificationManager.instance.register(NotificationManager.COLLECTION, new NotificationView(button, 20, 20));
		}

		private function showMail(e:MouseEvent):void
		{
			GameSounds.play(SoundConstants.BUTTON_CLICK, true);

			RuntimeLoader.load(function():void
			{
				DialogMail.show();
			});
		}

		private function showWardrobe(e:MouseEvent):void
		{
			GameSounds.play(SoundConstants.BUTTON_CLICK, true);
			GameSounds.play(SoundConstants.WINDOW_BIG_OPEN, true);

			ScreenProfile.setPlayerId(Game.selfId);
			ScreensLoader.load(ScreenWardrobe.instance);
		}

		private function showCollection(e:MouseEvent):void
		{
			GameSounds.play(SoundConstants.BUTTON_CLICK, true);
			GameSounds.play(SoundConstants.WINDOW_BIG_OPEN, true);

			ScreenProfile.setPlayerId(Game.selfId);
			ScreensLoader.load(ScreenCollection.instance);
		}

		private function showShaman(e:MouseEvent = null):void
		{
			GameSounds.play(SoundConstants.BUTTON_CLICK, true);
			GameSounds.play(SoundConstants.WINDOW_BIG_OPEN, true);

			ScreensLoader.load(ScreenShamanTree.instance);
		}

		private function showAward(e:MouseEvent):void
		{
			GameSounds.play(SoundConstants.BUTTON_CLICK, true);
			GameSounds.play(SoundConstants.WINDOW_BIG_OPEN, true);

			ScreensLoader.load(ScreenAward.instance);
		}

		private function showClan(e:MouseEvent):void
		{
			GameSounds.play(SoundConstants.BUTTON_CLICK, true);

			if (Experience.selfLevel < Game.LEVEL_TO_OPEN_CLANS)
				return;

			if (Game.self['clan_id'] == 0)
			{
				DialogClanCreate.show();
				return;
			}

			GameSounds.play(SoundConstants.WINDOW_BIG_OPEN, true);
			ScreenProfile.setPlayerId(Game.selfId);
			ScreensLoader.load(ScreenClan.instance);
		}

		private function onOver(e:MouseEvent):void
		{
			this.timer.stop();
		}

		private function onOut(e:MouseEvent):void
		{
			hideAfterTime();
		}
	}
}