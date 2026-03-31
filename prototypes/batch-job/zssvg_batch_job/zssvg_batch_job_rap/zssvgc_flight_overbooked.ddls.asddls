@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View Flight'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZSSVGC_FLIGHT_OVERBOOKED
  provider contract transactional_query
  as projection on ZSSVGI_FLIGHT_OVERBOOKED

{
      @Consumption.valueHelpDefinition: [ { entity: { name: '/DMO/I_CARRIER_STDVH', element: 'AirlineID' } } ]
      @UI.lineItem: [ { position: 10, label: 'Airline' } ]
  key AirlineID,

      @Consumption.valueHelpDefinition: [ { entity: { name: '/DMO/I_CONNECTION_STDVH', element: 'ConnectionID' } } ]
      @UI.lineItem: [ { position: 20, label: 'Connection Number' } ]
  key ConnectionID,

      @UI.lineItem: [ { position: 30, label: 'FlightDate' } ]
  key FlightDate,

      @UI.lineItem: [ { position: 40, label: 'IsOverbooked' } ]
      BookingRatio,

      @UI.lineItem: [ { position: 50, label: 'IsOverbooked' } ]
      IsOverbookedRisk,

      @UI.lineItem: [ { position: 60, label: 'IsOverbooked' } ]
      IsOverbooked
}
