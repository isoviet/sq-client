package utils.dragonBones
{
	import dragonBones.Armature;
	import dragonBones.Bone;

	import starling.textures.TextureSmoothing;

	public class SmoothingUtil
	{
		static public function setSmoothing(armature:Armature, type:String, bonesName:Array):void
		{
			for (var i:int = 0, len: int = bonesName.length; i < len; i++)
			{
				var item:Bone = armature.getBone(bonesName[i]);

				if (item && item.display && item.display.smoothing != TextureSmoothing.TRILINEAR)
					item.display.smoothing = type;
			}
		}
	}
}