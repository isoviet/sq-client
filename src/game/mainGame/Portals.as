package game.mainGame
{
	import sensors.PortalSensor;
	import sensors.PortalSensorEvent;

	public class Portals
	{
		private var _portalA:PortalSensor;
		private var _portalB:PortalSensor;
		private var _portalC:PortalSensor;

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

		public function set portalC(portal:PortalSensor):void
		{
			if (this._portalC != null)
			{
				this._portalC.removeEventListener(PortalSensorEvent.CONTACT, onPortal);
				this._portalC.dispose();
			}

			this._portalC = portal;

			if (portal == null)
				return;

			portal.addEventListener(PortalSensorEvent.CONTACT, onPortal);
		}

		public function reset():void
		{
			this.portalA = null;
			this.portalB = null;
			this.portalC = null;
		}

		public function doTeleport():void
		{
			if (this._portalA != null)
				_portalA.doTeleport();
			if (this._portalB != null)
				_portalB.doTeleport();
			if (this._portalC != null)
				_portalC.doTeleport();
		}

		private function onPortal(e:PortalSensorEvent):void
		{
			var source:PortalSensor = (e.currentTarget as PortalSensor);
			var target:PortalSensor;
			var hero:Hero = e.hero;

			if (source == this._portalA)
				target = this._portalC ? this._portalC : this._portalB;
			else if (source == this._portalB)
				target = this._portalC ? this._portalC : this._portalA;
			else if (source == this._portalC)
				target = ((this._portalA && this._portalB) || (!this._portalA && !this._portalB)) ? null : (this._portalA ? this._portalA : this._portalB);

			if (target == null)
				return;

			target.teleport(hero);
		}
	}
}