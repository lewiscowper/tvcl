fs = require('fs')
xml2js = require 'xml2js'
async = require 'async'
path = require('path')
_ = require 'underscore'

{error} = require '../lib/utils'

BASE = "#{process.env['HOME']}/.tvcli"
BASE_STORE = "#{BASE}/store"

storage = {}

findEp = (epId) ->
  ids = Object.keys(storage)
  series = findByEp(epId)
  return undefined if !series
  episodes = series['Data']['Episode']
  _.find episodes, (e) ->
      e['id'][0] == epId

findByEp = (epId) ->
  ids = Object.keys(storage)
  id = _.find ids, (id) ->
    episodes = storage[id]['Data']['Episode']
    _.some episodes, (e) ->
      e['id'][0] == epId
  storage[id]

readSeries = (id, cb) ->
  xml_file = "#{BASE_STORE}/#{id}/en.xml"
  error("Could not find the show: maybe `add` it first?") unless fs.existsSync(xml_file)
  str = fs.readFileSync(xml_file)
  parser = new xml2js.Parser()
  parser.parseString str, (err, result) ->
    return error(err) if err
    storage[id] = result
    cb('', result)

readAll = (cb) ->
  return error("Your database is empty") unless fs.existsSync(BASE_STORE)
  ids = fs.readdirSync(BASE_STORE).filter (f) ->
    fs.statSync(path.join(BASE_STORE, f)).isDirectory()

  async.map ids, readSeries, (err, results) ->
    cb()

series = (id, cb) ->
  if storage[id]
    cb(storage[id])
  else
    readSeries id, (err, res) ->
      cb(storage[id])

module.exports =
  series: series
  readAll: readAll
  findSeriesByEp: findByEp
  findEp: findEp
