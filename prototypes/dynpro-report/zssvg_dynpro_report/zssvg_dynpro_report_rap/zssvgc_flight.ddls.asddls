@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View Flight'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

@UI.headerInfo: {
  typeName: 'Flight',
  typeNamePlural: 'Flights',
  title: {
    label: 'Flight',
    value: 'AirlineID'
  },
  description: {
    label: 'Flight Details',
    value: 'ConnectionID'
  }
}

define root view entity ZSSVGC_FLIGHT
  provider contract transactional_query
  as projection on ZSSVGI_FLIGHT
{
      @UI.facet: [
          { id: 'GeneralInfo', label: 'General Information', purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE, position: 10 },
          { id: 'PlaneInfo', label: 'Aircraft Details', purpose: #STANDARD, type: #FIELDGROUP_REFERENCE, targetQualifier: 'Plane', position: 20 },
          { id: 'SeatsInfo', label: 'Seat Information', purpose: #STANDARD, type: #FIELDGROUP_REFERENCE, targetQualifier: 'Seats', position: 30 },
          { id: 'PriceInfo', label: 'Price Details', purpose: #STANDARD, type: #FIELDGROUP_REFERENCE, targetQualifier: 'Pricing', position: 40 }
      ]

      @Consumption.valueHelpDefinition: [ {entity.name: '/DMO/I_CARRIER_STDVH' , entity.element: 'AirlineID' }]
      @UI: { lineItem: [{ position: 10 }, { type: #FOR_ACTION, dataAction: 'setOccupiedSeats', label: 'Set Occupied Seats'}], identification: [{ position: 10 }, { type: #FOR_ACTION, dataAction: 'setOccupiedSeats', label: 'Set Occupied Seats'}], selectionField: [{ position: 10 }] }
  key AirlineID,

      @Consumption.valueHelpDefinition: [ {entity.name: '/DMO/I_CONNECTION_STDVH' , entity.element: 'ConnectionID' }]
      @UI: { lineItem: [{ position: 20 }], identification: [{ position: 20 }], selectionField: [{ position: 20 }] }
  key ConnectionID,

      @UI: { lineItem: [{ position: 30 }], identification: [{ position: 30 }], selectionField: [{ position: 30 }] }
  key FlightDate,

      @UI.fieldGroup: [{ qualifier: 'Pricing', position: 10 }]
      @UI: { lineItem: [{ position: 40 }], selectionField: [{ position: 40 }] }
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,

      @Consumption.valueHelpDefinition: [ {entity.name: 'I_CURRENCYSTDVH' , entity.element: 'Currency' }]
      @UI.fieldGroup: [{ qualifier: 'Pricing', position: 20 }]
      @UI: { lineItem: [{ position: 50 }], selectionField: [{ position: 50 }] }
      CurrencyCode,

      @Consumption.valueHelpDefinition: [ {entity.name: 'ZUGD_PLANETYPESTDVH' , entity.element: 'PlaneType' }]
      @UI.fieldGroup: [{ qualifier: 'Plane', position: 10 }]
      @UI: { lineItem: [{ position: 60 }], selectionField: [{ position: 60 }] }
      PlaneType,

      @UI.fieldGroup: [{ qualifier: 'Seats', position: 10 }]
      @UI: { lineItem: [{ position: 70 }], selectionField: [{ position: 70 }] }
      MaximumSeats,

      @UI.fieldGroup: [{ qualifier: 'Seats', position: 20 }]
      @UI: { lineItem: [{ position: 80 }], selectionField: [{ position: 80 }] }
      OccupiedSeats

}
