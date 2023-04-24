package game.mainGame.perks
{
	import flash.events.Event;
	import flash.events.MouseEvent;

	import game.mainGame.perks.hare.ICounted;
	import game.mainGame.perks.ui.ToolButton;

	public class HeroPerkButton extends ToolButton
	{
		public function HeroPerkButton(id:int):void
		{
			super(id);

			setSector();

			removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
		}

		override public function onClick(e:Event = null):void
		{
			if (!checkClick())
				return;

			this.perkInstance.hero.sendLocation(this.perkInstance.active ? PerkRechargeable(this.perkInstance).code : -(this.perkInstance as PerkRechargeable).code);
		}

		override public function updateState(e:Event = null):void
		{
			if (!checkState())
				return;

			var charge:Number = ((this.perkInstance is game.mainGame.perks.hare.ICounted) && (PerkRechargeable(this.perkInstance).charge == 0) ? 100 : PerkRechargeable(this.perkInstance).charge);

			this.sector.end = Math.PI * 2 - charge / 100 * Math.PI * 2;

			this.status.setStatus(gls("<B>«{0}»</B>\n{1}\n<B>Заряд: </B>{2}%", this.title, this.description, int(PerkRechargeable(perkInstance).charge)));
		}

		public function get title():String
		{
			return "";
		}

		public function get description():String
		{
			return "";
		}

		override protected function setSector():void
		{
			super.setSector();

			this.sector.radius = 39.65 / 2;
			this.sector.x = this.sector.radius;
			this.sector.y = this.sector.radius;
		}
	}
}