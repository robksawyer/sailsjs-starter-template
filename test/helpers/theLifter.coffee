#
# * Location: /test/helpers/theLifter.js
# *
# * @description :: Provides 'lift' and 'lower' methods to set up
# *   and tear down a Sails instance (for use in tests)
#
SailsApp = require("sails").Sails
async = require("async")
fs = require('fs')
path = require("path")
lifted = false
Barrels = require("barrels")
sailsprocess = undefined
global.sails =  undefined
mockUtility = require('./mockUtils')
clear = require("cli-clear")
RSVP = require('rsvp')
request = require("supertest")

global.fixtures = undefined
global.agent = undefined

theLifter =

  # Starts the Sails server, or if already started, stops and then starts it
  #   *
  #   * @param {function} done Callback function
  #   * @usage
  #   * before('bootstrap', function (done) {
  #   *    theLifter.lift(done);
  #   * });
  #
  lift: (next, cb, clearTerm) ->
    #Clear the terminal window
    if not clearTerm then clearTerm = true
    if clearTerm then clear()

    # Check whether the Sails server is already running, and stop it if so
    promise = new RSVP.Promise( (fulfill, reject) ->
      async.waterfall [
        (next) ->
          if lifted
            #Clear the terminal window
            clear()
            theLifter.lower(next)
          next()

        , (next) ->
          # Start the Sails server
          sailsprocess = new SailsApp()
          sailsprocess.log.warn "Lifting sails..."
          sailsprocess.log "Loading models from " + path.join(process.cwd(), "test/fixtures/models")
          sailsLiftSettings =
            port: 1335
            log:
              level: "silly"
            connections:
              test:
                adapter: "sails-disk"
            # loadHooks: [
            #   "blueprints", "controllers", "http", "moduleloader", "orm", "policies", "request", "responses", "session", "userconfig", "views"
            # ]
            hooks:
              "grunt": false
            models:
              # Use in-memory database for tests
              connection: "test"
              migrate: "drop"
            liftTimeout: 10000

          sailsprocess.lift sailsLiftSettings, (err, app) ->
            if err
              sails.log.error err
              reject(err)

            # Load fixtures
            barrels = new Barrels()
            lifted = true
            global.sails = app
            sailsprocess = app

            # Populate the DB
            barrels.populate [ "passport", "user" ], ((err) ->
              if err
                sails.log.error err
                reject(err)

              sails.log "--- Populated the database. ---"
              # Save original objects in `fixtures` variable and return it to the callback
              global.fixtures = barrels.data

              # Set a global request agent
              global.agent = request.agent(sails.hooks.http.app)

              next()
            ), false

        , (next) ->

          # Register any mock users found
          mockUtility.registerMockUsers().then(
            (results) ->
              next()
            , (err) ->
              sails.log.error err
              next()
          )

        , (next) ->
          if cb then cb()

          # Complete the request
          fulfill('You are sailing!')
          next()

        ], next
    )


  # Stops the Sails server
  #   *
  #   * @param {function} done Callback function
  #   * @usage
  #   * after('bootstrap', function (done) {
  #   *    theLifter.lower(done);
  #   * });
  #
  lower: (next) ->
    # Destroy the test database
    fs.unlink path.join(process.cwd(),'.tmp/test.db'), (err) ->
      if (err) then throw err
      console.log 'Successfully deleted local database .tmp/test.db'
      next()


###
Expose should to external world.
###
exports = module.exports = theLifter
