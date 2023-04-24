package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display3D.Context3DProfile;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;
	import flash.geom.Rectangle;

	import screens.ScreenStarling;

	import starling.core.Starling;

	[SWF(width="900", height="620", frameRate="30", backgroundColor="#FFFFFF")]
	[Frame(factoryClass="PreLoader")]
	public class Main extends Sprite
	{

		public function Main():void
		{
			if (this.stage != null)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);

		}

		private function init(e:Event = null):void
		{

			var context3DProfile:String = Context3DProfile.BASELINE_CONSTRAINED;

			CONFIG::mobile {
				context3DProfile = Context3DProfile.BASELINE;
			}
			Starling.handleLostContext = true;

			var viewPortRect: Rectangle = new Rectangle(0, 0, Config.GAME_WIDTH, Config.GAME_HEIGHT);
			var starlingPort: Starling = new Starling(ScreenStarling, this.stage, viewPortRect, null, Context3DRenderMode.AUTO, context3DProfile);

			resizeMobile();
			starlingPort.supportHighResolutions = true;
			starlingPort.antiAliasing = 0;
			starlingPort.showStats = CONFIG::debug;

			starlingPort.start();

			removeEventListener(Event.ADDED_TO_STAGE, init);

			this.stage.align = StageAlign.TOP_LEFT;
			Game.gameSprite = new Sprite();
			Game.gameSprite.tabChildren = false;
			addChild(Game.gameSprite);
			Game.gameSprite.addChild(new Game);
			Game.starling = starlingPort;
			starlingPort.showStats = false;
			Game.stage.color = 0xffffff;
			Starling.current.stage.color = 0xffffff;

		}

		private function resizeMobile():void
		{
			CONFIG::mobile{
				var thisScreen:Screen = Screen.mainScreen;
				var newScaleX:Number = thisScreen.visibleBounds.width / 900;
				var newScaleY:Number = thisScreen.visibleBounds.height / 620;
				var newScale:Number = Math.min(newScaleX, newScaleY);
				this.scaleX = this.scaleY = newScale;
				this.x = thisScreen.visibleBounds.width / 2 - (900 * newScale) / 2;
				this.y = thisScreen.visibleBounds.height / 2 - (620 * newScale) / 2;
			}
		}
	}
}