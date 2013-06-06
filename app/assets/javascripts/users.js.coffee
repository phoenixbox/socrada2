jQuery ->
  $('#q').autocomplete
    source: "/search_screen_names"
  onLoad()
  $('form#search').bind('ajax:success', (event, data, status, xhr) ->
    addNeo(graph, {edges:data}))