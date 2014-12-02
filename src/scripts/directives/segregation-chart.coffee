angular.module "segregationChartDirective", []
  .directive "segregationChart", ($window, $timeout, $filter) ->
    restrict: "E"
    scope:
      data: "="
      chartId: "@"
    link: (scope, element, attrs) ->
      firstRun = true
      animationSpeed = 800
      retina = true if $window.devicePixelRatio > 1
      pi = Math.PI
      svg = d3.select(element[0]).append "svg"
      partyColors =
        "Ø": "#731525"
        F: "#9C1D2A"
        A: "#E32F3B"
        B: "#E52B91"
        C: "#0F854B"
        V: "#0F84BB"
        O: "#005078"
        I: "#EF8535"
        K: "#F0AC55"
      tip = d3.tip()
        .attr "class", "d3-tip"
        .html (d) ->
          value = $filter('number')(d.value)
          html = "<p>#{value}%</p>"

          return html
      svg.call tip

      $window.onresize = -> scope.$apply()

      scope.$watch (->
        angular.element($window)[0].innerWidth
      ), ->
        return if firstRun

        firstRun = true

        svg.selectAll("*").remove()
        render scope.data

      scope.$watchCollection  "data", (newData, oldData) ->
        render newData if newData.data

      render = (data) ->
        if element[0].offsetParent is 0 or element[0].offsetParent is null
          firstRun = false
          return

        renderData = []
        redTotal = 0
        blueTotal = 0
        redParties = ""
        blueParties = ""
        height = element[0].offsetHeight
        width = element[0].offsetWidth

        for key, value of data.data
          if key.length is 1
            newValue = value.replace ",", "."
            newValue = newValue.replace "-", "0"

            if data.parties[key].blok is "rød"
              redTotal+= parseFloat newValue
              redParties+= key
            if data.parties[key].blok is "blå"
              blueTotal+= parseFloat newValue
              blueParties+= key

            renderData.push
              party: key
              value: parseFloat newValue

        logoSize = 20
        logoMargin = 20
        sliceWidth = (pi * 2) / renderData.length
        sliceStart = 0
        radius = (Math.min(width, height) / 2) - (logoMargin * 2)
        innerRadius = 72.5
        maxValue = d3.max renderData, (d) -> d.value
        blockWidth = radius * 2
        blockHeight = 20
        blockMargin = (width - blockWidth) / 2
        blockMaxValue = Math.max redTotal, blueTotal
        blockXScale = d3.scale.linear()
          .domain [0, blockMaxValue]
          .range [0, blockWidth]

        if width <= 360
          innerRadius = width / 6
          logoSize = width / 23
          logoMargin = logoSize

        outerRadiusCal = (value) -> (radius - innerRadius) * (value / maxValue) + innerRadius + 1

        arc = d3.svg.arc()
          .innerRadius innerRadius
          .outerRadius (d) -> outerRadiusCal d.value

        if firstRun
          chart = svg.append "g"
            .attr "class", "chart #{scope.chartId}"
            .attr "transform", "translate(#{width / 2}, #{(height / 2) - blockHeight})"

          totalChart = svg.append "g"
            .attr "class", "total-chart"

          layout = svg.append "g"

          layout
            .attr "class", "layout #{scope.chartId}"
            .attr "transform", "translate(#{width / 2}, #{(height / 2) - blockHeight})"

          layout
            .append "circle"
              .attr "r", innerRadius - 13
              .attr "class", "filled"

          label = layout.append "text"

          redBlockText = label.append "tspan"
            .attr "class", "red-block"
            .attr "text-anchor", "middle"
            .attr "fill", "#b0b0b0"
            .attr "x", 0
            .attr "dy", "-5px"

          blueBlockText = label.append "tspan"
            .attr "class", "blue-block"
            .attr "text-anchor", "middle"
            .attr "fill", "#b0b0b0"
            .attr "x", 0
            .attr "dy", "20px"

          redBlockBar = totalChart.append "rect"
            .attr "class", "red"
            .attr "height", blockHeight
            .attr "width", 0
            .attr "x", blockMargin
            .attr "y", height - (blockHeight * 3)
            .attr "fill", "#BB242E"

          blueBlockBar = totalChart.append "rect"
            .attr "class", "blue"
            .attr "height", 20
            .attr "width", 0
            .attr "x", blockMargin
            .attr "y", height - (blockHeight * 2)
            .attr "fill", "#136A90"

          if scope.chartId is "one"
            redBlockParties = totalChart.append "text"
              .attr "class", "red text"
              .attr "x", blockMargin
              .attr "y", height - (blockHeight * 3) - 5
              .attr "fill", "#BB242E"

            blueBlockParties = totalChart.append "text"
              .attr "class", "blue text"
              .attr "x", blockMargin
              .attr "y", height - 5
              .attr "fill", "#136A90"
        else
          chart = svg.select ".chart.#{scope.chartId}"
          totalChart = svg.select ".total-chart"
          layout = svg.select ".layout.#{scope.chartId}"
          redBlockText = layout.select ".red-block"
          blueBlockText = layout.select ".blue-block"
          redBlockBar = totalChart.select ".red"
          blueBlockBar = totalChart.select ".blue"
          if scope.chartId is "one"
            redBlockParties = totalChart.select ".red.text"
            blueBlockParties = totalChart.select ".blue.text"

        tooltip = d3.select "info-popup"
        slices = chart.selectAll(".slice").data renderData

        slices
          .enter()
            .append "path"
              .attr "class", "slice"
              .attr "fill", (d) -> partyColors[d.party]
              .attr "d", ->
                return if !firstRun
                s = {}
                s.startAngle = sliceStart
                s.endAngle = sliceStart + sliceWidth
                sliceStart = s.endAngle
                s.value = 0

                return arc s

        sliceStart = 0

        slices
          .transition()
          .duration(animationSpeed)
          .ease "elastic", 2, 2
          .delay (d, i) -> 100 * i
            .attr "d", (d) ->
              d.startAngle = sliceStart
              d.endAngle = sliceStart + sliceWidth
              sliceStart = d.endAngle

              return arc d

        slices
          .on "mouseover", (d) -> tip.show(d)
          .on "mouseout", tip.hide

        partyLogos = chart.selectAll(".party-logos").data renderData

        partyLogos
          .enter()
            .append "image"
            .attr "class", "party-logos"
            .attr "xlink:href", (d) ->
              return "/upload/tcarlsen/voter-segregation/img/#{d.party.toLowerCase()}_small@2x.png" if retina
              return "/upload/tcarlsen/voter-segregation/img/#{d.party.toLowerCase()}_small.png"
            .attr 'width', logoSize
            .attr 'height', logoSize

        partyLogos
          .transition()
          .duration(animationSpeed)
          .ease "elastic", 2, 2
          .delay (d, i) -> 100 * i
            .attr "x", (d) ->
              c = arc.centroid(d)
              x = c[0]
              y = c[1]
              h = Math.sqrt(x*x + y*y)
              r = outerRadiusCal(d.value) + logoMargin

              return ((x / h) * r) - (logoSize / 2)
            .attr "y", (d) ->
               c = arc.centroid(d)
               x = c[0]
               y = c[1]
               h = Math.sqrt(x*x + y*y)
               r = outerRadiusCal(d.value) + logoMargin

               return ((y / h) * r) - (logoSize / 2)

        redBlockText
          .text ->
            value = $filter('number')(redTotal, 1)

            return "RØD: #{value}%"

        blueBlockText
          .text ->
            value = $filter('number')(blueTotal, 1)

            return "BLÅ: #{value}%"

        redBlockBar
          .transition().duration(animationSpeed)
            .attr "width", blockXScale redTotal

        blueBlockBar
          .transition().duration(animationSpeed)
            .attr "width", blockXScale blueTotal

        if scope.chartId is "one"
          redBlockParties
            .text redParties

          blueBlockParties
            .text blueParties

        firstRun = false
