@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View Connection'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZSSVGC_CONNECTION
  provider contract transactional_query
  as projection on ZSSVGI_CONNECTION


{
      @Consumption.valueHelpDefinition: [ {entity.name: '/DMO/I_CARRIER_STDVH' , entity.element: 'AirlineID' }]
      @UI.lineItem: [{ position: 10, label: 'Airline' }]
  key AirlineID,

      @Consumption.valueHelpDefinition: [ {entity.name: '/DMO/I_CONNECTION_STDVH' , entity.element: 'ConnectionID' }]
      @UI.lineItem: [{ position: 20, label: 'Connection Number' }]
  key ConnectionID,

      @Consumption.valueHelpDefinition: [ {entity.name: '/DMO/I_Airport' , entity.element: 'AirportID' }]
      @UI.lineItem: [{ position: 30, label: 'DepartureAirport' }]
      DepartureAirport,

      @Consumption.valueHelpDefinition: [ {entity.name: '/DMO/I_Airport' , entity.element: 'AirportID' }]
      @UI.lineItem: [{ position: 40, label: 'DestinationAirport' }]
      DestinationAirport,

      @UI.lineItem: [{ position: 50, label: 'DepartureTime' }]
      DepartureTime,

      @UI.lineItem: [{ position: 60, label: 'ArrivalTime' }]
      ArrivalTime,

      @UI.lineItem: [{ position: 70, label: 'Distance' }]
      Distance,

      @UI.lineItem: [{ position: 80, label: 'DistanceUnit' }]
      DistanceUnit
}
