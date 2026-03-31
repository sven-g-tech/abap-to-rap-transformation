@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root View Flight'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZSSVGR_FLIGHT
  as select from /DMO/I_Flight as Flight
{
  key AirlineID,
  key ConnectionID,
  key FlightDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      CurrencyCode,
      PlaneType,
      MaximumSeats,
      OccupiedSeats
}
