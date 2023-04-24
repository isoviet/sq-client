package game.mainGame.perks
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	import game.mainGame.IUpdate;
	import sounds.GameSounds;

	import interfaces.IDispose;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;

	import utils.InstanceCounter;

	public class Perk extends EventDispatcher implements IUpdate, IDispose
	{
		static public const CHANGE_STATE:String = "STATE_CHANGED";

		protected var lastAvalibleState:Boolean = true;
		protected var _active:Boolean = false;
		protected var activateSound:String = "magic";
		protected var soundOnlyHimself:Boolean = false;

		public var currentCooldown:Number = 0;
		public var currentActiveTime:Number = 0;

		public var isBlock:Boolean = false;
		public var activationCount:int = 0;
		public var hero:Hero;
		public var code:int = 0;
		public var isSent:Boolean = false;

		public static var dispatcher:EventDispatcher = new EventDispatcher();

		public function Perk(hero:Hero):void
		{
			InstanceCounter.onCreate(this);
			this.hero = hero;

			Connection.listen(onPacket, packets, 1);
		}

		public function onUse():void
		{
			this.isSent = true;
			Connection.sendData(PacketClient.ROUND_SKILL, this.code, !this.active, this.target, this.json);
		}

		public function get isSelf():Boolean
		{
			return this.hero && (this.hero.id == Game.selfId);
		}

		public function get switchable():Boolean
		{
			return false;
		}

		public function get canTurnOff():Boolean
		{
			return true;
		}

		public function get active():Boolean
		{
			return this._active;
		}

		public function get available():Boolean
		{
			if (!this.hero)
				return false;
			var canOn:Boolean = this.currentCooldown == 0 && this.activationCount < this.maxCountUse && this.hero.perksAvailable;
			var canOff:Boolean = this.switchable && this.canTurnOff;
			return this.heroAlive && (this.active ? canOff : canOn);
		}

		public function set active(value:Boolean):void
		{
			if (this._active == value)
				return;

			this._active = value;

			if (value)
				activate();
			else
				deactivate();
		}

		public function update(timeStep:Number = 0):void
		{
			if (!this.isSelf)
				return;
			if (this.currentCooldown > 0)
				this.currentCooldown = Math.max(0, this.currentCooldown - timeStep);

			if (this.currentActiveTime > 0)
			{
				this.currentActiveTime -= timeStep;
				if (this.currentActiveTime <= 0)
					onComplete();
			}

			if (this.lastAvalibleState != this.available || (this.currentCooldown > 0))
				updatePerkButton();
			this.lastAvalibleState = this.available;
		}

		public function dispose():void
		{
			this.active = false;

			InstanceCounter.onDispose(this);
			this.hero = null;

			Connection.forget(onPacket, packets);

			updatePerkButton();
		}

		public function resetRound():void
		{
			this.active = false;

			this.isBlock = false;
			this.activationCount = 0;
			this.currentCooldown = this.startCooldown;
		}

		public function get maxCountUse():int
		{
			return int.MAX_VALUE;
		}

		public function get haveUseCount():Boolean
		{
			return this.activationCount < this.maxCountUse;
		}

		public function get activeTime():Number
		{
			return 0;
		}

		public function get totalCooldown():Number
		{
			return 0;
		}

		public function get startCooldown():Number
		{
			return 0;
		}

		public function get target():int
		{
			return 0;
		}

		public function get json():String
		{
			return "";
		}

		protected function onComplete():void
		{
			this.active = false;

			Connection.sendData(PacketClient.ROUND_SKILL, this.code, PacketServer.SKILL_DEACTIVATE, 0, "");
		}

		protected function get isEndGame():Boolean
		{
			return this.hero == null || this.hero.game == null;
		}

		protected function get packets():Array
		{
			return [];
		}

		protected function activate():void
		{
			Logger.add("Perk.activate " + this + " " + hero.id);

			var self:Boolean = this.hero && this.hero.id == Game.selfId;
			if (this.activateSound != "" && ((this.soundOnlyHimself && self) || !this.soundOnlyHimself))
				GameSounds.play(this.activateSound);

			if (this.switchable)
			{
				this.currentActiveTime = this.activeTime;
				updatePerkButton();
			}
			else
				this.active = false;
		}

		protected function deactivate():void
		{
			this.activationCount++;
			this.currentCooldown = this.totalCooldown;
			this.currentActiveTime = 0;

			updatePerkButton();
		}

		protected function onPacket(packet:AbstractServerPacket):void
		{}

		private function get heroAlive():Boolean
		{
			return this.hero && !this.hero.isDead && !this.hero.inHollow && !this.hero.hover && !this.hero.game.paused;
		}

		private function updatePerkButton():void
		{
			if (!this.hero || this.hero.id != Game.selfId)
				return;
			dispatcher.dispatchEvent(new Event(CHANGE_STATE));
			dispatchEvent(new Event(CHANGE_STATE));
		}
	}
}