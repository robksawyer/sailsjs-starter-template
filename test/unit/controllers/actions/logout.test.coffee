proxyquire = require('proxyquire')
chai = require('chai')
expect = chai.expect
should = chai.should()
assert = chai.assert

describe 'actions', ->
  describe 'logout', ->
    it 'should trigger default logout if params.type is undefined', (done) ->
      done()
