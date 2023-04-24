package utils
{
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;

	import starling.filters.BlurFilter;

	public class FiltersUtil
	{
		static public const GREY_FILTER:Array = [new ColorMatrixFilter([0.3, 0.6, 0.08, 0, 0, 0.3, 0.6, 0.08, 0, 0, 0.3, 0.6, 0.08, 0, 0, 0, 0, 0, 1, 0])];
		static public const BLACK_FILTER:Array = [new ColorMatrixFilter([0.0, 0.0, 0.0, 0, 0,
			0.0, 0.0, 0.0, 0, 50,
			0.0, 0.0, 0.0, 0, 50,
			0, 0, 0, 1, 50])];
 		static public const GLOW_FILTER:Array = [new GlowFilter(0xFFFFEA, 1, 15, 15, 5.5)];
		static public const GLOW_HIGH_LIGHT:Array = [new GlowFilter(0x00B7FF, 0, 15, 15, 5)];
		static public const GLOW_RED:Array = [new GlowFilter(0xff0000, 1, 7, 7, 1.5, 2)];

		static private var _perkOverFilter:ColorMatrixFilter = null;
		static private var _perkDownFilter:ColorMatrixFilter = null;
		static private var _ribbonEdgeRed:ColorMatrixFilter = null;

		static public function get glowRed(): BlurFilter
		{
			return BlurFilter.createGlow(0xff3a33, 1, 5);
		}

		static public function get glowLight(): BlurFilter
		{
			return BlurFilter.createGlow(0xFFCC33, 1, 5);
		}

		static public function get glowLightHighlight(): BlurFilter
		{
			return BlurFilter.createGlow();
		}

		static public function get perkOverFilter():ColorMatrixFilter
		{
			if (!_perkOverFilter)
			{
				var matrix:ColorMatrix = new ColorMatrix();
				matrix.adjustColor(10, 15, 0, 0);
				_perkOverFilter = new ColorMatrixFilter(matrix);
			}
			return _perkOverFilter;
		}

		static public function get perkDownFilter():ColorMatrixFilter
		{
			if (!_perkDownFilter)
			{
				var matrix:ColorMatrix = new ColorMatrix();
				matrix.adjustColor(-20, 0, 0, 0);
				_perkDownFilter = new ColorMatrixFilter(matrix);
			}
			return _perkDownFilter;
		}

		static public function get ribbonEdgeRed():ColorMatrixFilter
		{
			if (!_ribbonEdgeRed)
			{
				var matrix:ColorMatrix = new ColorMatrix();
				matrix.adjustColor(-50, 0, 10, 180);
				_ribbonEdgeRed = new ColorMatrixFilter(matrix);
			}
			return _ribbonEdgeRed;
		}
	}
}