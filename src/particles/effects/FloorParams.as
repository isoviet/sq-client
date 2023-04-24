package particles.effects
{
	public class FloorParams
	{
		public var height:Number;
		public var fadeSpeed:Number;
		public var fadeDelay:Number;
		public var useFade:Boolean;

		public function FloorParams(height:Number, useFade:Boolean = false, fadeDelay:Number = 2, fadeSpeed:Number = 1/4):void
		{
			this.height = height;
			this.fadeSpeed = fadeSpeed;
			this.useFade = useFade;
			this.fadeDelay = fadeDelay;
		}
	}
}