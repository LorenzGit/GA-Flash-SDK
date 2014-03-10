
### Recent Changes:

##### v.2.0.1:

- Implemented the switchToIDFV for the mobile version. This will use the IDFV instead of IDFA as the device id. If you do NOT have any ads in your application, you should use IDFV as the device identifier. ios_id is NOT send in this case in the startup user event.
- Send timer is now reset after sending data manually with sendData(); The data send interval is increased from 5 to 7 seconds to allow longer response times on slow connections
- Fixed the unhandled ioError exception that happened after trying to send data with an invalid game id