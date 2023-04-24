package wear.decorators
{
	import wear.ClothesItem;

	import dragonBones.Armature;

	public class ClothesZOrderItem extends ClothesDecorator
	{
		private var currentOrder:Object = null;

		public function ClothesZOrderItem(item:ClothesItem)
		{
			super(item);
		}

		override public function dress(armature:Armature, isStarling:Boolean):void
		{
			super.dress(armature, isStarling);

			currentOrder = {};
			for (var name:String in this.params.zOrderBones)
			{
				currentOrder[name] = armature.getBone(name).slot.zOrder;
				armature.getBone(name).slot.zOrder = armature.getBone(this.params.zOrderBones[name]).slot.zOrder + 1;
			}
		}

		override public function undress(armature:Armature):void
		{
			for (var name:String in this.params.zOrderBones)
				armature.getBone(name).slot.zOrder = name in currentOrder ? currentOrder[name] : armature.getBone(this.params.zOrderBones[name]).slot.zOrder - 1;

			super.undress(armature);
		}
	}
}