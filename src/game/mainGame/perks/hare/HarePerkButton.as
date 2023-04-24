package game.mainGame.perks.hare
{
	import flash.events.Event;

	import game.mainGame.perks.HeroPerkButton;
	import game.mainGame.perks.PerkRechargeable;
	import screens.ScreenEdit;
	import screens.Screens;

	public class HarePerkButton extends HeroPerkButton
	{
		public function HarePerkButton(id:int):void
		{
			super(id);
		}

		override public function set hero(value:Hero):void
		{
			if (!checkHero(value))
				return;

			for each (var perk:PerkHare in value.perkController.perksHare)
			{
				if (perk.code != this.id)
					continue;

				this.perkInstance = perk;
				this.perkInstance.addEventListener("STATE_CHANGED", updateState);

				if (Screens.active is ScreenEdit)
					this.gray = this.perkInstance is PerkRebornHare ? this.gray : false;
			}
		}

		override public function get title():String
		{
			return HarePerkFactory.perkData[HarePerkFactory.perkCollection[this.id]]['name'];
		}

		override public function get description():String
		{
			return HarePerkFactory.perkData[HarePerkFactory.perkCollection[this.id]]['description'];
		}

		override public function get iconClass():Class
		{
			return HarePerkFactory.getIconClassById(this.id);
		}

		override public function onClick(e:Event = null):void
		{
			if (!checkClick())
				return;

			this.perkInstance.hero.sendLocation((this.perkInstance as PerkRechargeable).code * (this.perkInstance.active ? 1 : 1));
			this.perkInstance.active = !this.perkInstance.active;
		}
	}
}