package views
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import dialogs.DialogShop;
	import events.GameEvent;
	import events.ScreenEvent;
	import game.gameData.PowerManager;
	import game.gameData.VIPManager;
	import loaders.RuntimeLoader;
	import screens.ScreenGame;
	import screens.Screens;
	import sounds.GameSounds;
	import sounds.SoundConstants;
	import statuses.StatusPowers;

	import com.greensock.TweenMax;

	public class PowerBarsView extends Sprite
	{
		private var statusPowers:StatusPowers;
		private var powersSprite:Sprite;

		private var glowTween:TweenMax = null;
		private var stopGlowTimer:Timer = new Timer(15 * 1000, 1);

		private var playerExpirience:ExperienceView;

		public function PowerBarsView():void
		{
			this.visible = false;

			init();

			Experience.addEventListener(GameEvent.EXPERIENCE_CHANGED, onExperience);
			PowerManager.addEventListener(GameEvent.ENERGY_CHANGED, onEnergy);
			Screens.instance.addEventListener(ScreenEvent.SHOW, onScreenChanged);
			VIPManager.addEventListener(GameEvent.VIP_START, onVIP);
			VIPManager.addEventListener(GameEvent.VIP_END, onVIP);
		}

		private function init():void
		{
			this.powersSprite = new Sprite();
			addChild(this.powersSprite);

			var backgroundPower:PowerBarBackground = new PowerBarBackground();
			backgroundPower.cacheAsBitmap = true;
			this.powersSprite.addChild(backgroundPower);
			addEventListener(MouseEvent.CLICK, onShowShopPotion);

			var energy:EnergyView = new EnergyView();
			energy.x = 31;
			energy.y = 10;
			this.powersSprite.addChild(energy);

			var mana:ManaView = new ManaView();
			mana.x = energy.x;
			mana.y = 17;
			this.powersSprite.addChild(mana);

			this.playerExpirience = new ExperienceView();
			this.playerExpirience.x = mana.x;
			this.playerExpirience.y = 24;
			this.powersSprite.addChild(this.playerExpirience);

			this.statusPowers = new StatusPowers(this.powersSprite);

			this.stopGlowTimer.addEventListener(TimerEvent.TIMER_COMPLETE, stopGlow);
			this.playerExpirience.double = VIPManager.haveVIP;
		}

		private function onShowShopPotion(event:MouseEvent):void
		{
			GameSounds.play(SoundConstants.BUTTON_CLICK);

			RuntimeLoader.load(function():void
			{
				DialogShop.selectTape(DialogShop.OTHER, true);
			});
		}

		private function onExperience(e:GameEvent):void
		{
			this.playerExpirience.updateData();
		}

		private function onEnergy(e:GameEvent):void
		{
			if (e.data['value'] > 29)
			{
				if (this.glowTween != null)
				{
					this.glowTween.kill();
					this.glowTween = null;
					this.powersSprite.filters = [];
				}
				return;
			}

			if (!(Screens.active is ScreenGame))
				return;

			if (this.glowTween != null)
				return;

			this.startGlowAnimation();
		}

		private function stopGlow(e:TimerEvent):void
		{
			if (this.glowTween == null)
				return;

			this.glowTween.kill();
			this.glowTween = null;
			this.powersSprite.filters = [];
		}

		private function startGlowAnimation():void
		{
			this.glowTween = TweenMax.to(this.powersSprite, 1, {'glowFilter': {'color': 0xffcc00, 'alpha': 1, 'blurX': 8, 'blurY': 8, 'strength': 1.8}, 'onComplete': function():void
			{
				glowTween = TweenMax.to(powersSprite, 1.3, {'glowFilter': {'color': 0xffcc00, 'alpha': 0, 'blurX': 0, 'blurY': 0, 'strength': 0}, 'onComplete': function():void
				{
					startGlowAnimation();
				}});
			}});
		}

		private function onScreenChanged(e:ScreenEvent):void
		{
			if ((this.glowTween == null) || (this.glowTween != null && this.stopGlowTimer.running))
				return;

			this.stopGlowTimer.reset();
			this.stopGlowTimer.start();
		}

		private function onVIP(e:GameEvent):void
		{
			this.playerExpirience.double = VIPManager.haveVIP;
		}
	}
}