# Email Sending System

## Overview
The email sending system provides a centralized, secure, and reliable way to send transactional emails from the SystemPraktiker application. It uses Microsoft Exchange Web Services (EWS) with OAuth2 authentication to deliver professional emails for password resets, user invitations, and other system notifications.

## Architecture

### Core Components

#### 1. Base Email Service (`PasswordResetEmailService`)
- **Location**: `system_praktiker/email_service.py`
- **Purpose**: Foundation class for all email operations
- **Features**:
  - JWT token generation and validation
  - HTML email template generation
  - EWS client configuration
  - Professional SystemPraktiker branding

#### 2. Extended Services
- **OnboardingEmailService**: Extends base for user invitations
- **Future Extensions**: Newsletter, notifications, alerts

#### 3. EWS Client (`MsEwsClient`)
- **Location**: `system_praktiker/ews_client.py`
- **Purpose**: Microsoft Exchange Web Services integration
- **Features**:
  - OAuth2 authentication with Azure AD
  - Email sending via Exchange/Office 365
  - Connection testing and validation

## Technical Implementation

### Exchange Web Services (EWS) Integration

#### Authentication Flow
```python
# OAuth2 with Client Credentials Flow
app = ConfidentialClientApplication(
    client_id,
    authority=f"https://login.microsoftonline.com/{tenant_id}",
    client_credential=client_secret
)

# Acquire token for Exchange access
result = app.acquire_token_for_client(
    scopes=["https://outlook.office365.com/.default"]
)
```

#### Email Sending Process
1. **Token Acquisition**: Get OAuth2 access token from Azure AD
2. **Account Setup**: Create authenticated Exchange account
3. **Message Creation**: Build HTML message with recipients
4. **Delivery**: Send via Exchange infrastructure
5. **Logging**: Confirm successful delivery

### Email Template System

