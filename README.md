# Electric Vehicle Charge Points & Places of Interest

## Getting Started

### Data Source

#### Electric vehicle charge points (EVCP)
* https://www.esb.ie/our-businesses/ecars/charge-point-map
* http://www.cpinfo.ie/data/archive.html

#### Places of interest - Google Places API (POI)
* https://developers.google.com/places/web-service/search

### Description

#### EVCP

| variables         | description                                                                                 |
|-------------------|---------------------------------------------------------------------------------------------|
| date              | yyyymmdd                                                                                    |
| time              | hhmm (Snapshot taken every 5 minutes)                                                       |
| id                |                                                                                             |
| type              | StandardType2, CHAdeMO, CCS, FastAC                                                         |
| status            | OOS (out of service), OOC (out of contact), Part (partially occupied), Occ (fully occupied) |
| coordinates       |                                                                                     |
| address           |                                                                                     |
| latitude          |                                                                                     |
| longitude         |                                                                                     |

![evcp_layout](https://raw.githubusercontent.com/prrvdrs/evcp-poi/master/figures/EVCP_Layout2.PNG)

Note: On a fast multi-standard charger you can only use one of the DC connectors (CHAdeMO and CCS) at a time, however it is possible for the DC connector and fast AC connector to be used at the same time (Source:[ESB](https://www.esb.ie/our-businesses/ecars/how-to-charge-your-ecar)).

#### POI

| variables         | description                                                                                 |
|-------------------|---------------------------------------------------------------------------------------------|
| coordinates_cp    | Coordinates Charging Point                                                                  |
| coordinates_pi    | Coordinates Point of Interest                                                               |
| distance_vincenty | [Vincenty Distance](https://en.wikipedia.org/wiki/Vincenty%27s_formulae)                    |
| id                | [Google Places ID](https://developers.google.com/places/place-id)                           |
| name              |  |
| place_id          |  |
| rating            | rating                                                                                      |
| user_rating       | # of submitted ratings                                                                      |
| scope             |  |
| vicinity          |  |
| type_raw          | List - [All place types](https://developers.google.com/places/supported_types)|
| type_one          | List - [Place Type 1](https://developers.google.com/places/supported_types#table2) |
| type_two          | List - [Place Type 2](https://developers.google.com/places/supported_types#table2) |
| type              | List - Matching (O/1)|


<Graph indexType="custom" height="400" width="400" nodes={[{options:{circleAttr:{radius:25},fixed:true},label:"EVCP",center:{x:274.8,y:156.1}},{options:{circleAttr:{radius:25},fixed:true},label:"PoI_0",center:{x:60.6,y:181.5}},{options:{circleAttr:{radius:25},fixed:true},label:"PoI_1",center:{x:359.6,y:327.8}},{options:{circleAttr:{radius:25},fixed:true},label:"PoI_2",center:{x:60.6,y:395.8}},{options:{circleAttr:{radius:25},fixed:true},label:"PoI_3",center:{x:138.2,y:60.6}},{options:{circleAttr:{radius:25},fixed:true},label:"PoI_4",center:{x:394.4,y:71.8}}]} edges={[{label:"200m",source:0,target:3},{label:"10m",source:0,target:5},{label:"12m",source:0,target:4},{label:"50m",source:0,target:2},{label:"49m",source:0,target:1}]} />

## Transformation
