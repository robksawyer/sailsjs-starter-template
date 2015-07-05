#
# * Location: /test/helpers/theLifter.js
# *
# * @description :: Provides 'lift' and 'lower' methods to set up
# *   and tear down a Sails instance (for use in tests)
#
SailsApp = require("sails").Sails
async = require("async")
lifted = false
Barrels = require("barrels")
sailsprocess = undefined

#loginHelper = require('./login'),
clear = require("cli-clear")
global.fixtures = undefined

theLifter =

  # Starts the Sails server, or if already started, stops and then starts it
  #   *
  #   * @param {function} done Callback function
  #   * @usage
  #   * before('bootstrap', function (done) {
  #   *    theLifter.lift(done);
  #   * });
  #
  lift: (next, cb) ->
    #Clear the terminal window
    clear()
    # Check whether the Sails server is already running, and stop it if so
    async.waterfall [ (next) ->
      if lifted
        #Clear the terminal window
        clear()
        return theLifter.lower(next)
      next()

    # Start the Sails server
    , (next) ->
      sailsprocess = new SailsApp()
      sailsprocess.log.warn "Lifting sails..."
      sailsprocess.log "Loading models from " + require("path").join(process.cwd(), "test/fixtures/models")
      sailsLiftSettings =
        port: 1335
        log:
          level: "debug"
        connections:
          test:
            adapter: "sails-disk"
        models:
          # Use in-memory database for tests
          connection: "test"
          migrate: "drop"
        liftTimeout: 10000

      sailsprocess.lift sailsLiftSettings, (err, app) ->
        if err
          sails.log.error err
          return next(err)

        # Load fixtures
        barrels = new Barrels()
        lifted = true
        global.sails = app
        sailsprocess = app

        # Populate the DB
        barrels.populate [ "passport", "user" ], ((err) ->
          if err
            sails.log.error err
            return next(err)

          sails.log "--- Populated the database. ---"
          # Save original objects in `fixtures` variable and return it to the callback
          global.fixtures = barrels.data

          next()

        ), false

    , (next) ->
      #loginHelper.init(next);
      next()
     ], next


  # Stops the Sails server
  #   *
  #   * @param {function} done Callback function
  #   * @usage
  #   * after('bootstrap', function (done) {
  #   *    theLifter.lower(done);
  #   * });
  #
  lower: (next) ->
    "use strict"
    sailsprocess.log.warn "Lowering sails..."
    sailsprocess.lower (err) ->
      lifted = false
      next err



###
Expose should to external world.
###
exports = module.exports = theLifter
