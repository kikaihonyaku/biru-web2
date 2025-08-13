# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# jQuery and related libraries
pin "jquery", to: "jquery.min.js"
pin "jquery_ujs", to: "jquery_ujs.js"
pin "jquery-ui", to: "jquery-ui.min.js"

# Custom JavaScript libraries for Biru Web
pin "tree.jquery", to: "tree.jquery.js"
pin "biru-map", to: "biru-map.js"
pin "jquery.cookie", to: "jquery.cookie.js"

# Bootstrap and UI components
pin "bootstrap", to: "bootstrap.min.js"
pin "bootstrap-datepicker", to: "bootstrap-datepicker.js"
pin "bootstrap-datepicker-ja", to: "bootstrap-datepicker.ja.js"

# jQuery plugins
pin "jquery.sidr", to: "jquery.sidr.min.js"
pin "jquery.Jcrop", to: "jquery.Jcrop.js"
pin "jquery.blockUI", to: "jquery.blockUI.js"
pin "select2", to: "select2.min.js"

# Charts and graphs
pin "highstock", to: "highcharts/highstock.js"

# Slick grid components
pin "slick.core", to: "slick.core.js"
pin "slick.grid", to: "slick.grid.js"
pin "slick.dataview", to: "slick.dataview.js"
pin "slick.editors", to: "slick.editors.js"
pin "slick.formatters", to: "slick.formatters.js"
pin "slick.columnpicker", to: "slick.columnpicker.js"
pin "slick.pager", to: "slick.pager.js"
pin "slick.rowselectionmodel", to: "slick.rowselectionmodel.js"
pin "slick.groupitemmetadataprovider", to: "slick.groupitemmetadataprovider.js"
pin "slick.remotemodel", to: "slick.remotemodel.js"

# Grid and table components
pin "grid.locale-ja", to: "grid.locale-ja.js"
pin "jquery.jqGrid.src", to: "jquery.jqGrid.src.js"

# Wice Grid components
pin "wice_grid", to: "wice_grid.js"

# Other utilities
pin "jquery.ui.ympicker", to: "jquery.ui.ympicker.js"
pin "prettify", to: "prettify.js"
pin "modernizr", to: "modernizr.min.js"
pin "responsive-nav", to: "responsive-nav.js"
pin "jquery.sparkline", to: "jquery.sparkline.min.js"