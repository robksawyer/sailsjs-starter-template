request = require("supertest")
chai = require("chai")
expect = chai.expect
should = chai.should()
assert = chai.assert

authHelper =
  regUserObj: undefined
  agent: -> global.agent
  userStub: ->
    randString = crypto.randomBytes(20).toString("hex")
    username: randString.slice(0, 15)
    biography: randString + " is a auto generated user!"
    email: randString + "@gmail.com"
    password: "123123123123"
    displayName: "John Doe"
    language: "en-us"

  loginUser: (done, userObj) ->
    global.agent = request.agent(sails.hooks.http.app)
    global.agent.post("/auth/local/login")
      .send(userObj)
      .redirects(1)
      .end (err, res) ->
        sails.log res
        should.not.exist(err)
        res.status.should.eql 200
        global.agent.saveCookies(res)
        done()

  registerUser: (done, userObj) ->
    global.agent = request.agent(sails.hooks.http.app)
    global.agent.post("/auth/local/register")
      .send(userObj)
      .redirects(1)
      .end (err, res) ->
        should.not.exist(err)
        res.status.should.eql 200
        global.agent.saveCookies(res)
        done()

  registerRandomUser: (done) ->
    global.agent = request.agent(sails.hooks.http.app)
    uStub = userStub()
    password = uStub.password
    regUserObj =
      email: uStub.email
      username: uStub.username
      biography: uStub.biography
      displayName: uStub.displayName
      language: uStub.language
      password: password
    global.agent.post("/auth/local/register")
      .send(regUserObj)
      #.redirects(1)
      .end (err, res) ->
        sails.log res
        should.not.exist(err)
        res.status.should.eql 200
        global.agent.saveCookies(res)
        done()
