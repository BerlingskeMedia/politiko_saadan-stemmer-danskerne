angular.module "reformatService", []
  .service "reformatter", ($filter) ->
    format: (data) ->
      output = []

      for key, value of data
        subs = []
        category = key.toLowerCase()

        # removing
        continue if category is "uddannelse"
        continue if category is "hvad er deres erhverv p.t. ?"
        continue if category is "storkreds"
        continue if category is "type"
        continue if category is "partier"

        # renaming
        if category is "hvad er din egen sidst afsluttede uddannelse ?"
          category = "uddannelsesniveau"
        else if category is "hvilken form for bolig bor du i ?"
          category = "boligform"
        else if category is "bor du i en ejer-, andels- eller lejerbolig ?"
          category = "bolig"
        else if category is "er du for tiden beskæftiget i privat eller offentlig virksomhed ?"
          category = "ansættelsesforhold"
        else if category is "hvor stor en del af de daglige indkøb står du for ?"
          category = "daglige indkøb"
        else if category is "hvad er din nuværende civilstand ?"
          category = "civilstand"

        for subKey, subValue of value
          subCategory = subKey.toLowerCase()

          # removing
          continue if subCategory is "base"
          continue if subCategory is "andet"
          continue if subCategory is "ved ikke/vil ikke svare"
          continue if subCategory is "værelse"
          continue if subCategory is "arbejdsløs" and category is "ansættelsesforhold"
          continue if subCategory is "foretager aldrig indkøb"

          # reformating
          subCategory = subCategory.replace "-", " - "

          # renaming
          if subCategory is "mand"
            subCategory = "mænd"
          else if subCategory is "kvinde"
            subCategory = "kvinder"
          else if subCategory is "arbejdsløs"
            subCategory = "arbejdsløse"
          else if subCategory is "kort videregående uddannelse (til og med 3 år)"
            subCategory = "kort videregående"
          else if subCategory is "lang videregående uddannelse/universitetsuddannelse (mere end 3 år)"
            subCategory = "lang videregående"
          else if subCategory is "erhvervsuddannelse / hg - eksamen (grundlæggende/afsluttende)"
            subCategory = "erhvervsuddannelse"
          else if subCategory is "studentereksamen/ hf - eksamen/ hh-eksamen/htx-eksamen"
            subCategory = "studentereksamen"
          else if subCategory is "mellemskole - /realeksamen/præliminæreksamen"
            subCategory = "realeksamen"
          else if subCategory is "funktionær (lavere, højere)"
            subCategory = "funktionære"
          else if subCategory is "selvstændig (landbrug, detail, øvrigt)"
            subCategory = "selvstændige"
          else if subCategory is "arbejder (ufaglært/faglært)"
            subCategory = "ufaglærte/faglærte"
          else if subCategory is "ude af erhverv (pens. o.lign)"
            subCategory = "pensionister"
          else if subCategory is "indtil 199.999 kr."
            subCategory = "optil 199.999 kr."
          else if subCategory is "600.000 kr. og derover"
            subCategory = "600.000 kr. +"
          else if subCategory is "etageejendom, beboelsesejendom (lejlighed)"
            subCategory = "lejlighed"
          else if subCategory is "række - /klynge-kædehus"
            subCategory = "rækkehus"
          else if subCategory is "hus/villa/parcelhus"
            subCategory = "hus"
          else if subCategory is "lejerbolig/tjenestebolig"
            subCategory = "lejerbolig"
          else if subCategory is "ja, privat virksomhed"
            subCategory = "privat ansat"
          else if subCategory is "ja, offentlig virksomhed"
            subCategory = "offentligt ansat"
          else if subCategory is "samlevende (papirløst)"
            subCategory = "samlevende"
          else if subCategory is "skilt/separeret/tidl. samlevende"
            subCategory = "skilt"
          else if subCategory is "4 personer eller flere"
            subCategory = "4 personer +"
          else if subCategory is "folkeskole 7 år eller kortere"
            subCategory = "folkeskole under 7 år"

          subs.push
            label: subCategory
            data: subValue

        output.push
          label: category
          subs: subs

      output = $filter('orderBy')(output, 'label')

      return output
