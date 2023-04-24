package dialogs
{
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFormat;

	import buttons.ButtonBase;

	import com.api.Services;

	public class DialogPromoGroup extends Dialog
	{
		static private const FORMAT:TextFormat = new TextFormat(null, 12, 0x673401, true, null, null, null, null, "center");

		private var field:GameField = null;

		public function DialogPromoGroup():void
		{
			super(gls("Промо-акция"));

			init();
		}

		private function init():void
		{
			this.field = new GameField(gls("Вступи в официальную группу, чтобы\nучаствовать в промо-акции!"), 0, 0, FORMAT);
			addChild(this.field);

			var button:ButtonBase = new ButtonBase(gls("Вступить"));
			button.addEventListener(MouseEvent.CLICK, onGroup);
			button.x = (this.field.textWidth - button.width) * 0.5;
			button.y = this.field.textHeight + 5;
			addChild(button);

			place();

			this.height += 35;
		}

		private function onGroup(event:MouseEvent):void
		{
			var url:String = "";
			switch (Game.self.type)
			{
				case Config.API_VK_ID:
					url = Services.config.vk_groupAddress;
					break;
				case Config.API_MM_ID:
					url = Services.config.mm_groupAddress;
					break;
				case Config.API_OK_ID:
					url = Services.config.ok_groupAddress;
					break;
				case Config.API_FS_ID:
					url = Services.config.fs_groupAdress;
					break;
				case Config.API_FB_ID:
					url = Services.config.fb_groupAddress;
					break;
			}
			navigateToURL(new URLRequest(url), "_blank");

			hide();
		}
	}
}