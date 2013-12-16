package com.gameanalytics.domain
{
	import com.adobe.crypto.MD5;
	import com.gameanalytics.GALogEvent;
	import com.gameanalytics.constants.GAErrorSeverity;
	import com.gameanalytics.constants.GAEventConstants;
	import com.gameanalytics.constants.GASharedObjectConstants;
	import com.gameanalytics.utils.GAUniqueIdUtil;
	import com.gameanalytics.utils.IGADeviceUtil;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.Timer;

	public class GACore extends EventDispatcher
	{
		// public
		public var RUN_IN_EDITOR_MODE:Boolean; // If set to true, the data will be not sent to the server but you still would see the data that WOULD be sent

		// private
		private const API_URL:String = "http://api.gameanalytics.com"; // The API base URL
		private const API_VERSION:String = "1"; // API version
		private const SDK_VERSION:String = "GA SDK FLASH 1.0.0"; // GameAnalytics SDK version

		private const DATA_SEND_INTERVAL:int = 5000; // Interval for sending data to server (in milliseconds)

		private var debugMode:Boolean;
		private var initialized:Boolean;
		private var secretKey:String;
		private var gameKey:String;
		private var gameBuild:String;
		private var userId:String;
		private var sessionId:String;

		private var sharedObject:SharedObject;
		private var debugArray:Array = [];
		private var eventQueue:Array;
		private var dataSendTimer:Timer;

		private var deviceIdUtil:IGADeviceUtil;

		public function GACore(deviceIdUtil:IGADeviceUtil)
		{
			this.deviceIdUtil = deviceIdUtil;
		}

		////////////////////////////
		//
		//	PUBLIC
		//
		////////////////////////////

		/**
		 * Initialise the GameAnalytics.
		 *
		 * @param secretKey:String - This is your secret key that you have got from your GameAnalytics account
		 * @param gameKey:String - The game key that is specific to your game. You will get it once you register your game in your GameAnalytics account
		 * @param gameBuild:String - This is the current version of your game so you can spot problems along different release versions.
		 * @param sessionId:String (optional) - You can specify a custom sessionId that should be unique and specific to one game session. If you leave it out, the SDK will create a sessionId for you.
		 * @param userId:String (optional) - You can specify a custom userId that should be unique. If you leave it out, the SDK will create a userId for you.
		 */
		public function init(secretKey:String, gameKey:String, gameBuild:String, sessionId:String = null, userId:String = null):void
		{
			if (isValidString(secretKey))
			{
				this.secretKey = secretKey;
			}
			else
			{
				throwError("init() - the secret key can not be null or empty");
				return;
			}

			if (isValidString(gameKey))
			{
				this.gameKey = gameKey;
			}
			else
			{
				throwError("init() - the game key can not be null or empty");
				return;
			}

			if (isValidString(gameBuild))
			{
				this.gameBuild = gameBuild;
			}
			else
			{
				throwError("init() - the game build can not be null or empty");
				return;
			}

			if (userId != null)
			{
				if (isValidString(userId))
				{
					this.userId = userId;
				}
				else
				{
					throwError("init() - the user id can not be null or empty");
					return;
				}
			}
			else
			{
				this.userId = deviceIdUtil.getDeviceId();
			}

			this.sessionId = (sessionId) ? sessionId : GAUniqueIdUtil.createUnuqueId();

			// read saved events from the local storage
			eventQueue = getEventsQueue();

			// send initial user event with device information
			addEventToQueue(GAEventConstants.USER, deviceIdUtil.createInitialUserObject(this.userId, this.sessionId, gameBuild));

			// send events from the local storage(if any) as well as the initial user event
			sendData();

			dataSendTimer = new Timer(DATA_SEND_INTERVAL);
			dataSendTimer.addEventListener(TimerEvent.TIMER, onDataSendTimer);
			dataSendTimer.start();

			initialized = true;
		}

		/**
		 * Loop trough all event type queues and send them to server
		 */
		public function sendData():void
		{
			for (var key:String in eventQueue)
			{
				var array:Array = eventQueue[key];

				if (array.length != 0)
					sendEvent(key, array);
			}
		}

		/**
		 * Creates a new design event and adds it to the event queue. Events are sent in batches every couple of seconds
		 *
		 * @param eventId:String - Your type of an event (for example, "Powerup" or "Ammo pickup")
		 * @param value:Number - This can be the amount of ammo the user have picked up, for example
		 * @param area:String (optional) - Where did this even occur (for example, "Level 2")
		 * @param x:Number (optional) - The x coordinate of this event
		 * @param y:Number (optional) - The y coordinate of this event
		 * @param z:Number (optional) - The z coordinate of this event
		 *
		 */
		public function newDesignEvent(eventId:String, value:Number, area:String = null, x:Number = NaN, y:Number = NaN, z:Number = NaN):void
		{
			addEventToQueue(GAEventConstants.DESIGN, addOptionalParameters({user_id: userId, session_id: sessionId, build: gameBuild, event_id: eventId, value: value}, area, x, y, z));
		}

		/**
		 * Creates a new business event and adds it to the event queue. Events are sent in batches every couple of seconds
		 *
		 * @param eventId:String - Your type of an event (for example, "Level pack purchase" or "Special Weapon unlock")
		 * @param amount:int - The monetary amount of the transaction multiplied by 100. For example, if the amount is 0.99 cents it should be passed as 99
		 * @param currency:String - The currency for thsi transaction (for example, "USD" or "EUR")
		 * @param area:String (optional) - Where did this even occur (for example, "Level 2")
		 * @param x:Number (optional) - The x coordinate of this event
		 * @param y:Number (optional) - The y coordinate of this event
		 * @param z:Number (optional) - The z coordinate of this event
		 *
		 */
		public function newBusinessEvent(eventId:String, amount:uint, currency:String, area:String = null, x:Number = NaN, y:Number = NaN, z:Number = NaN):void
		{
			addEventToQueue(GAEventConstants.BUSINESS, addOptionalParameters({user_id: userId, session_id: sessionId, build: gameBuild, event_id: eventId, amount: amount, currency: currency}, area, x, y, z));
		}

		/**
		 * Creates a new user event and adds it to the event queue. Events are sent in batches every couple of seconds
		 *
		 * @param gender:String - The gender of your user (acceptable values are "M" or "F")
		 * @param birthYear:int (optional) - Full birth year of the user (for example, 1975)
		 * @param friendCount:int (optional) - Number of friends of this user
		 * @param facebookId:String (optional) - User's facebook id
		 * @param googlePlusId:String (optional) - User's google+ id
		 * @param installPublisher:String (optional) - The name of the ad publisher.
		 * @param installSite:String (optional) - The website or app where the ad for your game was shown.
		 * @param installCampaign:String (optional) - The name of your ad campaign this user comes from.
		 * @param installAdGroup:String (optional) - The name of the ad group this user comes from.
		 * @param installAd:String (optional) - A keyword to associate with this user and the campaign ad.
		 * @param installKeyword:String (optional) - A keyword to associate with this user and the campaign ad.
		 * @param adTruthId:String (optional) - The AdTruth ID of the user, in clear.
		 *
		 */
		public function newUserEvent(gender:String, birthYear:uint = NaN, friendCount:uint = NaN, facebookId:String = "", googlePlusId:String = "", installPublisher:String = "", installSite:String = "", installCampaign:String = "", installAdGroup:String = "", installAd:String = "", installKeyword:String = "", adTruthId:String = ""):void
		{
			var object:Object = {user_id: userId, session_id: sessionId, build: gameBuild};

			// check if optional parameters were passed and if they are valid. If so, add them to the event object
			if (isValidString(gender))
			{
				if (gender == "M" || gender == "F")
					object.gender = gender;
				else
					throwError('ERROR: newUserEvent - gender can only have values "M" or "F"')
			}

			if (!isNaN(birthYear))
				object.birth_year = birthYear;

			if (!isNaN(friendCount))
				object.friend_count = friendCount;

			if (!isNaN(friendCount))
				object.friend_count = friendCount;

			if (isValidString(facebookId))
				object.facebook_id = facebookId;

			if (isValidString(googlePlusId))
				object.googleplus_id = googlePlusId;

			if (isValidString(installPublisher))
				object.install_publisher = installPublisher;

			if (isValidString(installSite))
				object.install_site = installSite;

			if (isValidString(installCampaign))
				object.install_campaign = installCampaign;

			if (isValidString(installAdGroup))
				object.install_ad_group = installAdGroup;

			if (isValidString(installAd))
				object.install_ad = installAd;

			if (isValidString(installKeyword))
				object.install_keyword = installKeyword;

			if (isValidString(adTruthId))
				object.adtruth_id = adTruthId;

			addEventToQueue(GAEventConstants.USER, object);
		}

		/**
		 * Creates a new design event and adds it to the event queue. Events are sent in batches every couple of seconds
		 *
		 * @param eventId:String - Your type of an event (for example, "Wrong username" or "Wrong password")
		 * @param message:String - The message that is associated with this error
		 * @param severity:String - Error severity. Please use the constants in the ErrorSeverity class - for example ErrorSeverity.CRITICAL
		 * @param x:Number (optional) - The x coordinate of this event
		 * @param y:Number (optional) - The y coordinate of this event
		 * @param z:Number (optional) - The z coordinate of this event
		 *
		 */
		public function newErrorEvent(eventId:String, message:String, severity:String, x:Number = NaN, y:Number = NaN, z:Number = NaN):void
		{
			if (severity == GAErrorSeverity.CRITICAL || severity == GAErrorSeverity.DEBUG || severity == GAErrorSeverity.ERROR || severity == GAErrorSeverity.INFO || severity == GAErrorSeverity.WARNING)
				addEventToQueue(GAEventConstants.ERROR, addOptionalParameters({user_id: userId, session_id: sessionId, build: gameBuild, event_id: eventId, message: message, severity: severity}, null, x, y, z));
			else
				throwError("newErrorEvent: " + severity + " is not a valid error severity. Please use the ErrorSeverity constants for the types - for example, ErrorSeverity.ERROR");
		}

		/**
		 * Deletes all pending events from both the current event queue and the local shared storage. Useful if you have had any problems with corrupted data that is now stuck in the local storage
		 */
		public function deleteAllEvents():void
		{
			eventQueue = createNewEventsQueue();

			if (sharedObject)
			{
				writeEventQueueToLocalSharedObject(null);
				log("All events deleted from the queue and local shared object");
			}
			else
			{
				log("All events deleted from the queue. Local shared object was not available so nothing was deleted in there");
			}

		}

		////////////////////////////
		//
		//	GETTERS
		//
		////////////////////////////

		/**
		 * Returns the session id for the current user session (either passed by you in the init() function or auto-generated by the SDK)
		 *
		 * @return sessionId:String
		 */
		public function getSessionId():String
		{
			return sessionId;
		}

		/**
		 * Returns the current SDK version
		 *
		 * @return SDK_VERSION:String
		 */
		public function getVersion():String
		{
			return SDK_VERSION;
		}

		/**
		 * Returns the current userId
		 *
		 * @return userId:String
		 */
		public function getUserId():String
		{
			return userId;
		}

		/**
		 * Returns the current initialization state of the SDK.
		 * If you are getting false after calling the init() function, something went really wrong during the initialization.
		 * You should be able to spot the problem if you set the DEBUG_MODE to true
		 *
		 * @return initialized:Boolean
		 */
		public function isInitialized():Boolean
		{
			return initialized;
		}

		/**
		 *  If set to true, the SDK will trace debug information and errors / warnings for you
		 */
		public function set DEBUG_MODE(value:Boolean):void
		{
			debugMode = value;

			// if we already have some debug info, send it in an event
			if (debugMode && debugArray.length != 0)
			{
				var text:String = "";

				for (var i:int = 0; i < debugArray.length; i++)
				{
					text += debugArray[i] + "\n";
				}

				dispatchEvent(new GALogEvent(GALogEvent.LOG, text));
			}
		}

		public function get DEBUG_MODE():Boolean
		{
			return debugMode;
		}

		////////////////////////////
		//
		//	PRIVATE
		//
		////////////////////////////

		/**
		 * Adds an event to queue
		 */
		private function addEventToQueue(type:String, data:Object):void
		{
			if (RUN_IN_EDITOR_MODE)
			{
				log("RUN_IN_EDITOR_MODE is set to true - we will not send this " + type + " event: " + JSON.stringify(data));
			}
			else
			{
				log(type + " event added to queue: " + JSON.stringify(data));

				eventQueue[type].push(data);

				if (!RUN_IN_EDITOR_MODE)
				{
					writeEventQueueToLocalSharedObject(eventQueue);
				}
			}
		}

		/**
		 * Resets the event queue for a certain event type after the data was succesfully sent to the server
		 */
		private function resetQueue(eventType:String):void
		{
			eventQueue[eventType] = [];

			writeEventQueueToLocalSharedObject(eventQueue);
		}

		/**
		 * Sends a single event or the event type queue to the server.s
		 */
		private function sendEvent(type:String, data:Array):void
		{
			var jsonString:String;

			try
			{
				jsonString = JSON.stringify(data);
			}
			catch (e:Error)
			{
				throwError("ERROR: sendEvent - There was an error encoding the event as a JSON object. Error: " + e.message);
			}

			if (RUN_IN_EDITOR_MODE)
			{
				log("Event would be sent to the server if we were not in RUN_IN_EDITOR_MODE: " + type + " - " + jsonString);
				resetQueue(type);
				return;
			}
			else
			{
				log("Sending " + data.length + " " + type + " event(s): " + jsonString);
			}

			var request:URLRequest = new URLRequest(API_URL + "/" + API_VERSION + "/" + gameKey + "/" + type);

			request.data = jsonString;
			request.method = URLRequestMethod.POST;
			request.requestHeaders.push(new URLRequestHeader("Authorization", MD5.hash(jsonString + secretKey)));

			var loader:URLLoader = new URLLoader();
			loader.data = type; // remember data type so we can clear the queue if the sending was successfull
			loader.addEventListener(Event.COMPLETE, onRequestComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onRequestError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequestSecurityError);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onRequestStatus);

			loader.load(request);
		}

		/**
		 * Adds optional parameters to the event if they were passed to the public "new ... event" functions
		 */
		private function addOptionalParameters(object:Object, area:String, x:Number, y:Number, z:Number):Object
		{
			if (area != null && area != "")
				object.area = area;

			if (!isNaN(x))
				object.x = x;

			if (!isNaN(y))
				object.y = y;

			if (!isNaN(z))
				object.z = z;

			return object;
		}

		/**
		 * Read events stored in the local shared object (the events that were not yet send for any reason - missing internet connection, missing saveData() call on aplication exit etc).
		 * If there are no events in the local storage (on initional app startup or because the local sotrage is disabled), a new events queue is created
		 */
		private function getEventsQueue():Array
		{
			var eventsQueue:Array;

			try
			{
				sharedObject = SharedObject.getLocal(GASharedObjectConstants.SHARED_OBJECT_ID);
				eventsQueue = sharedObject.data[GASharedObjectConstants.SHARED_OBJECT_EVENTQUEUE];
			}
			catch (e:Error)
			{
				log("ERROR: Local storage is disabled - please check if the shared objects are enabled in the flash player settings. Events will not be stored locally and might get lost if there will be problems with sending events to the server (for example, if there is no internet connection available");
			}

			if (!eventsQueue)
			{
				log("No events found in local storage, creating new event queue");
				eventsQueue = createNewEventsQueue();
			}

			return eventsQueue;
		}

		private function createNewEventsQueue():Array
		{
			var array:Array = [];
			array[GAEventConstants.BUSINESS] = [];
			array[GAEventConstants.DESIGN] = [];
			array[GAEventConstants.ERROR] = [];
			array[GAEventConstants.QUALITY] = [];
			array[GAEventConstants.USER] = [];

			return array;
		}

		/**
		 * Checks if the strings passed to the funstions are valid
		 */
		private function isValidString(string:String):Boolean
		{
			return (string != null && string.length != 0);
		}

		/**
		 * Throws an exception on critical errors and logs them
		 */
		private function throwError(message:String):void
		{
			log("GameAnalytics Error: " + message);
			throw new Error(message);
		}

		/**
		 * Traces messages if DEBUG_MODE is set to true
		 */
		private function log(message:String):void
		{
			if (debugMode)
			{
				trace("GA SDK " + message);
				dispatchEvent(new GALogEvent(GALogEvent.LOG, message));
			}
			else
			{
				debugArray.push(message);

				if (debugArray.length == 11)
					debugArray.shift();
			}

		}

		private function writeEventQueueToLocalSharedObject(array:Array):void
		{
			if (sharedObject)
			{
				sharedObject.data[GASharedObjectConstants.SHARED_OBJECT_EVENTQUEUE] = array;
				sharedObject.flush();
			}
		}

		////////////////////////////
		//
		//	CALLBACKS
		//
		////////////////////////////

		private function onDataSendTimer(e:TimerEvent):void
		{
			sendData();
		}

		private function onRequestComplete(event:Event):void
		{
			//log("Game Analytics Request Complete: " + event.target.data);
		}

		private function onRequestError(error:IOErrorEvent):void
		{
			log("ERROR - There was an error with the Game Analytics Server. " + error.text);
		}

		private function onRequestSecurityError(error:SecurityErrorEvent):void
		{
			log("ERROR - There was an error with the Game Analytics Server. " + error.text);
		}

		private function onRequestStatus(event:HTTPStatusEvent):void
		{
			switch (event.status)
			{
				case 200:
					// everything seem to be fine
					log(event.currentTarget.data + " event(s) were sent successfully.");
					resetQueue(event.currentTarget.data);
					break;

				case 400:
					log("ERROR while sending " + event.currentTarget.data + " event(s). Most likely this is because of an incorrect secret key, game id or corrupt JSON data");
					break;

				case 401:
					log("ERROR while sending " + event.currentTarget.data + " event(s). Most likely this is because of an incorrect secret key, game id or the value of the authorization header is not valid or missing");
					break;

				case 403:
					log("ERROR while sending " + event.currentTarget.data + " event(s). The url is invalid");
					break;

				case 404:
					log("ERROR while sending " + event.currentTarget.data + " event(s). Most likely the secret key or the game id are incorrect or there is a problem with the API call");
					break;

				case 500:
					log("ERROR while sending " + event.currentTarget.data + " event(s). Internal server error");
					break;

				case 501:
					log("ERROR while sending " + event.currentTarget.data + " event(s). The used HTTP method is not supported.");
					break;

				default:
					log("ERROR while sending " + event.currentTarget.data + " event(s). Unknown error with the response code of " + event.status);
			}

		}
	}
}
