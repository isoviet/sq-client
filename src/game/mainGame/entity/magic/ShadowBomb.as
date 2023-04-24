package game.mainGame.entity.magic
{
	import Box2D.Common.Math.b2Vec2;

	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;
	import utils.starling.particleSystem.CollectionEffects;

	public class ShadowBomb extends SheepBomb
	{
		public function ShadowBomb()
		{
			this.view = new StarlingAdapterSprite(new WitchBombView());
			this.view.scaleXY(0.5, 0.5);
			addChildStarling(this.view);

			this.viewExplode = new StarlingAdapterMovie(new WitchBombExplodeView());
			this.viewExplode.scaleXY(0.5, 0.5);
			this.viewExplode.visible = false;
			this.viewExplode.stop();
			this.viewExplode.x = -9;
			this.viewExplode.y = -17;
			addChildStarling(this.viewExplode);
		}

		override protected function doEffect():void
		{
			if (Game.selfId != this.playerId)
				return;
			try
			{
				Hero.self.magicTeleportTo(new b2Vec2(this.position.x, this.position.y));
				Hero.self.sendLocation();
			}
			catch (e:Error)
			{
				Logger.add("Error" + e.getStackTrace());
			}
		}

		override protected function get effectName():String
		{
			return CollectionEffects.EFFECT_SHADOW_BOMB;
		}
	}
}