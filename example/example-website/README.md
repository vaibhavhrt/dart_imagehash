# dart_imagehash Website

A beautiful, responsive website for the dart_imagehash package built with SvelteKit 5, Tailwind CSS, and modern web technologies.

🌐 **[Live Website](https://vaibhavhrt.github.io/dart_imagehash/)**

## Features

- **Modern Design**: Clean, responsive design with smooth animations
- **Interactive Demo**: Test image hashing algorithms with sample images
- **Comprehensive Documentation**: Complete API reference and usage examples
- **Algorithm Comparison**: Visual comparison of different hashing algorithms
- **GitHub Pages Ready**: Configured for easy deployment

## Development

### Prerequisites

- Node.js 18 or higher
- npm

### Setup

1. Clone the repository:

```bash
git clone https://github.com/vaibhavhrt/dart_imagehash.git
cd dart_imagehash/example/example-website
```

2. Install dependencies:

```bash
npm install
```

3. Start development server:

```bash
npm run dev
```

Visit `http://localhost:5173` to view the website.

### Building for Production

```bash
npm run build
```

The built files will be in the `build/` directory.

### Deployment

The website is configured for GitHub Pages deployment:

1. **Automatic**: Push to main branch triggers automatic deployment via GitHub Actions

## Project Structure

```
src/
├── routes/
│   ├── +layout.svelte          # Main layout with navigation
│   ├── +layout.ts              # Layout configuration
│   ├── +page.svelte            # Homepage
│   ├── features/
│   │   └── +page.svelte        # Features comparison page
│   ├── demo/
│   │   └── +page.svelte        # Interactive demo page
│   └── docs/
│       └── +page.svelte        # Documentation page
├── app.css                     # Global styles
└── app.html                    # HTML template
```

## Technologies Used

- **SvelteKit 5**: Modern web framework with runes
- **Tailwind CSS 4**: Utility-first CSS framework
- **TypeScript**: Type-safe JavaScript
- **Vite**: Fast build tool
- **GitHub Pages**: Static site hosting

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the same license as the dart_imagehash package.