#### Base Template Structure
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>SystemPraktiker - {subject}</title>
    <style>
        /* Professional styling with SystemPraktiker branding */
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; }
        .container { max-width: 600px; margin: 0 auto; background: white; }
        .logo h1 { color: #ff6b35; font-size: 28px; }
        .button { background: #ff6b35; color: white; padding: 12px 24px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo"><h1>SystemPraktiker</h1></div>
        <div class="content">{content}</div>
        <div class="footer">{footer}</div>
    </div>
</body>
</html>
```

#### Design Principles
- **Mobile Responsive**: Works on all device sizes
- **Professional Styling**: Clean, modern design
- **Brand Consistency**: SystemPraktiker orange (#ff6b35) theme
- **Accessibility**: High contrast, readable fonts
- **Cross-Client**: Compatible with all major email clients

### Configuration Management

#### Environment Variables
```bash
# Microsoft Azure AD OAuth2 Configuration
EWS_CLIENT_ID=azure_application_client_id
EWS_CLIENT_SECRET=azure_application_secret
EWS_TENANT_ID=azure_tenant_id
EWS_SENDER_ADDRESS=noreply@system-praktiker.de
EWS_SERVER=outlook.office365.com

# Application Configuration
BASE_URL=https://system-praktiker.de
SECRET_KEY=jwt_signing_secret
```

#### Settings Integration
```python
# Centralized configuration via Pydantic Settings
class Settings(BaseSettings):
    ews_client_id: Optional[str] = None
    ews_client_secret: Optional[str] = None
    ews_tenant_id: Optional[str] = None
    ews_sender_address: Optional[str] = None
    ews_server: str = "outlook.office365.com"
    base_url: str = "http://localhost:8877"
```

## Email Types and Templates

### 1. Password Reset Emails

#### Purpose
Send secure password reset links to users who forgot their credentials.

#### Template Features
- **Subject**: "SystemPraktiker - Passwort zurücksetzen"
- **Content**: Clear explanation of password reset process
- **CTA Button**: Prominent "Neues Passwort erstellen" button
- **Security Warnings**: 1-hour expiry, single-use notice
- **Fallback Link**: Plain text URL for accessibility

#### Security Elements
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

### 2. User Invitation Emails

#### Purpose
Invite new users to join the SystemPraktiker platform with onboarding links.

#### Template Features
- **Subject**: "SystemPraktiker - Einladung"
- **Content**: Welcome message and movement description
- **CTA Button**: "Profil einrichten" for onboarding
- **Information Box**: What is SystemPraktiker explanation
- **Security Warnings**: Token validity and usage instructions

#### Welcome Content
```html
<div class="welcome-box">
    <strong>Was ist SystemPraktiker?</strong>
    <p>Eine Gemeinschaft von SystemPraktikern, die sich für praktische Lösungen
    und gegenseitige Unterstützung einsetzen.</p>
</div>
```

### 3. Future Email Types
- System notifications
- Event reminders
- Newsletter campaigns
- Administrative alerts

## Security Implementation

### JWT Token Security
- **Algorithm**: HS256 with secret key
- **Expiration**: 1-hour for security tokens
- **Payload Validation**: Type checking and nonce verification
- **Single Use**: Tokens invalidated after successful use

### OAuth2 Security
- **Client Credentials Flow**: Secure application-level authentication
- **Token Scoping**: Limited to email sending permissions
- **Automatic Refresh**: Handles token expiry gracefully

### Content Security
- **HTML Sanitization**: Prevents injection attacks
- **Template Validation**: Ensures proper email structure
- **Link Security**: Validates all URLs in emails

## Error Handling and Fallbacks

### Development Mode
```python
# Fallback when EWS not configured
if not has_credentials:
    logger.warning("EWS credentials not configured, logging email instead")
    logger.info(f"Email would be sent to {user_email} with content: {content}")
```

### Production Reliability
- **Connection Retry**: Automatic retry on temporary failures
- **Graceful Degradation**: Logs errors without breaking application flow
- **Monitoring**: Comprehensive logging for debugging
- **Backup Options**: Ready for SMTP fallback if needed

### Error Types
1. **Authentication Failures**: OAuth2 token issues
2. **Network Issues**: Exchange server connectivity
3. **Configuration Errors**: Missing or invalid credentials
4. **Rate Limiting**: Exchange API limits
5. **Content Issues**: Template rendering problems

## Testing and Validation

### Connection Testing
```python
def test_connection(self) -> bool:
    """Test Exchange connection and authentication"""
    try:
        token = self.get_access_token()
        account = self.get_authenticated_account(token)
        inbox_count = account.inbox.total_count
        return True
    except Exception as e:
        logger.error(f"Connection test failed: {e}")
        return False
```

### Email Validation
- **Template Rendering**: Ensure proper HTML generation
- **Link Validation**: Verify all URLs are accessible
- **Content Testing**: Check for formatting issues
- **Cross-Client Testing**: Verify appearance in major email clients

### Monitoring and Logging
```python
# Comprehensive logging
logger.info(f"EWS Config Check - Client ID: {'***' if self.client_id else 'None'}")
logger.info(f"Password reset email sent successfully to {user_email}")
logger.error(f"Failed to send email to {user_email}: {error}")
```

## Performance and Scalability

### Current Scale
- **Target Users**: ~100 users
- **Email Volume**: Low to moderate transactional emails
- **Performance**: Synchronous sending adequate for current needs

### Optimization Strategies
- **Connection Pooling**: Reuse Exchange connections
- **Template Caching**: Cache compiled email templates
- **Async Processing**: Queue emails for high-volume scenarios
- **Batch Operations**: Group multiple recipients when possible

### Monitoring Metrics
- Email delivery success rates
- Response times for email operations
- Authentication failure rates
- Template rendering performance

## Azure AD Configuration

### Application Registration
1. **Register App**: Create Azure AD application
2. **API Permissions**: Grant `https://outlook.office365.com/.default`
3. **Client Secret**: Generate and securely store
4. **Tenant Setup**: Configure for organizational use

### Required Permissions
```
Application Permissions:
- Mail.Send (Send mail as any user)
- Mail.ReadWrite (Read and write mail in all mailboxes)
```

### Security Best Practices
- **Least Privilege**: Minimal required permissions
- **Secret Rotation**: Regular client secret updates
- **Environment Isolation**: Separate dev/prod applications
- **Audit Logging**: Track all email operations

## Deployment Considerations

### Production Setup
1. **Azure AD Configuration**: Proper application registration
2. **Environment Variables**: Secure credential storage
3. **DNS Configuration**: Proper sender domain setup
4. **Monitoring**: Email delivery tracking
5. **Backup Plans**: Alternative delivery methods

### Security Checklist
- [ ] Client credentials securely stored
- [ ] Sender domain authenticated (SPF, DKIM, DMARC)
- [ ] Rate limiting configured
- [ ] Error handling implemented
- [ ] Logging and monitoring active

### Maintenance Tasks
- Regular credential rotation
- Template updates and testing
- Performance monitoring
- Security audit reviews
- Backup configuration testing

## Integration Points

### Application Integration
- **User Authentication**: Password reset emails
- **User Management**: Invitation emails
- **System Notifications**: Administrative alerts
- **Event Management**: Event-related communications

### External Dependencies
- **Azure AD**: Authentication and authorization
- **Exchange Online**: Email delivery infrastructure
- **DNS Services**: Domain authentication
- **Monitoring Systems**: Logging and alerting

## Future Enhancements

### Planned Features
- **Template Management**: Admin interface for email templates
- **Email Analytics**: Delivery and engagement tracking
- **Multi-language Support**: Localized email content
- **Rich Content**: Dynamic content and personalization

### Scalability Improvements
- **Queue System**: Async email processing
- **Load Balancing**: Multiple Exchange endpoints
- **Caching**: Template and configuration caching
- **Batch Processing**: Bulk email operations

### Advanced Features
- **Email Scheduling**: Delayed delivery options
- **A/B Testing**: Template effectiveness testing
- **Webhook Integration**: Delivery status callbacks
- **Advanced Analytics**: Open rates, click tracking

## Troubleshooting Guide

### Common Issues

#### Authentication Failures
```
Problem: "Failed to acquire token"
Solution: Verify Azure AD app configuration and credentials
Check: Client ID, secret, tenant ID validity
```

#### Email Delivery Issues
```
Problem: Emails not reaching recipients
Solution: Check sender domain authentication (SPF/DKIM)
Verify: Exchange Online configuration and permissions
```

#### Template Rendering Problems
```
Problem: Broken email layout
Solution: Validate HTML template syntax
Test: Cross-client compatibility
```

### Debug Mode
```python
# Enable detailed logging
logger.setLevel(logging.DEBUG)

# Test connection
ews_client.test_connection()

# Validate template
email_service.generate_reset_email_html(test_url)
```

## Compliance and Standards

### Email Standards
- **RFC 5322**: Internet Message Format compliance
- **CAN-SPAM**: Anti-spam regulation compliance
- **GDPR**: Data protection and privacy
- **Accessibility**: WCAG guidelines for email content

### SystemPraktiker Standards
- **Brand Guidelines**: Consistent visual identity
- **Content Guidelines**: Professional and clear messaging
- **Security Standards**: Industry-standard practices
- **Performance Standards**: Reliable delivery metrics