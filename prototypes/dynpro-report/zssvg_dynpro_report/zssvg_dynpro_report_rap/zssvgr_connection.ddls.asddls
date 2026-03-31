@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root View Flight'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZSSVGR_CONNECTION
  as select from /DMO/I_Connection as Connection
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
