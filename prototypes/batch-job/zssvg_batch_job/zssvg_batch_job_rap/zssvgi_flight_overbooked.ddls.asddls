@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight Overbooked Interface'

define root view entity ZSSVGI_FLIGHT_OVERBOOKED
  provider contract transactional_interface
  as projection on ZSSVGR_FLIGHT_OVERBOOKED

{
  key AirlineID,
  key ConnectionID,
  key FlightDate,

      BookingRatio,
      IsOverbookedRisk,
      IsOverbooked,

      /* Associations */
      _Flight,
      _Airline
}
