import { defineConfig } from 'vite';
import RubyPlugin from 'vite-plugin-ruby';

export default defineConfig({
  plugins: [
    RubyPlugin(),
  ],
  build: {
    rollupOptions: {
      input: './app/javascript/packs/application.js',
    },
  },
});
