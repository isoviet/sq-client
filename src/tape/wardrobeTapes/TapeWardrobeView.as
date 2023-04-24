package tape.wardrobeTapes
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFormat;

	import game.gameData.ClothesManager;
	import game.gameData.GameConfig;
	import game.gameData.OutfitData;
	import tape.TapeData;
	import tape.TapeDataSelectable;
	import tape.TapeSelectableObject;
	import tape.TapeSelectableView;
	import tape.events.TapeElementEvent;

	public class TapeWardrobeView extends TapeSelectableView
	{
		static public const SELECT_SKIN:String = "TapeWardrobeView.SELECT_SKIN";

		private var spriteSkins:Sprite = null;
		private var tapeSkins:TapeWardrobeSkinView = null;
		private var fieldEmpty:GameField = null;

		public var selectId:int = -1;

		public function TapeWardrobeView():void
		{
			super(7, 1, 10, 0, 10, 0, 110, 120);
		}

		override public function setData(data:TapeData):void
		{
			super.setData(data);

			this.fieldEmpty.visible = data.objects.length == 0;

			if (this.lastSticked != null)
			{
				for each (var object:TapeSelectableObject in data.objects)
				{
					if (object.id != this.lastSticked.id)
						continue;
					select(object);
					return;
				}
			}
			select(data.objects.length != 0 ? data.objects[0] as TapeSelectableObject : null);
		}

		public function selectSelf(isShaman:Boolean = false):void
		{
			var packages:Array = ClothesManager.wornPackages.filter(function(item:int, index:int, parentArray:Array):Boolean
			{
				if (index || parentArray) {/*unused*/}
				var owner:int = GameConfig.getOutfitCharacter(OutfitData.packageToOutfit(item));
				return owner == (isShaman ? OutfitData.CHARACTER_SHAMAN : OutfitData.CHARACTER_SQUIRREL);
			});
			if (packages.length == 0)
				return;

			var value:int = OutfitData.packageToOutfit(packages[0]);
			for (var i:int = 0; i < this.data.objects.length; i++)
			{
				if ((this.data.objects[i] as TapeWardrobeElement).id != value)
					continue;
				select(this.data.objects[i] as TapeWardrobeElement);
				this.offset = Math.max(0, Math.min(i, this.data.objects.length - this.numColumns));
				break;
			}
		}

		override protected function init():void
		{
			this.spriteSkins = new Sprite();
			this.spriteSkins.x = 300;
			this.spriteSkins.y = -120;
			this.spriteSkins.graphics.beginFill(0x000000, 0.3);
			this.spriteSkins.graphics.drawRoundRect(0, 0, 240, 105, 25);
			addChild(this.spriteSkins);

			var field:GameField = new GameField(gls("Образы костюма"), 0, 0, new TextFormat(GameField.PLAKAT_FONT, 14, 0xFFFFFF));
			field.x = int((this.spriteSkins.width - field.textWidth) * 0.5);
			this.spriteSkins.addChild(field);

			this.tapeSkins = new TapeWardrobeSkinView(60, 10, 2);
			this.tapeSkins.x = 91;
			this.tapeSkins.y = 18;
			this.tapeSkins.addEventListener(TapeElementEvent.SELECTED, onSkinSelect);
			this.spriteSkins.addChild(this.tapeSkins);

			this.spriteSkins.visible = false;

			this.fieldEmpty = new GameField(gls("У тебя ещё нет ни одного костюма"), 0, 50, new TextFormat(GameField.PLAKAT_FONT, 16, 0xFFFFFF));
			this.fieldEmpty.x = 450 - int(this.fieldEmpty.textWidth * 0.5);
			addChild(this.fieldEmpty);
		}

		override protected function placeButtons():void
		{
			super.placeButtons();

			this.buttonPrevious.x = -this.buttonPrevious.width - 1;
			this.buttonPrevious.y = this.topMargin + (this.numRows * (this.objectHeight + this.offsetY) - this.offsetY) * 0.5
				- this.buttonPrevious.height * 0.5;
			this.buttonNext.x = this.leftMargin * 2 + this.numColumns * (this.objectWidth + this.offsetX)
				- this.offsetX + 1;
			this.buttonNext.y = this.topMargin + (this.numRows * (this.objectHeight + this.offsetY) - this.offsetY) * 0.5
				- this.buttonNext.height * 0.5;
		}

		override protected function updateInfo(selected:TapeSelectableObject):void
		{
			this.spriteSkins.visible = selected != null;
			if (selected == null)
				return;
			var data:TapeDataSelectable = new TapeDataSelectable(TapeWardrobeSkinElement);
			data.setData(GameConfig.getOutfitPackages(selected.id).filter(function(item:int, index:int, parentArray:Array):Boolean
			{
				if (index || parentArray) {/*unused*/}
				return GameConfig.getPackageCoinsPrice(item) != 0 || ClothesManager.haveItem(item, ClothesManager.KIND_PACKAGES);
			}));
			this.tapeSkins.setData(data);
		}

		protected function onSkinSelect(e:TapeElementEvent):void
		{
			if (e.element == null)
				return;
			this.selectId = (e.element as TapeSelectableObject).id;
			dispatchEvent(new Event(SELECT_SKIN));
		}
	}
}