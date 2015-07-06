request = require("supertest")
crypto = require("crypto")
async = require("async")
chai = require("chai")
expect = chai.expect
should = chai.should()
assert = chai.assert
authHelper = require("../helpers/authHelper")


describe "Auth", ->
  user = undefined
  regUserObj = undefined

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
          authHelper.registerRandomUser(done)

        it "should be able to access /thing with registered user", (done) ->
          req = global.agent.get("/thing")
          global.agent.attachCookies(req)
          req.end (err, res) ->
            should.not.exist(err)
            res.status.should.eql 200
            # res.text.should.include 'You are not permitted to perform this action.'
            done()

  describe "Sign Out User", ->
    describe "JSON Requests", ->
      describe "GET", ->
        it "should start with signin", (done) ->
          userObj =
            email: global.fixtures.user[2].email
            password: global.fixtures.passport[2].password
          authHelper.loginUser(done, userObj)

        it "should sign the user out", (done) ->
          req = authHelper.agent.get("/auth/local/logout")
          # authHelper.agent.attachCookies(req)
          req.redirects(1).end (err, res) ->
            should.not.exist(err)
            res.status.should.eql 200
            # res.redirects.should.eql [ "http://localhost:1335/login" ]
            done()
        it "should destroy the user session", (done) ->
          req = authHelper.agent.get("/thing")
          authHelper.agent.attachCookies(req)
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
          authHelper.loginUser(done, userObj)

        it "/thing should allow access", (done) ->
          # do a seccond request to ensures how user is logged in
          req = authHelper.agent.get("/thing")
          authHelper.agent.attachCookies(req)
          req.end (err, res) ->
            should.not.exist(err)
            res.status.should.eql 200
            done()
