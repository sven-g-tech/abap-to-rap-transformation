@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Overbooked Flights'
define root view entity ZSSVGR_FLIGHT_OVERBOOKED
  as select from zssvg_flight as Overbooked

  association [0..1] to /DMO/I_Flight  as _Flight  on  $projection.AirlineID    = _Flight.AirlineID
                                                   and $projection.ConnectionID = _Flight.ConnectionID
                                                   and $projection.FlightDate   = _Flight.FlightDate

  association [0..1] to /DMO/I_Carrier as _Airline on  $projection.AirlineID = _Airline.AirlineID

{
  key carrier_id         as AirlineID,
  key connection_id      as ConnectionID,
  key flight_date        as FlightDate,

      booking_ratio      as BookingRatio,
      is_overbooked_risk as IsOverbookedRisk,
      is_overbooked      as IsOverbooked,

      /* Associations */
      _Flight,
      _Airline
}
