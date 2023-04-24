package utils
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	public class Box2DUtil
	{
		static public function drawBox(world:b2World, pX:int, pY:int, w:int, h:int, dinamyc:Boolean, data:Object, angle:int = 0, categoryBits:int = 0x0004, maskBits:int = 0x0002, sensor:Boolean = false):b2Body
		{
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.position.Set(pX / Game.PIXELS_TO_METRE, pY / Game.PIXELS_TO_METRE);
			bodyDef.angle = angle * (Game.D2R);

			if (dinamyc)
				bodyDef.type = b2Body.b2_dynamicBody;
			else
				bodyDef.type = b2Body.b2_staticBody;

			var box:b2PolygonShape = new b2PolygonShape();
			box.SetAsBox(w / 2 / Game.PIXELS_TO_METRE, h / 2 / Game.PIXELS_TO_METRE);

			var fixture:b2FixtureDef = new b2FixtureDef();
			fixture.friction = 1;
			fixture.density = 1;
			fixture.shape = box;
			fixture.filter.categoryBits = categoryBits;
			fixture.filter.maskBits = maskBits;
			fixture.filter.groupIndex = 2;
			fixture.isSensor = sensor;

			var body:b2Body = world.CreateBody(bodyDef);
			data['object'] = body;
			body.SetUserData(data);
			body.CreateFixture(fixture);

			return body;
		}

		static public function debugDraw(world:b2World, owner:DisplayObjectContainer):void
		{
			var debugDraw:b2DebugDraw = new b2DebugDraw();
			var debugSprite:Sprite = new Sprite();
			debugSprite['name'] = "debug";
			owner.addChild(debugSprite);
			debugDraw.SetSprite(debugSprite);
			debugDraw.SetDrawScale(Game.PIXELS_TO_METRE);
			debugDraw.SetFlags(b2DebugDraw.e_shapeBit);
			world.SetDebugDraw(debugDraw);
		}

		static public function clearDebug(owner:DisplayObjectContainer):void
		{
			for (var i:int = 0; i < owner.numChildren; i++)
			{
				var child:DisplayObject = owner.getChildAt(i);
				if(!('name' in child))
					continue;
				if (child['name'] != "debug")
					continue;

				owner.removeChild(child);
			}
		}
	}
}