package utils
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	import com.api.Player;

	public class PlayerUtil
	{
		static public function formatName(field:TextField, player:Player, width:int, isHtml:Boolean = false, isLink:Boolean = true, forceType:Boolean = false, withRank:Boolean = false):void
		{
			var name:String;
			if (withRank)
				name = player.nameRank;
			else
				name = player.name;

			name += (player['moderator'] && Game.self['moderator'] ? " [M]" : "");
			do
			{
				if (!isHtml)
					field.text = name;
				else
				{
					if (isLink && (player['type'] == Game.self['type'] || forceType))
						field.htmlText = "<body><a class='name' href='event:" + player.id + "'>" + name + "</a></body>";
					else
						field.htmlText = "<body><a class='name'>" + name + "</a></body>";
				}
				name = name.substr(0, name.length - 1);
			}
			while (field.textWidth > width);
		}

		static public function network(player:Player, x:int, y:int, listener:Function = null):Sprite
		{
			return PlayerUtil.networkByType(player.type, x, y, listener);
		}

		static public function networkByType(type:int, x:int, y:int, listener:Function = null):Sprite
		{
			var networkSocial:DisplayObject;
			switch (type)
			{
				default:
				case Config.API_VK_ID:
					networkSocial = new ProfileVKActiveMenuItem();
					break;
				case Config.API_MM_ID:
					networkSocial = new ProfileMMActiveMenuItem();
					break;
			}

			var sprite:Sprite = new Sprite();
			sprite.x = x;
			sprite.y = y;

			networkSocial.height = 16;
			networkSocial.width = 16;
			sprite.addChild(networkSocial);

			if (listener != null)
			{
				sprite.buttonMode = true;
				sprite.addEventListener(MouseEvent.CLICK, listener);
			}

			return sprite;
		}

		static public function stripName(name:String):String
		{
			name = StringUtil.stripHTML(name);
			name = name.replace(new RegExp("[^a-z^A-Z^0-9^а-я^А-Я^ё^Ё^ ^[^]]", "g"), "");
			name = name.substr(0, Config.NAME_MAX_LENGTH);

			return name;
		}
	}
}