package wear.decorators
{
	import wear.ClothesItem;

	import dragonBones.Armature;

	public class ClothesDecorator extends ClothesItem
	{
		protected var item:ClothesItem;

		public function ClothesDecorator(item:ClothesItem)
		{
			super();

			this.item = item;
		}

		override public function get params():Object
		{
			return this.item.params;
		}

		override public function dress(armature:Armature, isStarling:Boolean):void
		{
			this.item.dress(armature, isStarling);
		}

		override public function undress(armature:Armature):void
		{
			this.item.undress(armature);
		}
	}
}