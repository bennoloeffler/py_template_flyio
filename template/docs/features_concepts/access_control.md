# Access Control Feature

## Overview
The access control system implements role-based permissions for file operations, ensuring proper security while maintaining ease of access for visitors.

## Implementation Date
2025-10-04

## Access Control Matrix

| Operation | Visitor (Unauthenticated) | User (Authenticated) | Admin |
|-----------|---------------------------|---------------------|-------|
| View files list | ✅ Allowed | ✅ Allowed | ✅ Allowed |
| Download files | ✅ Allowed | ✅ Allowed | ✅ Allowed |
| Upload files | ❌ Denied | ✅ Allowed | ✅ Allowed |
| Delete own files | ❌ Denied | ✅ Allowed | ✅ Allowed |
| Delete any file | ❌ Denied | ❌ Denied | ✅ Allowed |
| View users | ❌ Denied | ❌ Denied | ✅ Allowed* |
| Delete users | ❌ Denied | ❌ Denied | ✅ Allowed* |
| Delete own account | ❌ N/A | ✅ Allowed* | ✅ Allowed* |

*Not yet implemented - requires `/api/users` endpoints

## Technical Implementation

### Authentication Mechanism
- **JWT Tokens**: Used for authenticated users
- **Optional Authentication**: Implemented via `get_optional_current_user()` function
- **Required Authentication**: Implemented via `get_current_active_user()` function

### Key Code Components

#### Optional Authentication Helper (main.py:194-224)
```python
# OAuth2 scheme that doesn't require authentication
oauth2_scheme_optional = OAuth2PasswordBearer(tokenUrl="token", auto_error=False)

async def get_optional_current_user(
    token: str = Depends(oauth2_scheme_optional),
) -> Optional[Dict[str, Any]]:
    """Get current user if authenticated, None otherwise (for visitors)."""
    if not token:
        return None
    # ... validate token and return user or None
```

#### Public File Viewing (main.py:381-412)
- `/api/files` GET endpoint uses `Depends(get_optional_current_user)`
- Allows unauthenticated access for visitors
- `my_files_only` filter only works for authenticated users

#### Public File Download (main.py:415-436)
- `/api/files/{filename}` GET endpoint uses optional authentication
- Visitors can download any public file

#### Protected File Upload (main.py:367-378)
- `/api/files/upload` POST endpoint uses `Depends(get_current_active_user)`
- Requires valid JWT token
- Returns 401 if not authenticated

## Frontend Behavior

### Files Page (html_templates/files.html)
- Allows visitors to view file listings without authentication
- Shows "Please login to view files" message if API returns 401 (edge case)
- Delete button only shown for files where `can_delete` is true

### Upload Page (html_templates/upload.html)
- Checks authentication on page load
- Redirects to login if not authenticated
- Shows upload form only for authenticated users

## Security Considerations

1. **No Sensitive Data Exposure**: File listings show public metadata only
2. **Upload Protection**: Only authenticated users can upload to prevent abuse
3. **Delete Protection**: Users can only delete their own files; admins can delete any
4. **Token Validation**: All authenticated endpoints validate JWT tokens

## Testing Results

### Visitor Access (Unauthenticated)
```bash
# ✅ Can view files
curl -s "http://localhost:8877/api/files"
# Returns: {"files": [], "total": 0, ...}

# ❌ Cannot upload files
curl -X POST "http://localhost:8877/api/files/upload" -F "file=@test.txt"
# Returns: {"detail": "Not authenticated"}
```

### User Access (Authenticated)
```bash
# ✅ Can upload files with valid token
curl -X POST "http://localhost:8877/api/files/upload" \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@test.txt"
# Returns: {"id": 1, "filename": "...", ...}
```

## Design Alignment

This implementation aligns with the original design specification from `/docs/design.md`:
- ✅ Visitors can view and download files
- ✅ Visitors cannot upload files
- ✅ Users must authenticate to upload
- ✅ Users can delete their own files
- ✅ Admins can delete any file

## Future Enhancements

1. **User Management API**: Implement `/api/users` endpoints for admin user management
2. **Rate Limiting**: Consider rate limits for unauthenticated file viewing
3. **File Privacy**: Option to mark files as private (only owner can view/download)
4. **Audit Logging**: Track who downloads files for security auditing