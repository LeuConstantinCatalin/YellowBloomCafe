import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["loginForm", "signupForm"]

  connect() {
    console.log("AuthController connected!");
  }

  showSignup() {
    console.log("Switching to Sign Up");
    this.loginFormTarget.style.display = "none";
    this.signupFormTarget.style.display = "block";
  }

  showLogin() {
    console.log("Switching to Login");
    this.loginFormTarget.style.display = "block";
    this.signupFormTarget.style.display = "none";
  }
}
