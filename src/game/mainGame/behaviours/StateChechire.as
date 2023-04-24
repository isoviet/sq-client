package game.mainGame.behaviours
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.setTimeout;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;

	public class StateChechire extends HeroState
	{
		private var transformIn:MovieClip = null;
		private var transformOut:MovieClip = null;

		private var smile:MovieClip;
		private var smileOut:MovieClip;

		private var destination:b2Vec2;
		private var joint:b2Joint;

		public function StateChechire(destination:b2Vec2)
		{
			super(0);

			this.destination = destination;

			this.transformIn = new CheshireTransformIn();
			this.transformOut = new CheshireTransformOut();
		}

		override public function set hero(value:Hero):void
		{
			if (value == null && this.hero != null)
			{
				this.hero.visible = true;
				this.hero.isStoped = false;

				if (this.joint)
					removeFix();

				this.hero.changeView();

				if (this.smileOut && this.smileOut.parent)
				{
					this.smileOut.removeEventListener(Event.CHANGE, onSmileOut);

					this.smileOut.parent.removeChild(this.smileOut);
					this.smileOut = null;
				}

				if (this.smile && this.smile.parent)
				{
					this.smile.parent.removeChild(this.smile);
					this.smile = null;
				}
			}
			else
			{
				value.isStoped = true;
				value.changeView(this.transformIn);
				this.transformIn.addEventListener(Event.CHANGE, onTransformIn);
				this.transformIn.gotoAndPlay(0);
			}

			super.hero = value;
		}

		private function onTransformIn(e:Event):void
		{
			this.transformIn.removeEventListener(Event.CHANGE, onTransformIn);
			this.transformIn.gotoAndStop(0);

			if (!this.hero || this.hero.onRemove)
				return;

			this.hero.visible = false;

			var position:Point = this.hero.getPosition();
			this.smile = new CheshireSmile();
			this.smile.x = position.x;
			this.smile.y = position.y;
			this.smile.rotation = this.hero.rotation;
			this.smile.scaleX = (this.hero.heroView.direction ? 1 : -1) * Math.abs(this.smile.scaleX);
			this.hero.game.map.userUpperSprite.addChild(this.smile);

			setTimeout(teleport, 1000);
		}

		private function teleport():void
		{
			if (!this.hero || this.hero.onRemove)
				return;

			this.hero.teleportTo(new b2Vec2(this.destination.x, this.destination.y));

			fixHero();

			this.hero.visible = true;

			this.hero.changeView(this.transformOut);
			this.transformOut.addEventListener(Event.CHANGE, onTransformOut);
			this.transformOut.gotoAndPlay(0);
		}

		private function onTransformOut(e:Event):void
		{
			this.transformOut.removeEventListener(Event.CHANGE, onTransformOut);

			if (!this.hero || this.hero.onRemove)
				return;

			this.hero.changeView();

			removeFix();

			this.hero.isStoped = false;

			setTimeout(hideSmile, 500);
		}

		private function hideSmile():void
		{
			if (!this.smile || !this.smile.parent)
				return;

			this.smileOut = new CheshireSmileOut();
			this.smileOut.x = this.smile.x;
			this.smileOut.y = this.smile.y;
			this.smileOut.scaleX = this.smile.scaleX;
			this.smileOut.rotation = this.smile.rotation;

			this.smileOut.addEventListener(Event.CHANGE, onSmileOut);

			this.smile.parent.addChildAt(this.smileOut, this.smile.parent.getChildIndex(this.smile));

			this.smile.parent.removeChild(smile);
			this.smile = null;
		}

		private function onSmileOut(event:Event):void
		{
			this.permanent = false;
		}

		private function fixHero():void
		{
			this.hero.body.SetFixedRotation(false);

			var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			jointDef.Initialize(this.hero.body.GetWorld().GetGroundBody(), this.hero.body, this.hero.body.GetPosition());
			jointDef.enableLimit = true;
			jointDef.lowerAngle = 0;
			jointDef.upperAngle = 0;

			this.joint = this.hero.body.GetWorld().CreateJoint(jointDef);
			this.hero.hover = true;
		}

		private function removeFix():void
		{
			if (!this.hero || this.hero.onRemove)
				return;
			this.hero.body.GetWorld().DestroyJoint(this.joint);
			this.hero.body.SetFixedRotation(true);
			this.hero.hover = false;
			this.hero.resetMass = true;

			this.joint = null;
		}
	}
}