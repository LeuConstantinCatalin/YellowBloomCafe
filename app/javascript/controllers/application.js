import { Application } from "@hotwired/stimulus"

// Standard Stimulus setup for importmap
const application = Application.start()

// Expose globally if needed by other scripts
window.Stimulus = application

export { application }

