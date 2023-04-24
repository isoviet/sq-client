package game.mainGame.entity.magic
{
	import flash.events.Event;

	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2ContactImpulse;

	import game.mainGame.entity.simple.Missile;

	import utils.starling.StarlingAdapterSprite;

	public class TuxedoMaskRose extends Missile
	{
		private var hitView:StarlingAdapterSprite;

		public function TuxedoMaskRose():void
		{
			super();
		}

		override public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{
			if (impulse) {/*unused*/}

			var otherObject:* = contact.GetFixtureA().GetBody().GetUserData();
			if (otherObject == this)
				otherObject = contact.GetFixtureB().GetBody().GetUserData();

			if (otherObject is TuxedoMaskRose)
			{
				contact.SetEnabled(false);
				return;
			}

			var hero:Hero = (otherObject as Hero);
			if (!hero)
			{
				if (!this.fixed)
				{
					this.fixed = true;
					this.branchView.visible = false;

					this.hitView = new StarlingAdapterSprite(new TuxedoMaskRoseHit());
					this.hitView.getStarlingView().scaleX = branchView.getStarlingView().scaleX;
					if (branchView.scaleX >=0)
					{
						this.hitView.pivotX = this.hitView.width / 2 - 15;
					}
					else
					{
						this.hitView.pivotX = 0;
					}
					this.hitView.y = 7;
					this.hitView.addEventListener(Event.CHANGE, endView);
					addChildStarling(this.hitView);

					this.resetMass = true;
				}
			}
		}

		override protected function init():void
		{
			originBranchView = new TuxedoMaskRoseView();

			super.init();
		}

		private function endView(e:Event):void
		{
			if (this.hitView)
			{
				this.hitView.removeEventListener(Event.CHANGE, endView);
				if (containsStarling(this.hitView))
					removeChildStarling(this.hitView);
				this.hitView = null;
			}
			this.branchView.visible = true;
		}
	}
}