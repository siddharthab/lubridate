#' Get date-time in a different time zone
#'
#' with_tz returns a date-time as it would appear in a different time zone.
#' The actual moment of time measured does not change, just the time zone it is
#' measured in. with_tz defaults to the Universal Coordinated time zone (UTC)
#' when an unrecognized time zone is inputted. See [Sys.timezone()]
#' for more information on how R recognizes time zones.
#'
#' @export with_tz
#' @param time a POSIXct, POSIXlt, Date, chron date-time object or a data.frame
#'   object. When a data.frame all POSIXt elements of a data.frame are processed
#'   with `with_tz()` and new data.frame is returned.
#' @param tzone a character string containing the time zone to convert to. R
#'   must recognize the name contained in the string as a time zone on your
#'   system.
#' @return a POSIXct object in the updated time zone
#' @keywords chron manip
#' @seealso [force_tz()]
#' @examples
#' x <- as.POSIXct("2009-08-07 00:00:01", tz = "America/New_York")
#' with_tz(x, "GMT")
with_tz <- function (time, tzone = ""){
  if(is.data.frame(time)){
    for(nm in names(time)){
      if(is.POSIXt(time[[nm]])){
        time[[nm]] <- with_tz(time[[nm]], tzone = tzone)
      }
    }
    time
  } else {
    check_tz(tzone)
    if (is.POSIXlt(time)) new <- as.POSIXct(time)
    else new <- time
    attr(new, "tzone") <- tzone
    reclass_date(new, time)
  }
}

#' Replace time zone to create new date-time
#'
#' force_tz returns a the date-time that has the same clock time as x in the new
#'  time zone.
#' Although the new date-time has the same clock time (e.g. the
#' same values in the year, month, days, etc. elements) it is a
#' different moment of time than the input date-time. force_tz defaults to the
#' Universal Coordinated time zone (UTC) when an unrecognized time zone is
#' inputted. See [Sys.timezone()] for more information on how R
#' recognizes time zones.
#'
#' @export force_tz
#'
#' @param time a POSIXct, POSIXlt, Date, chron date-time object, or a data.frame
#'   object. When a data.frame all POSIXt elements of a data.frame are processed
#'   with `force_tz()` and new data.frame is returned.
#' @param tzone a character string containing the time zone to convert to. R
#'   must recognize the name contained in the string as a time zone on your
#'   system.
#' @param roll logical. If TRUE, and `time` falls into DST skip assume the next
#'   valid civil time, otherwise return NA. See examples.
#' @return a POSIXct object in the updated time zone
#' @keywords chron manip
#' @seealso [with_tz()]
#' @examples
#' x <- ymd_hms("2009-08-07 00:00:01", tz = "America/New_York")
#' force_tz(x, "UTC")
#' force_tz(x, "Europe/Amsterdam")
#' ## DST skip:
#' y <- ymd_hms("2010-03-14 02:05:05 UTC")
#' force_tz(y, "America/New_York", roll=FALSE)
#' force_tz(y, "America/New_York", roll=TRUE)
force_tz <- function(time, tzone = "", roll = FALSE){
  if(is.data.frame(time)){
    for(nm in names(time)){
      if(is.POSIXt(time[[nm]])){
        time[[nm]] <- force_tz(time[[nm]], tzone = tzone)
      }
    }
    time
  } else {
    check_tz(tzone)
    out <- C_force_tz(as.POSIXct(time), tz = as.character(tzone), roll)
    reclass_date(out, time)
    ## update(time, tz = tzone)
  }
}

check_tz <- function(tz) {}

# Note: alternative method? as.POSIXlt(format(as.POSIXct(x)), tz = tzone)
