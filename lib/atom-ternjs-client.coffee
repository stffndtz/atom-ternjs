{View} = require 'atom'
module.exports = (port) ->
  completions: (file, end, text) =>
    View.post("http://localhost:#{port}",
      JSON.stringify
        query:
          type: 'completions'
          file: file
          end: end
          types: true
          guess: true
          lineCharPositions: true
          caseInsensitive: true
    ).then (data) ->
      data
  update: (file, text) =>
    View.post("http://localhost:#{port}",
      JSON.stringify
        files: [
            type: 'full'
            name: file
            text: text
        ]
    ).then (data) ->
      data
  definition: (file, end, text) =>
    View.post("http://localhost:#{port}",
      JSON.stringify
        query:
          type: 'definition'
          file: file
          end: end
        files: [
          type: 'full'
          name: file
          text: text
        ]
    ).then (data) ->
      data
