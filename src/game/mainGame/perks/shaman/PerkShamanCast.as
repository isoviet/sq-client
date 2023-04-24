package game.mainGame.perks.shaman
{
	import flash.utils.setTimeout;

	import game.mainGame.Cast;
	import game.mainGame.entity.IGameObject;

	public class PerkShamanCast extends PerkShamanActive
	{
		protected var castObject:IGameObject = null;

		public function PerkShamanCast(hero:Hero, levels:Array):void
		{
			super(hero, levels);
		}

		override public function dispose():void
		{
			if (this.hero && this.hero.game && this.hero.game.cast)
				this.hero.game.cast.forget(onCast);

			super.dispose();
		}

		override protected function activate():void
		{
			if (!this.hero || !this.hero.game || !this.hero.isSelf)
			{
				this.active = false;
				return;
			}

			super.activate();

			initCastObject();

			this.hero.game.cast.castObject = this.castObject;
			this.hero.game.cast.listen(onCast);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!this.hero || !this.hero.game || !this.hero.game.cast)
				return;

			this.hero.game.cast.forget(onCast);

			if (this.castObject == null || this.hero.game.cast.castObject != this.castObject)
				return;

			this.hero.game.cast.castObject = null;
		}

		protected function initCastObject():void
		{}

		protected function onCast(result:String):void
		{
			if (this.hero.game.cast.castObject != this.castObject)
				return;

			if (result != Cast.CAST_DROP)
				return;

			setTimeout(deactive, 0);
		}

		private function deactive():void
		{
			active = false;
		}
	}
}