package game.mainGame.perks
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	import game.mainGame.IUpdate;
	import sounds.GameSounds;

	import interfaces.IDispose;

	import protocol.Connection;
	import protocol.packages.server.AbstractServerPacket;

	import utils.InstanceCounter;

	public class PerkOld extends EventDispatcher implements IUpdate, IDispose
	{
		static public const CHANGE_STATE:String = "STATE_CHANGED";

		protected var lastAvalibleState:Boolean = true;
		protected var _active:Boolean = false;
		protected var activateSound:String = "magic";

		public var activationCount:int = 0;
		public var hero:Hero;

		public static var dispatcher:EventDispatcher = new EventDispatcher();

		public function PerkOld(hero:Hero):void
		{
			InstanceCounter.onCreate(this);
			this.hero = hero;

			reset();

			Connection.listen(onPacket, packets, 1);
		}

		public function get active():Boolean
		{
			return this._active;
		}

		public function get available():Boolean
		{
			return this.heroAlive && this.hero && this.hero.perksAvailable;
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
			if (this.lastAvalibleState != heroAlive)
				updatePerkButton();

			this.lastAvalibleState = heroAlive;
		}

		public function dispose():void
		{
			InstanceCounter.onDispose(this);
			this.hero = null;

			Connection.forget(onPacket, packets);

			updatePerkButton();
		}

		public function resetRound():void
		{
			reset();

			this.activationCount = 0;
		}

		public function reset():void
		{
			this.active = false;

			updatePerkButton();
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
			this.activationCount++;
			Logger.add("Perk.activate " + this + " " + hero.id);

			if (this.activateSound != "")
				GameSounds.play(this.activateSound);

			updatePerkButton();
		}

		protected function deactivate():void
		{
			updatePerkButton();
		}

		protected function onPacket(packet:AbstractServerPacket):void
		{}

		private function get heroAlive():Boolean
		{
			return this.hero && !this.hero.isDead && !this.hero.inHollow && !this.hero.hover;
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