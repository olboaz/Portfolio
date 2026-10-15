function initImagePreviews() {
  const fields = [
    {
      inputId: "project_project_photo",
      previewId: "project-main-preview",
      multiple: false,
    },
    {
      inputId: "project_photos",
      previewId: "project-photos-preview",
      multiple: true,
    },
  ];

  fields.forEach(({ inputId, previewId, multiple }) => {
    const input = document.getElementById(inputId);
    const container = document.getElementById(previewId);

    if (!input || !container || input.dataset.previewInitialized) return;

    input.dataset.previewInitialized = "true";

    input.addEventListener("change", () => {
      container.replaceChildren();

      const files = Array.from(input.files || []);

      files.forEach((file) => {
        if (!["image/jpeg", "image/png", "image/webp"].includes(file.type)) {
          return;
        }

        const url = URL.createObjectURL(file);
        const image = document.createElement("img");

        image.src = url;
        image.alt = file.name;
        image.className = "img-thumbnail m-2";

        image.style.width = multiple ? "120px" : "300px";
        image.style.height = multiple ? "90px" : "200px";
        image.style.objectFit = "contain";

        image.addEventListener("load", () => URL.revokeObjectURL(url), {
          once: true,
        });

        container.appendChild(image);
      });
    });
  });
}

function initProjectPhotosQuota() {
  const quota = document.getElementById("project-photos-quota");
  if (!quota || quota.dataset.quotaInitialized) return;

  quota.dataset.quotaInitialized = "true";

  const input = document.getElementById("project_photos");
  const upload = document.getElementById("project-photos-upload");
  const counter = document.getElementById("project-photos-count");
  const remaining = document.getElementById("project-photos-remaining");
  const warning = document.getElementById("project-photos-limit-message");
  const preview = document.getElementById("project-photos-preview");

  if (!input || !upload || !counter || !remaining || !warning) return;

  const max = Number(quota.dataset.maxPhotos);
  const existing = Number(quota.dataset.existingPhotos);

  const getDeletedCount = () =>
    document.querySelectorAll(".project-photo-checkbox:checked").length;

  function updateQuota() {
    const kept = existing - getDeletedCount();
    const selected = input.files.length;
    const available = max - kept;

    if (selected > available) {
      input.value = "";

      if (preview) preview.replaceChildren();

      alert(
        `Impossible d'ajouter ${selected} images : ` +
          `il reste seulement ${available} place(s) disponibles.`,
      );
    }

    const newSelected = input.files.length;
    const total = kept + newSelected;
    const free = Math.max(0, max - total);

    counter.textContent = total;
    remaining.textContent = `Vous pouvez encore ajouter ${free} image(s).`;

    upload.hidden = free === 0;
    warning.hidden = free !== 0;
  }

  input.addEventListener("change", updateQuota);

  document.querySelectorAll(".project-photo-checkbox").forEach((checkbox) => {
    checkbox.addEventListener("change", updateQuota);
  });

  updateQuota();
}

document.addEventListener("turbolinks:load", initImagePreviews);

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initImagePreviews);
} else {
  initImagePreviews();
}

document.addEventListener("turbolinks:load", initProjectPhotosQuota);

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initProjectPhotosQuota);
} else {
  initProjectPhotosQuota();
}
