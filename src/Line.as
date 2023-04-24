package
{
	import Box2D.Common.Math.b2Vec2;

	public class Line
	{
		public var A:Number = 0;
		public var B:Number = 0;
		public var C:Number = 0;

		public function Line(A:Number, B:Number, C:Number):void
		{
			var v:b2Vec2 = new b2Vec2(A, B);
			this.A = v.x;
			this.B = -v.y;
			this.C = C;
		}

		static public function getOffeset(p1:b2Vec2, p2:b2Vec2):Number
		{
			var l:b2Vec2 = p1.Copy();
			l.Subtract(p2);

			var a:Number = p1.Length();
			var b:Number = p2.Length();
			var c:Number = l.Length();
			var p:Number = (a + b + c) / 2;

			return Math.sqrt(p * (p - a) * (p - b) * (p - c)) / (c / 2);
		}

		static public function fromPoints(p1:b2Vec2, p2:b2Vec2):Line
		{
			var result:Line = new Line(p2.y - p1.y, p1.x - p2.x, -(p1.y * (p2.x) - p1.x * (p2.y)));
			return result;
		}

		public function contain(point:b2Vec2):Boolean
		{
			return (A * point.x + B * point.y + C) == 0;
		}

		public function get normal():b2Vec2
		{
			return new b2Vec2(A, B);
		}

		public function get offset():Number
		{
			var divider:Number = Math.sqrt(A * A + B * B);
			var p:Number = C / divider;
			return p;
		}

		public function get a():Number
		{
			return -C / A;
		}

		public function get b():Number
		{
			return -C / B;
		}

		public function get k():Number
		{
			return -A / B;
		}
	}
}