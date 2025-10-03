# Onboarding Flow Feature

## Overview
The onboarding flow allows administrators to invite new users to the SystemPraktiker platform via email. The invited users receive a magic link that allows them to complete their profile and set their password without the admin knowing it.

## User Stories
- As an admin, I want to invite new members via email so they can join the platform
- As an invited user, I want to receive a clear invitation email with a secure link
- As an invited user, I want to complete my profile and set my own password

## Technical Architecture

### Database Schema
```sql
-- Added to users table
ALTER TABLE users ADD COLUMN onboarding_token VARCHAR(255);
ALTER TABLE users ADD COLUMN onboarding_token_expires TIMESTAMP WITHOUT TIME ZONE;

-- Status field now includes 'invited' option
-- status VARCHAR(50) can be: 'active', 'inactive', 'invited'
```

### Flow Sequence

1. **Admin Invites User**
   - Admin clicks "Mitglied per Email einladen" button on Menschen page
   - Modal opens asking for email address
   - System checks if email already exists
   - If new, creates user with status='invited'
   - Generates JWT onboarding token (3 day expiry)
   - Sends invitation email

2. **Email Sent**
   - Subject: "Einladung zu SystemPraktiker"
   - Contains magic link: `/onboarding/{token}`
   - Professional HTML template matching password reset design
   - Link expires in 3 days

3. **User Clicks Link**
   - System verifies token validity
   - Loads onboarding page with pre-filled email
   - Shows comprehensive profile form

4. **User Completes Profile**
   - User fills in:
     - Password (required)
     - Full name
     - Phone number
     - Company information
     - About sections
     - Portrait URL
   - Submits form

5. **Account Activation**
   - System validates all data
   - Updates user record
   - Sets status to 'active'
   - Clears onboarding tokens
   - Automatically logs user in
   - Redirects to Menschen page

## API Endpoints

### POST /api/admin/invite-user
- **Auth Required:** Admin
- **Body:** `{ "email": "user@example.com" }`
- **Response:** Success message or error
- **Actions:**
  - Validates email uniqueness
  - Creates user with status='invited'
  - Generates onboarding token
  - Sends invitation email

### GET /onboarding/{token}
- **Auth Required:** None (public)
- **Response:** HTML onboarding page
- **Actions:**
  - Verifies token validity
  - Extracts email from token
  - Renders onboarding form

### POST /api/onboarding/complete
- **Auth Required:** None (token validates)
- **Body:** User profile data + password
- **Response:** JWT login token
- **Actions:**
  - Verifies token
  - Updates user profile
  - Sets status='active'
  - Clears tokens
  - Returns auth token

## Security Considerations

1. **Token Security**
   - JWT tokens with HS256 algorithm
   - 3-day expiration
   - Contains email + nonce for uniqueness
   - Single use (cleared after successful onboarding)

2. **Email Verification**
   - Token validates email ownership
   - No password visible to admin
   - Secure magic link pattern

3. **Error Handling**
   - Generic error messages for security
   - Token expiry clearly communicated
   - Duplicate email prevention

## UI Components

### Invite Modal (Menschen Page)
```html
<div id="invite-modal">
  <h2>Mitglied per Email einladen</h2>
  <input type="email" placeholder="E-Mail-Adresse">
  <button>Einladung senden</button>
</div>
```

### Onboarding Page
- Clean, professional design
- SystemPraktiker branding
- Clear instructions
- Comprehensive form with all user fields
- Password strength indicator
- Success feedback

## Email Template
- Matches existing password reset email design
- Clear call-to-action button
- Expiration warning
- SystemPraktiker branding
- Mobile responsive

## Testing Requirements

1. **Unit Tests**
   - Token generation and validation
   - Email uniqueness checking
   - User creation with invited status
   - Token expiry handling

2. **Integration Tests**
   - Complete flow from invitation to activation
   - Email sending (mocked)
   - Token validation edge cases
   - Duplicate email handling

3. **E2E Tests**
   - Admin invite flow
   - User onboarding completion
   - Error scenarios

## Implementation Status
- [x] Feature documented
- [x] Database schema updated (Step 3 migration)
- [x] Email service extended (`OnboardingEmailService`)
- [x] API endpoints created and tested
- [x] Onboarding page template created
- [x] Admin invitation system with re-invitation support
- [x] JWT token system with UTC timezone handling
- [x] Exchange Web Services (EWS) email integration
- [x] Complete profile form with auto-login
- [x] Rate limiting and security measures
- [x] Error handling and validation

## Future Enhancements
- Bulk invite functionality
- Invite tracking/analytics
- Resend invitation option
- Custom invitation messages
- Role selection during invite