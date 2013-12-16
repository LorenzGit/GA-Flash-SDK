package com.gameanalytics.utils
{
	import com.freshplanet.ane.AirDeviceId;

	import flash.system.Capabilities;

	public class GADeviceUtilMobile implements IGADeviceUtil
	{
		private var airDeviceId:AirDeviceId;
		private var deviceId:String;

		public function GADeviceUtilMobile()
		{
			init();
		}

		private function init():void
		{
			airDeviceId = AirDeviceId.getInstance();

			if (airDeviceId.isOnDevice)
			{
				// get device ids if on device
				if (airDeviceId.isOnAndroid)
					deviceId = airDeviceId.getID("GameAnalytics");
				else
					deviceId = airDeviceId.getIDFA();
			}
			else
			{
				// create a unique id to test in the simulator
				deviceId = GAUniqueIdUtil.createUnuqueId();
			}
		}

		/**
		 * Returns the device id for non-mobile applications
		 *
		 * @return deviceId:String
		 */
		public function getDeviceId():String
		{
			return deviceId;
		}

		/**
		 * Returns a boolean that indicates if this class
		 *
		 * @return deviceId:String
		 */
		public function isMobileDevice():Boolean
		{
			return true;
		}

		/**
		 * Builds the initial user event with device information
		 */
		public function createInitialUserObject(userId:String, sessionId:String, build:String):Object
		{
			var obj:Object = {user_id: userId, session_id: sessionId, build: build};

			if (airDeviceId.isOnDevice)
			{
				// if on device, get device infos

				if (airDeviceId.isOnAndroid)
				{
					obj.android_id = deviceId;
					obj.platform = Capabilities.os;
					obj.device = Capabilities.os;
					obj.os_major = Capabilities.os;
				}
				else
				{
					obj.ios_id = deviceId;
					obj.platform = "iPhone OS";

					// Capabilities.os looks like "iPhone OS 7.0.3 iPad3,1"
					// remove "iPhone OS " and we will get "7.0.3" and "iPad 3,1"
					var osArray:Array = Capabilities.os.split("iPhone OS ").join("").split(" ");

					// convert "iPad 3,1" to "iPad 3"
					if (osArray.length > 0)
						obj.device = osArray[1].split(",")[0];
					else
						obj.device = osArray[0];

					// convert "7.0.3" to "7"
					obj.os_major = osArray[0].split(".")[0];
					obj.os_minor = osArray[0];
				}
			}
			else
			{
				// If we are in simulator (not on device), send the system info
				obj.platform = Capabilities.os;
				obj.os_major = Capabilities.os
			}

			return obj;
		}
	}
}
