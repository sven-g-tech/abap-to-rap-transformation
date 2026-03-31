@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Connection Transactional Interface'
define root view entity ZSSVGI_CONNECTION
  provider contract transactional_interface
  as projection on ZSSVGR_CONNECTION


{
  key AirlineID,
  key ConnectionID,

      DepartureAirport,
      DestinationAirport,
      DepartureTime,
      ArrivalTime,
      Distance,
      DistanceUnit
}
