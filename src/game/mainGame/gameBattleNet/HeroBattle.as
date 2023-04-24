package game.mainGame.gameBattleNet
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.utils.Timer;

	import Box2D.Dynamics.b2World;

	import game.mainGame.CastItem;
	import game.mainGame.IHealth;
	import game.mainGame.entity.EntityFactory;
	import game.mainGame.entity.battle.SpikePoise;
	import game.mainGame.events.CastEvent;
	import screens.ScreenGame;
	import statuses.Status;

	import protocol.Connection;
	import protocol.PacketClient;

	public class HeroBattle extends Hero implements IHealth
	{
		static public const MAX_HEALTH:int = 10;
		static public const SELF_INVULNERABLE_TIME:int = 250;
		static public const EXTRA_DAMAGE_TIME:int = 10000;
		static public const GOD_MODE_TIME:int = 10000;

		static public const MAX_RELOAD:int = 5;
		static public const AUTO_RELOAD_TIME:int = 2000;

		private var _health:uint;
		private var _extraDamage:Boolean = false;
		private var _godMode:Boolean = false;
		private var spriteHealth:Sprite = new Sprite();
		private var godModeIcon:GodModeActivate = new GodModeActivate();
		private var godModeView:BuffRadialView = new BuffRadialView(new GodModeImage(), 1, 0.5, gls("Неуязвимость"));
		private var extraDamageIcon:ExtraDamageImage = new ExtraDamageImage();
		private var extraDamageView:BuffRadialView = new BuffRadialView(new ExtraDamageImage(), 1, 0.5, gls("Двойной урон"));
		private var damageView:DamageView = new DamageView();

		private var timerExtraDamage:Timer = new Timer(250, EXTRA_DAMAGE_TIME / 250);
		private var timerGodMode:Timer = new Timer(250, GOD_MODE_TIME / 250);
		private var timerReload:Timer = new Timer(AUTO_RELOAD_TIME);

		private var damageDealers:Array = [];
		private var onTeamChange:Boolean = false;

		public function HeroBattle(playerId:int, world:b2World, x:int = 0, y:int = 0)
		{
			super(playerId, world, x, y);

			if (!(this.game is SquirrelGameBattleNet))
				this.team = playerId == Game.selfId ? Hero.TEAM_RED : Hero.TEAM_BLUE;

			this.jumpVelocity *= 1.45;
			this.health = 10;
			this.extraDamage = false;
			this.godMode = false;

			this.godModeIcon.visible = false;
			this.godModeIcon.y = -30;
			this.godModeIcon.filters = [new GlowFilter(0x0099FF, 1, 5, 5)];
			this.godModeIcon.alpha = 0.5;
			this.spriteHealth.addChild(this.godModeIcon);

			this.extraDamageIcon.visible = false;
			this.extraDamageIcon.alpha = 0.5;
			this.extraDamageIcon.y = -105;
			this.extraDamageIcon.x = -18;
			this.extraDamageIcon.filters = [new GlowFilter(0xFFFFFF, 1, 10, 10)];
			this.spriteHealth.addChild(this.extraDamageIcon);

			this.damageView.x = -30;
			this.damageView.y = -60;
			this.spriteHealth.addChild(this.damageView);

			this.extraDamageView.x = 650;
			this.extraDamageView.y = 50;
			new Status(this.extraDamageView, gls("Двойной урон"));

			this.godModeView.x = 650;
			this.godModeView.y = 50;
			new Status(this.godModeView, gls("Неуязвимость"));

			this.timerExtraDamage.addEventListener(TimerEvent.TIMER_COMPLETE, onExtraDamageEnd);
			this.timerExtraDamage.addEventListener(TimerEvent.TIMER, onExtraDamageTimer);
			this.timerGodMode.addEventListener(TimerEvent.TIMER_COMPLETE, onGodModeEnd);
			this.timerGodMode.addEventListener(TimerEvent.TIMER, onGodModeTimer);
			this.timerReload.addEventListener(TimerEvent.TIMER, onReload);

			this.timerReload.reset();
			this.timerReload.start();
		}

		public function get health():int
		{
			return _health;
		}

		public function set health(value:int):void
		{
			if (this.vitalityTimer.running && (value != MAX_HEALTH) && (this.game is SquirrelGameBattleNet))
				return;
			if ((value == this.health) && !this.onTeamChange)
				return;
			var isDamage:Boolean = this._health > value;
			this._health = Math.min(Math.max(value, 0), MAX_HEALTH);

			addView(this.spriteHealth, true);
			while (this.spriteHealth.numChildren > 0)
				this.spriteHealth.removeChildAt(0);
			this.spriteHealth.addChild(this.godModeIcon);
			this.spriteHealth.addChild(this.extraDamageIcon);
			this.spriteHealth.addChild(this.damageView);

			for (var i:int = 0; i < int((this.health + 1) / 2); i++)
			{
				var image:DisplayObject;
				if ((this.health - i * 2) == 1)
					image = this.heroView.team == Hero.TEAM_RED ? new HitPointRedHalf() : new HitPointBlueHalf();
				else
					image = this.heroView.team == Hero.TEAM_RED ? new HitPointRed() : new HitPointBlue();
				image.y = -70;
				image.x = -6 * (int(this.health / 2) - 1) + 12 * i;
				this.spriteHealth.addChild(image);
			}
			this.onTeamChange = false;

			if (isDamage)
				this.damageView.play();
		}

		public function get extraDamage():Boolean
		{
			return this._extraDamage;
		}

		public function set extraDamage(value:Boolean):void
		{
			this._extraDamage = value;
			this.extraDamageIcon.visible = value;

			if (!this._extraDamage)
			{
				if (this.extraDamageView.parent != null)
					this.extraDamageView.parent.removeChild(this.extraDamageView);
				this.timerExtraDamage.stop();
				return;
			}

			if (this.id == Game.selfId)
			{
				this.godModeView.x = this.godModeView.parent != null ? 800 : 840;
				this.extraDamageView.x = 840;
				this.extraDamageView.update(0);
				this.stage.addChild(this.extraDamageView);
			}
			this.timerExtraDamage.reset();
			this.timerExtraDamage.start();
		}

		public function get godMode():Boolean
		{
			return this._godMode;
		}

		public function set godMode(value:Boolean):void
		{
			this._godMode = value;
			this.godModeIcon.visible = value;

			if (!this._godMode)
			{
				if (this.godModeView.parent != null)
					this.godModeView.parent.removeChild(this.godModeView);
				this.timerGodMode.stop();
				return;
			}

			if (this.id == Game.selfId)
			{
				this.extraDamageView.x = this.extraDamageView.parent != null ? 800 : 840;
				this.godModeView.x = 840;
				this.godModeView.update(0);
				this.stage.addChild(this.godModeView);
			}
			this.timerGodMode.reset();
			this.timerGodMode.start();
		}

		public function assist(playerId:int, damage:int):void
		{
			if (damage == 0)
				return;
			this.damageDealers.unshift({'player': playerId, 'damage': damage});
			var total:int = MAX_HEALTH - this.health;
			for (var i:int = 0; i < this.damageDealers.length; i++)
			{
				total -= this.damageDealers[i]['damage'];
				if (total <= 0)
				{
					this.damageDealers[i]['damage'] += total;
					this.damageDealers.splice(i + 1);
					break;
				}
			}
		}

		public function get isAssist():Boolean
		{
			for (var i:int = 0; i < this.damageDealers.length; i++)
				if (this.damageDealers[i]['player'] == Game.selfId)
					return true;
			return false;
		}

		private function onReload(e:TimerEvent):void
		{
			if (!(this.game is SquirrelGameBattleNet))
				return;
			if (isDead)
				return;

			var spikeItem:CastItem = this.castItems.getItem(SpikePoise, CastItem.TYPE_ROUND);
			if ((spikeItem != null) && (spikeItem.count >= MAX_RELOAD))
				return;

			this.castItems.add(new CastItem(SpikePoise, CastItem.TYPE_ROUND, 1));
			var item:CastItem = this.castItems.getItem(EntityFactory.getEntity(EntityFactory.getId(this.game.cast.castObject)), CastItem.TYPE_ROUND);
			if (item == null)
				return;
			if (this.game.cast.castObject == null || item.count == 0)
				this.game.cast.onObjectSelect(new CastEvent(CastEvent.SELECT, SpikePoise));
		}

		private function onExtraDamageEnd(e:TimerEvent):void
		{
			this.extraDamage = false;
		}

		private function onExtraDamageTimer(e:TimerEvent):void
		{
			this.extraDamageView.update(int(this.timerExtraDamage.currentCount / this.timerExtraDamage.repeatCount * 100));
		}

		private function onGodModeEnd(e:TimerEvent):void
		{
			this.godMode = false;
		}

		private function onGodModeTimer(e:TimerEvent):void
		{
			this.godModeView.update(int(this.timerGodMode.currentCount / this.timerGodMode.repeatCount * 100));
		}

		override public function remove():void
		{
			super.remove();

			if (this.extraDamageView.parent != null)
				this.extraDamageView.parent.removeChild(this.extraDamageView);
			if (this.godModeView.parent != null)
				this.godModeView.parent.removeChild(this.godModeView);

			this.timerExtraDamage.stop();
			this.timerGodMode.stop();
			this.timerReload.stop();
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			this.spriteHealth.scaleX = this.scale > 0 ? 1 : -1;
		}

		override public function set team(value:int):void
		{
			this._team = value;

			var selfTeam:int = Hero.TEAM_BLUE;
			if (Hero.self)
				selfTeam = value == Hero.self.team ? Hero.TEAM_BLUE : Hero.TEAM_RED;

			if (ScreenGame.cheaterId != 0)
				selfTeam = value;

			this.onTeamChange = this.heroView.team != selfTeam;
			this.heroView.team = selfTeam;
			this.health = this.health;
		}

		override public function sendLocation(keyCode:int = 0):void
		{
			if (this.id != Game.selfId || this.isDead || this.inHollow || !this.sendMove)
				return;

			Connection.sendData(PacketClient.ROUND_HERO, keyCode, this.position.x, this.position.y, this.velocity.x, this.velocity.y, this.health);
		}

		override public function reset():void
		{
			super.reset();

			this.onTeamChange = true;
			this.health = 10;
			this.extraDamage = false;
			this.godMode = false;
			this.damageDealers.splice(0);

			if (!(this.game is SquirrelGameBattleNet))
			{
				this.team = this.id == Game.selfId ? Hero.TEAM_RED : Hero.TEAM_BLUE;
				this.health = this.id == Game.selfId ? 8 : 2;
			}
		}

		override public function respawn(withAnimation:int = RESPAWN_NONE):void
		{
			super.respawn(withAnimation);

			this.onTeamChange = true;
			this.health = 10;
			this.extraDamage = false;
			this.godMode = false;
			this.damageDealers.splice(0);
		}
	}
}