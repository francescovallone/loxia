import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Loxia",
  description: "Yet another ORM in dart 🎯",
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: '/' },
    ],

    sidebar: [
      {
        text: 'Introduction',
        link: '/introduction',
      },
      {
        text: 'Annotations',
        items: [
          { text: 'Entity', link: '/annotations/entity' },
          { text: 'Column', link: '/annotations/column' },
          { text: 'Relations', link: '/annotations/relations' },
        ]      
      },
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/vuejs/vitepress' }
    ]
  }
})
