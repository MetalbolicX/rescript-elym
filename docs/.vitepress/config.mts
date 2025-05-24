import { defineConfig } from "vitepress";
import {
  groupIconMdPlugin,
  groupIconVitePlugin,
} from "vitepress-plugin-group-icons";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  markdown: {
    config(md) {
      md.use(groupIconMdPlugin);
    },
  },
  vite: {
    plugins: [groupIconVitePlugin()],
  },
  title: "rescript-elym",
  description: "Documentation of the Elym module for ReScript.",
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: "Home", link: "/" },
      { text: "Examples", link: "/markdown-examples" },
    ],

    sidebar: [
      {
        text: "Quick Start",
        items: [
          { text: "API Index", link: "/api-index" },
          { text: "Examples", link: "/examples" },
        ],
      },
    ],

    socialLinks: [
      { icon: "github", link: "https://github.com/MetalbolicX/rescript-elym" },
    ],
  },
});
