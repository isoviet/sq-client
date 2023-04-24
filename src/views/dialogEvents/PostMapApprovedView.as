package views.dialogEvents
{
	import protocol.PacketServer;

	import utils.FieldUtils;

	public class PostMapApprovedView extends PostElementView
	{
		private var inited:Boolean = false;

		private var location:int = 0;
		private var map:int = 0;

		public function PostMapApprovedView(id:int, type:int, map:int, location:int, time:int):void
		{
			super(id, type, time);

			this.location = location;
			this.map = map;
		}

		override public function onShow():void
		{
			if (this.inited)
				return;

			this.inited = true;

			super.onShow();

			addChild(new PostElementAdmin);
			addChild(new GameField("<body><b>" + gls("Информация") + "</b></body>", 85, 5, style));

			var message:GameField = new GameField("", 85, 20, style);
			addChild(message);

			switch (this.type)
			{
				case PacketServer.MAP_APPROVED:
					if (this.map > 0 && Locations.getLocation(this.location) != null)
					{
						message.htmlText = gls("<body>Твоя карта №{0} одобрена модератором\nв локацию «{1}»! Поздравляем!\nВ награду ты получаешь  <b>{2}</b> #Ac.", this.map, Locations.getLocation(location).name, Locations.getLocation(this.location).award);
					}
					else
						message.htmlText = gls("<body>Поздравляем! Твоя карта №{0} одобрена модератором!\nВ награду ты получаешь  <b>{1}</b> #Ac\nВперед в редактор, создавать новые шедевры!", this.map, this.location);
					FieldUtils.replaceSign(message, "#Ac", ImageIconNut, 0.6, 0.6, -message.x -1, -message.y + 1, true);
					break;
				case PacketServer.MAP_REJECTED:
					message.htmlText = gls("<body>К сожалению, твоя карта №{0} отклонена модератором.\nПопытайся снова! Но помни: твоя карта должна быть\nнеповторимой и интересной! Удачи!", this.map);
					break;
				case PacketServer.MAP_RETURN:
					message.htmlText = gls("<body>Дорогой друг! Мы закрываем возможность отправки карт\nна модерацию по причине реконструкции всех локаций.\nОрехи, потраченные на отправку карт, возвращены.");
					break;
			}
		}
	}
}