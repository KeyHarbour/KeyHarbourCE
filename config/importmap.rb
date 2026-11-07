# Pin npm packages by running ./bin/importmap

pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin_all_from 'app/javascript/controllers', under: 'controllers'

pin "apexcharts", to: "apexcharts.js"
pin 'tabler', to: 'tabler.min.js'
pin 'fullcalendar', to: 'fullcalendar.global.js'
pin 'jquery', to: 'https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js'
pin 'flatpickr' # @4.6.13
pin 'trix'
pin "d3" # @7.9.0
pin "d3-array" # @3.2.4
pin "d3-axis" # @3.0.0
pin "d3-brush" # @3.0.0
pin "d3-chord" # @3.0.1
pin "d3-color" # @3.1.0
pin "d3-contour" # @4.0.2
pin "d3-delaunay" # @6.0.4
pin "d3-dispatch" # @3.0.1
pin "d3-drag" # @3.0.0
pin "d3-dsv" # @3.0.1
pin "d3-ease" # @3.0.1
pin "d3-fetch" # @3.0.1
pin "d3-force" # @3.0.0
pin "d3-format" # @3.1.2
pin "d3-geo" # @3.1.1
pin "d3-hierarchy" # @3.1.2
pin "d3-interpolate" # @3.0.1
pin "d3-path" # @3.1.0
pin "d3-polygon" # @3.0.1
pin "d3-quadtree" # @3.0.1
pin "d3-random" # @3.0.1
pin "d3-scale" # @4.0.2
pin "d3-scale-chromatic" # @3.1.0
pin "d3-selection" # @3.0.0
pin "d3-shape" # @3.2.0
pin "d3-time" # @3.1.0
pin "d3-time-format" # @4.1.0
pin "d3-timer" # @3.0.1
pin "d3-transition" # @3.0.1
pin "d3-zoom" # @3.0.0
pin "delaunator" # @5.1.0
pin "internmap" # @2.0.3
pin "robust-predicates" # @3.0.3
pin '@rails/actiontext', to: 'actiontext.esm.js'
pin 'tom-select' # @2.6.2
