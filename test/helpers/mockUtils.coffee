###
# mockUtils.coffee
# This is a helper that handles repetive mock-related tasks
###
authHelper = require('./authHelper')
RSVP = require('rsvp')

mockUtils =

  registerMockUsers: (logout) ->
    if not global.fixtures
      throw new Error "Barrel fixtures are undefined."
    if not global.fixtures.user.length > 0
      throw new Error "Barrel fixtures have not been populated."
    if not logout then logout = true

    sails.log "--- Registering " + global.fixtures.user.length + " mock users. ---"
    promise = new RSVP.Promise( (fulfill, reject) ->
      promises = []
      for user, key in global.fixtures.user
        promises.push authHelper.registerUser(key, logout)

      RSVP.all(promises)
        .then(
          (results) ->
            sails.log "--- Finished registering mock users. ---"
            fulfill(results)
          , (err) ->
            sails.log "--- Error registering mock users. ---"
            reject(err)
        )
    )

  destroyMockUsers: () ->
    promise = new RSVP.Promise( (fulfill, reject) ->
      authHelper.destroyMockUsers()
        .then(
          (results) ->
            fulfill(results)
          , (err) ->
            reject(err)
        )
    )

###
Expose should to external world.
###
exports = module.exports = mockUtils
