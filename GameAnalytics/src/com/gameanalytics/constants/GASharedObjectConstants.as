package com.gameanalytics.constants
{

	/**
	 * Provides constants for the local shared object storage
	 */
	public class GASharedObjectConstants
	{
		public static const SHARED_OBJECT_ID:String = "GAME_ANALYTICS_SDK"; // the id that is used to retrieve the local shared object

		public static const SHARED_OBJECT_EVENTQUEUE:String = "GAME_ANALYTICS_EVENTQUEUE"; // the id that is used to store the event queue
		public static const DEVICE_ID:String = "GAME_ANALYTICS_DEVICE_ID"; // the device id for non-mobile devices

		public function GASharedObjectConstants()
		{
		}
	}
}
