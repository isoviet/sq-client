package game.mainGame.entity.editor.decorations
{
	import Box2D.Dynamics.b2World;

	import game.mainGame.ISideObject;
	import game.mainGame.SideIconView;
	import game.mainGame.entity.IWaterSource;
	import game.mainGame.gameDesertNet.ThirstController;

	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class DecorationFountain extends Decoration implements IWaterSource, ISideObject
	{
		private var view:StarlingAdapterMovie = null;
		private var _isVisible: Boolean = false;

		public function DecorationFountain():void
		{
			super(null);
			this.view = new StarlingAdapterMovie(new Fountain);
			this.view.stop();
			this.view.y = 5;
			addChildStarling(this.view);
		}

		override public function get cacheBitmap():Boolean
		{
			return false;
		}

		override public function build(world:b2World):void
		{
			super.build(world);
			this.view.play();
		}

		override public function dispose():void
		{
			this.view.removeFromParent();

			super.dispose();
		}

		public function get waterAuraSize():int
		{
			return ThirstController.FOUNTAIN_AURA_SIZE;
		}

		public function get sideIcon():StarlingAdapterSprite
		{
			return new SideIconView(SideIconView.COLOR_BLUE, SideIconView.ICON_WATER_SOURCE);
		}

		public function get showIcon():Boolean
		{
			return true;
		}

		public function get isVisible():Boolean {
			return _isVisible;
		}

		public function set isVisible(value: Boolean): void {
			_isVisible = false;
		}
	}
}