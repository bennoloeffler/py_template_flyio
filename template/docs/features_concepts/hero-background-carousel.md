# Hero Background Carousel Component

## Feature Overview

The Hero Background Carousel is a sophisticated visual component that transforms static hero sections into dynamic, engaging experiences with rotating background images. It applies Ken Burns effects (slow zoom and pan) with smooth crossfades to create cinematic backgrounds while maintaining full readability of overlay content.

## Architecture

### Core Components

1. **Backend Image Reader** (`system_praktiker/image_utils.py`)
   - `read_images_from_folder(folder_name)`: Scans static image directories
   - `get_hero_images(page_name)`: Page-specific image retrieval
   - Supports: `.jpg`, `.jpeg`, `.png`, `.webp`, `.gif`
   - Graceful fallback for missing/empty folders

2. **Frontend Carousel Component** (`components/hero-background-carousel.html`)
   - Self-contained HTML template with embedded CSS
   - Dynamic image background generation
   - Responsive design with mobile optimizations
   - Reduced motion accessibility support

3. **Route Integration** (`main.py`)
   - All hero routes enhanced with `hero_images` context
   - Page-specific folder mapping
   - Automatic image loading per route

## Usage Pattern

### Template Integration
```jinja2
{% with page_name="home", hero_images=hero_images %}
    {% set content %}
        <!-- Your hero content here -->
        <h1>Your Title</h1>
        <p>Your description</p>
        <!-- Buttons, forms, etc. -->
    {% endset %}
    {% include "components/hero-background-carousel.html" %}
{% endwith %}
```

### Page Mappings
- **Home**: `/static/images/home/` → `index.html`
- **Was ist das**: `/static/images/was_ist_das/` → `was-ist-das.html`
- **Unternehmen**: `/static/images/unternehmen/` → `landkarte_unternehmen.html`
- **Menschen**: `/static/images/menschen/` → `menschen.html`  
- **Veranstaltungen**: `/static/images/veranstaltungen/` → `veranstaltungen.html`

## Animation System

### Ken Burns Effect
- **Duration**: 24 seconds per image cycle
- **Zoom Range**: 1.1x → 1.2x scale during display
- **Pan Movement**: Subtle 2% translation in x/y directions
- **Transitions**: 1-second crossfades between images

### Animation Timing (per image)
```
0-1s:    Fade in (opacity 0→1)
1-7s:    Display with Ken Burns effect
7-8s:    Fade out (opacity 1→0)
8-24s:   Hidden (next image cycling)
```

### Performance Optimizations
- GPU acceleration with `transform3d(0, 0, 0)`
- `will-change: transform, opacity` for smooth animations
- `backface-visibility: hidden` to prevent flicker

## Visual Design System

### Background Overlay System
1. **Primary Gradient**: Maintains existing aesthetic
   ```css
   linear-gradient(135deg, 
       rgba(255, 255, 255, 0.85) 0%, 
       rgba(248, 250, 252, 0.8) 50%, 
       rgba(241, 245, 249, 0.75) 100%)
   ```

2. **Orange Accent Overlays**: Preserves brand identity
   ```css
   radial-gradient(circle at 25% 25%, var(--orange-glow) 0%, transparent 50%)
   ```

3. **Text Readability**: Multiple overlay layers ensure content visibility

### Responsive Design
- **Desktop**: Full Ken Burns effect with 1.2x maximum zoom
- **Mobile**: Reduced animation intensity (1.05x → 1.1x zoom)
- **Reduced Motion**: Fade-only transitions for accessibility

## Fallback Behavior

### No Images Available
- Gracefully degrades to original gradient background
- All overlay styling and orange accents preserved
- No JavaScript errors or visual breaks
- Identical user experience to pre-carousel implementation

### Error Handling
- Empty folders: Returns empty array, uses fallback
- Missing folders: Returns empty array, uses fallback
- Invalid images: Skipped during file iteration
- Permission errors: Returns empty array, uses fallback

## Content Management

