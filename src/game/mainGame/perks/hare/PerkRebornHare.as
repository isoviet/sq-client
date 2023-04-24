package game.mainGame.perks.hare
{
	import flash.events.Event;
	import flash.ui.Keyboard;

	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.gameEditor.SquirrelGameEditor;
	import sounds.GameSounds;

	import protocol.Connection;
	import protocol.PacketClient;

	public class PerkRebornHare extends PerkHare implements IReborn
	{
		public function PerkRebornHare(hero:Hero):void
		{
			super(hero);

			this.code = Keyboard.BACKSPACE;
			this.hero.addEventListener(SquirrelEvent.DIE, onDie);
		}

		override public function update(timeStep:Number = 0):void
		{
			if (this.hero && this.hero.isHare && !this.hero.isDead && this.charge != 100)
			{
				this.charge = 100;
				dispatchEvent(new Event("STATE_CHANGED"));
			}
			if (this.hero && this.hero.isHare && this.hero.isDead && this.charge == 100 && !(this.hero.game && this.hero.game is SquirrelGameEditor))
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

			GameSounds.playUnrepeatable("hare_reborn", HareView.SOUND_PROBABILITY);
			Connection.sendData(PacketClient.ROUND_RESPAWN);
			this.charge = 100;
			dispatchEvent(new Event("STATE_CHANGED"));
		}

		private function onDie(e:SquirrelEvent):void
		{
			if (!this.hero || !this.hero.isHare)
				return;

			this.charge = 0;
		}
	}
}