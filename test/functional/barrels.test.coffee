###
Dependencies
###
chai = require("chai")
expect = chai.expect
should = chai.should()
assert = chai.assert
async = require("async")

describe "Barrels", ->

  # Load fixtures into memory
  describe "constructor", ->
    it "should load all the json files from default folder", ->
      Object.keys(global.fixtures).length.should.be.greaterThan 0, "At least one fixture files should be loaded!"

    it "should set generate lowercase property names for models", ->
      oneWord = Object.keys(global.fixtures).join()
      oneWord.toLowerCase().should.be.eql oneWord, "Property names should be in lowercase!"

  # Populate DB with fixtures
  describe "populate()", ->
    describe "populate(cb)", ->
      it "should populate the DB with users", (done) ->
        User.find().exec (err, users) ->
          if err then done(err)
          gotUsers = (global.fixtures["user"].length > 0)
          usersAreInTheDb = (users.length is global.fixtures["user"].length)
          expect(gotUsers and usersAreInTheDb).be.ok
          done()
