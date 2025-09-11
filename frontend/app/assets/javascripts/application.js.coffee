# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require fastclick/lib/fastclick
#= require angular
#= require bootstrap
#= require angular-ui-router
#= require angular-resource
#= require angular-rails-templates
#= require lodash/dist/lodash
#= require jquery.foggy.min
#= require moment/moment
#= require moment-timezone/moment-timezone
#= require jquery-textfill/source/jquery.textfill
#= require cryptojs/core
#= require cryptojs/aes
#= require app
#= require_tree .

moment.tz.add([
  'America/New_York|EST EDT|50 40|0101|1Lz50 1zb0 Op0'
]);

$(document).on 'page:load', ->
  $('[ng-app]').each ->
    module = $(this).attr('ng-app')
    angular.bootstrap(this, [module])

$(document).on 'ready page:load', ->

  $(document).on 'click', '.back-btn', (e) ->
    e.preventDefault()
    window.history.back()

  $(document).on 'click', '.overlay .content', (e) ->
    e.stopPropagation()

  $(document).on 'click', '.overlay', ->
    $('.container').removeClass('blurred')
    $('.overlay').hide()
