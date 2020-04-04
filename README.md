# An Electricity-Basic Index of Economic Disruption
An electricity-based index of economic disruption for the Philadelphia area (and nearby regions).

This model links electricity and weather data in the PECO load area (Philadelphia and suburban counties) in an attempt to measure economic disruption in response to COVID-19. I am attempting to update this twice a week, and am sharing the code if anyone wants to create similar measures. Documentation and discussion of analysis is provided in the PDF.

Data preparation and analysis is predominantly conducted in Stata, but I have included CSV versions of the post-processed data in case you would prefer to use another software to analyze. If requested, I may try to produce similar code in R. 

There are similar (and broader) efforts underway by other researchers (for example, see Steve Cicala's [recent Twitter thread](https://twitter.com/SteveCicala/status/1240273368110202880)). I will link to them when their work goes live.

![Results as of April 2, 2020](https://github.com/cseveren/PA-Electricity-Economic-Disruption/blob/master/output/dailydevs_both_model2.png)

## Data Sources
* Electricity Data: from [PJM's API](https://www.pjm.com/markets-and-operations/etools/data-miner-2.aspx) (requires an account, but it easy to obtain one)
* Weather Data are from two sources 
  * [Climate Reference Network (CRN)](https://www.ncdc.noaa.gov/crn/qcdatasets.html): High quality data updated often, but with occasional gaps. Fewer variables than other data. Starts a bit later (coverage phases in across the country starting in ~2000).
  * [Local Climatological Data (LCD)](https://www.ncdc.noaa.gov/data-access/land-based-station-data/land-based-datasets/quality-controlled-local-climatological-data-qclcd): Rich data with long, long time series. Actually consists of many types of reports. Can be occasionally spotty. Updated slightly less frequently.
