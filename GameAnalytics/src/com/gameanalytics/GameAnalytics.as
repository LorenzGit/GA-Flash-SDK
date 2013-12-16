package com.gameanalytics
{
	import com.gameanalytics.domain.GACore;
	import com.gameanalytics.utils.GADeviceUtil;

	import flash.events.EventDispatcher;

	public class GameAnalytics extends EventDispatcher
	{
		private static var core:GACore;

		public function GameAnalytics():void
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
		 */
		public static function init(secretKey:String, gameKey:String, gameBuild:String, sessionId:String = null, userId:String = null):void
		{
			core = new GACore(new GADeviceUtil());
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
		public static function newUserEvent(gender:String, birthYear:uint = NaN, friendCount:uint = NaN, facebookId:String = "", googlePlusId:String = "", installPublisher:String = "", installSite:String = "", installCampaign:String = "", installAdGroup:String = "", installAd:String = "", installKeyword:String = "", adTruthId:String = ""):void
		{
			core.newUserEvent(gender, birthYear, friendCount, facebookId, googlePlusId, installPublisher, installSite, installCampaign, installAdGroup, installAd, installKeyword, adTruthId);
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
		public static function newErrorEvent(eventId:String, message:String, severity:String, x:Number = NaN, y:Number = NaN, z:Number = NaN):void
		{
			core.newErrorEvent(eventId, message, severity, x, y, z);
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

		public static function getLogEvents(callBackFunction:Function):void
		{
			core.addEventListener(GALogEvent.LOG, callBackFunction);
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

