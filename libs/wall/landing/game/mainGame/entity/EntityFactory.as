package landing.game.mainGame.entity
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	import landing.game.mainGame.entity.cast.BodyDestructor;
	import landing.game.mainGame.entity.editor.CoverIce;
	import landing.game.mainGame.entity.editor.IslandBig;
	import landing.game.mainGame.entity.editor.IslandLessSmall;
	import landing.game.mainGame.entity.editor.IslandMedium;
	import landing.game.mainGame.entity.editor.IslandSmall;
	import landing.game.mainGame.entity.editor.Mount;
	import landing.game.mainGame.entity.editor.MountIce;
	import landing.game.mainGame.entity.editor.MountSliced;
	import landing.game.mainGame.entity.editor.PlatformGroundBody;
	import landing.game.mainGame.entity.editor.PlatformHerbBody;
	import landing.game.mainGame.entity.editor.PlatformSandBody;
	import landing.game.mainGame.entity.editor.ShamanBody;
	import landing.game.mainGame.entity.editor.SquirrelBody;
	import landing.game.mainGame.entity.editor.Stone;
	import landing.game.mainGame.entity.joints.JointDistance;
	import landing.game.mainGame.entity.joints.JointLinear;
	import landing.game.mainGame.entity.joints.JointPrismatic;
	import landing.game.mainGame.entity.joints.JointPulley;
	import landing.game.mainGame.entity.joints.JointToBody;
	import landing.game.mainGame.entity.joints.JointToBodyFixed;
	import landing.game.mainGame.entity.joints.JointToBodyMotor;
	import landing.game.mainGame.entity.joints.JointToBodyMotorCCW;
	import landing.game.mainGame.entity.joints.JointToWorld;
	import landing.game.mainGame.entity.joints.JointToWorldFixed;
	import landing.game.mainGame.entity.joints.JointToWorldMotor;
	import landing.game.mainGame.entity.joints.JointToWorldMotorCCW;
	import landing.game.mainGame.entity.joints.JointWeld;
	import landing.game.mainGame.entity.simple.AcornBody;
	import landing.game.mainGame.entity.simple.Balk;
	import landing.game.mainGame.entity.simple.BalkCage;
	import landing.game.mainGame.entity.simple.BalkIce;
	import landing.game.mainGame.entity.simple.BalkIceLong;
	import landing.game.mainGame.entity.simple.BalkLong;
	import landing.game.mainGame.entity.simple.Box;
	import landing.game.mainGame.entity.simple.BoxBig;
	import landing.game.mainGame.entity.simple.BoxIce;
	import landing.game.mainGame.entity.simple.BoxIceBig;
	import landing.game.mainGame.entity.simple.HollowBody;
	import landing.game.mainGame.entity.simple.Poise;
	import landing.game.mainGame.entity.simple.PoiseRight;
	import landing.game.mainGame.entity.simple.PortalBlue;
	import landing.game.mainGame.entity.simple.PortalRed;
	import landing.game.mainGame.entity.simple.SunflowerBody;
	import landing.game.mainGame.entity.simple.TreeBody;
	import landing.game.mainGame.entity.simple.WeightBody;

	public class EntityFactory
	{
		static private var entityCollection:Array = [
			Box,
			BoxBig,
			Balk,
			BalkLong,
			null,
			PortalBlue,
			PortalRed,
			Poise,
			PoiseRight,
			ShamanBody,
			SquirrelBody,
			HollowBody,
			AcornBody,
			IslandSmall,
			IslandMedium,
			IslandBig,
			JointToWorldFixed,
			JointToWorld,
			JointToBodyFixed,
			JointToBody,
			PlatformGround,
			PoiseRight,
			BalkIce,
			BalkIceLong,
			BoxIce,
			BoxIceBig,
			PlatformSandBody,
			PlatformHerbBody,
			PlatformGroundBody,
			CoverIce,
			SunflowerBody,
			TreeBody,
			IslandLessSmall,
			JointToBodyMotor,
			JointToBodyMotorCCW,
			JointToWorldMotor,
			JointToWorldMotorCCW,
			JointDistance,
			JointPrismatic,
			JointPulley,
			JointWeld,
			JointLinear,
			WeightBody,
			Mount,
			MountIce,
			MountSliced,
			Stone,
			BodyDestructor,
			BalkCage
		];

		static private var images:Dictionary = new Dictionary();

		static public function init():void
		{
			images[ShamanBody] = {'icon': Shaman, 'width': 24, 'height': 35};
			images[SquirrelBody] = {'icon': HeroIcon, 'width': 29, 'height': 30};
			images[HollowBody] = {'icon': Hollow, 'width': 36, 'height': 33};
			images[AcornBody] = {'icon': Acorns, 'width': 40, 'height': 29};
			images[IslandSmall] = {'icon': Island3, 'width': 33, 'height': 18};
			images[IslandMedium] = {'icon': Island2, 'width': 40, 'height': 18};
			images[IslandBig] = {'icon': Island1, 'width': 43, 'height': 17};
			images[Box] = {'icon': Box1, 'width': 20, 'height': 20};
			images[BoxBig] = {'icon': Box2, 'width': 29, 'height': 29};
			images[Balk] = {'icon': Balk1, 'width': 27, 'height': 5};
			images[BalkLong] = {'icon': Balk2, 'width': 42, 'height': 5};
			images[PortalBlue] = {'icon':PortalBIcon , 'width': 32, 'height': 32};
			images[PortalRed] = {'icon':PortalAIcon, 'width': 32, 'height': 32};
			images[Poise] = {'icon': PoiseL};
			images[PoiseRight] = {'icon': PoiseR};
			images[BalkIce] = {'icon': IceBalk1, 'width': 27, 'height': 5};
			images[BalkIceLong] = {'icon': IceBalk2, 'width': 42, 'height': 5};
			images[BoxIce] = {'icon': IceBox1, 'width': 20, 'height': 20};
			images[BoxIceBig] = {'icon': IceBox2, 'width': 29, 'height': 29};
			images[PlatformGroundBody] = {'icon': PlatformGround, 'width': 41, 'height': 29};
			images[PlatformHerbBody] = {'icon': PlatformHerbIcon, 'x': 6, 'y': 0};
			images[PlatformSandBody] = {'icon': Send, 'width': 41, 'height': 29};
			images[CoverIce] = {'icon': IceIcon, 'image': Ice};
			images[SunflowerBody] = {'icon': Sunflower, 'width': 28, 'height': 33};
			images[TreeBody] = {'icon': Tree, 'width': 35, 'height': 36};
			images[IslandLessSmall] = {'icon': Island4, 'width': 25, 'height': 17};
			images[WeightBody] = {'icon': WeightIcon, 'width': 35 * 0.8, 'height': 43 * 0.8};
			images[Mount] = {'icon': MountIcon, 'width': 45 * 0.7, 'height': 45 * 0.7};
			images[MountIce] = {'icon': MountIcedIcon, 'width': 72 * 0.7, 'height': 83 * 0.7};
			images[MountSliced] = { 'icon': MountSlicedIcon, 'width': 45 * 0.9, 'height': 33 * 0.9 };
			images[Stone] = { 'icon': StoneIcon, 'width': 44.95 * 0.7, 'height': 44.45 * 0.7 };

			images[JointToWorldFixed] = { 'icon': PinLimited, 'x': 6, 'y': 6};
			images[JointToWorld] = { 'icon': PinUnlimited, 'x': 6, 'y': 6};
			images[JointToBodyFixed] = { 'icon': JointToBodyFixedImage, 'x': 6, 'y': 6};
			images[JointToBody] = { 'icon': JointToBodyImage, 'x': 6, 'y': 6};

			images[JointToBodyMotor] = { 'icon': JointToBodyMotorImage, 'x': 12, 'y': 12};
			images[JointToBodyMotorCCW] = { 'icon': JointToBodyMotorImage, 'scaleX': true, 'x': 12, 'y': 12};
			images[JointToWorldMotor] = { 'icon': JointToWorldMotorImage, 'x': 12, 'y': 12};
			images[JointToWorldMotorCCW] = { 'icon': JointToWorldMotorImage, 'scaleX': true, 'x': 12, 'y': 12};

			images[JointDistance] = { 'icon': SpringJointView, 'width': 75 * 0.6, 'height': 21 * 0.7, 'x': 23, 'y': 5};
			images[JointPulley] = { 'icon': PulleyjointView, 'width': 71 * 0.5, 'height': 65 * 0.5, 'x': 16, 'y': 15};
			images[JointWeld] = { 'icon': WeldJointView,  'width': 53 * 0.7, 'height': 13 * 0.7, 'x': 18, 'y': 5 };

			images[BodyDestructor] = {'icon': SightIcon,  'width': 32.40, 'height': 32.40};
		}

		static public function getImage(id:int):Class
		{
			var className:Class = getEntity(id);
			return images[className]['image'];
		}

		static public function getByClass(className:Class):DisplayObject
		{
			var data:Object = images[className];
			if (data == null)
			{
				trace("X");
			}
			var className:Class = data['icon'];
			var image:DisplayObject = new className();
			if ("width" in data)
			{
				image.width = data['width'];
				image.height = data['height'];
			}
			if ("x" in data)
			{
				image.x = data['x'];
				image.y = data['y'];
			}
			if ("scaleX" in data)
				image.scaleX = - image.scaleX;
			return image;
		}

		static public function getEntity(id:int):Class
		{
			return entityCollection[id];
		}

		static public function getId(object:*):int
		{
			for (var id:int = 0; id < entityCollection.length; id++)
			{
				if (object is Class && object == entityCollection[id])
					return id;

				if (getQualifiedClassName(object) == getQualifiedClassName(entityCollection[id]))
					return id;
			}

			return -1;
		}
	}
}