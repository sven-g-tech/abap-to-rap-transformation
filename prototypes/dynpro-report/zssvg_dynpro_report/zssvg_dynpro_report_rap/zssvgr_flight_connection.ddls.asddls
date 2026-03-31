@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root View Flight Connection'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZSSVGR_FLIGHT_CONNECTION
  with parameters
    p_target_currency : /dmo/currency_code

  as select from /DMO/I_Flight     as flight

    inner join   /DMO/I_Connection as connection on  flight.ConnectionID = connection.ConnectionID
                                                 and flight.AirlineID    = connection.AirlineID

{
  key flight.AirlineID,
  key flight.ConnectionID,
  key flight.FlightDate,

      connection.DepartureAirport,
      connection.DestinationAirport,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight.Price,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      currency_conversion(
        amount             => flight.Price,
        source_currency    => flight.CurrencyCode,
        target_currency    => $parameters.p_target_currency,
        exchange_rate_date => flight.FlightDate,
        error_handling     => 'SET_TO_NULL'
      ) as PriceInTargetCurrency,
      flight.CurrencyCode,
      flight.PlaneType,
      flight.MaximumSeats,
      flight.OccupiedSeats,
      connection.DepartureTime,
      connection.ArrivalTime,
      connection.Distance,
      connection.DistanceUnit
}
