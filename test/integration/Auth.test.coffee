request = require("supertest")
crypto = require("crypto")
async = require("async")
chai = require("chai")
expect = chai.expect
should = chai.should()
assert = chai.assert

agent = undefined
regUser = undefined

userStub = ->
  randString = crypto.randomBytes(20).toString("hex")
  username: randString.slice(0, 15)
  biography: randString + " is a auto generated user!"
  email: randString + "@gmail.com"
  password: "123123123123"
  displayName: "John Doe"
  language: "en-us"

before (done) ->
  agent = request.agent(sails.hooks.http.app)
  done()

describe "Auth", ->

  loginUser = (agent, userObj, done) ->
    agent.post("/auth/local")
      .send(userObj)
      .redirects(1)
      .end( (err, res) ->
        should.not.exist(err)
        agent.saveCookies(res)
        res.req.path.should.eql "/"
        # res.text.should.include "Your Campaigns"
        done()
      )

  logoutUser = (agent, done) ->
    # req = agent.post("/auth/local")
    # agent.attachCookies(req) # Attach cookies (session info) to the request
    agent.get("/logout")
      .redirects(1)
      .end( (err, res) ->
        should.not.exist(err)
        done()
      )

  registerUser = (agent, userObj, done) ->
    agent.post("/auth/local/register")
      .send(userObj)
      .redirects(1)
      .end( (err, res) ->
        should.not.exist(err)
        agent.saveCookies(res)
        res.req.path.should.eql "/"
        # res.text.should.include "Your Campaigns"
        done()
      )

  # before all create one user stub
  # before (done) ->
  #   async.series [
  #     createUser = (done) ->
  #       uStub = userStub()
  #       password = uStub.password
  #       User.create(uStub).exec (err, u) ->
  #         if err
  #           sails.log.error err
  #           done(err)
  #
  #         user = u
  #         user.password = password
  #         done()
  #
  #   ], (err) ->
  #     if err
  #       sails.log.error "Error on create stub data", err
  #       done(err)
  #     done()

  describe "Register User", ->
    describe "Requests", ->
      describe "POST", ->
        it "should register a user", (done) ->
          uStub = userStub()
          password = uStub.password
          regUser =
            email: uStub.email
            username: uStub.username
            biography: uStub.biography
            displayName: uStub.displayName
            language: uStub.language
            password: password
          registerUser(agent, regUser, done)

  describe "Sign Out Registered User", ->
    describe "Requests", ->
      it "should sign the currently logged in user out", (done) ->
        logoutUser(agent, done)
      it "should NOT have access to /thing after logout", (done) ->
        agent.get("/thing")
          .end( (err, res) ->
            should.exist(err)
            expect(res).to.have.property('error')
            res.status.should.eql 403
            res.error.text.should.include 'You are not permitted to perform this action.'
            res.error.path.should.eql '/thing'
            res.text.should.include 'You are not permitted to perform this action.'
            done()
          )

  describe "UnAuthenticated", ->
    describe "Requests", ->
      it "should login user", (done) ->
        userObj =
          identifier: regUser.email
          password: regUser.password
        loginUser(agent, userObj, done)
      it "should allow access to /thing", (done) ->
        # do a seccond request to ensures how user is logged in
        agent.get("/thing")
          .end( (err, res) ->
            should.not.exist(err)
            res.status.should.eql 200
            done()
          )
