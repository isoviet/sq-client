package game.mainGame.perks.dragon
{
	import flash.events.Event;

	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.gameBattleNet.SquirrelGameBattleNet;
	import game.mainGame.perks.hare.IReborn;

	import protocol.Connection;
	import protocol.PacketClient;

	public class PerkRebornDragon extends PerkDragon implements IReborn
	{
		static private const ACTIVATIONS_COUNT:int = 1;

		public function PerkRebornDragon(hero:Hero):void
		{
			super(hero);

			this.code = 10;
			if (this.hero.id == Game.selfId)
				this.hero.addEventListener(SquirrelEvent.DIE, onDie);
		}

		override public function update(timeStep:Number = 0):void
		{
			if (this.hero.id != Game.selfId)
				return;

			if (this.hero && this.hero.isDragon && !this.hero.isDead && this.charge != 100)
			{
				this.charge = 100;
				dispatchEvent(new Event("STATE_CHANGED"));
			}
			if (this.hero && this.hero.isDragon && this.hero.isDead && !this.hero.inHollow && this.charge == 100 && checkActivationCount() && !this.hero.healedByDeath)
				activate();
			super.update(timeStep);
		}

		override public function get available():Boolean
		{
			return false;
		}

		override public function dispose():void
		{
			this.hero.removeEventListener(SquirrelEvent.DIE, onDie);
			super.dispose();
		}

		override protected function activate():void
		{
			super.activate();

			Connection.sendData(PacketClient.ROUND_RESPAWN);
			this.charge = 0;
			dispatchEvent(new Event("STATE_CHANGED"));
		}

		private function onDie(e:SquirrelEvent):void
		{
			if (!this.hero || !this.hero.isDragon || !checkActivationCount() || this.hero.healedByDeath)
				return;

			this.charge = 0;
		}

		private function checkActivationCount():Boolean
		{
			if (this.hero && (this.hero.game is SquirrelGameBattleNet))
				return true;

			return this.activationCount < ACTIVATIONS_COUNT;
		}
	}
}