package wear
{
	import dragonBones.Bone;
	import dragonBones.Slot;

	dynamic public class ClothesUpperItem extends ClothesItem
	{
		public function ClothesUpperItem(params:Object = null)
		{
			super(params);
		}

		override protected function generateImage(bone:Bone, isStarling:Boolean):Slot
		{
			var image:Object = getFactory(this.params.id, isStarling).getTextureDisplay(bone.name + "/" + this.params.skeleton);

			if (image)
			{
				var slot:Slot = buildSlot(bone, isStarling);
				slot.display = image;
			}

			return slot;
		}
	}
}