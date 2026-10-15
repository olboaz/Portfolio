function initProjectGallery() {
  const gallery = document.querySelector(".project-detail__gallery");
  const heroImage = document.querySelector(".project-detail__hero img");

  if (!gallery || !heroImage || gallery.dataset.initialized) return;

  gallery.dataset.initialized = "true";

  const thumbnails = Array.from(
    gallery.querySelectorAll(".project-detail__thumbnail"),
  );

  const previousButton = document.querySelector(".project-detail__prev");
  const nextButton = document.querySelector(".project-detail__next");
  const counter = document.querySelector(".project-detail__counter");

  let currentIndex = 0;

  // Visionneuse plein écran
  const lightbox = document.querySelector(".project-lightbox");
  const lightboxImage = lightbox?.querySelector(".project-lightbox__image");
  const closeButton = lightbox?.querySelector(".project-lightbox__close");

  function openLightbox() {
    if (!lightbox || !lightboxImage) return;

    lightboxImage.src = heroImage.currentSrc || heroImage.src;
    lightboxImage.alt = heroImage.alt;

    lightbox.hidden = false;
    document.body.style.overflow = "hidden";
    lightbox.removeAttribute("aria-hidden");
    const lightboxCounter = lightbox.querySelector(
      ".project-lightbox__counter",
    );

    if (lightboxCounter) {
      lightboxCounter.textContent = `${currentIndex + 1} / ${thumbnails.length}`;
    }
    closeButton?.focus();
  }

  function closeLightbox() {
    if (!lightbox) return;

    lightbox.hidden = true;
    document.body.style.overflow = "";
    lightbox.setAttribute("aria-hidden", "true");
    heroImage.focus();
  }

  // Ouvrir en cliquant sur l'image principale
  heroImage.addEventListener("click", openLightbox);

  // Ouvrir la visionneuse avec Entrée ou Espace
  heroImage.addEventListener("keydown", (event) => {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      openLightbox();
    }
  });
  // Fermer avec le bouton ×
  closeButton?.addEventListener("click", closeLightbox);

  // Fermer en cliquant sur le fond noir
  lightbox?.addEventListener("click", (event) => {
    if (event.target === lightbox) {
      closeLightbox();
    }
  });

  // Navigation dans la visionneuse
  const lightboxPrevious = lightbox?.querySelector(".project-lightbox__prev");

  const lightboxNext = lightbox?.querySelector(".project-lightbox__next");

  lightboxPrevious?.addEventListener("click", () => {
    showImage(currentIndex - 1);
  });

  lightboxNext?.addEventListener("click", () => {
    showImage(currentIndex + 1);
  });

  function showImage(index) {
    currentIndex = (index + thumbnails.length) % thumbnails.length;

    const selected = thumbnails[currentIndex];
    const imageUrl = selected.dataset.imageUrl;

    if (!imageUrl) return;

    heroImage.src = imageUrl;
    heroImage.removeAttribute("srcset");

    thumbnails.forEach((thumbnail, i) => {
      const active = i === currentIndex;

      thumbnail.classList.toggle("is-active", active);
      thumbnail.setAttribute("aria-pressed", String(active));
    });

    if (counter) {
      counter.textContent = `${currentIndex + 1} / ${thumbnails.length}`;
    }
    // Synchroniser la visionneuse plein écran
    if (lightbox && !lightbox.hidden) {
      lightboxImage.src = imageUrl;

      const lightboxCounter = lightbox.querySelector(
        ".project-lightbox__counter",
      );

      if (lightboxCounter) {
        lightboxCounter.textContent = `${currentIndex + 1} / ${thumbnails.length}`;
      }
    }
  }

  thumbnails.forEach((thumbnail, index) => {
    thumbnail.addEventListener("click", () => showImage(index));
  });

  if (previousButton) {
    previousButton.addEventListener("click", () => {
      showImage(currentIndex - 1);
    });
  }

  if (nextButton) {
    nextButton.addEventListener("click", () => {
      showImage(currentIndex + 1);
    });
  }

  // Éviter les événements en doublon avec Turbolinks
  if (window.projectGalleryKeyHandler) {
    document.removeEventListener("keydown", window.projectGalleryKeyHandler);
  }

  window.projectGalleryKeyHandler = (event) => {
    if (!gallery.isConnected) return;

    // Fermer la visionneuse avec Échap
    if (event.key === "Escape" && lightbox && !lightbox.hidden) {
      event.preventDefault();
      closeLightbox();
      return;
    }
    if (event.target.closest("input, textarea, select, [contenteditable]"))
      return;

    if (event.key === "ArrowLeft") {
      showImage(currentIndex - 1);
    }

    if (event.key === "ArrowRight") {
      showImage(currentIndex + 1);
    }
  };

  document.addEventListener("keydown", window.projectGalleryKeyHandler);
}

document.addEventListener("turbolinks:load", initProjectGallery);

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initProjectGallery);
} else {
  initProjectGallery();
}

// Nettoyage avant un changement de page avec Turbolinks
document.addEventListener("turbolinks:before-cache", () => {
  document.body.style.overflow = "";

  const lightbox = document.querySelector(".project-lightbox");

  if (lightbox) {
    lightbox.hidden = true;
    lightbox.setAttribute("aria-hidden", "true");
  }

  if (window.projectGalleryKeyHandler) {
    document.removeEventListener("keydown", window.projectGalleryKeyHandler);

    window.projectGalleryKeyHandler = null;
  }

  const gallery = document.querySelector(".project-detail__gallery");

  if (gallery) {
    delete gallery.dataset.initialized;
  }
});
