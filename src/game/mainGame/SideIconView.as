package game.mainGame
{
	import utils.starling.StarlingAdapterSprite;

	public class SideIconView extends StarlingAdapterSprite
	{
		static public const COLOR_YELLOW:int = 0;
		static public const COLOR_BLUE:int = 1;
		static public const COLOR_GREEN:int = 2;
		static public const COLOR_RED:int = 3;
		static public const COLOR_PURPLE:int = 4;
		static public const COLOR_PINK:int = 5;
		static public const COLOR_ORANGE:int = 6;

		static public const ICON_HOLLOW:int = 0;
		static public const ICON_ACORN:int = 1;
		static public const ICON_SHAMAN:int = 2;
		static public const ICON_SQUIRREL:int = 3;
		static public const ICON_HARE:int = 4;
		static public const ICON_POISE_RESPAWN:int = 5;
		static public const ICON_COLLECTION:int = 6;
		static public const ICON_DRAGON:int = 7;
		static public const ICON_WATER_SOURCE:int = 8;
		static public const ICON_CARD:int = 9;
		static public const ICON_COCKTAIL:int = 10;
		static public const ICON_GOLD_SACK:int = 11;
		static public const ICON_MEDKIT:int = 12;
		static public const ICON_SURPRISE_BOX:int = 13;
		static public const ICON_VENDIGO:int = 14;
		static public const ICON_VICTIM:int = 15;

		private var _color:int = -1;
		private var _icon:int = -1;

		private var colorSprite:StarlingAdapterSprite;
		private var iconSprite: StarlingAdapterSprite;

		public function SideIconView(color:int = -1, icon:int = -1):void
		{
			this.color = color;
			this.icon = icon;
		}

		override public function set rotation(value:Number):void
		{
			super.rotation = value;

			if (this.iconSprite)
				this.iconSprite.rotation = -value;
		}

		public function get color():int
		{
			return this._color;
		}

		public function set color(value:int):void
		{
			if (this._color == value)
				return;
			this._color = value;

			if (this.colorSprite)
				removeChildStarling(this.colorSprite);

			switch (color)
			{
				case COLOR_YELLOW:
					this.colorSprite = addChildStarling(new StarlingAdapterSprite(new YellowSideArrow));
					break;
				case COLOR_BLUE:
					this.colorSprite = addChildStarling(new StarlingAdapterSprite(new BlueSideArrow));
					break;
				case COLOR_GREEN:
					this.colorSprite = addChildStarling(new StarlingAdapterSprite(new GreenSideArrow));
					break;
				case COLOR_RED:
					this.colorSprite = addChildStarling(new StarlingAdapterSprite(new RedSideArrow));
					break;
				case COLOR_PURPLE:
					this.colorSprite = addChildStarling(new StarlingAdapterSprite(new PurpleSideArrow));
					break;
				case COLOR_PINK:
					this.colorSprite = addChildStarling(new StarlingAdapterSprite(new PinkSideArrow));
					break;
				case COLOR_ORANGE:
					this.colorSprite = addChildStarling(new StarlingAdapterSprite(new OrangeSideArrow));
					break;
			}

			if (this.iconSprite)
				this.colorSprite.addChildStarling(this.iconSprite);
		}

		public function get icon():int
		{
			return this._icon;
		}

		public function set icon(value:int):void
		{
			if (this._icon == value)
				return;

			this._icon = value;

			if (this.colorSprite && this.iconSprite)
				this.colorSprite.removeChildStarling(iconSprite);

			switch (icon)
			{
				case ICON_ACORN:
					this.iconSprite = addChildStarling(new StarlingAdapterSprite(new AcornSideIcon));
					break;
				case ICON_HOLLOW:
					this.iconSprite = addChildStarling(new StarlingAdapterSprite(new HollowSideIcon));
					break;
				case ICON_SHAMAN:
					this.iconSprite = addChildStarling(new StarlingAdapterSprite(new ShamanSideIcon));
					break;
				case ICON_SQUIRREL:
					this.iconSprite = addChildStarling(new StarlingAdapterSprite(new SquirrelSideIcon));
					break;
				case ICON_HARE:
					this.iconSprite = addChildStarling(new StarlingAdapterSprite(new HareSideIcon));
					break;
				case ICON_POISE_RESPAWN:
					this.iconSprite = addChildStarling(new StarlingAdapterSprite(new PoiseRespawnIcon));
					break;
				case ICON_COLLECTION:
					this.iconSprite = addChildStarling(new StarlingAdapterSprite(new SideCollectionIcon));
					break;
				case ICON_DRAGON:
					this.iconSprite = addChildStarling(new StarlingAdapterSprite(new DragonSideIcon));
					break;
				case ICON_WATER_SOURCE:
					this.iconSprite = addChildStarling(new StarlingAdapterSprite(new FountainSideIcon));
					break;
				case ICON_CARD:
					this.iconSprite = addChildStarling(new StarlingAdapterSprite(new CardSideIcon));
					break;
				case ICON_COCKTAIL:
					this.iconSprite = addChildStarling(new StarlingAdapterSprite(new CocktailSideIcon));
					break;
				case ICON_GOLD_SACK:
					this.iconSprite = addChildStarling(new StarlingAdapterSprite(new GoldBugSideIcon));
					break;
				case ICON_MEDKIT:
					this.iconSprite = addChildStarling(new StarlingAdapterSprite(new MedkitSideIcon));
					break;
				case ICON_SURPRISE_BOX:
					this.iconSprite = addChildStarling(new StarlingAdapterSprite(new SurpriseBoxSideIcon));
					break;
				case ICON_VENDIGO:
					this.iconSprite = addChildStarling(new StarlingAdapterSprite(new VendigoSideIcon));
					break;
				case ICON_VICTIM:
					this.iconSprite = addChildStarling(new StarlingAdapterSprite(new VictimSideIcon));
					break;
			}

			if (!this.iconSprite)
				return;

			this.colorSprite.addChildStarling(this.iconSprite);
			this.iconSprite.y = 22;
		}
	}
}