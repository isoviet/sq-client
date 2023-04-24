package statuses
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.text.StyleSheet;

	import events.GameEvent;
	import game.gameData.ExpirationsManager;
	import game.gameData.PowerManager;
	import game.gameData.VIPManager;

	public class StatusPowers extends Status
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 12px;
				color: #1B120E;
			}
		]]>).toString();

		private var text:GameField;
		private var imageEn:DisplayObject;
		private var imageMn:DisplayObject;
		private var imageVIP:DisplayObject;
		private var imageExp:DisplayObject;

		public function StatusPowers(owner:DisplayObject):void
		{
			super(owner);

			init();

			Experience.addEventListener(GameEvent.EXPERIENCE_CHANGED, updateText);
			PowerManager.addEventListener(Event.CHANGE, updateTime);
			PowerManager.addEventListener(GameEvent.ENERGY_CHANGED, updateText);
			PowerManager.addEventListener(GameEvent.MANA_CHANGED, updateText);
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			this.text = new GameField("", 12, 2, style);
			addChild(this.text);

			this.imageEn = new ImageIconEnergy();
			this.imageEn.scaleX = this.imageEn.scaleY = 0.55;
			this.imageEn.x = 4;
			this.imageEn.y = 5;
			addChild(this.imageEn);

			this.imageMn = new ImageIconMana();
			this.imageMn.scaleX = this.imageMn.scaleY = 0.55;
			this.imageMn.x = 1;
			this.imageMn.y = this.imageEn.y + this.imageEn.height;
			addChild(this.imageMn);

			this.imageVIP = new ImageIconVIP();
			this.imageVIP.scaleX = this.imageVIP.scaleY = 0.55;
			this.imageVIP.x = 2;
			this.imageVIP.y = this.imageMn.y + this.imageMn.height + 1;
			addChild(this.imageVIP);

			this.imageExp = new ImageIconExp();
			this.imageExp.scaleX = this.imageExp.scaleY = 0.55;
			this.imageExp.x = 2;
			addChild(this.imageExp);

			updateText();
			draw();
		}

		private function updateTime(e:Event = null):void
		{
			updateText();
		}

		private function updateText(e:GameEvent = null):void
		{
			var exp:int = Experience.remainedExp;
			var energyString:String = gls("Энергия: <b>{0}/{1}</b>", PowerManager.currentEnergy, PowerManager.maxEnergy);
			var manaString:String = gls("\nМана: <b>{0}/{1}</b>", PowerManager.currentMana, PowerManager.maxMana);
			if (ExpirationsManager.haveExpiration(ExpirationsManager.MANA_REGENERATION))
			{
				if (!PowerManager.isManaEnergy)
					manaString += ", " + gls("<b>+{0}</b> маны через <b>{1}</b>", 25, ExpirationsManager.timeToManaRegeneration);
				else
					manaString += ", " + gls("у тебя полная мана.");
				manaString += "\n" + gls("Зелье Могущества действует ещё <b>{0}</b>", ExpirationsManager.getDurationString(ExpirationsManager.MANA_REGENERATION));
			}

			var VIPString:String = "";
			var superStatus:String = "";
			var expirienceStatus:String = "\n" + (exp == 0 ? gls("<body>Ты достиг максимального уровня</body>") : gls("<body>До следующего уровня:  <b>{0}</b> опыта</body>", exp));

			if (!PowerManager.isFullEnergy)
				energyString += gls(", <b>+{0}</b> {1} через: <b>{2}</b>", VIPManager.haveVIP ? 2 : 1, VIPManager.haveVIP ? gls("энергии") : gls("энергия"), PowerManager.durationString);

			this.imageVIP.visible = VIPManager.haveVIP;
			this.imageVIP.y = this.imageMn.y + this.imageMn.height + (ExpirationsManager.haveExpiration(ExpirationsManager.MANA_REGENERATION) ? 16 : 1);
			this.imageExp.y = this.imageVIP.y + (this.imageVIP.visible ? this.imageVIP.height + 2 : -1);
			if (VIPManager.haveVIP)
				VIPString += gls("\nVIP-статус действует ещё <b> {0}</b>", VIPManager.durationString);

			this.text.htmlText = "<body>" + energyString + manaString + VIPString + superStatus + expirienceStatus + "</body>";
			draw();
		}
	}
}