@EndUserText.label: 'Flight Transactional Interface'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZSSVGI_FLIGHT
  provider contract transactional_interface
  as projection on ZSSVGR_FLIGHT


{
  key AirlineID,
  key ConnectionID,
  key FlightDate,

      Price,
      CurrencyCode,
      PlaneType,
      MaximumSeats,
      OccupiedSeats
}
