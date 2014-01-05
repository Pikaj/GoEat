class Restaurant
  constructor: (@name) ->

class Category
  constructor: (@name) ->

class ServerSide

  getRestarantsForCity: (city_name)=>
    $.ajax(
          type: "GET"
          #url: "http://localhost:3000/cities/#{city_name}.json"
          url: "http://localhost:3000/city.json"
          success: (restaurantsJson) =>
            console.log("success")
            console.log(restaurantsJson)
            @restaurantsLoaded(@restaurantsFromJson(restaurantsJson))
          error: =>
            console.log("fail")
          )
  restaurantsFromJson: (json) => 
    json.map (s) -> new Restaurant s

  restaurantsLoaded: (restaurants) ->

  getCategories: =>
    $.ajax(
          type: "GET"
          #url: "http://localhost:3000/cities/#{city_name}.json"
          url: "http://localhost:3000/city.json"
          success: (categoriesJson) =>
            console.log("success")
            console.log(categoriesJson)
            @categoriesLoaded(@categoriesFromJson(categoriesJson))
          error: =>
            console.log("fail")
          )

  categoriesFromJson: (json) => 
    json.map (s) -> new Category s

  categoriesLoaded: (categories) ->

class UseCase
  constustor: ->
    @restaurants = []
    @categories = []

  findRestaurants: (city_name) =>
    @getRestarantsForCity(city_name)

  findCategories: =>
    @getCategories()

  start: =>

  getCategories: =>

  setCategories: (@categories) =>

  getRestarantsForCity: (city_name) =>

  setRestaurants: (@restaurants) =>


class Gui
  constructor: ->

  showCityForm: =>
    element = @_createElementFor("#city-form-template")
    $("#main").append(element)
    $("#city_form").fadeIn(500)
    $("#city_form").submit(@onSubmitLocation)

  showRestaurants: (restaurants) =>
    $("#city_form .form-signin").animate({'margin-top': '-120px', 'padding-top': '160px'})
    $("#city_form").animate({top:'0px',right:'0px',width:'400px'}).animate({height:'100%' }, 500,'linear', =>
      i = 500
      for r in restaurants 
        element = @_createElementFor("#restaurant-label", {restaurant: r}).fadeIn(i)
        $("#restaurants-list").append(element)
        i = i + 500
      element = @_createElementFor("#search-form-template")
      $("#main").append(element)
      $("#search_form").fadeIn(1500)
      $("#add-category").click(@moveFormSearch)
      $(".nano").nanoScroller()
    )

  moveFormSearch: =>
    $("#search_form").animate({left:'5%'}, => @afterMoveFormSearch())

  showCategories: (categories) =>
    element = @_createElementFor("#categories-template")
    $("#main").append(element)
    $("#categories-list-container").html('')
    @addCategories(categories)
    $("#categories-list").fadeIn(500)
    $(".nano").nanoScroller()

  addCategories: (categories) =>
    i = 1
    searchList = @getAllCategoriesToSearch()
    for c in categories
      if (searchList.indexOf(i) < 0)
        @addCategoryToList(c, i, i*300)
      i = i + 1
    $(".add-category-container").click( (e) =>
      element = $(e.target).parent()
      id = element.data('id')
      element.fadeOut(400, -> 
        element.remove()
      )
      @addCategoryToSearch(categories,id)
      $(".nano").nanoScroller()
    )
    element = @_createElementFor("#button-done-template")
    $("#button-done-conatiner").html('')
    $("#button-done-conatiner").append(element)
    $("#done-category").fadeIn(i*400)
    $("#done-category").click(@hiddenCategories)
    #$("add-category-container").click( -> {$(this).fadeOut(100)})

  addCategoryToSearch: (categories, categoryID) =>
    element = @_createElementFor("#category-added-template", { category: categories[categoryID-1], categoryID: categoryID })
    $("#list-category-added").append(element)
    element.fadeIn(500)
    $(".remove-category-container").click((e) =>
      element = $(e.target).parent()
      id = element.data('id')
      element.fadeOut(400, -> 
      element.remove()
      )
      @addCategoryToList(categories[id-1], id, 300)
      $(".nano").nanoScroller()
    ) 
    $(".nano").nanoScroller()

  addCategoryToList: (category, categoryID, fadeTime) =>
    element = @_createElementFor("#category-name-template", {category: category.name, categoryID: categoryID}).fadeIn(fadeTime)
    $("#categories-list-container").append(element)

  getAllCategoriesToSearch: =>
    list = $("#list-category-added").children("span")
    idList = []
    for element in list 
      idList.push($(element).data('id'))
    return idList

  hiddenCategories: =>
    $("#categories-list").fadeOut(500, => $("#search_form").animate({left:'20%'}))

  onSubmitLocation: =>
    city_name = $("#city_form input[name='city']").val()
    $("#restaurants-list").html('')
    @findRestaurants(city_name)
    return false

  _createElementFor: (templateId, data) =>
    source = $(templateId).html()
    template = Handlebars.compile(source)
    html = template(data)
    element = $(html)


  findRestaurants: (city_name) =>

  afterMoveFormSearch: =>


class Glue
  constructor:(@useCase, @serverSide,@gui) ->
  # After(@useCase, "start", => @serverSide.loadUsers())
    After(@useCase, "start", => @gui.showCityForm())
    After(@gui, "findRestaurants", (city_name) => @useCase.findRestaurants(city_name))
    After(@gui, "afterMoveFormSearch", => @useCase.findCategories())
    After(@useCase, "getRestarantsForCity", (city_name) => @serverSide.getRestarantsForCity(city_name))
    After(@useCase, "getCategories", => @serverSide.getCategories())
    After(@serverSide, 'restaurantsLoaded', (restaurants) => @useCase.setRestaurants(restaurants))
    After(@serverSide, 'categoriesLoaded', (categories) => @useCase.setCategories(categories))
    After(@useCase, "setRestaurants", (restaurants) => @gui.showRestaurants(restaurants))
    After(@useCase, "setCategories", (categories) => @gui.showCategories(categories))

class App
  constructor: ->
    @useCase = new UseCase()
    @serverSide = new ServerSide(@useCase)
    @gui = new Gui(@useCase)
    @glue = new Glue(@useCase, @serverSide, @gui)
    console.log("halo")

  start: =>
    @useCase.start()

  users: =>
    #[new User("Jan Kowalski"), new User("Jan Nowak")]


$ ->
  app = new App()
  app.start()