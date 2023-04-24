package utils.starling
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import starling.display.DisplayObject;

	public interface IStarlingAdapter
	{
		function hitTestStarling(localPoint:Point, forTouch:Boolean = false):*;

		function removeFromParent(dispose:Boolean = true):void;

		function set pivotX(value:Number):void;

		function get pivotX():Number;

		function set pivotY(value:Number):void;

		function get pivotY():Number;

		function getStarlingView():starling.display.DisplayObjectContainer;

		function addChildStarlingAt(child:*, index:int):void;

		function addChildStarling(child:*):*;

		function removeChildStarling(child:*, dispose:Boolean = true):void;

		function containsStarling(child:*):Boolean;

		function get parentStarling():*;

		function set parentStarling(parent:*):void;

		function getChildStarlingIndex(child:*, onlyReal:Boolean = false):int;

		function setChildStarlingIndex(child:*, index:int):void;

		function getChildStarlingAt(index:int):*;

		function removeChildStarlingAt(index:int, dispose:Boolean = true):starling.display.DisplayObject;

		function set alpha(value:Number):void;

		function get alpha():Number;

		function set name(value:String):void;

		function get name():String;

		function set rotation(value:Number):void;

		function get rotation():Number;

		function set scaleX(value:Number):void;

		function set scaleY(value:Number):void;

		function get scaleX():Number;

		function get scaleY():Number;

		function scaleXY(x:Number, y: Number = 0): void

		function set localRect(value: Rectangle): void

		function get localRect(): Rectangle

		function set x(value: Number): void

		function get x(): Number

		function set y(value: Number): void

		function get y(): Number
	}
}