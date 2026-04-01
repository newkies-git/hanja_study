import globals from "globals";
import pluginVue from "eslint-plugin-vue";
import tseslint from "typescript-eslint";
import prettierConfig from "eslint-config-prettier";

export default tseslint.config(
  { languageOptions: { globals: { ...globals.browser } } },
  ...pluginVue.configs["flat/recommended"],
  ...tseslint.configs.recommended,
  prettierConfig,
  {
    rules: {
      "vue/multi-word-component-names": "off",
      "vue/require-default-prop": "off",
      "@typescript-eslint/no-unused-vars": ["warn", { argsIgnorePattern: "^_" }],
    },
  },
);
