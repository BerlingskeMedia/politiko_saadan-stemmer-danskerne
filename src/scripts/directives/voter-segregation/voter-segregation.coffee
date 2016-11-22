angular.module "voterSegregationDirective", []
  .directive "voterSegregation", ($http, reformatter) ->
    restrict: "E"
    templateUrl: "/upload/tcarlsen/voter-segregation/partials/voter-segregation.html"
    link: (scope, element, attr) ->
      scope.activeCategory = 0
      scope.activeChart = "one"
      scope.view =
        one:
          category: null
          subCategory: null
          data: null
          parties: null
        two:
          category: null
          subCategory: null
          data: null
          parties: null

      scope.changeCategory = (index) -> scope.activeCategory = index
      scope.changeView = (sub) ->
        scope.view[scope.activeChart].category = scope.segregations[scope.activeCategory].label
        scope.view[scope.activeChart].subCategory = sub.label
        scope.view[scope.activeChart].data = sub.data

      scope.dataLabel = 'fra oktober 2016 - november 2016'

      $http.get "/upload/tcarlsen/voter-segregation/POLIT2015V1PROFILBERL_OKT16_NOV16B.json"
      # $http.get "/upload/tcarlsen/voter-segregation/POLIT2015V1PROFILBERL_SEP15_FEB16B.json"
      # $http.get "/upload/tcarlsen/voter-segregation/POLIT2013V1PROFILBERL_NOV14_APR15B_med_blok.json"
        .then (response) ->
          scope.segregations = reformatter.format response.data
          scope.view.one =
            category: scope.segregations[1].label
            subCategory: scope.segregations[1].subs[0].label
            data: scope.segregations[1].subs[0].data
            parties: response.data['partier']
          scope.view.two =
            category: scope.segregations[2].label
            subCategory: scope.segregations[2].subs[2].label
            data: scope.segregations[2].subs[2].data
            parties: response.data['partier']
