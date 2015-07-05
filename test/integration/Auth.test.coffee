request = require("supertest")
crypto = require("crypto")
assert = require("assert")
async = require("async")

userStub = ->
  randString = crypto.randomBytes(20).toString("hex")
  username: randString.slice(0, 15)
  biography: randString + " is a auto generated user!"
  email: randString + "@gmail.com"
  password: "123123123123"
  displayName: "John Doe"
  language: "en-us"

describe "Auth", ->
  user = undefined

  # before all create one user stub
  before (done) ->
    async.series [
      createUser = (done) ->
        uStub = userStub()
        password = uStub.password

        User.create(uStub).exec (err, u) ->
          if err
            sails.log.error err
            done(err)
          user = u
          user.password = password
          done()

     ], (err) ->
      if err
        sails.log.error "Error on create stub data", err
        done(err)
      done()


  describe "UnAuthenticated", ->
    describe "JSON Requests", ->
      describe "POST", ->
        it "/auth/login should login user and returns logged in user object", (done) ->
          agent = request.agent "http://localhost:1335"
          agent.post("/auth/login").send(
            email: user.email
            password: user.password
          )
          .expect(200)
          .end (err, res) ->
            if err then done(err)
            assert.ok res.body
            assert.ok res.body.id
            assert.equal res.body.username, user.username
            assert.equal res.body.displayName, user.displayName
            assert.equal res.body.id, user.id
            done();

            # do a seccond request to ensures how user is logged in
            # agent.get("/somecontroller").expect(200).end (err, res) ->
            #   if err then done(err)
            #   assert.ok res.body
            #   assert.ok res.body.user
            #   assert.equal res.body.user.username, user.username
            #   assert.equal res.body.user.displayName, user.displayName
            #   assert.equal res.body.user.id, user.id
            #   done()
