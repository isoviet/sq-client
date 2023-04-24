package wear.decorators
{
	import wear.ClothesItem;

	import dragonBones.Armature;

	public class ClothesHidingItem extends ClothesDecorator
	{
		public function ClothesHidingItem(item:ClothesItem)
		{
			super(item);
		}

		override public function dress(armature:Armature, isStarling:Boolean):void
		{
			super.dress(armature, isStarling);

			Logger.add("ClothesHidingItem", this.params.hiddenBones);
			for each(var name:String in this.params.hiddenBones)
			{
				Logger.add("this.params.hiddenBones", name);
				armature.getBone(name).visible = false;
			}
		}

		override public function undress(armature:Armature):void
		{
			for each(var name:String in this.params.hiddenBones)
				armature.getBone(name).visible = true;

			super.undress(armature);
		}
	}
}