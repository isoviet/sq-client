package views
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import buttons.ButtonDouble;
	import screens.ScreenProfile;
	import statuses.Status;

	import com.api.Player;

	public class SexView extends Sprite
	{
		private var sexButton:ButtonDouble = null;
		private var changeSexView:Sprite = null;
		private var status:Status = null;

		public function SexView():void
		{
			super();

			init();
		}

		public function updateSex(sex:int):void
		{
			hide();
			sexButton.setState(sex != Player.WOMAN);
			sexButton.removeEventListener(MouseEvent.CLICK, show);
			sexButton.mouseChildren = (Game.selfId == ScreenProfile.playerId);
			if (this.status)
			{
				this.status.remove();
				this.status = null;
			}

			if (Game.selfId != ScreenProfile.playerId)
				return;

			sexButton.addEventListener(MouseEvent.CLICK, show);
			this.status = new Status(this.sexButton, gls("Сменить пол"));
		}

		private function changeSex(e:MouseEvent):void
		{
			var sex:int = (e.target is ManButton) ? Player.MAN : Player.WOMAN;
			if (sex == Game.self.sex)
			{
				hide();
				return;
			}

			updateSex(sex);

			Game.saveSelf({
				'name': Game.self['name'],
				'sex': sex
			});
			Game.request(Game.selfId, PlayerInfoParser.SEX, true);
		}

		private function hide():void
		{
			this.changeSexView.visible = false;
			Game.stage.removeEventListener(MouseEvent.CLICK, click);
		}

		private function show(e:MouseEvent):void
		{
			this.changeSexView.visible = !this.changeSexView.visible;
			Game.stage.addEventListener(MouseEvent.CLICK, click);

			e.stopImmediatePropagation();
		}

		private function init():void
		{
			this.changeSexView = new Sprite();
			this.changeSexView.visible = false;
			this.changeSexView.y = 15;
			addChild(this.changeSexView);

			var background:SettingsBackground = new SettingsBackground();
			background.x = 1;
			background.width = 23;
			background.height = 59;
			this.changeSexView.addChild(background);

			var manSex:ManButton = new ManButton();
			manSex.x = 1 + int((this.width - manSex.width) / 2);
			manSex.y = 13;
			manSex.addEventListener(MouseEvent.CLICK, changeSex);
			this.changeSexView.addChild(manSex);
			new Status(manSex, gls("Мужской"));

			var womanSex:WomanButton = new WomanButton();
			womanSex.x = 1 + int((this.width - womanSex.width) / 2);
			womanSex.y = 36;
			womanSex.addEventListener(MouseEvent.CLICK, changeSex);
			this.changeSexView.addChild(womanSex);
			new Status(womanSex, gls("Женский"));

			this.sexButton = new ButtonDouble(new ManIcon, new WomanIcon, true);
			addChild(this.sexButton);
		}

		private function click(e:MouseEvent):void
		{
			var gamePoint:Point = Game.gameSprite.globalToLocal(new Point(e.stageX, e.stageY));
			if (gamePoint.x >= this.x && gamePoint.x <= (this.x + this.width) && gamePoint.y >= this.y && gamePoint.y <= (this.y + this.height))
				return;

			hide();
		}
	}
}