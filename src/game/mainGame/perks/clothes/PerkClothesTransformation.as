package game.mainGame.perks.clothes
{
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import protocol.Connection;
	import protocol.PacketClient;

	import utils.Animation;

	public class PerkClothesTransformation extends PerkClothes implements ITransformation
	{
		protected var animation:Class = null;

		public function PerkClothesTransformation(hero:Hero):void
		{
			super(hero);
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get canTurnOff():Boolean
		{
			return false;
		}

		override public function dispose():void
		{
			super.dispose();

			Game.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKey);
			Game.stage.removeEventListener(KeyboardEvent.KEY_UP, onKey);
		}

		override public function get available():Boolean
		{
			return super.available && !(this.hero.heroView.running) && !this.active;
		}

		override protected function activate():void
		{
			super.activate();
			var perkSprite:Sprite = new Sprite();
			var view:Animation = new Animation(new animation());
			view.play();
			view.x = -int(view.width / 2);
			view.y = - view.height;
			perkSprite.addChild(view);
			this.hero.changeView(perkSprite);

			this.hero.heroView.playerNameSprite.visible = false;

			if (this.hero.id != Game.selfId)
				return;

			Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey, false, 0, true);
			Game.stage.addEventListener(KeyboardEvent.KEY_UP, onKey, false, 0, true);
		}

		override protected function deactivate():void
		{
			super.deactivate();
			this.hero.changeView();

			this.hero.heroView.playerNameSprite.visible = true;

			Game.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKey);
			Game.stage.removeEventListener(KeyboardEvent.KEY_UP, onKey);
		}

		private function onKey(e:KeyboardEvent):void
		{
			if (Game.chat.hasFocus())
				return;

			switch (e.keyCode)
			{
				case Keyboard.W:
				case Keyboard.SPACE:
				case Keyboard.UP:
				case Keyboard.A:
				case Keyboard.LEFT:
				case Keyboard.D:
				case Keyboard.RIGHT:
					this.active = false;
					Connection.sendData(PacketClient.ROUND_SKILL, code, false, 0, "");
					break;
			}
		}
	}
}