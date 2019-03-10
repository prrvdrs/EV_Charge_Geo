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

![graph](https://raw.githubusercontent.com/prrvdrs/evcp-poi/master/figures/graph.png)


## Transformation
