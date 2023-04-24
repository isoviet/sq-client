package buttons
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import events.ButtonTabEvent;
	import sounds.GameSounds;
	import sounds.SoundConstants;

	public class ButtonTab extends Sprite
	{
		protected var stateUp:DisplayObject;
		protected var stateOver:DisplayObject;
		protected var stateActive:DisplayObject;
		protected var stateDown:DisplayObject;
		private var stateBlock:DisplayObject;

		private var _sticked:Boolean;
		private var _block:Boolean = false;

		public function ButtonTab(stateUp:DisplayObject, stateOver:DisplayObject = null, stateDown:DisplayObject = null, stateActive:DisplayObject = null, stateBlock:DisplayObject = null, hitArea:Sprite = null):void
		{
			super();

			this.buttonMode = true;
			this.mouseChildren = false;

			if (stateUp is SimpleButton)
			{
				var states:SimpleButton = stateUp as SimpleButton;

				this.stateUp = states.upState;
				this.stateOver = states.overState;
				this.stateDown = states.downState;
				this.stateActive = states.downState;
				this.stateBlock = states.upState;
				this.hitArea = hitArea ? hitArea : (states.upState as Sprite);
			}
			else
			{
				this.stateUp = stateUp;
				this.stateOver = stateOver;
				this.stateDown = stateDown;
				this.stateActive = (stateActive ? stateActive : stateDown);
				this.stateBlock = stateBlock;
				this.hitArea = hitArea;
			}

			init();

			this.sticked = false;
		}

		public function chageView(button:SimpleButton):void
		{
			removeChild(this.stateUp);
			removeChild(this.stateOver);
			removeChild(this.stateDown);

			this.stateUp = button.upState;
			this.stateOver = button.overState;
			this.stateDown = button.downState;
			this.stateActive = button.downState;

			addChildAt(this.stateUp, 0);
			addChildAt(this.stateOver, 0);
			addChildAt(this.stateDown, 0);

			this.sticked = this.sticked;
		}

		public function set sticked(value:Boolean):void
		{
			hideAll();

			if (value)
				doActive();
			else
				doUp();

			this._sticked = value;
		}

		public function set block(value:Boolean):void
		{
			if (value == this.block)
				return;
			hideAll();

			if (value)
				play(this.stateBlock);
			else
				play(this.stateUp);

			if (!value && this._block)
			{
				addEventListener(MouseEvent.ROLL_OVER, over);
				addEventListener(MouseEvent.ROLL_OUT, out);
				addEventListener(MouseEvent.MOUSE_DOWN, down);
				addEventListener(MouseEvent.MOUSE_UP, up);
			}
			if (value && !this._block)
			{
				removeEventListener(MouseEvent.ROLL_OVER, over);
				removeEventListener(MouseEvent.ROLL_OUT, out);
				removeEventListener(MouseEvent.MOUSE_DOWN, down);
				removeEventListener(MouseEvent.MOUSE_UP, up);
			}

			this._block = value;
		}

		public function get block():Boolean
		{
			return this._block;
		}

		public function get sticked():Boolean
		{
			return this._sticked;
		}

		protected function doUp():void
		{
			play(this.stateUp);
		}

		protected function doActive():void
		{
			play(this.stateActive);
		}

		protected function doOver():void
		{
			play(this.stateOver);
		}

		private function init():void
		{
			addChild(this.stateUp);
			addChild(this.stateOver);
			addChild(this.stateActive);

			if (this.stateBlock != null)
				addChild(this.stateBlock);

			if (this.stateDown != null)
				addChild(this.stateDown);

			addEventListener(MouseEvent.ROLL_OVER, over);
			addEventListener(MouseEvent.ROLL_OUT, out);
			addEventListener(MouseEvent.MOUSE_DOWN, down);
			addEventListener(MouseEvent.MOUSE_UP, up);
		}

		private function over(e:Event):void
		{
			if (this.sticked)
				return;

			GameSounds.play(SoundConstants.OVER);

			hideAll();
			doOver();
		}

		private function out(e:Event):void
		{
			this.sticked = this.sticked;
		}

		private function up(e:Event):void
		{
			this.sticked = true;

			GameSounds.play(SoundConstants.OVER);

			dispatchEvent(new ButtonTabEvent(ButtonTabEvent.SELECT, this));
		}

		private function down(e:Event):void
		{
			if (this.sticked)
				return;

			hideAll();

			dispatchEvent(new ButtonTabEvent(ButtonTabEvent.CLICK));

			if (this.stateDown != null)
				play(this.stateDown);
			else
				play(this.stateOver);
		}

		private function play(state:DisplayObject):void
		{
			state.visible = true;

			if (state is MovieClip)
				(state as MovieClip).play();
		}

		private function hideAll():void
		{
			this.stateUp.visible = false;
			this.stateOver.visible = false;
			this.stateActive.visible = false;

			if (this.stateBlock != null)
				this.stateBlock.visible = false;

			if (this.stateDown != null)
				this.stateDown.visible = false;
		}
	}
}