class BikeIndex.Views.Global extends Backbone.View
  events:
    'click #nav-header-collapse':           'toggleCollapsibleHeader'
    'click #header-tabs .expand_t a':       'expandHeaderTab'
    'click .footnote-ref':                  'scrollToRef'
    'click .footnote-back-link':            'scrollToRef'
    'click .scroll-to-ref':                 'scrollToRef'
    'click .no-tab':                        'openNewWindow'
    'click #serial-absent':                 'updateSerialAbsent'
    'focus #header-search':                 'expandSearch'
    'change input#stolen':                  'toggleProximitySearch'
    
  initialize: ->
    BikeIndex.hideFlash()
    @setElement($('#body'))
    @loadChosen() if $('#chosen-container').length > 0
    if $('#what-spokecards-are').length > 0
      $('.spokecard-extension').addClass('on-spokecard-page')
    @initializeHeaderSearch()
    @setProximityLocation()
    @setLightspeedMovie() if $('#lightspeed-automation').length > 0

  setLightspeedMovie: ->
    height = '394'
    height = '315' if $(window).width() < 768
    video = """<iframe width="100%" height="#{height}" src="//www.youtube.com/embed/52QTFWm7gHk" frameborder="0" allowfullscreen></iframe>"""
    $('#lightspeed-tutorial-video').append(video)
    
  openNewWindow: (e) ->
    e.preventDefault()
    target = $(e.target)
    local = target.attr("data-target")
    if target.hasClass('same-window')
      window.location = local
    else
      window.open(local, '_blank')

  loadChosen: ->
    $('.chosen-select select').select2()

  initializeHeaderSearch: ->
    v = @
    $.ajax
      type: "GET"
      url: $("#head-search-bikes #query").attr('data-url')
      success: (data, textStatus, jqXHR) ->
        v.setSearchfantasy(data.tags)

  updateSerialAbsent: (e) ->
    e.preventDefault()
    $('#serial-absent, .absent-serial-blocker').toggleClass('absents')
    if $('#serial-absent').hasClass('absents')
      $('#serial')
        .val('absent')
        .addClass('absent-serial')
    else
      $('#serial')
        .val('')
        .removeClass('absent-serial')

  toggleProximitySearch: ->
    if $('#stolen-proximity').hasClass('unhidden')
      $('#stolen-proximity span').fadeOut 100, ->
        $('#stolen-proximity')
          .slideUp "medium"
          .removeClass('unhidden')
    else
      $('#stolen-proximity').slideDown "medium", ->
        $('#stolen-proximity span').fadeIn 100
        $('#stolen-proximity').addClass('unhidden')
        

  setProximityLocation: ->
    unless $('#stolenness_query').length > 0 && $('#stolenness_query').attr('data-stolen')
      $.ajax
        type: "GET"
        url: 'https://freegeoip.net/json/'
        dataType: "jsonp",
        success: (location) ->
          $('#stolen-proximity #proximity').val("#{location.city}, #{location.zipcode}")


  setSearchfantasy: (tags) ->
    $('#head-search-bikes #query').select2
      tags: tags
      openOnEnter: false
      # matcher: (term, text) ->
      #   text.toUpperCase().indexOf(term.toUpperCase()) >= 0
      tokenSeparators: [","]
  
  toggleCollapsibleHeader: ->
    # This is for the content pages where the search header is hidden
    $('#total-top-header').find('.search-background').toggleClass('show')
    $('#total-top-header').find('.background-extend').toggleClass('show')
    $('#total-top-header').find('.search-fields').toggleClass('show')
    $('#total-top-header').find('.global-tabs').toggleClass('show')
    $('#header').toggleClass('invisibled')
    $('#nav-header-collapse').toggleClass('expandable')
    if $('#content-wrap').length > 0
      $('#content-wrap').toggleClass('header-closed')

  expandHeaderTab:(event) ->
    event.preventDefault()
    target = $(event.target)
    if target.parents('li').hasClass('active')
      $('#header-tabs .global-tabs li').removeClass('active')
      $('#header-tabs').removeClass('visibled')
      $('#total-top-header').removeClass('header-tabs-in')
    else 
      # console.log(target)
      # $('#session_email').focus() if target.hasClass('.expand-sign-in')
      # console.log('hihih')
      window.setTimeout (->
        $('#session_email').focus()
      ), 500
      
      
      $('#total-top-header').addClass('header-tabs-in')
      if $('#header-tabs .tab-content').hasClass('visibled') 
        target.tab('show')
      else
        $('#header-tabs').addClass('visibled')
        target.tab('show')

  scrollToRef: (event) ->
    event.preventDefault()
    target = $(event.target).attr('href')
    $('body').animate( 
      scrollTop: ($(target).offset().top - 20), 'fast' 
    )

  intializeContent: ->
    if $(window).width() > 650 
      $('#content-menu').addClass('affix')
      footer_offset = $('#page-foot').offset().top
      menu = $('#content-menu')
      tp = menu.css('padding-top')
      bp = menu.css('padding-bottom')
      menu_height = menu.height()
      b_offset = footer_offset - ( menu_height + 120 ) 
      
      $("<style>#content-menu.affix{top:#{b_offset}px};</style>").appendTo('head')
      $('#content-menu').attr('data-spy', 'affix').attr('data-offset-top', (b_offset))

  expandSearch: ->
    # unless $('#total-top-header').hasClass('search-expanded')
    #   $('#header-search .optional-fields').fadeIn()

  # loadUserHeader: ->
    # This is minified and inlined in the header
    # 
    # $('#header-tabs').prepend("<div id='tab-cover'></div>")
    # $.ajax({
    #   type: "GET"
    #   url: '/api/v1/users/current'
    #   success: (data, textStatus, jqXHR) ->
    #     if data["user_present"]
    #       $('#total-top-header .yes_user').removeClass('hidden')
    #       if data["is_superuser"]
    #         $('#total-top-header .super_user').removeClass('hidden')
    #       if _.isArray(data["memberships"])
    #         for membership in data["memberships"]
    #           tab = """
    #             <li class="expand_t">
    #               <a href="##{membership["slug"]}">#{membership["short_name"]}</a>
    #             </li>
    #           """
    #           links = """
    #             <div class="tab-pane" id="#{membership["slug"]}">
    #               <ul>
    #                 <li>
    #                   <a href="/bikes/new?creation_organization_id=#{membership["organization_id"]}">
    #                     <strong>Add a bike</strong> through #{membership["organization_name"]}
    #                   </a>
    #                 </li>
    #                 <li>
    #                   <a href="#{membership["base_url"]}">
    #                     #{membership["organization_name"]} Account
    #                   </a>
    #                 </li>
    #           """
    #           if membership["is_admin"]
    #             links = links + """
    #               <li>
    #                 <a href="#{membership["base_url"]}/edit">
    #                   Manage organization
    #                 </a>
    #               </li>
    #             """
    #           links = links + "</ul></div>"
    #           $('#total-top-header .global-tabs').append(tab)
    #           $('#total-top-header .tab-content').append(links)
    #       $('#your_settings_n_stuff').text(data["email"]) if data["email"]
    #       $('#tab-cover').fadeOut()
    #     else
    #       $('#total-top-header .no_user').removeClass('hidden')
    #       $('#tab-cover').fadeOut()
    #   error: (data, textStatus, jqXHR) ->
    #     $('#total-top-header .no_user').removeClass('hidden')
    #     $('#tab-cover').fadeOut()
    #     BikeIndex.alertMessage("error", "User load error", "We're sorry, we failed to load your user information. Try reloading maybe?")
    #   })