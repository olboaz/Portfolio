const GA_MEASUREMENT_ID = "G-QGG0XT3YV7";

let analyticsInitialized = false;
let lastTrackedUrl = null;

function loadAnalyticsScript() {
  if (document.getElementById("google-analytics-script")) return;

  const script = document.createElement("script");
  script.id = "google-analytics-script";
  script.async = true;
  script.src = `https://www.googletagmanager.com/gtag/js?id=${GA_MEASUREMENT_ID}`;

  document.head.appendChild(script);
}

export function enableAnalytics() {
  if (analyticsInitialized) return;

  analyticsInitialized = true;

  // Réautoriser le suivi après une acceptation.
  window[`ga-disable-${GA_MEASUREMENT_ID}`] = false;

  window.dataLayer = window.dataLayer || [];

  window.gtag =
    window.gtag ||
    function () {
      window.dataLayer.push(arguments);
    };

  window.gtag("js", new Date());

  // Les pages vues seront envoyées manuellement avec Turbo.
  window.gtag("config", GA_MEASUREMENT_ID, {
    send_page_view: false,
  });

  loadAnalyticsScript();
  trackPageView();
}

export function trackPageView() {
  if (!analyticsInitialized || !window.gtag) return;

  const currentUrl = window.location.href;

  if (lastTrackedUrl === currentUrl) return;

  lastTrackedUrl = currentUrl;

  window.gtag("event", "page_view", {
    page_title: document.title,
    page_location: currentUrl,
  });
}

export function disableAnalytics() {
  analyticsInitialized = false;
  lastTrackedUrl = null;

  window[`ga-disable-${GA_MEASUREMENT_ID}`] = true;
}
