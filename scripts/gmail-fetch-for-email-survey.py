#!/usr/bin/env python3
"""
Gmail Email Fetcher for Email Survey Organizer

This script fetches emails from Gmail and formats them for use with the
@emailsurvey agent. It uses the Gmail API to securely access your emails.

Setup Instructions:
1. Install required packages:
   pip install google-auth google-auth-oauthlib google-auth-httplib2 google-api-python-client

2. Enable Gmail API:
   - Go to https://console.cloud.google.com/
   - Create a new project (or select existing)
   - Enable Gmail API
   - Create OAuth 2.0 credentials (Desktop app)
   - Download credentials as 'credentials.json' and place in this directory

3. Run the script:
   python gmail-fetch-for-email-survey.py

4. First run will open browser for OAuth authentication
5. Token will be saved for future runs
"""

import os
import base64
import json
from datetime import datetime
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# Gmail API scopes - read-only access
SCOPES = ['https://www.googleapis.com/auth/gmail.readonly']

# File paths
CREDENTIALS_FILE = 'credentials.json'
TOKEN_FILE = 'token.json'
OUTPUT_DIR = 'email_exports'


def get_gmail_service():
    """Authenticate and return Gmail service object"""
    creds = None
    
    # Load existing token if available
    if os.path.exists(TOKEN_FILE):
        creds = Credentials.from_authorized_user_file(TOKEN_FILE, SCOPES)
    
    # If no valid credentials, run OAuth flow
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            if not os.path.exists(CREDENTIALS_FILE):
                print(f"ERROR: {CREDENTIALS_FILE} not found!")
                print("\nPlease download OAuth credentials from Google Cloud Console:")
                print("1. Go to https://console.cloud.google.com/")
                print("2. Create/select a project")
                print("3. Enable Gmail API")
                print("4. Create OAuth 2.0 credentials (Desktop app)")
                print(f"5. Download as '{CREDENTIALS_FILE}' and place in this directory")
                return None
            
            flow = InstalledAppFlow.from_client_secrets_file(
                CREDENTIALS_FILE, SCOPES)
            creds = flow.run_local_server(port=0)
        
        # Save credentials for next run
        with open(TOKEN_FILE, 'w') as token:
            token.write(creds.to_json())
    
    return build('gmail', 'v1', credentials=creds)


def extract_email_body(payload):
    """Extract email body from Gmail API payload"""
    body = ""
    
    if 'parts' in payload:
        # Multi-part message
        for part in payload['parts']:
            mime_type = part.get('mimeType', '')
            if mime_type == 'text/plain':
                data = part['body'].get('data')
                if data:
                    body = base64.urlsafe_b64decode(data).decode('utf-8')
                    break
            elif mime_type == 'text/html' and not body:
                # Fallback to HTML if plain text not available
                data = part['body'].get('data')
                if data:
                    body = base64.urlsafe_b64decode(data).decode('utf-8')
    else:
        # Single-part message
        mime_type = payload.get('mimeType', '')
        if mime_type in ['text/plain', 'text/html']:
            data = payload['body'].get('data')
            if data:
                body = base64.urlsafe_b64decode(data).decode('utf-8')
    
    return body


def get_header_value(headers, name):
    """Get header value by name"""
    for header in headers:
        if header['name'].lower() == name.lower():
            return header['value']
    return ''


def fetch_emails(service, query='', max_results=10, label_ids=None):
    """
    Fetch emails from Gmail
    
    Args:
        service: Gmail API service object
        query: Gmail search query (e.g., 'is:unread subject:"job"')
        max_results: Maximum number of emails to fetch
        label_ids: List of label IDs to search (e.g., ['INBOX'])
    
    Returns:
        List of email dictionaries
    """
    try:
        # Build search request
        request_params = {
            'userId': 'me',
            'maxResults': max_results
        }
        
        if query:
            request_params['q'] = query
        
        if label_ids:
            request_params['labelIds'] = label_ids
        
        # Search for messages
        results = service.users().messages().list(**request_params).execute()
        messages = results.get('messages', [])
        
        if not messages:
            print("No emails found matching your criteria.")
            return []
        
        print(f"Found {len(messages)} email(s). Fetching details...")
        
        emails = []
        for i, msg in enumerate(messages, 1):
            print(f"  Processing email {i}/{len(messages)}...", end='\r')
            
            # Get full message details
            message = service.users().messages().get(
                userId='me', 
                id=msg['id'],
                format='full'
            ).execute()
            
            payload = message['payload']
            headers = payload.get('headers', [])
            
            # Extract email data
            email_data = {
                'id': msg['id'],
                'thread_id': message.get('threadId', ''),
                'subject': get_header_value(headers, 'Subject'),
                'from': get_header_value(headers, 'From'),
                'to': get_header_value(headers, 'To'),
                'date': get_header_value(headers, 'Date'),
                'snippet': message.get('snippet', ''),
                'body': extract_email_body(payload),
                'labels': message.get('labelIds', [])
            }
            
            emails.append(email_data)
        
        print(f"\n[SUCCESS] Successfully fetched {len(emails)} email(s).")
        return emails
        
    except HttpError as error:
        print(f"ERROR: An error occurred: {error}")
        return []


