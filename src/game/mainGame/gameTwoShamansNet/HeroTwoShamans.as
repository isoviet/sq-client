package game.mainGame.gameTwoShamansNet
{
	import flash.utils.setTimeout;

	import Box2D.Dynamics.b2World;

	import game.mainGame.entity.editor.RedShamanBody;
	import game.mainGame.entity.editor.ShamanBody;

	public class HeroTwoShamans extends Hero
	{
		public function HeroTwoShamans(playerId:int, world:b2World, x:int = 0, y:int = 0):void
		{
			super(playerId, world, x, y);
		}

		override public function set dead(value:Boolean):void
		{
			if (value && this.shaman)
			{
				setTimeout(teleportShaman, 0);
				return;
			}
			super.dead = value;
		}

		override public function set shaman(value:Boolean):void
		{
			if (this.shaman == value)
				return;
			teleportShaman();

			if (!value)
				this.team = TEAM_NONE;

			super.shaman = value;
		}

		private function teleportShaman():void
		{
			switch (this.team)
			{
				case Hero.TEAM_BLUE:
					this.teleportTo(this.game.map.get(ShamanBody).length > 0 ? this.game.map.get(ShamanBody)[0].position : null);
					break;
				case Hero.TEAM_RED:
					this.teleportTo(this.game.map.get(RedShamanBody).length > 0 ? this.game.map.get(RedShamanBody)[0].position : null);
					break;
			}
		}
	}
}