import globals from "globals";
import pluginVue from "eslint-plugin-vue";
import tseslint from "typescript-eslint";
import prettierConfig from "eslint-config-prettier";
import vueParser from "vue-eslint-parser";

export default tseslint.config(
  { ignores: ["dist", "node_modules"] },
  {
    languageOptions: { globals: { ...globals.browser } },
  },
  ...tseslint.configs.recommended,
  ...pluginVue.configs["flat/recommended"],
  {
    files: ["**/*.vue"],
    languageOptions: {
      parser: vueParser,
      parserOptions: {
        parser: tseslint.parser,
        ecmaVersion: "latest",
        extraFileExtensions: [".vue"],
        sourceType: "module",
      },
    },
  },
  prettierConfig,
  {
    rules: {
      "vue/multi-word-component-names": "off",
      "vue/require-default-prop": "off",
      "@typescript-eslint/no-unused-vars": ["warn", { argsIgnorePattern: "^_" }],
    },
  },
);