def format_email_for_agent(email_data):
    """Format email data for use with @emailsurvey agent"""
    formatted = f"""From: {email_data['from']}
To: {email_data['to']}
Date: {email_data['date']}
Subject: {email_data['subject']}

{email_data['body']}

---
Snippet: {email_data['snippet']}
"""
    return formatted


def save_emails(emails, output_format='text'):
    """Save emails to files"""
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)
    
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    
    if output_format == 'text':
        # Save as individual text files
        for i, email in enumerate(emails, 1):
            filename = f"{OUTPUT_DIR}/email_{timestamp}_{i:03d}.txt"
            with open(filename, 'w', encoding='utf-8') as f:
                f.write(format_email_for_agent(email))
            print(f"  Saved: {filename}")
    
    elif output_format == 'json':
        # Save as single JSON file
        filename = f"{OUTPUT_DIR}/emails_{timestamp}.json"
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(emails, f, indent=2, ensure_ascii=False)
        print(f"  Saved: {filename}")
    
    elif output_format == 'combined':
        # Save all emails in one text file
        filename = f"{OUTPUT_DIR}/emails_{timestamp}.txt"
        with open(filename, 'w', encoding='utf-8') as f:
            for i, email in enumerate(emails, 1):
                f.write(f"\n{'='*80}\n")
                f.write(f"EMAIL {i} of {len(emails)}\n")
                f.write(f"{'='*80}\n\n")
                f.write(format_email_for_agent(email))
                f.write("\n")
        print(f"  Saved: {filename}")


def print_email_summary(emails):
    """Print summary of fetched emails"""
    print("\n" + "="*80)
    print("EMAIL SUMMARY")
    print("="*80)
    for i, email in enumerate(emails, 1):
        print(f"\n{i}. {email['subject']}")
        print(f"   From: {email['from']}")
        print(f"   Date: {email['date']}")
        print(f"   Preview: {email['snippet'][:100]}...")


def main():
    """Main function"""
    print("="*80)
    print("Gmail Email Fetcher for Email Survey Organizer")
    print("="*80)
    print()
    
    # Authenticate
    print("[AUTH] Authenticating with Gmail...")
    service = get_gmail_service()
    if not service:
        return
    
    print("[SUCCESS] Authentication successful!")
    print()
    
    # Get user preferences
    print("Email Search Options:")
    print("1. Unread emails")
    print("2. Job application emails (subject contains 'job' or 'interview')")
    print("3. Custom search query")
    print("4. Recent emails (last 10)")
    
    choice = input("\nSelect option (1-4) [default: 4]: ").strip() or "4"
    
    query = ''
    max_results = 10
    
    if choice == '1':
        query = 'is:unread'
        max_results = int(input("How many unread emails? [default: 10]: ").strip() or "10")
    elif choice == '2':
        query = 'subject:"job" OR subject:"interview" OR subject:"application"'
        max_results = int(input("How many emails? [default: 20]: ").strip() or "20")
    elif choice == '3':
        query = input("Enter Gmail search query (e.g., 'is:unread from:recruiter@company.com'): ").strip()
        max_results = int(input("How many emails? [default: 10]: ").strip() or "10")
    elif choice == '4':
        query = ''
        max_results = int(input("How many recent emails? [default: 10]: ").strip() or "10")
    
    # Fetch emails
    print(f"\n[FETCH] Fetching emails (query: '{query or 'recent'}' limit: {max_results})...")
    emails = fetch_emails(service, query=query, max_results=max_results)
    
    if not emails:
        return
    
    # Print summary
    print_email_summary(emails)
    
    # Save options
    print("\n" + "="*80)
    print("Save Options:")
    print("1. Save as individual text files (easy to upload to Claude)")
    print("2. Save as single JSON file")
    print("3. Save as combined text file (all emails in one file)")
    print("4. Display formatted for copy/paste (don't save)")
    
    save_choice = input("\nSelect option (1-4) [default: 1]: ").strip() or "1"
    
    if save_choice == '1':
        save_emails(emails, output_format='text')
    elif save_choice == '2':
        save_emails(emails, output_format='json')
    elif save_choice == '3':
        save_emails(emails, output_format='combined')
    elif save_choice == '4':
        print("\n" + "="*80)
        print("FORMATTED EMAILS (copy and paste to Claude with @emailsurvey)")
        print("="*80)
        for i, email in enumerate(emails, 1):
            print(f"\n{'='*80}")
            print(f"EMAIL {i} of {len(emails)}")
            print(f"{'='*80}\n")
            print(format_email_for_agent(email))
    
    print("\n[SUCCESS] Done!")
    print(f"\nNext steps:")
    print("1. If saved to files, upload them to Claude")
    print("2. Use: @emailsurvey analyze this email: [paste content]")
    print("3. Or: @emailsurvey analyze these email files: [upload files]")


if __name__ == '__main__':
    main()


