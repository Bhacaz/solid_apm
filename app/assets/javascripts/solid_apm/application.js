import {
  Application,
  Controller,
} from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js";
window.Stimulus = Application.start();

// Global function for chart selection
window.handleChartSelection = function(minTimestamp, maxTimestamp) {
  const currentUrl = new URL(window.location.href);
  const params = new URLSearchParams(currentUrl.search);
  
  // Convert from milliseconds to seconds (ApexCharts provides timestamps in milliseconds)
  params.set('from_timestamp', Math.floor(minTimestamp / 1000));
  params.set('to_timestamp', Math.floor(maxTimestamp / 1000));
  
  // Remove relative time params
  params.delete('from_value');
  params.delete('from_unit');
  params.delete('to_value');
  params.delete('to_unit');
  
  // Navigate to the new URL
  window.location.href = `${currentUrl.pathname}?${params.toString()}`;
};

//= require_tree .

// require "./controllers/spans-chart_controller"
// import "./controllers/spans-chart_controller.js"
