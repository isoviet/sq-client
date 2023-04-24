package game.mainGame.perks.dragon.ui
{
	import flash.events.Event;

	import game.mainGame.perks.HeroPerkButton;
	import game.mainGame.perks.PerkRechargeable;
	import game.mainGame.perks.dragon.DragonPerkFactory;
	import game.mainGame.perks.dragon.PerkDragon;

	public class DragonPerkButton extends HeroPerkButton
	{
		public function DragonPerkButton(id:int):void
		{
			super(id);
		}

		override public function set hero(value:Hero):void
		{
			if (!checkHero(value))
				return;

			for each (var perk:PerkDragon in value.perkController.perksDragon)
			{
				if (perk.code != this.id)
					continue;

				this.perkInstance = perk;
				this.perkInstance.addEventListener("STATE_CHANGED", updateState);
			}
		}

		override public function get title():String
		{
			return DragonPerkFactory.perkData[DragonPerkFactory.perkCollection[this.id]]['name'];
		}

		override public function get description():String
		{
			return DragonPerkFactory.perkData[DragonPerkFactory.perkCollection[this.id]]['description'];
		}

		override public function get iconClass():Class
		{
			return DragonPerkFactory.getIconClassById(this.id);
		}

		override public function onClick(e:Event = null):void
		{
			if (!checkClick())
				return;

			this.perkInstance.hero.sendLocation((this.perkInstance as PerkRechargeable).code);
			this.perkInstance.active = true;
		}
	}
}