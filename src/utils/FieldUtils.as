package utils
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.text.TextField;

	public class FieldUtils
	{
		static public function replaceSign(field:TextField, replaceString:String, imageClass:Class, scaleX:Number, scaleY:Number, shiftX:int, shiftY:int, isHtml:Boolean, replace:Boolean = true):Vector.<DisplayObject>
		{
			var index:int = -1;
			var images:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			while (true)
			{
				index = field.text.indexOf(replaceString, ++index);
				if (index == -1)
					break;

				var rectangle:Rectangle = field.getCharBoundaries(index);
				if (rectangle == null)
				{
					trace("Replacing " + replaceString + ", found at " + index + ", but boundaries is null!");
					break;
				}

				var image:DisplayObject = (new imageClass) as DisplayObject;
				image.scaleX = scaleX;
				image.scaleY = scaleY;
				image.x = rectangle.x - shiftX;
				image.y = rectangle.y - shiftY;
				(image as MovieClip).mouseEnabled = false;
				images.push(field.parent.addChild(image));

				if (!replace)
					continue;

				if (isHtml)
					field.htmlText = field.htmlText.replace(replaceString, "    ");
				else
					field.text = field.text.replace(replaceString, "    ");
			}
			return images;
		}

		static public function multiReplaceSign(field:TextField, replaces:Array):void
		{
			while (true)
			{
				var index:int = -1;
				var type:int = -1;
				for (var i:int = 0; i < replaces.length; i++)
				{
					var currentIndex:int = field.text.indexOf(replaces[i]['replaceString']);
					if (currentIndex == -1)
						continue;

					if ((index == -1)||(index > currentIndex))
					{
						index = currentIndex;
						type = i;
					}
				}
				if (index == -1)
					return;

				var rectangle:Rectangle = field.getCharBoundaries(index);
				if (rectangle == null)
				{
					trace("Replacing " + replaces[type]['replaceString'] + ", found at " + index + ", but boundaries is null!");
					return;
				}

				var image:DisplayObject = (new replaces[type]['imageClass']) as DisplayObject;
				image.scaleX = replaces[type]['scaleX'];
				image.scaleY = replaces[type]['scaleY'];
				image.x = rectangle.x - replaces[type]['shiftX'];
				image.y = rectangle.y - replaces[type]['shiftY'];
				field.parent.addChild(image);

				if ('replace' in replaces[type])
					if (!replaces[type]['replace'])
						continue;

				if (replaces[type]['isHtml'])
					field.htmlText = field.htmlText.replace(replaces[type]['replaceString'], "    ");
				else
					field.text = field.text.replace(replaces[type]['replaceString'], "    ");
			}
		}
	}
}