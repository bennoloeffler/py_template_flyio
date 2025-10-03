# Password Reset Feature

## Overview
The password reset feature provides a secure, email-based password recovery system for users who have forgotten their credentials. It implements industry-standard security practices with JWT tokens, rate limiting, and anti-enumeration protection.

## User Stories
- As a user, I want to reset my password when I forget it
- As a user, I want to receive a secure reset link via email
- As a user, I want the reset process to be simple and secure
- As a security admin, I want to prevent abuse and enumeration attacks

## Technical Architecture

### Database Schema
```sql
-- Added to users table in Step 3 migration
ALTER TABLE users ADD COLUMN password_reset_token VARCHAR(255);
ALTER TABLE users ADD COLUMN password_reset_expires TIMESTAMP WITHOUT TIME ZONE;
CREATE INDEX IF NOT EXISTS idx_users_password_reset_token ON users(password_reset_token);
```

### Security Implementation

#### JWT Token System
- **Algorithm**: HS256 with configurable secret key
- **Expiration**: 1 hour (3600 seconds)
- **Payload**:
  ```json
  {
    "email": "user@example.com",
    "exp": 1758955371,
    "type": "password_reset",
    "nonce": "random_hex_16_chars"
  }
  ```
- **Nonce**: Random 16-character hex for additional security

#### Timezone Handling
- **Critical Fix**: All operations use UTC timestamps
- **Database**: Stores naive UTC datetimes
- **Comparison**: Uses `CURRENT_TIMESTAMP AT TIME ZONE 'UTC'` for proper timezone comparison
- **Token Generation**: UTC timestamp in JWT exp field

#### Anti-Enumeration Protection
- Same response message regardless of email existence
- No revelation of whether email is registered
- Consistent response timing
- Logging for security monitoring

## API Endpoints

### POST /api/auth/password-reset-request
**Purpose**: Initiate password reset process
- **Rate Limit**: 3 requests per hour per IP
- **Auth Required**: None (public)
- **Request Body**:
  ```json
  {
    "email": "user@example.com"
  }
  ```
- **Response**: Always returns success message
- **Security**: Anti-enumeration protection

### GET /api/auth/password-reset-verify/{token}
**Purpose**: Verify reset token validity
- **Auth Required**: None (token validates)
- **Response**: Token validity status and email
- **Error Handling**: Clear messages for invalid/expired tokens

### POST /api/auth/password-reset-complete
**Purpose**: Complete password reset with new password
- **Request Body**:
  ```json
  {
    "token": "jwt_token",
    "password": "new_password",
    "password_confirm": "new_password"
  }
  ```
- **Validation**: Password strength, confirmation match, token validity
- **Security**: Single-use token invalidation

### GET /password-reset?token={token}
**Purpose**: Password reset completion page
- **Template**: `password-reset.html`
- **Validation**: Token checked before page render
- **Redirect**: To home with error if token invalid

## Flow Sequence

### 1. User Initiates Reset
1. User clicks "Password vergessen?" link in login modal
2. Modal opens with email input field
3. User enters email and clicks "Link senden"
4. System validates email format
5. AJAX request to `/api/auth/password-reset-request`

