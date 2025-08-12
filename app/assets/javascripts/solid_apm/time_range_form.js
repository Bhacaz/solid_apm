class TimeRangeForm {
  constructor() {
    this.form = document.getElementById('time-range-form');
    this.relativeTab = document.getElementById('relative-tab');
    this.absoluteTab = document.getElementById('absolute-tab');
    this.relativePanel = document.getElementById('relative-panel');
    this.absolutePanel = document.getElementById('absolute-panel');
    this.customFromControl = document.getElementById('custom-from-control');
    this.customToControl = document.getElementById('custom-to-control');
    
    // Timezone handling
    this.browserTimezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
    this.timezoneOffset = new Date().getTimezoneOffset();
    
    this.init();
  }
  
  init() {
    this.setupEventListeners();
    this.initializeFormState();
    this.addTimezoneToForm();
    this.adjustAbsoluteTimes();
  }
  
  setupEventListeners() {
    if (this.form) {
      this.form.addEventListener('submit', (e) => this.handleFormSubmit(e));
    }
  }
  
  switchToRelative(event) {
    event.preventDefault();
    
    this.relativeTab.classList.add('is-primary');
    this.absoluteTab.classList.remove('is-primary');
    this.relativePanel.classList.remove('is-hidden');
    this.absolutePanel.classList.add('is-hidden');
    
    this.removeFields(['from_timestamp', 'to_timestamp']);
    this.cleanupUrlParams(['from_timestamp', 'to_timestamp', 'from_datetime', 'to_datetime']);
  }
  
  switchToAbsolute(event) {
    event.preventDefault();
    
    this.absoluteTab.classList.add('is-primary');
    this.relativeTab.classList.remove('is-primary');
    this.absolutePanel.classList.remove('is-hidden');
    this.relativePanel.classList.add('is-hidden');
    
    this.cleanupUrlParams(['quick_range', 'from_value', 'from_unit', 'to_value', 'to_unit', 'quick_range_apply']);
  }
  
  handleQuickRangeChange(select) {
    const isCustom = select.value === 'custom';
    
    this.toggleVisibility(this.customFromControl, isCustom);
    this.toggleVisibility(this.customToControl, isCustom);
    
    if (!isCustom) {
      this.applyQuickRange();
    }
  }
  
  applyQuickRange() {
    const quickRangeSelect = this.form.querySelector('[name="quick_range"]');
    if (!quickRangeSelect || quickRangeSelect.value === 'custom') return;
    
    this.removeFields(['from_datetime', 'to_datetime', 'from_timestamp', 'to_timestamp']);
    this.addHiddenField('quick_range_apply', quickRangeSelect.value);
    this.form.submit();
  }
  
  handleFormSubmit(event) {
    const isAbsoluteMode = !this.absolutePanel.classList.contains('is-hidden');
    
    if (isAbsoluteMode) {
      this.handleAbsoluteModeSubmit();
    } else {
      this.handleRelativeModeSubmit();
    }
  }
  
  handleAbsoluteModeSubmit() {
    const fromDatetime = this.form.querySelector('[name="from_datetime"]');
    const toDatetime = this.form.querySelector('[name="to_datetime"]');
    
    if (fromDatetime?.value && toDatetime?.value) {
      const fromTimestamp = Math.floor(new Date(fromDatetime.value).getTime() / 1000);
      const toTimestamp = Math.floor(new Date(toDatetime.value).getTime() / 1000);
      
      fromDatetime.disabled = true;
      toDatetime.disabled = true;
      
      this.addHiddenField('from_timestamp', fromTimestamp);
      this.addHiddenField('to_timestamp', toTimestamp);
      this.addHiddenField('browser_timezone', this.browserTimezone);
      this.removeFields(['quick_range', 'from_value', 'from_unit', 'to_value', 'to_unit', 'quick_range_apply']);
    }
  }
  
  handleRelativeModeSubmit() {
    const quickRangeSelect = this.form.querySelector('[name="quick_range"]');
    const quickRangeValue = quickRangeSelect?.value;
    
    if (quickRangeValue && quickRangeValue !== 'custom') {
      this.removeFields(['from_value', 'from_unit', 'to_value', 'to_unit', 'quick_range_apply']);
    } else if (quickRangeValue === 'custom') {
      this.removeFields(['quick_range_apply']);
    }
    
    this.removeFields(['from_datetime', 'to_datetime', 'from_timestamp', 'to_timestamp']);
  }
  
  initializeFormState() {
    const urlParams = new URLSearchParams(window.location.search);
    const hasCustomParams = urlParams.has('from_value') && urlParams.has('from_unit');
    const hasQuickRange = urlParams.has('quick_range') && urlParams.get('quick_range') !== 'custom';
    const quickRangeSelect = this.form.querySelector('[name="quick_range"]');
    
    if (hasQuickRange) {
      this.toggleVisibility(this.customFromControl, false);
      this.toggleVisibility(this.customToControl, false);
    } else if (hasCustomParams || urlParams.get('quick_range') === 'custom') {
      if (quickRangeSelect) quickRangeSelect.value = 'custom';
      this.toggleVisibility(this.customFromControl, true);
      this.toggleVisibility(this.customToControl, true);
    } else {
      // Default state - show quick range only
      this.toggleVisibility(this.customFromControl, false);
      this.toggleVisibility(this.customToControl, false);
    }
  }
  
  // Utility methods
  removeFields(fieldNames) {
    fieldNames.forEach(name => {
      this.form.querySelectorAll(`[name="${name}"]`).forEach(field => field.remove());
    });
  }
  
  addHiddenField(name, value) {
    const input = document.createElement('input');
    input.type = 'hidden';
    input.name = name;
    input.value = value;
    this.form.appendChild(input);
  }
  
  toggleVisibility(element, show) {
    if (!element) return;
    element.classList.toggle('is-hidden', !show);
  }
  
  cleanupUrlParams(params) {
    const url = new URL(window.location);
    params.forEach(param => url.searchParams.delete(param));
    window.history.replaceState({}, '', url);
  }
  
  // Timezone-related methods
  addTimezoneToForm() {
    // Add timezone information to form for server processing
    this.addHiddenField('browser_timezone', this.browserTimezone);
  }
  
  adjustAbsoluteTimes() {
    // Convert timestamps from URL to browser timezone for datetime-local inputs
    const urlParams = new URLSearchParams(window.location.search);
    const fromTimestamp = urlParams.get('from_timestamp');
    const toTimestamp = urlParams.get('to_timestamp');
    
    if (fromTimestamp && toTimestamp) {
      const fromDatetime = this.form.querySelector('[name="from_datetime"]');
      const toDatetime = this.form.querySelector('[name="to_datetime"]');
      
      if (fromDatetime && toDatetime) {
        // Convert UTC timestamps to local datetime strings
        const fromDate = new Date(parseInt(fromTimestamp) * 1000);
        const toDate = new Date(parseInt(toTimestamp) * 1000);
        
        fromDatetime.value = this.formatDatetimeLocal(fromDate);
        toDatetime.value = this.formatDatetimeLocal(toDate);
      }
    }
  }
  
  formatDatetimeLocal(date) {
    // Format date for datetime-local input (YYYY-MM-DDTHH:MM)
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    
    return `${year}-${month}-${day}T${hours}:${minutes}`;
  }

}

// Global functions for onclick handlers (maintaining backward compatibility)
let timeRangeFormInstance;

function switchToRelative(event) {
  timeRangeFormInstance?.switchToRelative(event);
}

function switchToAbsolute(event) {
  timeRangeFormInstance?.switchToAbsolute(event);
}

function handleQuickRangeChange(select) {
  timeRangeFormInstance?.handleQuickRangeChange(select);
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
  timeRangeFormInstance = new TimeRangeForm();
});