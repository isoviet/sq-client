package interfaces
{
	import flash.media.SoundChannel;

	public interface IPlay
	{

		function play(name:String, block:Boolean = false):SoundChannel;
	}
}