### Adding Images
1. Place images in appropriate folder: `/static/images/{page_name}/`
2. Use supported formats: JPG, PNG, WebP, GIF
3. Images automatically detected and sorted alphabetically
4. Recommended size: 1920x1080 or higher for quality

### Image Requirements
- **Aspect Ratio**: 16:9 recommended for optimal display
- **Resolution**: Minimum 1200px width for sharp display
- **File Size**: Optimize for web (under 500KB per image)
- **Content**: Consider text overlay areas in composition

## Implementation Details

### CSS Classes Structure
```css
.hero-carousel-container    /* Main container */
├── .hero-carousel-bg       /* Background layer (z-index: 1) */
│   ├── .carousel-slide     /* Individual image slides */
│   └── .hero-gradient-overlay  /* Readability overlay (z-index: 2) */
└── .hero-content-overlay   /* Content layer (z-index: 3) */
```

### Animation Keyframes
- `kenBurnsCarousel`: Main desktop animation
- `carouselFadeOnly`: Reduced motion alternative
- Mobile-specific keyframes for performance

### Template Variables
- `page_name`: Folder identifier for image lookup
- `hero_images`: List of image URLs from backend
- `content`: Hero content (title, description, buttons)

## Performance Considerations

### Optimization Features
- CSS-only animations (no JavaScript required)
- GPU-accelerated transforms
- Preload optimization through CSS `background-image`
- Minimal DOM manipulation

### Loading Strategy
- Images loaded as CSS backgrounds (browser-optimized)
- Progressive enhancement (works without images)
- No layout shift during image loading
- Responsive image handling through CSS

## Security & Validation

### File System Security
- Path traversal protection via `pathlib`
- Extension validation for supported image types
- Permission error handling
- No user input processing (admin-only image management)

### Input Sanitization
- Folder names validated against allowed page names
- File paths constructed safely using `pathlib`
- No dynamic path construction from user input

## Browser Compatibility

### Modern Browsers
- Full animation support in Chrome, Firefox, Safari, Edge
- Hardware acceleration support
- CSS Grid and Flexbox compatibility

### Accessibility Features
- `prefers-reduced-motion` support
- Semantic HTML structure preserved
- No dependency on JavaScript for core functionality
- Screen reader compatible content structure

## Maintenance & Updates

### Adding New Pages
1. Create image folder in `/static/images/{page_name}/`
2. Update route handler to include `get_hero_images("{page_name}")`
3. Update hero section template with carousel component
4. Add images to folder

### Customization Options
- Animation timing via CSS custom properties
- Overlay opacity adjustments
- Mobile breakpoint modifications
- Ken Burns effect intensity tuning

## Future Enhancements

### Potential Improvements
- **Admin Interface**: Upload images via web interface
- **Image Optimization**: Automatic WebP conversion
- **Lazy Loading**: Deferred loading for performance
- **Preload Control**: Smart preloading of next images
- **Animation Controls**: User preference for reduced animations
- **Video Backgrounds**: Support for MP4/WebM background videos

### Advanced Features
- **Image Metadata**: Alt text and caption support
- **Focal Point**: Smart cropping for mobile displays
- **Color Extraction**: Dynamic overlay colors from image palette
- **Performance Monitoring**: Animation performance metrics

## Dependencies

### Backend Dependencies
- **pathlib**: Safe path handling (built-in)
- **os**: File system operations (built-in)
- **typing**: Type hints (built-in)

### Frontend Dependencies
- **CSS**: Modern browser support for animations
- **HTML**: Template engine (Jinja2)
- **No JavaScript**: Pure CSS implementation

## Testing

### Manual Testing Checklist
- [ ] Images load correctly per page
- [ ] Animations play smoothly
- [ ] Fallback works with empty folders
- [ ] Mobile responsiveness
- [ ] Reduced motion compliance
- [ ] Content readability over images
- [ ] Performance on slower devices

### Browser Testing
- [ ] Chrome (latest)
- [ ] Firefox (latest)  
- [ ] Safari (latest)
- [ ] Edge (latest)
- [ ] Mobile Safari
- [ ] Mobile Chrome