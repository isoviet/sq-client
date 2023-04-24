# Installation

Просто добавьте Brightstat.swc к вашему проекту.

# Initialization

Для отправки событий необходимо проинициализировать библиотеку.

Инициализация через VKontakte API:

	BrightStat.initWithVKApi("test2", flashVars['viewer_id'], VK);

Инициализация через передачу всех необходимых параметров:
	
	BrightStat.initWithFullUserInfo...

Метод initWithFullUserInfo принимает следующие параметры:

	initWithFullUserInfo(brandingId:String,
						 userId:int,
						 friendsCount:int,
						 sex:int = 0,
						 age:int = 0,
						 city:int = 0,
						 country:int = 0)

# Sending events


	BrightStat.eventComplete("event2");
	
# Init handler


	BrightStat.onInit = function():void { trace('initialized'); };


# Redirect urls

	BrightStat.getRedirectURL("eventId"):String
	


# Example

	package {
		import flash.display.Sprite;
		import flash.events.Event;
		import flash.text.TextField;
		
		import ru.freetopay.brightstat.BrightStat;
		
		import vk.APIConnection;
		
		public class BrightstatTest extends Sprite {
			
			public function BrightstatTest() {
				this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
			}
			
			private function onAddedToStage(e:Event):void {
				
				var flashVars: Object = stage.loaderInfo.parameters as Object;
				
				var VK:APIConnection = new APIConnection(flashVars);
				
				BrightStat.initWithVKApi("test2", flashVars['viewer_id'], VK);
				BrightStat.eventComplete("event2");
			}
		}
	}

# Custom error handling (for debugging)

	BrightStat.onError = function(message:String):void {
		tf.appendText('\nERROR:'+message);
	};
	