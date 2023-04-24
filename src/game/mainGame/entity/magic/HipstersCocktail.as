package game.mainGame.entity.magic
{
	import flash.display.MovieClip;

	import chat.ChatDeadServiceMessage;
	import game.mainGame.ISideObject;
	import game.mainGame.SideIconView;
	import game.mainGame.perks.clothes.PerkClothesFactory;
	import views.GameBonusImageView;

	import utils.starling.StarlingAdapterSprite;

	public class HipstersCocktail extends EnergyObject implements ISideObject
	{
		private var _isVisible: Boolean = false;

		public function HipstersCocktail():void
		{
			this.perkCode = PerkClothesFactory.HIPSTER_WOMAN;
			this.messageId = ChatDeadServiceMessage.HIPSTERS_COCKTAIL;

			super();
		}

		override protected function get animation():MovieClip
		{
			var view:CocktailView = new CocktailView();
			view.mouseChildren = false;
			return view;
		}

		override protected function get beginAnimation():MovieClip
		{
			var view:CocktailBegin = new CocktailBegin();
			view.x = 2;
			view.y = 32;
			return view;
		}

		override protected function showAward():void
		{
			var acornImage:EnergyNurseBonus = new EnergyNurseBonus();

			var acornImageView:GameBonusImageView = new GameBonusImageView(acornImage, this.x + this.gameInst.shift.x, this.y + this.gameInst.shift.y);
			Game.gameSprite.addChild(acornImageView);
		}

		public function get sideIcon():StarlingAdapterSprite
		{
			return new SideIconView(SideIconView.COLOR_PINK, SideIconView.ICON_COCKTAIL);
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