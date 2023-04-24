package wear
{
	import game.gameData.ClothesManager;

	import dragonBones.Armature;
	import dragonBones.animation.WorldClock;

	public class Clothing
	{
		private var view:Vector.<ClothesItem> = new Vector.<ClothesItem>();

		private var armature:Armature;
		private var isStarling:Boolean = true;

		public function Clothing(armature:Armature, isStarling:Boolean = true):void
		{
			this.isStarling = isStarling;
			this.armature = armature;
		}

		public function remove():void
		{
			clear();

			this.armature = null;
		}

		public function clear():void
		{
			var i:int = this.view.length;

			while (i--)
				undress(i);

			this.view = new Vector.<ClothesItem>();
		}

		public function getClothesDressed():Array
		{
			var clothesIds:Array = [];
			var len:int = this.view.length;

			for (var i:int = 0; i < len; i++)
				clothesIds.push(this.view[i].params.id);

			return clothesIds;
		}

		public function setItems(packagesIds:Array, accessoriesIds:Array = null):void
		{
			clear();

			if (accessoriesIds == null)
				accessoriesIds = [];
			var bonesItems:Array = ClothesManager.convertToBones(packagesIds, accessoriesIds);

			var len:int;
			if (!(len = bonesItems.length))
				return;

			var item:ClothesItem;
			for (var i:int = 0; i < len; i++)
			{
				item = ClothesFactory.create(bonesItems[i]);
				item.dress(this.armature, this.isStarling);
				this.view.push(item);
			}

			this.armature.invalidUpdate();
			WorldClock.clock.advanceTime(-1);
		}

		private function undress(i:int):void
		{
			if (i < 0)
				return;

			this.view[i].undress(this.armature);
			this.view.splice(i, 1);

			this.armature.invalidUpdate();
			WorldClock.clock.advanceTime(-1);
		}
	}
}