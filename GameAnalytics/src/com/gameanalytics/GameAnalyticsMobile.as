package com.gameanalytics
{
	import com.gameanalytics.domain.GACore;
	import com.gameanalytics.utils.GADeviceUtilMobile;
	import com.gameanalytics.utils.IGADeviceUtil;

	import flash.display.LoaderInfo;
	import flash.events.EventDispatcher;

	public class GameAnalyticsMobile extends EventDispatcher
	{
		private static var core:GACore;

		public function GameAnalyticsMobile():void
		{
		}

		/**
		 * Initialise the GameAnalytics.
		 *
		 * @param secretKey:String - This is your secret key that you have got from your GameAnalytics account
		 * @param gameKey:String - The game key that is specific to your game. You will get it once you register your game in your GameAnalytics account
		 * @param gameBuild:String - This is the current version of your game so you can spot problems along different release versions.
		 * @param sessionId:String (optional) - You can specify a custom sessionId that should be unique and specific to one game session. If you leave it out, the SDK will create a sessionId for you.
		 * @param userId:String (optional) - You can specify a custom userId that should be unique. If you leave it out, the SDK will create a userId for you.
		 * @param useIDFVinsteadOfIDFA:Boolean (optional) - If you DO NOT use any ads in your application, you should set it to true. This will use the IDFV instead of IDFA as the device id
		 * @param platform:String (optional) - Let's you set a custom platform for example (google, amazon, ios).
		 * @param osVersion:String (optional) - Version of the os, let's you override the one used by Capabilities.
		 * @param deviceName:String (optional) - Let's you set a custom device name.
		 */
		public static function init(secretKey:String, gameKey:String, gameBuild:String, sessionId:String = null, userId:String = null, useIDFVinsteadOfIDFA:Boolean = false, platform:String = null, osVersion:String = null, deviceName:String = null):void
		{
			var deviceUtil:IGADeviceUtil = new GADeviceUtilMobile(useIDFVinsteadOfIDFA, platform, osVersion, deviceName);

			core = new GACore(deviceUtil);
			core.init(secretKey, gameKey, gameBuild, sessionId, userId);
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
		public static function newDesignEvent(eventId:String, value:Number, area:String = null, x:Number = NaN, y:Number = NaN, z:Number = NaN):void
		{
			core.newDesignEvent(eventId, value, area, x, y, z);
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
		public static function newBusinessEvent(eventId:String, amount:uint, currency:String, area:String = null, x:Number = NaN, y:Number = NaN, z:Number = NaN):void
		{
			core.newBusinessEvent(eventId, amount, currency, area, x, y, z);
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
		public static function newUserEvent(gender:String, birthYear:uint = 0, friendCount:uint = 0, facebookId:String = "", googlePlusId:String = "", installPublisher:String = "", installSite:String = "", installCampaign:String = "", installAdGroup:String = "", installAd:String = "", installKeyword:String = "", adTruthId:String = ""):void
		{
			core.newUserEvent(gender, birthYear, friendCount, facebookId, googlePlusId, installPublisher, installSite, installCampaign, installAdGroup, installAd, installKeyword, adTruthId);
		}

		/**
		 * Creates a new design event and adds it to the event queue. Events are sent in batches every couple of seconds
		 *
		 * @param message:String - The message that is associated with this error
		 * @param severity:String - Error severity. Please use the constants in the ErrorSeverity class - for example ErrorSeverity.CRITICAL
		 * @param area:String (optional) - The event area (for example, "Level 1")
		 * @param x:Number (optional) - The x coordinate of this event
		 * @param y:Number (optional) - The y coordinate of this event
		 * @param z:Number (optional) - The z coordinate of this event
		 *
		 */
		public static function newErrorEvent(message:String, severity:String, area:String = null, x:Number = NaN, y:Number = NaN, z:Number = NaN):void
		{
			core.newErrorEvent(message, severity, area, x, y, z);
		}

		/**
		 * Sends all events immediately to the server
		 */
		public static function sendData():void
		{
			core.sendData();
		}

		/**
		 * Deletes all pending events from both the current event queue and the local shared storage. Useful if you have had any problems with corrupted data that is now stuck in the local storage
		 */
		public static function deleteAllEvents():void
		{
			core.deleteAllEvents();
		}

		/**
		 * If the DEBUG_MODE is set to true, you can listen for the log events that are dispatched by the SDK (basically, they contain the same text that you see in the traces).
		 * This can be useful if device debugging is not available on your device and you want to output the debugging info in your own debug window.
		 *
		 * Your callBack function should have a GALogEvent as parameter, similar to this:
		 *
		 * private function onLogEvent(e:GALogEvent):void
		 * {
		 *	 	trace(e.text);
		 * }
		 *
		 * @param callBackFunction:Function - your function that will receive the GALogEvent
		 */
		public static function getLogEvents(callBackFunction:Function):void
		{
			core.addEventListener(GALogEvent.LOG, callBackFunction);
		}

		/**
		 * You can automatically catch any unhandled exceptions and send them as Error events to the GameAnalytics. Optionally, you can surpress the exceptions from appearing in the Flash player
		 *
		 * NOTE: Please be careful with the exceptions surpressing since you will not see any runtime errors anymore
		 *
		 * @param loaderInfo:LoaderInfo - the loaderInfo from your main application class
		 * @param surpressExceptions:Boolean - wheter the exceptions should be surpressed or not
		 */
		public static function catchUnhandledExceptions(loaderInfo:LoaderInfo, surpressExceptions:Boolean):void
		{
			core.catchUnhandledExceptions(loaderInfo, surpressExceptions);
		}

		/**
		 * Destroys everything for a clean garbage collection. No need to call this unless you are using the GameAnalytics in some subloaded modules and want to get the GameAnalytics to be garbage collected properly.
		 * This will also delete all currently queued events.
		 *
		 * You still can re-initialize the GameAnalytics at a later point and use it again.
		 */
		public function destroy():void
		{
			core.destroy();
		}

		////////////////////////////
		//
		//	GETTERS
		//
		////////////////////////////

		/**
		 * Returns the session id for the current user session (either passed by you in the init() function or auto-generated by the SDK)
		 */
		public static function getSessionId():String
		{
			return core.getSessionId();
		}

		/**
		 * Returns the current SDK version
		 */
		public static function getVersion():String
		{
			return core.getVersion();
		}

		/**
		 * Returns the current user id
		 */
		public static function getUserId():String
		{
			return core.getUserId();
		}

		/**
		 * Returns the current initialization state of the SDK.
		 * If you are getting false after calling the init() function, something went really wrong during the initialization.
		 * You should be able to spot the problem if you set the DEBUG_MODE to true
		 */
		public static function isInitialized():Boolean
		{
			return core.isInitialized();
		}

		////////////////////////////
		//
		//	GETTERS / SETTERS
		//
		////////////////////////////

		public static function set DEBUG_MODE(value:Boolean):void
		{
			core.DEBUG_MODE = value;
		}

		public static function get DEBUG_MODE():Boolean
		{
			return core.DEBUG_MODE;
		}

		public static function set RUN_IN_EDITOR_MODE(value:Boolean):void
		{
			core.RUN_IN_EDITOR_MODE = value;
		}

		public static function get RUN_IN_EDITOR_MODE():Boolean
		{
			return core.RUN_IN_EDITOR_MODE;
		}

	}
}
