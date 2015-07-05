# Test File: Testing UserController
# File location: test/controllers/UserController.test.js

request = require 'supertest'
chai = require 'chai'
expect = chai.expect
should = chai.should()
assert = chai.assert

describe 'UserController', ->
  agent = request.agent 'http://localhost:1337'
  before (done) ->
      agent
        .post('/auth/local')
        .send({identifier: 'email', password: 'password'})
        .end (err, res) ->
          if err
            return done err
          it 'results', (done) ->
            should.exist res
            done()

  after (done) ->
      agent
        .get('/logout')
        .end (err, res) ->
          if err
            return done(err)
          done()
