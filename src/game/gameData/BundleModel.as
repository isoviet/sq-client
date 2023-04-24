package game.gameData
{
	import flash.display.DisplayObject;
	import flash.utils.getDefinitionByName;

	public class BundleModel
	{
		private var _id:int = 0;
		private var _offerId:int = 0;
		private var _name:String = null;
		private var _price:Number = 0;
		private var _discount:int = 0;
		private var _image:String = null;
		private var _nameImgSocial:String = '';
		private var _animation:String = null;
		private var _insidesInfo:Vector.<BundleInsidesInfo> = null;

		public function BundleModel(id:int, offerId:int, name:String, price:Number, discount:int, nameImgSocial:String,
			image: String, animation: String, insidesInfo: Vector.<BundleInsidesInfo>)
		{
			_id = id;
			_offerId = offerId;
			_name = name;
			_price = price;
			_discount = discount;
			_nameImgSocial = nameImgSocial;
			_image = image;
			_animation = animation;
			_insidesInfo = insidesInfo;
		}

		public function get id():int
		{
			return _id;
		}

		public function get offerId():int
		{
			return _offerId;
		}

		public function get name():String
		{
			return _name;
		}

		public function get price():Number
		{
			return _price;
		}

		public function get discount():int
		{
			return _discount;
		}

		public function get nameSocialImage():String
		{
			return _nameImgSocial;
		}

		public function get image():DisplayObject
		{
			var imageClass:Class = getDefinitionByName(_image) as Class;
			return new imageClass;
		}

		public function get animation(): Class
		{
			var imageClass:Class = getDefinitionByName(_animation) as Class;
			return imageClass;
		}

		public function get haveAnimation():Boolean
		{
			return _animation != "";
		}

		public function get insidesInfo(): Vector.<BundleInsidesInfo>
		{
			return _insidesInfo;
		}
	}
}