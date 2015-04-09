package com.gameanalytics.utils
{
	import com.freshplanet.ane.AirDeviceId;

	import flash.system.Capabilities;

	public class GADeviceUtilMobile implements IGADeviceUtil
	{
		private var airDevice:AirDeviceId;
		private var deviceId:String;
		private var platform:String;
		private var osVersion:String;
		private var deviceName:String;

		private var useIDFVinsteadOfIDFA:Boolean;

		public function GADeviceUtilMobile(useIDFVinsteadOfIDFA:Boolean, platform:String, osVersion:String, deviceName:String)
		{
			this.useIDFVinsteadOfIDFA = useIDFVinsteadOfIDFA;
			this.platform = platform;
			this.osVersion = osVersion;
			this.deviceName = deviceName;
			init();
		}

		private function init():void
		{
			airDevice = AirDeviceId.getInstance();

			if (airDevice.isOnDevice)
			{
				// get device ids if on device
				if (airDevice.isOnAndroid)
					airDevice.getID("GameAnalytics", setDeviceId);
				else if (useIDFVinsteadOfIDFA)
					airDevice.getIDFV( setDeviceId );
				else
					airDevice.getIDFA( setDeviceId );
			}
			else
			{
				// create a unique id to test in the simulator
				setDeviceId( GAUniqueIdUtil.createUnuqueId() );
			}
		}

		//callback
		private function setDeviceId(deviceId:String):void
		{
			this.deviceId = deviceId;
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
		public function createInitialUserObject(userId:String, sessionId:String, build:String, sdkVersion:String):Object
		{
			var obj:Object = {user_id: userId, session_id: sessionId, build: build, sdk_version: sdkVersion};

			if (airDevice.isOnDevice)
			{
				// if on device, get device infos

				if (airDevice.isOnAndroid)
				{
					obj.android_id = deviceId;
					obj.platform = this.platform ? this.platform : "Android";
					obj.device = this.deviceName ? this.deviceName : "Android";
					obj.os_major = this.osVersion ? this.osVersion : "Android " + Capabilities.os;
				}
				else
				{
					if (!useIDFVinsteadOfIDFA)
						obj.ios_id = deviceId;

					obj.platform = this.platform ? this.platform : "iPhone OS";

					// Capabilities.os looks like "iPhone OS 7.0.3 iPad3,1"
					// remove "iPhone OS " and we will get "7.0.3" and "iPad 3,1"
					var osArray:Array = Capabilities.os.split("iPhone OS ").join("").split(" ");

					// convert "iPad 3,1" to "iPad 3"
					if (this.deviceName)
						obj.device = this.deviceName;
					else if (osArray.length > 0)
						obj.device = osArray[1].split(",")[0];
					else
						obj.device = osArray[0];

					// convert "7.0.3" to "7"
					obj.os_major = this.osVersion ? this.osVersion : osArray[0].split(".")[0];
					obj.os_minor = osArray[0];
				}
			}
			else
			{
				// If we are in a local simulator (not on device), send the system info
				obj.platform = this.platform ? this.platform : Capabilities.os;
				obj.device = this.deviceName ? this.deviceName : "Desktop";
				obj.os_major = this.osVersion ? this.osVersion : Capabilities.os
			}

			return obj;
		}
	}
}
