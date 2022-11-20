module.exports = class GlobalAngle

  id: 1037
  name: 'GlobalAngle'

  constructor: (@resource) ->
    @file = @resource.file
    @data = 30 # If not present, assumed to be 30.

  parse: ->
    # Descriptor version
    @data = @file.readInt()

  export: ->
    @data