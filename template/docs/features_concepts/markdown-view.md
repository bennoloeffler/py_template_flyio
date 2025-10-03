# Markdown View Component

## Feature Overview

The markdown view component provides a consistent, elegant way to render markdown content throughout the system-praktiker application. It's a reusable HTML template component with comprehensive styling that handles various markdown elements with orange-themed visual identity.

## Architecture

### Core Components

1. **Backend Markdown Processing** (`system_praktiker/main.py:51-55`)
   - Uses `markdown_it` library for CommonMark-compliant parsing
   - Registered as Jinja2 template filter: `{{ content|markdown|safe }}`
   - Server-side rendering with safe HTML output

2. **Component Template** (`system_praktiker/html_templates/components/markdown-view.html`)
   - Reusable Jinja2 include component
   - Variable-driven configuration via `{% with %}` blocks
   - Self-contained styling with embedded CSS

3. **Legacy CSS Support** (`system_praktiker/static/markdown.css`)
   - Alternative lighter-weight markdown styling
   - Basic formatting without advanced features
   - Used for simple content areas

### Template Usage Pattern

```jinja2
{% with content=variable_with_markdown, max_height="300px", extra_classes="grayscale" %}
    {% include "components/markdown-view.html" %}
{% endwith %}
```

### Configuration Parameters

- **`content`** (required): The markdown text to render
- **`max_height`** (optional, default: "300px"): Maximum container height with scroll
- **`extra_classes`** (optional): Additional CSS classes for styling variations

## Visual Design System

### Color Palette
- **Primary Orange**: `#ea580c` (headings, links, bullets, table headers)
- **Text Colors**: 
  - Body: `#4b5563` (gray-600)
  - Headings: `#1f2937` (gray-800) 
  - Muted: `#6b7280` (gray-500)
- **Background Colors**:
  - Code: `#f8fafc` (slate-50)
  - Tables: Alternating white/`#f9fafb`
  - Blockquotes: `#f8fafc`

### Typography Hierarchy
- **H1**: 1.875rem, orange underline, bold
- **H2**: 1.5rem, orange color, semibold  
- **H3**: 1.25rem, gray-700, semibold
- **H4-H6**: Decreasing sizes, consistent semibold weight
- **Body**: 1.65 line-height, optimized readability

### Interactive Elements
- **Links**: Orange with hover states, external link indicators (`↗`)
- **Lists**: Custom orange bullet points, indented structure
- **Task Lists**: Checkbox support with orange accents
- **Tables**: Hover effects, responsive design
- **Code**: Inline and block code with syntax highlighting readiness

## Current Usage

The markdown-view component is actively used in:

1. **Events System** (`veranstaltungen.html:114, 244`)
   - Event descriptions in list and grid views
   - Variable height containers (250px, 200px)
   - Grayscale variant for inactive events

2. **Event Details** (`event-detail.html:81, 93`)
   - Full event descriptions (400px height)
   - Host statements with blue theming
   - Extended content areas

3. **Company Descriptions** (legacy in `OLD_UNUSED_unternehmen_grid.html:135`)
   - Company profile descriptions (150px height)
   - Currently unused but demonstrates pattern

## Technical Features

### Responsive Design
- Mobile-optimized typography scaling
- Responsive table handling with horizontal scroll
- Adjusted spacing and padding for smaller screens

### Scrolling & UX
- Thin custom scrollbars (webkit and Firefox)
- Smooth scroll behavior with `scrollbar-width: thin`
- Overflow handling with `overflow-y: auto`

### Accessibility
- Semantic HTML structure preserved from markdown
- Proper heading hierarchy
- Color contrast compliance
- Focus states for interactive elements

### Performance
- Self-contained component (no external dependencies)
- Embedded CSS for minimal HTTP requests  
- Efficient markdown parsing with markdown_it
- Server-side rendering for fast initial load

## Integration Points

### Backend Integration
```python
# main.py:51-55
markdown = MarkdownIt()
templates.env.filters["markdown"] = lambda text: markdown.render(text) if text else ""
```

### Template Integration
```jinja2
<!-- Standard usage -->
{% with content=description, max_height="300px" %}
    {% include "components/markdown-view.html" %}
{% endwith %}

<!-- With styling variations -->
{% with content=description, max_height="200px", extra_classes="grayscale" %}
    {% include "components/markdown-view.html" %}
{% endwith %}
```

## Future Enhancements

### Potential Improvements
- **Syntax Highlighting**: Add code block language detection and highlighting
- **Math Support**: LaTeX/MathJax integration for mathematical content
- **Media Embeds**: YouTube, image galleries, PDF preview integration
- **Interactive Elements**: Collapsible sections, tabs, accordions
- **Print Styling**: Optimized CSS for print media
- **Dark Mode**: Theme variations for dark/light mode toggle

### Standardization Opportunities
- Migrate remaining `markdown.css` usage to unified component
- Create preset configurations (compact, expanded, minimal)
- Add validation for markdown content security
- Implement content length warnings/truncation

## Security Considerations

- **Safe HTML Rendering**: Uses `|safe` filter after markdown processing
- **Input Sanitization**: Relies on markdown_it's built-in XSS protection
- **No User Input**: Currently only admin-controlled content
- **Future**: Consider additional sanitization for user-generated content

## Dependencies

- **markdown_it**: Python CommonMark parser
- **Jinja2**: Template engine integration
- **Tailwind CSS**: Utility classes (`prose`, `prose-sm`, responsive classes)