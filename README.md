# Electric car charge points & Places of interest

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
| charge point type | StandardType2, CHAdeMO, CCS, FastAC                                                         |
| status            | OOS (out of service), OOC (out of contact), Part (partially occupied), Occ (fully occupied) |


![alt text, 70%](https://raw.githubusercontent.com/prrvdrs/evcp-poi/master/figures/EVCP_Layout2.PNG)

Note: On a fast multi-standard charger you can only use one of the DC connectors (CHAdeMO and CCS) at a time, however it is possible for the DC connector and fast AC connector to be used at the same time (Source:[ESB](https://www.esb.ie/our-businesses/ecars/how-to-charge-your-ecar)).


#### POI

