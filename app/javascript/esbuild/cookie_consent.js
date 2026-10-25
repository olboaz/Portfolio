import { disableAnalytics, enableAnalytics } from "./analytics";

const CONSENT_KEY = "portfolio_analytics_consent";

function getConsent() {
  try {
    return localStorage.getItem(CONSENT_KEY);
  } catch {
    return null;
  }
}

function saveConsent(value) {
  try {
    localStorage.setItem(CONSENT_KEY, value);
  } catch {
    // Le stockage peut être désactivé par le navigateur.
  }
}

function removeAnalyticsCookies() {
  const cookies = document.cookie.split(";");

  cookies.forEach((cookie) => {
    const name = cookie.split("=")[0].trim();

    if (name === "_ga" || name.startsWith("_ga_")) {
      document.cookie = `${name}=; Max-Age=0; Path=/; SameSite=Lax`;
    }
  });
}

function applyConsent() {
  const consent = getConsent();

  if (consent === "accepted") {
    enableAnalytics();
  } else {
    disableAnalytics();
  }

  return consent;
}

export function acceptAnalytics() {
  saveConsent("accepted");
  enableAnalytics();
}

export function rejectAnalytics() {
  saveConsent("rejected");
  disableAnalytics();
  removeAnalyticsCookies();
}

export function getAnalyticsConsent() {
  return getConsent();
}

export function initializeCookieConsent() {
  const banner = document.getElementById("cookie-consent-banner");
  if (!banner) return;

  const consent = applyConsent();

  banner.hidden = consent === "accepted" || consent === "rejected";

  const manageButton = document.getElementById("manage-cookie-consent");

  if (manageButton && !manageButton.dataset.initialized) {
    manageButton.dataset.initialized = "true";

    manageButton.addEventListener("click", () => {
      banner.hidden = false;
      document.getElementById("cookie-accept")?.focus();
    });
  }

  const acceptButton = document.getElementById("cookie-accept");
  const rejectButton = document.getElementById("cookie-reject");

  if (acceptButton && !acceptButton.dataset.initialized) {
    acceptButton.dataset.initialized = "true";

    acceptButton.addEventListener("click", () => {
      acceptAnalytics();
      banner.hidden = true;
    });
  }

  if (rejectButton && !rejectButton.dataset.initialized) {
    rejectButton.dataset.initialized = "true";

    rejectButton.addEventListener("click", () => {
      rejectAnalytics();
      banner.hidden = true;
    });
  }
}
