request = require 'request'
http = require 'http'
fs = require 'fs'

# add "i-" in front of the instance ID if it isnt there
module.exports.getInstanceID = (InstID) ->
  if /^i-.*$/.test(InstID)
    return InstID
  else
    return "i-"+InstID

module.exports.getSimpleDateWithOffset = (DayOffset) ->
  currentDate = new Date(new Date().getTime() + DayOffset * 24 * 60 * 60 * 1000);
  day = currentDate.getDate()
  if day < 10 then day = "0"+day
  month = currentDate.getMonth() + 1
  if month < 10 then month = "0" + month
  year = currentDate.getFullYear()
  return year+"-"+month+"-"+day

# Returns mm/dd/yyyy from current date
module.exports.getSimpleDate = () ->
  today = new Date  
  dd = today.getDate()  
  #The value returned by getMonth is an integer between 0 and 11, referring 0 to January, 1 to February, and so on.  
  mm = today.getMonth() + 1  
  yyyy = today.getFullYear()  
  if dd < 10  
    dd = '0' + dd  
  if mm < 10  
    mm = '0' + mm  

  return mm + '/' + dd + '/' + yyyy  

# Returns a readable time from a number of seconds
module.exports.secondsToTime = (time) ->
  hours = Math.floor(time / 3600)
  time = time - hours * 3600
  minutes = Math.floor(time / 60)
  seconds = time - minutes * 60
  HRLABEL = "hr"
  MINLABEL = "min"
  if hours > 1
    HRLABEL = "hrs"
  if minutes > 1
    MINLABEL = "mins"
  return "#{hours}#{HRLABEL} #{minutes}#{MINLABEL}"

# Returns a readable file size based on number ob bytes
module.exports.getSizeInReadableFormat = (ItemSize) ->
  FinSizeName = "Kb"
  FinSize = ItemSize / 1000 #in Kb
  if FinSize > 1000
    FinSize = FinSize / 1000 
    FinSizeName = "Mb"
    if FinSize > 1000
      FinSize = FinSize / 1000 #in Gb
      FinSizeName = "Gb"
  FinSize = Number(FinSize).toFixed(2);
  return "#{FinSize} #{FinSizeName}"

# Timeout
module.exports.sleep = (ms) ->
  start = new Date().getTime()
  continue while new Date().getTime() - start < ms

# Converts EPOCH time to readable human time
module.exports.convertEpochToSpecificTimezone = (edate,offset) ->
  
  date = new Date(edate*1000);
  Year = date.getFullYear();
  Month = date.getMonth()+1;
  if Month < 10
    Month = "0"+Month
  Day = date.getDate();
  if Day < 10
    Day = "0"+Day
  hours = date.getHours();
  minutes = "0" + date.getMinutes();
  seconds = "0" + date.getSeconds();

  formattedTime = Year+ '-' +Month+'-'+Day+' ' +hours + ':' + minutes.substr(-2) + ':' + seconds.substr(-2);
  return formattedTime;

