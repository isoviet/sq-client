package game.mainGame.perks.shaman
{
	import flash.display.SimpleButton;

	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.gameBattleNet.BuffRadialView;
	import game.mainGame.gameSchool.SquirrelGameSchool;
	import game.mainGame.perks.PerkOld;
	import screens.ScreenGame;

	public class PerkShaman extends PerkOld
	{
		static public const MAX_PAID_PERK_LEVEL:int = 3;

		public var levelFree:int;
		public var levelPaid:int;

		public var code:int = 0;

		protected var buff:BuffRadialView = null;

		public function PerkShaman(hero:Hero, levels:Array):void
		{
			super(hero);

			this.levelFree = levels[0];
			this.levelPaid = levels[1];

			this.hero.addEventListener(SquirrelEvent.SHAMAN, onShaman);
		}

		static public function getBonus(levelFree:int, levelPaid:int, bonuses:Object):Number
		{
			var bonus:Number = 0;

			for (var i:int = 0; i < levelFree; i++)
				bonus += bonuses['free'][i];

			for (i = 0; i < levelPaid; i++)
				bonus += bonuses['paid'][i];

			return bonus;
		}

		override public function get available():Boolean
		{
			return super.available && this.hero.shaman && (ScreenGame.mode != Locations.BLACK_SHAMAN_MODE) && !(this.hero.game is SquirrelGameSchool);
		}

		override public function dispose():void
		{
			if (this.hero)
				this.hero.removeEventListener(SquirrelEvent.SHAMAN, onShaman);

			super.dispose();
		}

		public function get isMaxLevel():Boolean
		{
			return this.levelPaid == MAX_PAID_PERK_LEVEL;
		}

		protected function onShaman(e:SquirrelEvent):void
		{}

		protected function countBonus():Number
		{
			return getBonus(this.levelFree, this.levelPaid, PerkShamanFactory.perkData[(this as Object).constructor as Class]['bonuses']);
		}

		protected function countExtraBonus():Number
		{
			return getBonus(this.levelFree, this.levelPaid, PerkShamanFactory.perkData[(this as Object).constructor as Class]['extraBonuses']);
		}

		protected function createBuff(alpha:Number):BuffRadialView
		{
			var description:String = "<b/>" + PerkShamanFactory.perkData[PerkShamanFactory.getClassById(this.code)]['name'] + "</b>";

			if (this.hero.isSelf)
				description += ((this is PerkShamanActive) ? "" : ("<br/>" + PerkShamanFactory.getDescriptionById(this.code, PerkShamanFactory.TOTAL_BONUS_DESCRIPTION, [this.levelFree, this.levelPaid])));
			else
				description += ("<br/>" + PerkShamanFactory.getDescriptionById(this.code, PerkShamanFactory.BUFF_DESCRIPTION, [this.levelFree, this.levelPaid]));

			return new BuffRadialView((new PerkShamanFactory.perkData[PerkShamanFactory.getClassById(this.code)]['buttonClass'] as SimpleButton).upState, 0.7, alpha, description);
		}
	}
}