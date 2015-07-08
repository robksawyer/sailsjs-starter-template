###
# authHelper.coffee
# Helps with Authorization related tasks
###
request = require("supertest")
crypto = require("crypto")
RSVP = require('rsvp')

userStub = ->
  randString = crypto.randomBytes(20).toString("hex")
  username: randString.slice(0, 15)
  biography: randString + " is a auto generated user!"
  email: randString + "@gmail.com"
  password: "123123123123"
  displayName: "John Doe"
  language: "en-us"

authHelper =

  ###
  # Handles logging in a user based on the user id
  ###
  loginUser: (key) ->
    promise = new RSVP.Promise( (fulfill, reject) ->
      if not global.agent[key]
        global.agent[key] = request.agent(sails.hooks.http.app)
      userObj =
        identifier: global.fixtures.user[key].email
        password: global.fixtures.passport[key].password
      global.agent[key]
        .post("/auth/local")
        .send(userObj)
        .redirects(1)
        .end( (err, res) ->
          if err
            sails.log.error err
            reject(err)
          else
            global.agent[key].saveCookies(res)
            fulfill(res)
        )
    )

  ###
  # Handles logging out the current user
  ###
  logoutUser: (key) ->
    promise = new RSVP.Promise( (fulfill, reject) ->
      if not global.agent[key]
        global.agent[key] = request.agent(sails.hooks.http.app)
      global.agent[key]
        .get("/logout")
        .redirects(1)
        .end( (err, res) ->
          if err
            sails.log.error err
            reject(err)
          else
            fulfill(res)
        )
    )

  ###
  # Handles registering a user based on the user id
  ###
  registerUser: (key, logout) ->
    if not logout then logout = true
    if not global.agent[key]
      global.agent[key] = request.agent(sails.hooks.http.app)
    promise = new RSVP.Promise( (fulfill, reject) ->
      agent[key] = request.agent(sails.hooks.http.app)
      uStub = userStub()
      password = global.fixtures.passport[key].password
      userObj =
        email: global.fixtures.user[key].email
        username: global.fixtures.user[key].username
        biography: uStub.biography
        displayName: global.fixtures.user[key].displayName
        language: uStub.language
        password: password
      global.agent[key]
        .post("/auth/local/register")
        .send(userObj)
        .redirects(1)
        .end( (err, res) ->
          if err
            if err.status is 302 #Moved temporarily
              global.agent[key].saveCookies(res)
              fulfill err
            else
              reject(err)
          else
            global.agent[key].saveCookies(res)
            fulfill(res)
            # if logout
            #   User.findOne({email: userObj.email})
            #     .populate('passports')
            #     .exec(
            #       (err, user) ->
            #         if err then reject(err)
            #         console.log user
            #         sails.log.warn "Registered user " + user.id + " and now logging user out."
            #         # Log the user out
            #         authHelper.logoutUser()
            #           .then(
            #             (res) ->
            #               fulfill(res)
            #             , (err) ->
            #               reject(err)
            #           )
            #     )
            #
            # else
        )
    )

  ###
  # Handles destroying all of the mock user's in the database
  ###
  destroyMockUsers: (total) ->
    promise = new RSVP.Promise( (fulfill, reject) ->
      if not total then total = global.fixtures.user.length
      sails.log.warn "Destroying " + total + " mock records."
      User.destroy({id: [1..total]}).exec( (err) ->
        if err
          sails.log.error err
          reject(err)
        else
          Passport.destroy({user: [1..total]}).exec( (err) ->
            if (err)
              sails.log.error err
              reject(err)
            else
              fulfill()
          )
      )
    )

###
Expose should to external world.
###
exports = module.exports = authHelper
