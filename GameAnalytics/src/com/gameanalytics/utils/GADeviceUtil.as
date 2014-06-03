package com.gameanalytics.utils
{
	import com.gameanalytics.constants.GASharedObjectConstants;
	import com.gameanalytics.domain.GACore;

	import flash.net.SharedObject;
	import flash.system.Capabilities;

	/**
	 * Used to generate a device id for non-mobile applications.
	 */
	public class GADeviceUtil implements IGADeviceUtil
	{
		private var deviceId:String;

		public function GADeviceUtil()
		{
			init();
		}

		private function init():void
		{
			// try to read the local shared object to see if we have an id stored
			var obj:SharedObject = SharedObject.getLocal(GASharedObjectConstants.SHARED_OBJECT_ID);

			// check if we have got something
			if (obj && obj.data && obj.data[GASharedObjectConstants.DEVICE_ID] != undefined)
			{
				deviceId = obj.data[GASharedObjectConstants.DEVICE_ID];
			}
			else
			{
				// if there is no device id yet, create one
				deviceId = GAUniqueIdUtil.createUnuqueId();

				// if shared object is enabled, store it for the application usage in the future
				if (obj)
				{
					obj.data[GASharedObjectConstants.DEVICE_ID] = deviceId;
					obj.flush();
				}
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
			return false;
		}

		/**
		 * Builds the initial user event with device information
		 */
		public function createInitialUserObject(userId:String, sessionId:String, build:String, sdkVersion:String):Object
		{
			return {user_id: userId, session_id: sessionId, build: build, platform: Capabilities.os, os_major: Capabilities.os, sdk_version: sdkVersion};
		}
	}
}
