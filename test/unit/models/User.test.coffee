# Test File: Testing User
# File location: test/models/User.test.js

request = require 'supertest'
chai = require 'chai'
expect = chai.expect
should = chai.should()
assert = chai.assert

describe 'UserModel', (done) ->
  describe 'to have', (done) ->
    it 'attributes', (done) ->
        attributes = User.attributes
        expect(attributes).to.have.property 'username'
        expect(attributes).to.have.property 'email'
        expect(attributes).to.have.property 'passports'
        done()
