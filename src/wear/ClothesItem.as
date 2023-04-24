package wear
{
	import game.gameData.OutfitData;
	import loaders.ClothesLoader;
	import loaders.HeroLoader;

	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.Slot;
	import dragonBones.factorys.BaseFactory;

	public class ClothesItem
	{
		public var slots:Vector.<Slot> = new Vector.<Slot>();

		private var _params:Object;

		public function ClothesItem(params:Object = null)
		{
			super();

			this._params = params;
		}

		public function get params():Object
		{
			return this._params;
		}

		public function dress(armature:Armature, isStarling:Boolean):void
		{
			var bones:Vector.<Bone> = armature.getBones();
			var slot:Slot;

			for each(var bone:Bone in bones)
			{
				if (!(slot = generateImage(bone, isStarling)) && !(slot = buildArmature(bone, isStarling)))
					continue;

				this.slots.push(slot);
			}
		}

		public function undress(armature:Armature):void
		{
			for each(var slot:Slot in this.slots)
			{
				if (slot.childArmature)
				{
					slot.childArmature.dispose();
					slot.childArmature = null;
				}

				slot.display = null;

				if (!slot.userData)
					continue;

				slot.parent.removeChild(slot);
				slot.dispose();
			}

			this.slots = null;
		}

		protected function buildArmature(bone:Bone, isStarling:Boolean):Slot
		{
			var armature:Armature = getFactory(this.params.id, isStarling).buildArmature(bone.name + "/" + this.params.skeleton);
			if (armature)
			{
				var slot:Slot = buildSlot(bone, isStarling);
				slot.childArmature = armature;
			}
			return slot;
		}

		protected function buildSlot(bone:Bone, isStarling:Boolean):Slot
		{
			var slot:Slot = HeroLoader.buildSlot(isStarling);
			slot.origin.copy(bone.slot.origin);
			slot.zOrder = bone.slot.zOrder + 1;
			slot.userData = true;
			bone.addChild(slot);

			return slot;
		}

		protected function generateImage(bone:Bone, isStarling:Boolean):Slot
		{
			var image:Object = getFactory(this.params.id, isStarling).getTextureDisplay(bone.name + "/" + this.params.skeleton);

			if (!image)
				return null;

			bone.slot.display = image;

			return bone.slot;
		}

		protected function getFactory(clothesId:int, isStarling:Boolean):BaseFactory
		{
			switch(clothesId)
			{
				case OutfitData.SHAMAN_BLUE:
					return HeroLoader.getFactory(isStarling);
				default:
					return ClothesLoader.getFactory(clothesId, isStarling);
			}
		}
	}
}