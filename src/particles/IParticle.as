package particles
{
	public interface IParticle
	{
		function update(step:Number):void;

		function get garbage():Boolean;
	}
}