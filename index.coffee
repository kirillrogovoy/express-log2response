logsToHtml = (logs, defaultCss, callback) ->
  output = '<script type="text/javascript">'
  for log in logs
    do (log) ->
      log = input: log, css: defaultCss
      callback log
      output += if typeof log.input isnt "object"
        "console.log('%c ' + #{JSON.stringify(log.input)}, '#{log.css}');"
      else
        "console.log(#{JSON.stringify(log.input)});"
  output += '</script>'

module.exports = (options = {}) ->
  _options =
    css: 'background: #222; color: lightgreen;'
    logCallback: () ->
    sendCallback: () ->

  for own key, option of options
    _options[key] = options[key]
  options = _options

  (req, res, next) ->
    res.log = (input) ->
      res.log.stack.push(input)
    res.log.stack = []

    _send = res.send
    res.send = ->
      type = @get 'content-type'
      # content type is html or content type is unknown but res.send input is string
      isHtml = (type? and (type.indexOf 'html') isnt -1) or (not type? and typeof arguments[0] is 'string')
      if isHtml
        options.sendCallback(req, res)
        text = arguments[0]
        text += logsToHtml(res.log.stack, options.css, options.logCallback)
        arguments[0] = text
      _send.apply res, arguments
    next()
