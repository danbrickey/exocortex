# Email Survey Organizer - Integration Guide

## Overview

The `@emailsurvey` agent analyzes email content you provide to it. It doesn't directly connect to your email account. This guide explains the practical ways to use it with your emails.

## Option 1: Manual Email Processing (Simplest)

### Method A: Copy & Paste
1. Open your email client (Gmail, Outlook, etc.)
2. Copy the email content (subject, sender, body)
3. In Claude, say: `@emailsurvey analyze this email: [paste content]`
4. The agent will extract and organize the information

**Example:**
```
@emailsurvey analyze this job application email:

From: recruiter@company.com
Subject: Interview Request - Staff Data Engineer
Date: January 27, 2025

Hi Dan,
We'd like to schedule an interview...
```

### Method B: Email File Upload
1. Export emails as files (`.eml`, `.msg`, or `.txt`)
2. Upload the file to Claude
3. Say: `@emailsurvey analyze this email file`

**How to export emails:**
- **Gmail**: Use "Forward as attachment" or browser extensions
- **Outlook**: Right-click email → Save As → Choose format
- **Apple Mail**: File → Save As → Choose format

## Option 2: Automated Email Fetching (Advanced)

For automated processing, you'll need a script that connects to your email account and fetches emails. Here are options:

### Gmail API (Google Accounts)

**Setup:**
1. Enable Gmail API in Google Cloud Console
2. Create OAuth 2.0 credentials
3. Use Python script with `google-auth` and `google-api-python-client`

**Example Python Script:**
```python
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
import base64
import json

SCOPES = ['https://www.googleapis.com/auth/gmail.readonly']

def get_emails(query='', max_results=10):
    """Fetch emails from Gmail"""
    creds = None
    # Load existing credentials or run OAuth flow
    # ... (OAuth setup code)
    
    service = build('gmail', 'v1', credentials=creds)
    results = service.users().messages().list(
        userId='me', q=query, maxResults=max_results).execute()
    
    messages = results.get('messages', [])
    emails = []
    
    for msg in messages:
        message = service.users().messages().get(
            userId='me', id=msg['id']).execute()
        
        payload = message['payload']
        headers = payload.get('headers', [])
        
        email_data = {
            'id': msg['id'],
            'subject': next((h['value'] for h in headers if h['name'] == 'Subject'), ''),
            'from': next((h['value'] for h in headers if h['name'] == 'From'), ''),
            'date': next((h['value'] for h in headers if h['name'] == 'Date'), ''),
            'body': extract_body(payload)
        }
        emails.append(email_data)
    
    return emails

def extract_body(payload):
    """Extract email body from payload"""
    body = ""
    if 'parts' in payload:
        for part in payload['parts']:
            if part['mimeType'] == 'text/plain':
                data = part['body']['data']
                body = base64.urlsafe_b64decode(data).decode('utf-8')
                break
    else:
        if payload['mimeType'] == 'text/plain':
            data = payload['body']['data']
            body = base64.urlsafe_b64decode(data).decode('utf-8')
    return body

# Usage
emails = get_emails(query='is:unread subject:"job" OR subject:"interview"', max_results=5)
for email in emails:
    print(f"Subject: {email['subject']}")
    print(f"From: {email['from']}")
    print(f"Body: {email['body'][:200]}...")
```

### Microsoft Graph API (Outlook/Office 365)

**Setup:**
1. Register app in Azure Portal
2. Get client ID and secret
3. Use Microsoft Graph API to fetch emails

**Example Python Script:**
```python
import requests
import json

def get_outlook_emails(access_token, query='', top=10):
    """Fetch emails from Outlook using Microsoft Graph API"""
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Content-Type': 'application/json'
    }
    
    url = f'https://graph.microsoft.com/v1.0/me/messages'
    params = {
        '$filter': query,
        '$top': top,
        '$select': 'subject,from,receivedDateTime,body'
    }
    
    response = requests.get(url, headers=headers, params=params)
    return response.json().get('value', [])

# Usage requires OAuth token first
# See: https://learn.microsoft.com/en-us/graph/auth-v2-user
```

### IMAP (Universal - Works with Most Email Providers)

**Example Python Script:**
```python
import imaplib
import email
from email.header import decode_header

def get_emails_imap(server, username, password, folder='INBOX', search_criteria='ALL'):
    """Fetch emails using IMAP"""
    mail = imaplib.IMAP4_SSL(server)
    mail.login(username, password)
    mail.select(folder)
    
    _, messages = mail.search(None, search_criteria)
    email_ids = messages[0].split()
    
    emails = []
    for email_id in email_ids[-10:]:  # Last 10 emails
        _, msg_data = mail.fetch(email_id, '(RFC822)')
        email_body = msg_data[0][1]
        email_message = email.message_from_bytes(email_body)
        
        subject = decode_header(email_message["Subject"])[0][0]
        if isinstance(subject, bytes):
            subject = subject.decode()
        
        from_addr = email_message.get("From")
        date = email_message.get("Date")
        
        # Get body
        body = ""
        if email_message.is_multipart():
            for part in email_message.walk():
                if part.get_content_type() == "text/plain":
                    body = part.get_payload(decode=True).decode()
                    break
        else:
            body = email_message.get_payload(decode=True).decode()
        
        emails.append({
            'subject': subject,
            'from': from_addr,
            'date': date,
            'body': body
        })
    
    mail.close()
    mail.logout()
    return emails

# Usage
# Gmail: server='imap.gmail.com'
# Outlook: server='outlook.office365.com'
# Yahoo: server='imap.mail.yahoo.com'
emails = get_emails_imap(
    server='imap.gmail.com',
    username='your-email@gmail.com',
    password='your-app-password',  # Use app-specific password
    search_criteria='(UNSEEN SUBJECT "job")'
)
```

## Option 3: Browser Extension / Automation

### Using Browser Automation (Selenium/Playwright)

For web-based email clients, you could use browser automation:

```python
from playwright.sync_api import sync_playwright

def get_gmail_emails(email, password):
    """Fetch emails using browser automation (not recommended for production)"""
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        page = browser.new_page()
        page.goto('https://mail.google.com')
        # ... login and email extraction logic
        browser.close()
```

**Note:** Browser automation is fragile and may violate terms of service. Use APIs instead.

## Recommended Workflow

### For Job Applications

1. **Set up email filters** in your email client to label/tag job-related emails
2. **Weekly batch processing:**
   - Export or copy all job-related emails from the week
   - Process them with `@emailsurvey`
   - Let the agent organize them into your job applications folder

### For Documentation

1. **Forward important emails** to yourself with a specific subject tag (e.g., "[DOCS]")
2. **Batch process** documentation emails weekly
3. **Use the agent** to extract requirements and create action items

## Security Considerations

⚠️ **Important Security Notes:**

1. **Never hardcode passwords** - Use environment variables or secure credential storage
2. **Use OAuth 2.0** when possible (Gmail API, Microsoft Graph) instead of passwords
3. **App-specific passwords** - For IMAP, use app-specific passwords, not your main password
4. **Limit permissions** - Only request read-only access when possible
5. **Secure storage** - Store credentials securely (keychain, environment variables, not in code)

## Next Steps

Would you like me to:
1. **Create a Python script** for your specific email provider (Gmail, Outlook, etc.)?
2. **Set up a simple automation** that fetches emails and formats them for the agent?
3. **Create a PowerShell script** (since you're on Windows) for email processing?

Let me know which email provider you use and I can create a tailored solution!

---

*See also: [email-survey-organizer.md](email-survey-organizer.md) - The main agent prompt*


