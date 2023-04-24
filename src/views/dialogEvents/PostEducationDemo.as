package views.dialogEvents
{
	public class PostEducationDemo extends PostElementView
	{
		private var inited:Boolean = false;

		public function PostEducationDemo(id:int, type:int, time:int):void
		{
			super(id, type, time);
		}

		override public function onShow():void
		{
			if (this.inited)
				return;

			this.inited = true;

			super.onShow();

			addChild(new PostElementAdmin);
			addChild(new GameField("<body><b>" + gls("Информация") + "</b></body>", 85, 5, style));

			var message:GameField = new GameField("<body>" + gls("Все важные события будут отображены на твоей почте, ты всегда сможешь\nбыть в курсе всех дел. Также, не забывай проверять почту на наличие\nподарков от друзей!") + "</body>", 85, 20, style);
			addChild(message);
		}
	}
}