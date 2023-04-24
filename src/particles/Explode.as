package particles
{
	import flash.geom.Point;

	import Box2D.Common.Math.b2Vec2;

	import particles.ParticleBlock;
	import particles.effects.FloorEffect;
	import particles.effects.FloorParams;
	import particles.effects.GravityEffect;
	import particles.effects.GravityParams;

	import utils.starling.StarlingAdapterSprite;

	public class Explode
	{
		static public var particleEngine:ParticleEngine;
		static public var highQuality:Boolean = false;
		private static var newPoint:Point = new Point();

		static public function explodeBody(body:StarlingAdapterSprite, point:b2Vec2, gravity:b2Vec2, impulse:Number):void
		{
			var pieces:Array = recursiveSeparateBody(body);
			explode(particleEngine, pieces, new Point(point.x * Game.PIXELS_TO_METRE, point.y * Game.PIXELS_TO_METRE), new Point(gravity.x * Game.PIXELS_TO_METRE, gravity.y * Game.PIXELS_TO_METRE), impulse / Math.log(impulse));
		}

		private static function recursiveSeparateBody(body: StarlingAdapterSprite): Array
		{
			var pieces:Array = [];
			var sprite:StarlingAdapterSprite;

			if (body.numChildren > 0)
			{
				while (body.numChildren > 0)
				{
					pieces = pieces.concat(recursiveSeparateBody(body.getChildStarlingAt(0)));
					body.removeChildStarlingAt(0, false);
				}
			}
			else
			{
				sprite = body;
				var pos:Point = sprite.localToGlobal(newPoint);
				sprite.x = pos.x;
				sprite.y = pos.y;
				pieces.push(sprite);
			}
			return pieces;
		}

		static private function explode(engine:ParticleEngine, pieces:Array, explodePoint:Point, gravityParams:Point, power:Number, ttl:Number = 7):void
		{
			var gravity:GravityEffect = new GravityEffect();
			var gravityParam:GravityParams = new GravityParams(gravityParams);

			var floor:FloorEffect = new FloorEffect();

			for each (var piece:StarlingAdapterSprite in pieces)
			{
				var piecePower:Number = power * (Math.random() + 0.1);
				var floorParam:FloorParams = highQuality ? (new FloorParams(650, true, Math.random())) : new FloorParams(650, true, 0, 1);

				piece.cacheAsBitmap = true;

				var particle:ParticleBlock = new ParticleBlock();

				particle.x = piece.x;
				particle.y = piece.y;
				particle.rotation = piece.rotation;
				particle.addChildStarling(piece);

				piece.x = 0;
				piece.y = 0;
				piece.rotation = 0;

				particle.addEffect(gravity, gravityParam);

				if (highQuality)
					particle.addEffect(floor, floorParam);

				var direction:Point = new Point((particle.x - explodePoint.x), (particle.y - explodePoint.y + 5));
				direction.x *= Math.random();
				direction.y *= Math.random();
				var length:Number = 1 / Math.sqrt(direction.x * direction.x + direction.y * direction.y);

				particle.velocity = new Point(direction.x * length * piecePower, direction.y * length * piecePower);
				particle.torque = Math.random() * piecePower * length * 30 - piecePower * length * 15;

				particle.timeToLive = highQuality ? ttl : 2;

				engine.addParticle(particle);
			}
		}
	}
}