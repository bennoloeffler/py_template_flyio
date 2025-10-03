# PDF Preview Timeout Analysis & Solutions

## Current Issue
PDF previews on the veranstaltungen page are timing out after 10 seconds, particularly for larger PDF files like `230421_Ideentag_Hannover_Messe_2023_Finalentwurf230310[162645].pdf`.

## Current Implementation
- **Location**: `/system_praktiker/html_templates/veranstaltungen.html:352`
- **Timeout**: 10 seconds (10000ms)
- **Library**: PDF.js v3.11.174 loaded from CDN
- **Method**: Client-side rendering using canvas
- **Scale**: 0.6 for preview size
- **Optimizations**: Text and annotation layers disabled

## Root Causes
1. **Fixed 10-second timeout** - Too short for large PDFs, especially in production environment
2. **Client-side loading bottlenecks** - Entire PDF loaded in browser memory
3. **No progressive loading** - Users see nothing until complete load or timeout
4. **Network latency** - Test/production environments add latency

## Solution Options

### Option 1: Increase Timeout + Progressive Feedback (Quick Fix)
**Implementation**: Immediate
- Increase timeout to 30-60 seconds
- Add progress indicators during loading
- Implement retry mechanism with exponential backoff
- Show partial progress to users

### Option 2: Server-Side Preview Generation (Best Long-term)
**Implementation**: Requires backend changes
- Generate preview images server-side when PDFs uploaded
- Store as thumbnail files in database (like existing image thumbnails)
- Instant display, no client-side processing needed
- Consistent preview quality

### Option 3: Lazy Loading + Caching (Intermediate)
**Implementation**: Frontend optimization
- Load previews only when visible (intersection observer)
- Cache loaded PDFs in browser storage
- Add "click to load preview" for large files
- Progressive enhancement approach

### Option 4: Hybrid Approach (Recommended)
**Implementation**: Phased rollout
1. **Phase 1** (Immediate): Increase timeout to 30s
2. **Phase 2** (Next sprint): Add file size check - skip preview for files >5MB
3. **Phase 3** (Future): Implement server-side preview generation

## Current Implementation Plan (Option 1)

### Changes to implement:
1. **Increase timeout**: 10s → 30s
2. **Add progress indicator**: Show loading percentage
3. **Retry mechanism**: Auto-retry once on failure with 45s timeout
4. **Better error messages**: Distinguish between timeout, network, and format errors
5. **Loading state improvements**: Animated spinner with progress text

### Technical Details:
```javascript
// Current: 10 second timeout
setTimeout(() => reject(new Error('PDF loading timeout')), 10000);

// New: 30 second timeout with retry
setTimeout(() => reject(new Error('PDF loading timeout')), 30000);
```

### Progress Tracking:
- Use PDF.js loading progress events
- Display percentage loaded
- Show estimated time remaining for large files

### Retry Logic:
- First attempt: 30 seconds
- On failure: Auto-retry with 45 seconds
- Show "Retrying..." message
- Allow manual retry button after second failure

## Performance Metrics to Track
- Average load time per file size
- Timeout rate before/after changes
- User interaction with retry buttons
- Success rate by file size ranges

## Future Enhancements
- Implement WebWorker for PDF processing
- Add quality settings (low/medium/high)
- Preload PDFs when user hovers over event
- Consider PDF.js alternatives for better performance