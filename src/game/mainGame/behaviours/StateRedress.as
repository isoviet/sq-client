package game.mainGame.behaviours
{
	import game.mainGame.perks.clothes.ITransformation;

	import protocol.Connection;
	import protocol.PacketClient;

	public class StateRedress extends HeroState
	{
		protected var packages:Array = null;
		protected var blockMagic:Boolean = false;

		public function StateRedress(time:Number, packages:Array, blockMagic:Boolean)
		{
			super(time);

			this.packages = packages;
			this.blockMagic = blockMagic;
		}

		override public function set hero(value:Hero):void
		{
			if (value == null && this.hero != null)
			{
				this.hero.heroView.setClothing(this.hero.player['weared_packages'], this.hero.player['weared_accessories']);
				if (this.blockMagic)
				{
					for (var i:int = 0; i < this.hero.perkController.perksClothes.length; i++)
						this.hero.perkController.perksClothes[i].isBlock = false;
				}
			}
			else
			{
				value.heroView.setClothing(this.packages);
				if (this.blockMagic)
				{
					for (i = 0; i < value.perkController.perksClothes.length; i++)
					{
						value.perkController.perksClothes[i].isBlock = true;
						if (!(value.perkController.perksClothes[i] is ITransformation) || !value.perkController.perksClothes[i].active)
							continue;
						value.perkController.perksClothes[i].active = false;
						Connection.sendData(PacketClient.ROUND_SKILL, value.perkController.perksClothes[i].code, 0, 0, "");
					}
				}
			}
			super.hero = value;
		}
	}
}