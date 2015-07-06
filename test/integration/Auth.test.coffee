request = require("supertest")
crypto = require("crypto")
async = require("async")
chai = require("chai")
expect = chai.expect
should = chai.should()
assert = chai.assert

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
  agent1 = undefined

  before (done) ->
    # See https://github.com/visionmedia/supertest/issues/46
    agent1 = request.agent(global.sails.hooks.http.app)
    done()

  loginUser = (agent, userObj) ->
    (done) ->
      onResponse = (err, res) ->
        should.not.exist(err)
        res.status.should.eql 200
        agent.saveCookies(res)
        done(agent)
      agent.post("/login")
        .send(userObj)
        .end onResponse

  registerUser = (agent, userObj) ->
    (done) ->
      onResponse = (err, res) ->
        should.not.exist(err)
        res.status.should.eql 200
        agent.saveCookies(res)
        done(agent)
      agent.post("/auth/local/register")
        .send(userObj)
        .end onResponse

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
    describe "JSON Requests", ->
      describe "POST", ->
        it "/auth/local/register should register a user", (done) ->
          uStub = userStub()
          password = uStub.password
          userObj =
            email: uStub.email
            username: uStub.username
            biography: uStub.biography
            displayName: uStub.displayName
            language: uStub.language
            password: password
          regAgent = request.agent(global.sails.hooks.http.app)
          registerUser(regAgent, userObj)
          done()

  describe "Sign Out Registered User", ->
    describe "JSON Requests", ->
      describe "GET", ->
        it "should start with signin", (done) ->
          # agent2 = request.agent(sails.hooks.http.app)
          userObj =
            email: global.fixtures.user[0].email
            password: global.fixtures.passport[0].password
          loginUser(agent1,userObj)
          done()
        it "should sign the user out", (done) ->
          req = agent1.get("/auth/local/logout")
          agent1.attachCookies(req)
          req.redirects(1).end (err, res) ->
            should.not.exist(err)
            res.status.should.eql 200
            # res.redirects.should.eql [ "http://localhost:1335/login" ]
            done()
        it "should destroy the user session", (done) ->
          req = agent1.get("/thing")
          agent1.attachCookies(req)
          req.end (err, res) ->
              should.exist(err)
              expect(res).to.have.property('error')
              res.status.should.eql 403
              res.text.should.include 'You are not permitted to perform this action.'
              done()

  describe "UnAuthenticated", ->
    describe "JSON Requests", ->
      describe "POST", ->
        it "/auth/local should login user", (done) ->
          userObj =
            email: global.fixtures.user[1].email
            password: global.fixtures.passport[1].password
          loginUser(agent1, userObj)
          done()
        it "/thing should allow access", (done) ->
            # do a seccond request to ensures how user is logged in
            req = agent1.get("/thing")
            agent1.attachCookies(req)
            req.end (err, res) ->
                sails.log res
                should.not.exist(err)
                res.status.should.eql 200
                done()
