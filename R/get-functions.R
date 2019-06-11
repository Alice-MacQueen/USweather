#' @title Get Mesonet Station Info
#'
#' @description The first step for getting weather data for a location is to
#'     find which weather stations are closest to that location. This function
#'     will return a dataframe of Mesonet weather stations that are within some
#'     number of decimal degrees of some dataframe containing latitudes and
#'     longitudes that you provide.
#'
#' @param df A dataframe or tbl_df object that contains columns 'Latitude'
#'     and 'Longitude', and some grouping column to specify distinct locations.
#' @param decdegrees The distance, in decimal degrees,
#' @param loc_key The name of the grouping column that specifies distinct
#'     locations in the dataframe.
#'
#' @return a dataframe containing details for all Mesonet stations that are
#'     within some number of decimal degrees of the latitudes and longitudes
#'     in your input dataset.
#'
#' @examples
#'     \dontrun{get_station_info(df = bean_data, loc_key = "Location_code")}
#'     \dontrun{get_station_info(df = bean_data, decdegrees = 0.5,
#'     loc_key = "Location_code")}
#'
#' @import dplyr
#' @import rlang
#'
#' @export
get_station_info <- function(df, decdegrees = 0.1, loc_key = "Location_code"){
  loc_key <- sym(loc_key)
  locs <- list()
  Location_finder <- df %>%
    group_by(!! loc_key) %>%
    summarize(Lat1 = mean(Latitude, na.rm = TRUE) - decdegrees,
              Long1 = mean(Longitude, na.rm = TRUE) - decdegrees,
              Lat2 = Lat1 + decdegrees*2,
              Long2 = Long1 + decdegrees*2)
  for(i in 1:nrow(df)){
    locs[[i]] <- mesonet_stations %>%
      filter(between(lon, Location_finder$Long1[i], Location_finder$Long2[i]) &
               between(lat, Location_finder$Lat1[i], Location_finder$Lat2[i])) %>%
      arrange(begins)
  }
  station_info <- do.call(rbind.data.frame, locs)
  return(station_info)
}


#' @title Get Mesonet Weather Data
#'
#' @description This function gets weather data from MESONET for a particular
#'     weather station (find this using \link{get_station_info}), then converts
#'     the data into daily averages in Celcius, knots, and 0.1xmm precipitation.
#'     This function requires a lot of arguments, and it really exists just to
#'     test that you have the values specified correctly before you use the next
#'     function, \link{get_mesonet_weather_df}, on a dataframe with columns
#'     that are named correctly.
#'
#' @import httr
#' @import data.table
#' @import dplyr
#' @import lubridate
#'
#' @export
get_mesonet_weather <- function(station, year1, month1, day1, year2, month2, day2, tz){
  MESO_WEA <- GET(url = meso_url,
                  query = list(station = station,
                               data = "all",
                               year1 = year1,
                               month1 = month1,
                               day1 = day1,
                               year2 = year2,
                               month2 = month2,
                               day2 = day2,
                               tz = tz,
                               format = "comma")) %>%
    content() %>%
    read_csv(skip = 5, na = "M") %>%
    mutate(Working_date = as_date(valid)) %>%
    group_by(Working_date) %>%
    summarise(tmin = (min(as.numeric(tmpf), na.rm = TRUE)-32)*(5/9), # convert F to C for all temperatures
              tmax = (max(as.numeric(tmpf), na.rm = TRUE)-32)*(5/9),
              RHmean = mean(as.numeric(relh), na.rm = TRUE),
              dewp = (mean(as.numeric(dwpf), na.rm = TRUE)-32)*(5/9),
              wndk = mean(as.numeric(sknt), na.rm = TRUE),
              prcp = (sum(as.numeric(p01i), na.rm = TRUE)*254), # convert inches to 0.1x mm
              Tdrnl = mean(tmax - tmin),
              Tmean = (mean(as.numeric(tmpf), na.rm = TRUE)-32)*(5/9)) %>%
    mutate_if(is.double, funs(na_if(., NaN)))
  DT <- data.table(MESO_WEA)
  invisible(lapply(names(DT),function(.name) set(DT,
                                                 which(is.infinite(DT[[.name]])),
                                                 j = .name,value =NA)))
  invisible(lapply(names(DT),function(.name) set(DT, which(is.nan(DT[[.name]])),
                                                 j = .name,value =NA)))
  return(DT)
}


#' @title
#'
#' @import httr
#' @import data.table
#' @import dplyr
#' @import lubridate
#'
#' @export
get_mesonet_weather_df <- function(df){
  mn_out <- list()
  for(i in 1:nrow(df)){
    mn_out[[i]] <- GET(url = meso_url,
                       query = list(station = df$station[i],
                                    data = "all",
                                    year1 = df$year1[i],
                                    month1 = df$month1[i],
                                    day1 = df$day1[i],
                                    year2 = df$year2[i],
                                    month2 = df$month2[i],
                                    day2 = df$day2[i],
                                    tz = df$tz[i],
                                    format = "comma")) %>%
      content() %>%
      read_csv(skip = 5, na = "M") %>%
      mutate(Working_date = as_date(valid)) %>%
      group_by(Working_date) %>%
      summarise(tmin = (min(as.numeric(tmpf), na.rm = TRUE)-32)*(5/9), # convert F to C for all temperatures
                tmax = (max(as.numeric(tmpf), na.rm = TRUE)-32)*(5/9),
                RHmean = mean(as.numeric(relh), na.rm = TRUE),
                dewp = (mean(as.numeric(dwpf), na.rm = TRUE)-32)*(5/9),
                wndk = mean(as.numeric(sknt), na.rm = TRUE),
                prcp = (sum(as.numeric(p01i), na.rm = TRUE)*254), # convert inches to 0.1x mm
                Tdrnl = mean(tmax - tmin),
                Tmean = (mean(as.numeric(tmpf), na.rm = TRUE)-32)*(5/9)) %>%
      mutate_if(is.double, funs(na_if(., NaN)))
  }
  MESO_WEA <- do.call(rbind.data.frame, mn_out)
  DT <- data.table(MESO_WEA)
  invisible(lapply(names(DT),function(.name) set(DT,
                                                 which(is.infinite(DT[[.name]])),
                                                 j = .name,value =NA)))
  invisible(lapply(names(DT),function(.name) set(DT, which(is.nan(DT[[.name]])),
                                                 j = .name,value =NA)))
  return(DT)
}
