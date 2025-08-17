import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import { fileURLToPath, URL } from "node:url";

export default defineConfig({
  plugins: [RubyPlugin()],
  resolve: {
    alias: {
      "@": fileURLToPath(new URL("./app/frontend", import.meta.url)),
      "@cosmos": fileURLToPath(new URL("./app/frontend/cosmos", import.meta.url)),
    },
  },
});