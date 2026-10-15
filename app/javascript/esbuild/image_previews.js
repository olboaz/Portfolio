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

document.addEventListener("turbolinks:load", initImagePreviews);

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initImagePreviews);
} else {
  initImagePreviews();
}
