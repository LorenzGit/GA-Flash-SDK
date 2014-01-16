package com.gameanalytics.utils
{

	public interface IGADeviceUtil
	{
		function getDeviceId():String;
		function createInitialUserObject(userId:String, sessionId:String, build:String, sdkVersion:String):Object;
	}
}
