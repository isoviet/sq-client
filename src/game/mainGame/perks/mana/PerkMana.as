package game.mainGame.perks.mana
{
	import flash.display.SimpleButton;

	import footers.FooterGame;
	import game.mainGame.perks.Perk;
	import screens.ScreenEdit;
	import screens.ScreenGame;
	import screens.ScreenSchool;
	import screens.Screens;

	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundSkill;

	public class PerkMana extends Perk
	{
		static private const ICON_SHOW_DELAY:int = 3 * 1000;

		protected var delay:int;

		public function PerkMana(hero:Hero):void
		{
			super(hero);
			this.delay = ICON_SHOW_DELAY;
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get available():Boolean
		{
			var screenAvalible:Boolean = Screens.active is ScreenGame || (Screens.active is ScreenSchool && (this.code in ScreenSchool.allowedPerks)) || (Screens.active is ScreenEdit && (this.code in ScreenEdit.allowedPerks));

			return super.available && !this.hero.isHare && screenAvalible;
		}

		override protected function activate():void
		{
			super.activate();

			var perkButtonClass:Class = PerkFactory.getImageClass(this.code);
			this.hero.heroView.showPerkAnimation(new perkButtonClass() as SimpleButton, this.delay);
		}

		override protected function get packets():Array
		{
			return [PacketRoundSkill.PACKET_ID];
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			var skill:PacketRoundSkill = packet as PacketRoundSkill;

			if (skill.state == PacketServer.SKILL_ERROR)
				return;
			if (skill.state == PacketServer.SKILL_ACTIVATE && skill.type == this.code)
				FooterGame.toggleFreeCast(false);
			if (this.hero != null && skill.type == this.code && skill.playerId == this.hero.id)
				this.active = (skill.state == PacketServer.SKILL_ACTIVATE);
		}
	}
}