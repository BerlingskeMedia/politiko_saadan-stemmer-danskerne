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

      $http.get "/upload/tcarlsen/voter-segregation/POLIT2013V1PROFILBERL_JUN14_NOV14B.json"
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
