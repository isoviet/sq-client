package ru.freetopay.brightstat {
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	
	import ru.freetopay.serialization.json.JSON;
	
	public class BrightStat {
		
		private static function getStorageKey(brandingId:String, userId:String):String { 
			return 'BS_' + brandingId + '_' + userId;
		}
		
		private static var SHARED_OBJECT_ID:String = 'ru.freetopay.brightstat.v0';
		private static var BASE_URL:String = 'http://brightstat.freetopay.ru/inp/';
		
		private static var instance_:BrightStat;
		
		private var eventsQueue_:Array;
		
		public static function getInstance():BrightStat {
			if (instance_ == null) instance_ = new BrightStat();
			return instance_;
		}
		
		private var info_:UserInfo;
		private var brandingId_:String;
		private var initialized_:Boolean;
		private var userData_:String;
		private var vkAPI_:Object;
		private var triesCount_:int = 0;
		
		private static var MAX_TRIES:int = 5;
		
		public static var onError:Function;
		public static var onInit:Function;
		
		public function BrightStat() {
			initialized_ = false;
			isSendingEvents_ = false;
			userData_ = null;
			eventsQueue_ = [];
			_initSent = false;
		}
		
		public static function initWithFullUserInfo(brandingId:String,
											 userId:String,
											 friendsCount:int,
											 sex:String = '0',
											 age:int = 0,
											 city:String = '0',
											 country:String = '0'):void {
			getInstance().initWithFullUserInfo(brandingId, userId, friendsCount, sex, age, city, country);
		}
		
		private function initWithFullUserInfo(brandingId:String,
										 userId:String,
										 friendsCount:int,
										 sex:String = '0',
										 age:int = 0,
										 city:String = '0',
										 country:String = '0'):void {
			this._initSent = false;
			this.initialized_ = false;
			this.brandingId_ = brandingId;
			this.info_ = new UserInfo();
			this.info_.id = userId;
			this.info_.friendsCount = friendsCount;
			this.info_.sex = sex;
			this.info_.age = age;
			this.info_.city = city;
			this.info_.country = country;
			this.sendInit_();
		}
		
		private function initWithVKApi(brandingId:String, userId:int, VK:Object):void {
			this._initSent = false;
			this.initialized_ = false;
			this.brandingId_ = brandingId;
			this.info_ = new UserInfo();
			this.info_.id = String(userId);
			this.vkAPI_ = VK; 
			
			this.sendInit_();
		}
		
		public static function initWithVKApi(brandingId:String, userId:int, VK:Object):void {
			getInstance().initWithVKApi(brandingId, userId, VK);
		}
		
		public static function checkAvailability(onResult:Function):void {
			getInstance().checkAvailability(onResult);
		}
		
		public static function getRedirectURL(eventId:String):String {
			return getInstance().getRedirectURL(eventId);
		}
		
		private function getRedirectURL(eventId:String):String {
			return "http://brightstat.freetopay.ru/inp/event_redirect.php?branding_id=" + encodeURIComponent(this.brandingId_) +
								"&event_id="+encodeURIComponent(eventId)+
								"&user_id="+encodeURIComponent(this.info_.id)+
								"&user_data="+encodeURIComponent(this.userData_);
		}
		
		private var _checkAvailabilityOnInit:Boolean = false;
		private var _onCheckAvailability:Function;
		
		private function checkAvailability(onResult:Function):void {
			if (onResult == null) return;
			
			if (!initialized_) {
				_checkAvailabilityOnInit = true;
				_onCheckAvailability = onResult;
				return;
			}
			
			_checkAvailabilityOnInit = false;
			
			var so:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			if (so && so.data[getStorageKey(this.brandingId_, this.info_.id)]) 
				var userData:String = so.data[getStorageKey(this.brandingId_, this.info_.id)];
			
			var request:URLRequest = new URLRequest('http://brightstat.freetopay.ru/inp/checkAvailability.php');
			request.method = URLRequestMethod.POST;
			
			var vars:URLVariables = new URLVariables();
			vars.user_id = this.info_.id;
			vars.branding_id = this.brandingId_;
			vars.user_data = this.userData_ ? this.userData_ : 'null';
			request.data = vars;
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				var data:String = String(loader.data);
				if (!data.length) {
					onResult(false);
					return;
				}
				var res:Object = null;
				try {
					res = ru.freetopay.serialization.json.JSON.decode(data);
				}catch(error:Error) {
					log_('JSON parsing failed: '+error.message);
					onResult(false);
					return;
				}
				
				if (!res) {
					onResult(false);
					return;
				}
				
				onResult(res['status']);
			});
			loadURL_(loader, request);
		}
		
		private function sendInit_():void {
			
			var so:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
			if (so && so.data[getStorageKey(this.brandingId_, this.info_.id)]) 
				userData_ = so.data[getStorageKey(this.brandingId_, this.info_.id)];
			
			var request:URLRequest = new URLRequest(BASE_URL + 'init.php');
			request.method = URLRequestMethod.POST;
			
			var vars:URLVariables = new URLVariables();
			vars.user_id = this.info_.id;
			vars.branding_id = this.brandingId_;
			vars.user_data = this.userData_ ? this.userData_ : 'null';
			request.data = vars;
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				var data:String = String(loader.data);
				if (data.length == 0) {
					getBrandingUserId_();
				}else {
					saveBrandingUserId_(data);
				}
			});
			loadURL_(loader, request);
		}
		
		private function sendFullInit_():void {
			var request:URLRequest = new URLRequest(BASE_URL + 'init.php');
			request.method = URLRequestMethod.POST;
			
			var vars:URLVariables = new URLVariables();
			vars.user_id = this.info_.id;
			vars.branding_id = this.brandingId_;
			vars.sex = this.info_.sex;
			vars.age = this.info_.age;
			vars.city = this.info_.city;
			vars.country = this.info_.country;
			vars.friends_count = this.info_.friendsCount;
			
			request.data = vars;
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				var data:String = String(loader.data);
				if (data.length == 0) {
					log_('Brightstat: Error getting branding user id');
					if (onError != null) onError('Error getting branding user id');
				}else {
					saveBrandingUserId_(data);
				}
			});
			loadURL_(loader, request);
		}
		
		private function log_(msg:String):void {
			trace('[BrightStat]', msg);
		}
		
		private function loadURL_(loader:URLLoader, request:URLRequest):void {
			try {
				loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
					log_('Error loading' + ' ' + request.url + ' : ' + e + ' ' + loader.data);
					if (onError != null) onError('Error loading' + ' ' + request.url + ' : ' + e + ' ' + loader.data);
				});
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent):void {
					log_('Error loading' + ' ' + request.url + ' : ' + e + ' ' + loader.data);
					if (onError != null) onError('Error loading' + ' ' + request.url + ' : ' + e + ' ' + loader.data);
				});
				loader.load(request);
			}catch (e:Error) {
				log_('Error loading' + ' ' + request.url + ' : ' + e + ' ' + loader.data);
				if (onError != null) onError('Error loading' + ' ' + request.url + ' : ' + e + ' ' + loader.data);
			}
		}
		
		private var _initSent:Boolean = false;
		
		private function saveBrandingUserId_(data:String):void {
			var so:SharedObject = SharedObject.getLocal(SHARED_OBJECT_ID);
            if (so) {
                so.data[getStorageKey(this.brandingId_, this.info_.id)] = data;
				try{
					so.flush();
				} catch (e: Error) {
					trace('Error: saveBrandingUserId_: ' + e.message);
				}
                
            }

			this.userData_ = data;
			this.initialized_ = true;
			if (!_initSent) {
				if (_checkAvailabilityOnInit) this.checkAvailability(this._onCheckAvailability);
			}
			if (onInit != null && !_initSent) {
				_initSent = true;
				onInit();
			}
			this.sendNextEvent_();
		}
		
		private function getBrandingUserId_():void {
			var info:UserInfo = this.info_;
			var self:BrightStat = this;
			if (this.vkAPI_) {
				this.vkAPI_.api('users.get', {
					'uids': [String(info.id)],
					'fields': ['city', 'country', 'sex', 'counters', 'bdate']
				}, function(res:Object):void {
					res = res[0];
					info.city = String(res['city']);
					info.country = String(res['country']);
					info.sex = String(res['sex']);
					info.friendsCount = res['counters']['friends'];
					if (res['bdate']) {
						var parts:Array = String(res['bdate']).split('.');
						if (parts.length == 3) {
							var d1:Date = new Date();
							var d2:Date = new Date(Date.UTC(parseInt(parts[2]), parseInt(parts[1])-1, parseInt(parts[0])));
							
							var age:int = d1.getUTCFullYear() - d2.getUTCFullYear();
							var m:int = d1.getUTCMonth() - d2.getUTCMonth();
							if (m < 0 || (m === 0 && d1.getUTCDate() < d2.getUTCDate())) {
								age--;
							}
							info.age = age;
						}
					}
					sendFullInit_();
				}, function(error:Object):void {
					if (triesCount_ < MAX_TRIES) {
						triesCount_++;
						setTimeout(function():void {
							self.getBrandingUserId_();
						}, Math.pow(2, triesCount_)*1000);
					}else {
						if (onError != null) onError('BrightStat VK API error');
						log_('BrightStat VK API error');
					}
					//throw new Error(error);
				});
			}else {
				sendFullInit_();
			}
		}
		
		public static function eventComplete(eventId:String):void {
			getInstance().eventComplete(eventId);
		}
		
		private function eventComplete(eventId:String):void {
			eventsQueue_.push(eventId);
			
			if (this.initialized_ && !this.isSendingEvents_) {
				this.sendNextEvent_();
			}
		}
		
		private var isSendingEvents_:Boolean;
		
		private function sendNextEvent_():void {
			this.isSendingEvents_ = this.eventsQueue_.length > 0; 
			if (this.eventsQueue_.length) {
				var eventId:String = this.eventsQueue_.splice(0, 1)[0];
					
				var request:URLRequest = new URLRequest(BASE_URL + 'event_complete.php');
				request.method = URLRequestMethod.POST;
				
				var vars:URLVariables = new URLVariables();
				vars.user_id = this.info_.id;
				vars.branding_id = this.brandingId_;
				vars.user_data = this.userData_ ? this.userData_ : 'null';
				vars.event_id = eventId;
				
				request.data = vars;
				
				var loader:URLLoader = new URLLoader();
				loader.dataFormat = URLLoaderDataFormat.TEXT;
				loader.addEventListener(Event.COMPLETE, function(e:Event):void {
					//trace ('event_complete', loader.data);
					if (loader.data)
						saveBrandingUserId_(loader.data);
					else
						sendNextEvent_();
				});
				
				loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
					sendNextEvent_();
				});
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent):void {
					sendNextEvent_();
				});
				
				loadURL_(loader, request);
			}
		}
	}
}