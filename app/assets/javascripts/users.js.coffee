jQuery ->
  $('#q').autocomplete
    source: "/search_screen_names"
  onLoad()
  $('form#search').bind('ajax:success', (event, data, status, xhr) ->
    alert(JSON.stringify(graph)))
#    addNeo(graph, {edges:data}))