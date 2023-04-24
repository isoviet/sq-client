package dialogs
{
	import flash.display.Sprite;

	import fl.containers.ScrollPane;

	import tape.list.PlayerResultView;
	import tape.list.events.ListDataEvent;
	import views.MapInfoView;
	import views.PlayerResultListData;

	public class DialogRoundResult extends DialogResults
	{
		public function DialogRoundResult()
		{
			super(null);

		}

		override public function show():void
		{
			super.show();

			this.x = Config.GAME_WIDTH - this.width;
			this.y = 140;
		}

		override protected function setDefaultSize():void
		{
			this.leftOffset = 15;
			this.rightOffset = 20;
			this.topOffset = 10;
			this.bottomOffset = 0;
		}

		override protected function init(classHeader:Class):void
		{
			var bgHeight:int = 340;
			var width:Number = 300;

			this.canClose = true;
			this.drawBackground = true;
			this.caption = gls("Результаты раунда");
			place();

			this.width = 300;
			this.height = bgHeight;

			this.resultLayer = new Sprite();

			this.mapInfo = new MapInfoView();
			this.mapInfo.visible = false;
			this.mapInfo.x = (width - this.mapInfo.width) * 0.5 - 10;
			this.mapInfo.y = 40;
			addChild(this.mapInfo);

			this.listData = new PlayerResultListData();
			this.listData.addEventListener(ListDataEvent.SORTED, updateSelfData);
			this.listPlayers = new PlayerResultView();
			this.listPlayers.x = 0;
			this.listPlayers.y = 0;
			this.listPlayers.setData(this.listData);

			this.scrollPane = new ScrollPane();
			addChild(this.scrollPane);
			this.scrollPane.setStyle("thumbUpSkin", ScrollPaneButton);
			this.scrollPane.setStyle("thumbDownSkin", ScrollPaneButton);
			this.scrollPane.setStyle("thumbOverSkin", ScrollPaneButton);
			this.scrollPane.setStyle("trackUpSkin", BgImageScrollResult);
			this.scrollPane.setStyle("trackDownSkin", BgImageScrollResult);
			this.scrollPane.setStyle("trackOverSkin", BgImageScrollResult);
			this.scrollPane.setStyle("downArrowDownSkin", ButtonDownScrollResult);
			this.scrollPane.setStyle("downArrowOverSkin", ButtonDownScrollResult);
			this.scrollPane.setStyle("downArrowUpSkin", ButtonDownScrollResult);
			this.scrollPane.setStyle("upArrowDownSkin", ButtonUpScrollResult);
			this.scrollPane.setStyle("upArrowOverSkin", ButtonUpScrollResult);
			this.scrollPane.setStyle("upArrowUpSkin", ButtonUpScrollResult);
			this.scrollPane.setStyle("thumbIcon", ScrollPaneThumb);

			this.scrollPane.x = 0;
			this.scrollPane.y = 5;
			this.scrollPane.setSize(275, 232);

			this.scrollSprite = new Sprite();
			this.scrollSprite.addChild(this.listPlayers);

			this.scrollPane.source = this.scrollSprite;
			this.scrollPane.update();

			setBgHeight = bgHeight;
		}

		override protected function set setBgHeight(value:int):void
		{
			this.resultLayer.y = value - 20;
			this.mapInfo.y = value - 76;
		}
	}
}