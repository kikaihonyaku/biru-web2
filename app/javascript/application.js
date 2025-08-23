// Rails 8 Application JavaScript
// Configure your import map in config/importmap.rb

import "@hotwired/turbo-rails"
import "controllers"
import $ from "jquery"

// Make jQuery globally available
window.$ = window.jQuery = $

// Custom application JavaScript
// Note: Large JavaScript libraries are now managed through importmap
// Individual script loading is handled in the layout file

console.log('Biru Web application loaded successfully');

// Global error handler for debugging
window.addEventListener('error', function(e) {
  if (e.filename && (
    e.filename.includes('tree.jquery') ||
    e.filename.includes('gmaps') ||
    e.filename.includes('jquery')
  )) {
    console.warn('JavaScript library error:', e.message, 'in', e.filename);
    return false;
  }
});

// Global screen blocking function for compatibility
window.screen_block = function() {
  if (typeof $.blockUI !== 'undefined') {
    $.blockUI({
      message: '<div class="text-center"><i class="fa fa-spinner fa-spin fa-2x"></i><br><br>処理中...</div>',
      css: {
        border: 'none',
        padding: '15px',
        backgroundColor: '#000',
        '-webkit-border-radius': '10px',
        '-moz-border-radius': '10px',
        opacity: .5,
        color: '#fff'
      }
    });
  } else {
    console.warn('jQuery BlockUI not available');
  }
};

// Document ready handler for jQuery compatibility
document.addEventListener('DOMContentLoaded', function() {
  // Initialize any jQuery-dependent features after DOM is loaded
  if (typeof $ !== 'undefined') {
    console.log('jQuery available, version:', $.fn.jquery);
    
    // tree.jquery plugin initialization
    if (typeof $.fn.tree !== 'undefined') {
      console.log('tree.jquery plugin loaded successfully');
    } else {
      console.warn('tree.jquery plugin not loaded');
    }
  } else {
    console.warn('jQuery not available');
  }
});