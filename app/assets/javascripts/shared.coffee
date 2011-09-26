$ ->
  $("#shared_sharers").tokenInput('/shareds/friends',
    crossDomain: false
    prePopulate: $("#shared_sharers").data("pre")
    theme: 'mac'
  )