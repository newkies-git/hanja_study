import { createApp } from "vue";
import { createPinia } from "pinia";
import App from "./App.vue";
import router from "./router";
import "./style.css";
import { useAuthStore } from "./stores/auth";
import { useHanjaDisplayPreferencesStore } from "./stores/hanjaDisplayPreferences";

const pinia = createPinia();
const app = createApp(App);

app.use(pinia);
useHanjaDisplayPreferencesStore().hydrateFromStorage();
useAuthStore().bindAuthListener();
app.use(router);
app.mount("#app");
