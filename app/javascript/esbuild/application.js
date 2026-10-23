import "@hotwired/turbo-rails";
import * as ActiveStorage from "@rails/activestorage";
import $ from "jquery";
import "./image_previews";
import "./project_gallery";

ActiveStorage.start();

window.$ = $;
window.jQuery = $;

// Bootstrap 4 utilise jQuery.
// On le charge après avoir exposé jQuery globalement.
require("bootstrap");

const initializedBackToTopButtons = new WeakSet();

function initBackToTop() {
  const button = document.getElementById("back-to-top");
  if (!button) return;

  if (window.backToTopScrollHandler) {
    window.removeEventListener("scroll", window.backToTopScrollHandler);
  }

  const updateVisibility = () => {
    button.classList.toggle("is-visible", window.scrollY > 300);
  };

  window.backToTopScrollHandler = updateVisibility;

  window.addEventListener("scroll", updateVisibility, { passive: true });

  if (!initializedBackToTopButtons.has(button)) {
    initializedBackToTopButtons.add(button);

    button.addEventListener("click", () => {
      window.scrollTo({
        top: 0,
        behavior: "smooth",
      });
    });
  }

  updateVisibility();
}

document.addEventListener("turbo:load", initBackToTop);

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initBackToTop);
} else {
  initBackToTop();
}

// Cloudflare Turnstile — gestion compatible Turbo 8

let turnstileWidgetId = null;
let turnstileContainer = null;
let turnstileLoading = false;

function setContactSubmitEnabled(enabled) {
  const button = document.getElementById("contact-submit");

  if (button) {
    button.disabled = !enabled;
  }
}

function initContactTurnstile() {
  const container = document.getElementById("contact-turnstile");

  if (!container) return;

  setContactSubmitEnabled(false);

  // Attendre que l'API Cloudflare soit disponible.
  if (!window.turnstile) {
    loadContactTurnstile();
    return;
  }

  // Ne pas recréer un widget déjà initialisé.
  if (turnstileWidgetId !== null && turnstileContainer === container) {
    return;
  }

  // Nettoyer l'ancien widget si nécessaire.
  cleanupContactTurnstile();

  turnstileContainer = container;

  turnstileWidgetId = window.turnstile.render(container, {
    sitekey: container.dataset.sitekey,
    theme: "auto",

    callback: function (token) {
      setContactSubmitEnabled(Boolean(token));
    },

    "expired-callback": function () {
      setContactSubmitEnabled(false);
    },

    "error-callback": function () {
      setContactSubmitEnabled(false);
    },
  });
}

function loadContactTurnstile() {
  if (turnstileLoading) return;

  const existingScript = document.getElementById("cloudflare-turnstile-script");

  if (existingScript) return;

  turnstileLoading = true;

  const script = document.createElement("script");
  script.id = "cloudflare-turnstile-script";
  script.src =
    "https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit";
  script.async = true;

  script.onload = function () {
    turnstileLoading = false;
    initContactTurnstile();
  };

  script.onerror = function () {
    turnstileLoading = false;
    script.remove();
    console.error("Impossible de charger Cloudflare Turnstile.");
  };

  document.head.appendChild(script);
}

function cleanupContactTurnstile() {
  if (turnstileWidgetId !== null && window.turnstile) {
    try {
      window.turnstile.remove(turnstileWidgetId);
    } catch (error) {
      console.warn("Nettoyage Turnstile :", error);
    }
  }

  turnstileWidgetId = null;
  turnstileContainer = null;
  setContactSubmitEnabled(false);
}

document.addEventListener("turbo:before-cache", cleanupContactTurnstile);
document.addEventListener("turbo:before-render", cleanupContactTurnstile);

document.addEventListener("turbo:load", initContactTurnstile);
document.addEventListener("turbo:render", initContactTurnstile);

// Initialisation au chargement initial.
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initContactTurnstile);
} else {
  initContactTurnstile();
}

// Repositionner la page sur le formulaire après une erreur de validation.
function scrollToContactErrors() {
  const contact = document.querySelector(
    ".contact-form[data-has-errors='true']",
  );

  if (!contact) return;

  requestAnimationFrame(() => {
    requestAnimationFrame(() => {
      contact.scrollIntoView({
        behavior: "auto",
        block: "center",
      });
    });
  });
}

document.addEventListener("turbo:load", scrollToContactErrors);
document.addEventListener("turbo:render", scrollToContactErrors);
window.addEventListener("load", scrollToContactErrors);
