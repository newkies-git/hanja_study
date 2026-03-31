/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{vue,js,ts}"],
  theme: {
    extend: {
      colors: {
        primary: { DEFAULT: "#004ac6", container: "#2563eb" },
        surface: { DEFAULT: "#f7f9fb", low: "#f2f4f6", lowest: "#ffffff", bright: "#fafbfc" },
        onSurface: { DEFAULT: "#191c1e", variant: "#434655" },
        outline: { variant: "rgba(195, 198, 215, 0.2)" },
      },
      fontFamily: {
        display: ["Manrope", "system-ui", "sans-serif"],
        sans: ["Inter", "system-ui", "sans-serif"],
      },
      boxShadow: {
        float: "0 10px 30px rgba(25, 28, 30, 0.06)",
      },
    },
  },
  plugins: [],
};
