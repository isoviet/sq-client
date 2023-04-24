package views
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import game.gameData.OutfitData;
	import loaders.HeroLoader;
	import wear.Clothing;

	import dragonBones.Armature;
	import dragonBones.animation.WorldClock;

	public class ProfileHero extends Sprite
	{
		public var shaman:Boolean = false;

		private var armatures:Vector.<Armature> = new Vector.<Armature>();
		private var displays:Vector.<DisplayObject> = new Vector.<DisplayObject>();
		private var clothes:Vector.<Clothing> = new Vector.<Clothing>();

		private var _view:int = 0;
		private var _enableUpdate:Boolean = true;

		public function ProfileHero():void
		{
			super();
			init();
		}

		override public function set visible(value:Boolean):void
		{
			enableUpdate = super.visible = value;
		}

		public function setClothes(packagesIds:Array, accessoriesIds:Array = null):void
		{
			//TODO compareArrays
			this.clothes[OutfitData.OWNER_SQUIRREL].setItems(packagesIds.filter(filterSquirrelClothes), accessoriesIds);
			this.clothes[OutfitData.OWNER_SCRAT].setItems(packagesIds.filter(filterScratClothes));
			this.clothes[OutfitData.OWNER_SCRATTY].setItems(packagesIds.filter(filterScrattyClothes));
			this.clothes[OutfitData.OWNER_SHAMAN].setItems(packagesIds.filter(filterShaman));

			restartAnimation(view);

			checkShamanNude();
		}

		private function restartAnimation(type:int):void
		{
			this.armatures[type].animation.gotoAndPlay(Hero.DB_STAND);
		}

		public function get view():int
		{
			return _view;
		}

		public function set view(value:int):void
		{
			if (this._view == value)
				return;

			this.displays[view].visible = false;
			this.armatures[view].animation.stop();

			this._view = value;

			this.displays[view].visible = true;
			restartAnimation(view);

			checkShamanNude();
		}

		public function get enableUpdate():Boolean
		{
			return this._enableUpdate;
		}

		public function set enableUpdate(value:Boolean):void
		{
			if (value == this._enableUpdate)
				return;

			this._enableUpdate = value;

			for each(var armature:Armature in this.armatures)
			{
				if (value)
					WorldClock.clock.add(armature);
				else
					WorldClock.clock.remove(armature);
			}
		}

		private function filterSquirrelClothes(item:*, index:int, array:Array):Boolean
		{
			if (index || array) {/*unused*/}

			return !OutfitData.isScratSkin(item) && !OutfitData.isScrattySkin(item) && !OutfitData.isShamanSkin(item);
		}

		private function filterScratClothes(item:*, index:int, array:Array):Boolean
		{
			if (index || array) {/*unused*/}

			return OutfitData.isScratSkin(item);
		}

		private function filterScrattyClothes(item:*, index:int, array:Array):Boolean
		{
			if (index || array) {/*unused*/}

			return OutfitData.isScrattySkin(item);
		}

		private function filterShaman(item:*, index:int, array:Array):Boolean
		{
			if (index || array) {/*unused*/}

			return OutfitData.isShamanSkin(item);
		}

		private function init():void
		{
			for (var i:int = 0; i < OutfitData.OWNER_MAX_TYPE; i++)
			{
				this.armatures[i] = HeroLoader.getFactory(false).buildArmature(getArmatureName(i));
				WorldClock.clock.add(this.armatures[i]);

				if (i == OutfitData.OWNER_SQUIRREL)
					this.armatures[i].animation.gotoAndPlay(Hero.DB_STAND);

				this.clothes[i] = new Clothing(this.armatures[i], false);

				this.displays[i] = this.armatures[i].display as DisplayObject;
				this.displays[i].scaleX = 2.8;
				this.displays[i].scaleY = 2.8;
				this.displays[i].visible = (i == OutfitData.OWNER_SQUIRREL);
				addChild(this.displays[i]);
			}

			this.mouseChildren = false;
			this.mouseEnabled = false;

			this.view = OutfitData.OWNER_SQUIRREL;
		}

		private function getArmatureName(type:int):String
		{
			switch(type)
			{
				case OutfitData.OWNER_SCRAT:
					return HeroLoader.SCRAT;
				case OutfitData.OWNER_SCRATTY:
					return HeroLoader.SCRATTY;
				default:
					return HeroLoader.SQUIRREL;
			}
		}

		private function checkShamanNude():void
		{
			if (!this.shaman)
				return;

			if (this.clothes[OutfitData.OWNER_SHAMAN].getClothesDressed().length > 0)
				return;

			this.clothes[OutfitData.OWNER_SHAMAN].setItems([OutfitData.SHAMAN_BLUE]);
		}
	}
}