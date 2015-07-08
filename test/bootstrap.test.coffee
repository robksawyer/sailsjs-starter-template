###
# Mocha bootstrap file for backend application tests.
###

theLifter = require('./helpers/theLifter')
RSVP = require('rsvp')

# Mocha bootstrap before function, that is run before any tests are being processed. This will lift sails.js with
# test configuration.
# *
# Note! Tests will use localDiskDb connection and this _removes_ possible existing disk store file from .tmp folder!
# *
# @param   {Function}  next    Callback function
before (done) ->
  theLifter.lift(done).then(
    (res) ->
      sails.log res
    , (err) ->
      sails.log.error err
  )

# Mocha bootstrap after function, that is run after all tests are processed. Main purpose of this is just to
# lower sails test instance.
#
# @param   {Function}  next    Callback function

after (done) ->
  console.log() # Skip a line before displaying Sails lowering logs
  theLifter.lower(done)
