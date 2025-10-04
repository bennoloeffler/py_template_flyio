# Complete Use Cases Test Plan

## Test Environment
- Backend: FastAPI server running on port 8877
- Frontend: Web browser interface
- Database: PostgreSQL with MCP integration
- Tools: Chrome DevTools MCP for frontend, server.log for backend monitoring

## Detailed Use Cases

### 1. Admin Auto-Creation & Management
- **UC-1.1**: Admin auto-creation on server start
  - Verify admin user is created with ADMIN_PASSWORD from environment
  - Check database for admin role assignment

- **UC-1.2**: Admin login
  - Login with admin credentials
  - Verify JWT token contains admin role
  - Check access to admin-only features

- **UC-1.3**: Admin delete any user
  - Create test user
  - Admin deletes the test user
  - Verify user removed from database

- **UC-1.4**: Admin delete any file
  - User uploads file
  - Admin deletes file from another user
  - Verify file removed from database

### 2. User Registration & Authentication
- **UC-2.1**: Visitor registration as user
  - Access registration page
  - Fill registration form
  - Submit and verify account creation
  - Check database for new user entry

- **UC-2.2**: User login
  - Login with user credentials
  - Verify JWT token generation
  - Check session persistence

- **UC-2.3**: User logout
  - Click logout
  - Verify token invalidation
  - Check redirect to public page

### 3. File Operations - Visitor
- **UC-3.1**: View latest 200 files
  - Access home page as visitor
  - Verify file list displays
  - Check pagination/limit of 200 files

- **UC-3.2**: Search/filter files
  - Search by file title
  - Filter by user
  - Combined search (title + user)
  - Verify search results accuracy

- **UC-3.3**: Download file
  - Click download link
  - Verify file downloads correctly
  - Check file integrity

### 4. File Operations - User
- **UC-4.1**: Upload file
  - Login as user
  - Upload various file types (pdf, docx, md, images)
  - Verify file stored in database
  - Check thumbnail generation for images
  - Verify file appears in listing

- **UC-4.2**: Delete own file
  - User uploads file
  - User deletes own file
  - Verify file removed from database
  - Confirm cannot delete others' files

- **UC-4.3**: Delete own account
  - User requests account deletion
  - Verify all user files are deleted
  - Verify user removed from database
  - Check cannot login with deleted account

## Test Execution Order
1. Admin auto-creation verification
2. Admin login
3. User registration
4. User login/logout
5. File upload tests
6. Visitor file viewing/searching
7. File download tests
8. User file deletion
9. Admin file deletion
10. Admin user deletion
11. User account self-deletion

## Success Criteria
- All use cases pass without errors
- Database integrity maintained
- Proper role-based access control
- File operations work for all supported formats
- Search functionality returns accurate results
- Deletion cascades work correctly