### 2. Backend Processing
1. Check if user exists (don't reveal result)
2. If user exists:
   - Generate JWT reset token with 1-hour expiry
   - Store token and expiry in database
   - Send reset email via EWS
3. Return generic success message

### 3. Email Delivery
1. Professional HTML email with SystemPraktiker branding
2. Clear call-to-action button with reset link
3. Security warnings about 1-hour validity and single-use
4. Fallback text link for accessibility

### 4. User Clicks Link
1. Browser navigates to `/password-reset?token={token}`
2. Server verifies token validity and extracts email
3. If valid: Renders password reset form
4. If invalid: Redirects to home with error message

### 5. Password Update
1. User enters new password (8+ characters required)
2. Client-side validation for password strength
3. Form submission to `/api/auth/password-reset-complete`
4. Server validates token, password, and confirmation
5. Updates user password and clears reset token
6. Returns success message

## Frontend Components

### Login Modal Extension
```html
<!-- Added to existing login modal -->
<p class="text-center mt-4">
  <a href="#" class="text-blue-600 hover:text-blue-800"
     onclick="openPasswordResetModal()">
    Password vergessen?
  </a>
</p>
```

### Password Reset Request Modal
```html
<div id="password-reset-modal">
  <h2>Passwort zurücksetzen</h2>
  <form onsubmit="requestPasswordReset(event)">
    <input type="email" id="reset-email" required>
    <button type="submit">Link senden</button>
  </form>
  <div id="reset-error" class="error-message"></div>
  <div id="reset-success" class="success-message"></div>
</div>
```

### Password Reset Page
- **Template**: `system_praktiker/html_templates/password-reset.html`
- **Features**:
  - Token pre-validation
  - Password strength indicator
  - Real-time validation
  - CSRF protection
  - Mobile responsive design

## Email Template

### Design Features
- SystemPraktiker branding with orange (#ff6b35) color scheme
- Mobile-responsive HTML structure
- Clear visual hierarchy
- Professional typography

### Content Structure
- **Header**: SystemPraktiker logo and title
- **Main Message**: Clear explanation of password reset
- **Call-to-Action**: Prominent reset button
- **Security Warning**: 1-hour expiry and single-use notice
- **Fallback Link**: Plain text URL for accessibility
- **Footer**: Auto-generated disclaimer

### Security Warnings
```html
<div class="warning">
  <strong>⚠️ Wichtige Sicherheitshinweise:</strong>
  <ul>
    <li>Dieser Link ist nur <strong>1 Stunde</strong> gültig</li>
    <li>Der Link kann nur <strong>einmal</strong> verwendet werden</li>
    <li>Falls Sie diese Anfrage nicht gestellt haben, ignorieren Sie diese E-Mail</li>
  </ul>
</div>
```

## Security Features

### Rate Limiting
- **Reset Requests**: 3 per hour per IP address
- **Implementation**: slowapi with Redis backend
- **Error Handling**: Clear rate limit exceeded messages

### Password Validation
```python
def validate_password(password: str):
    """Validate password meets minimum requirements"""
    if not password or len(password) < 8:
        raise HTTPException(
            status_code=400,
            detail="Passwort muss mindestens 8 Zeichen lang sein"
        )
```

### Single-Use Tokens
- Tokens cleared from database after successful use
- Prevents token reuse attacks
- Database-level validation ensures atomicity

### Logging and Monitoring
- All reset requests logged with IP and email
- Failed attempts logged for security monitoring
- No sensitive data in logs (passwords, tokens truncated)

## Error Handling

### Client-Side Validation
- Email format validation
- Password length checking
- Password confirmation matching
- Real-time feedback

### Server-Side Validation
- Comprehensive input validation
- Token expiry checking
- Database constraint validation
- Graceful error responses

### Error Messages
- **Invalid Token**: "Der Link ist ungültig oder abgelaufen"
- **Rate Limited**: Clear explanation of limits
- **Weak Password**: "Passwort muss mindestens 8 Zeichen lang sein"
- **Mismatch**: "Die Passwörter stimmen nicht überein"

## Database Operations

### Core Functions
```python
# Store reset token
async def update_user_password_reset_token(user_id, token, expires_at)

# Retrieve user by token (with timezone fix)
async def get_user_by_password_reset_token(token) -> Optional[dict]

# Update password and clear token (atomic)
async def update_user_password_and_clear_reset_token(user_id, new_password)
```

### Critical Timezone Fix
```sql
-- Fixed comparison using UTC timezone
SELECT id, email, password_reset_token, password_reset_expires
FROM users
WHERE password_reset_token = $1
AND password_reset_expires > CURRENT_TIMESTAMP AT TIME ZONE 'UTC'
```

## Integration Points

### Email Service Integration
- Reuses existing `PasswordResetEmailService`
- Integrates with EWS (Exchange Web Services)
- OAuth2 authentication for Microsoft 365
- Fallback logging for development

### Authentication System
- Uses existing JWT infrastructure
- Consistent secret key management
- Integrates with existing user model

### Frontend Integration
- Extends existing login modal
- Consistent styling with application theme
- Uses existing error/success handling patterns

## Testing Strategy

### Unit Tests
- Token generation and validation
- Password validation logic
- Database operations
- Email service functions

### Integration Tests
- Complete reset flow
- Error handling paths
- Rate limiting behavior
- Email delivery (mocked)

### Security Tests
- Token expiry validation
- Anti-enumeration verification
- Rate limit enforcement
- SQL injection prevention

## Configuration

### Environment Variables
```bash
# Required for functionality
SECRET_KEY=your_jwt_secret_key
BASE_URL=https://yourdomain.com

# Email service (EWS)
EWS_CLIENT_ID=azure_app_client_id
EWS_CLIENT_SECRET=azure_app_secret
EWS_TENANT_ID=azure_tenant_id
EWS_SENDER_ADDRESS=noreply@yourdomain.com
```

### Rate Limiting Configuration
```python
# Configurable in main.py
@limiter.limit("3/hour")  # 3 reset requests per hour per IP
```

## Implementation Status
- [x] Database migration (Step 3) completed
- [x] JWT token system with UTC timezone handling
- [x] Password validation utility function
- [x] Email service with professional HTML templates
- [x] Complete API endpoints with rate limiting
- [x] Frontend "Password vergessen?" link
- [x] Password reset request modal
- [x] Password reset completion page
- [x] Exchange Web Services (EWS) integration
- [x] Anti-enumeration security measures
- [x] Single-use token enforcement
- [x] Comprehensive error handling

## Debugging and Troubleshooting

### Common Issues
1. **Token Not Found**: Check timezone comparison in database query
2. **Email Not Sending**: Verify EWS credentials and OAuth2 setup
3. **Token Expired**: Ensure proper UTC handling in token generation
4. **Rate Limiting**: Check Redis connection for rate limiter

### Debug Mode
- Temporary token logging for debugging (remove in production)
- Comprehensive error logging
- Email delivery confirmation logging

## Future Enhancements
- Multi-factor authentication for sensitive resets
- Customizable password strength requirements
- Password reset analytics and monitoring
- Integration with external identity providers
- Bulk password reset for admin emergencies

## Security Compliance
- Follows OWASP password reset guidelines
- Implements proper anti-enumeration protection
- Uses industry-standard JWT practices
- Includes comprehensive rate limiting
- Provides secure single-use token system