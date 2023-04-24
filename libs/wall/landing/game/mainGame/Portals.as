package landing.game.mainGame
{
	import landing.sensors.PortalSensor;
	import landing.sensors.PortalSensorEvent;

	public class Portals
	{
		private var _portalA:PortalSensor;
		private var _portalB:PortalSensor;

		public function set portalA(portal:PortalSensor):void
		{
			if (this._portalA != null)
			{
				this._portalA.removeEventListener(PortalSensorEvent.CONTACT, onPortal);
				this._portalA.dispose();
			}

			this._portalA = portal;

			if (portal == null)
				return;

			portal.addEventListener(PortalSensorEvent.CONTACT, onPortal);
		}

		public function set portalB(portal:PortalSensor):void
		{
			if (this._portalB != null)
			{
				this._portalB.removeEventListener(PortalSensorEvent.CONTACT, onPortal);
				this._portalB.dispose();
			}

			this._portalB = portal;

			if (portal == null)
				return;

			portal.addEventListener(PortalSensorEvent.CONTACT, onPortal);
		}

		public function reset():void
		{
			this.portalA = null;
			this.portalB = null;
		}

		public function doTeleport():void
		{
			if (this._portalA != null)
				_portalA.doTeleport();
			if (this._portalB != null)
				_portalB.doTeleport();
		}

		private function onPortal(e:PortalSensorEvent):void
		{
			var source:PortalSensor = (e.currentTarget as PortalSensor);
			var target:PortalSensor;
			var hero:wHero = e.hero;

			if (source == this._portalA)
			{
				target = this._portalB;
				trace("Teleporting A -> B");
			}

			if (source == this._portalB)
			{
				target = this._portalA;
				trace("Teleporting B -> A");
			}

			if (target == null)
			{
				trace("Target is null");
				return;
			}

			target.teleport(hero);
		}
	}
}