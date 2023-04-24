package controllers
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Timer;

	import screens.Screens;

	import protocol.Connection;
	import protocol.PacketClient;

	public class ControllerHeroLocal extends ControllerHero
	{
		static private const HERO_TIME_KICK:int = 40 * 1000;
		static private const SHAMAN_TIME_KICK:int = 40 * 1000;

		static private const TIME_SEND:int = 10 * 1000;

		static private var _doKick:Boolean = false;
		static private var _instance:ControllerHeroLocal;

		private var leftDown:Boolean = false;
		private var rightDown:Boolean = false;
		private var upDown:Boolean = false;
		private var sendPackets:Boolean = false;
		private var kickTimer:Timer = new Timer(HERO_TIME_KICK, 1);
		private var sendTimer:Timer = new Timer(TIME_SEND, 1);

		private var kickDelay:Number = HERO_TIME_KICK;

		public function ControllerHeroLocal(hero:IHero, sendPackets:Boolean = true):void
		{
			_instance = this;

			Logger.add("ControllerHeroLocal.ControllerHeroLocal " + sendPackets);

			super(hero);

			this.sendPackets = sendPackets;
			this.hero.sendMove = sendPackets;

			this.hero.setController(this);

			Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey, false, 0, true);
			Game.stage.addEventListener(KeyboardEvent.KEY_UP, onKey, false, 0, true);
			Game.stage.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);

			if (!this.sendPackets)
				return;

			this.kickTimer.addEventListener(TimerEvent.TIMER, onKick, false, 0, true);
			this.kickTimer.reset();
			this.kickTimer.start();

			this.sendTimer.addEventListener(TimerEvent.TIMER, onSend, false, 0, true);
			this.sendTimer.reset();
			this.sendTimer.start();
		}

		static public function resetKickTimer():void
		{
			if (_instance)
				_instance.resetKickTimer();
		}

		static public function get doKick():Boolean
		{
			if (_instance.hero && _instance.hero.shaman)
				return true;

			return _doKick;
		}

		static public function set doKick(value:Boolean):void
		{
			if (_instance && _instance.hero && _instance.hero.shaman)
				value = true;

			_doKick = value;
		}

		override public function set active(value:Boolean):void
		{
			value = ControllerHeroLocal.doKick ? value : false;

			var newDelay:Number = (this.hero && this.hero.shaman) ? SHAMAN_TIME_KICK : HERO_TIME_KICK;

			if (this._active != value || newDelay != this.kickDelay)
			{
				this.kickDelay = newDelay;
				this.kickTimer.delay = this.kickDelay;
				this.kickTimer.reset();

				if (value)
				{
					this.kickTimer.start();
					this.sendTimer.start();
				}
				else
					this.sendTimer.stop();
			}

			super.active = value;
		}

		override public function remove():void
		{
			Logger.add("ControllerHeroLocal.remove");
			super.remove();

			Game.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKey);
			Game.stage.removeEventListener(KeyboardEvent.KEY_UP, onKey);
			Game.stage.removeEventListener(MouseEvent.CLICK, onClick);

			this.kickTimer.stop();
			this.kickTimer.removeEventListener(TimerEvent.TIMER, onKick);

			this.sendTimer.stop();
			this.sendTimer.removeEventListener(TimerEvent.TIMER, onSend);

			this.hero = null;
		}

		private function onKick(e:TimerEvent):void
		{
			CONFIG::debug{return;}
			if (!this._active || this.stoped)
				return;

			Logger.add("ControllerHeroLocal.onKick");
			Screens.showLazyDialog = true;
			Connection.sendData(PacketClient.LEAVE);
		}

		private function onSend(e:TimerEvent):void
		{
			if (!this._active)
				return;

			this.sendMove(0, false);
		}

		private function onKey(e:KeyboardEvent):void
		{
			var down:Boolean = (e.type == KeyboardEvent.KEY_DOWN);

			if (this.hero == null)
				return;

			if (Game.chat && Game.chat.hasFocus())
			{
				resetKickTimer();

				if (down)
					return;
			}

			if (!(Game.stage.focus is TextField))
				Game.stage.focus = Game.stage;

			if (e.type != KeyboardEvent.KEY_DOWN && e.type != KeyboardEvent.KEY_UP)
				return;

			switch (e.keyCode)
			{
				case Keyboard.W:
				case Keyboard.SPACE:
				case Keyboard.UP:
					if (this.upDown == down || this.stoped)
						return;
					this.upDown = down;

					sendMove(e.keyCode * (down ? 1 : -1));
					this.hero.jump(down);
					break;
				case Keyboard.A:
				case Keyboard.LEFT:
					if (this.leftDown == down || this.stoped)
						return;
					this.leftDown = down;

					sendMove(e.keyCode * (down ? 1 : -1));
					this.hero.moveLeft(down);
					break;
				case Keyboard.D:
				case Keyboard.RIGHT:
					if (this.rightDown == down || this.stoped)
						return;
					this.rightDown = down;

					sendMove(e.keyCode * (down ? 1 : -1));
					this.hero.moveRight(down);
					break;
				case Keyboard.F1:
				case Keyboard.F2:
				case Keyboard.F3:
				case Keyboard.F4:
					if (!this.hero.shaman || !down)
						return;
					sendMove(e.keyCode);
					this.hero.setEmotion(e.keyCode - 111);
					break;
			}
		}

		private function onClick(e:MouseEvent):void
		{
			resetKickTimer();
		}

		private function sendMove(keyCode:int, resetKick:Boolean = true):void
		{
			if (!this.sendPackets)
				return;

			this.hero.sendLocation(keyCode);

			resetSendTimer();

			if (resetKick)
				resetKickTimer();
		}

		private function resetKickTimer():void
		{
			this.kickTimer.reset();
			this.kickTimer.start();
		}

		private function resetSendTimer():void
		{
			this.sendTimer.reset();
			this.sendTimer.start();
		}
	}
}