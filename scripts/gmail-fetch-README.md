# Gmail Email Fetcher - Setup Guide

This script fetches emails from Gmail and formats them for use with the `@emailsurvey` agent.

## Quick Start

### 1. Install Python Dependencies

```powershell
pip install google-auth google-auth-oauthlib google-auth-httplib2 google-api-python-client
```

### 2. Set Up Gmail API Access

1. **Go to Google Cloud Console**
   - Visit: https://console.cloud.google.com/

2. **Create or Select a Project**
   - Click "Select a project" → "New Project"
   - Name it (e.g., "Email Survey Organizer")
   - Click "Create"

3. **Enable Gmail API**
   - In the project, go to "APIs & Services" → "Library"
   - Search for "Gmail API"
   - Click "Enable"

4. **Create OAuth 2.0 Credentials**
   - Go to "APIs & Services" → "Credentials"
   - Click "Create Credentials" → "OAuth client ID"
   - If prompted, configure OAuth consent screen:
     - User Type: "External" (unless you have Google Workspace)
     - App name: "Email Survey Organizer"
     - User support email: Your email
     - Developer contact: Your email
     - Click "Save and Continue" through the steps
   - Application type: "Desktop app"
   - Name: "Email Survey Organizer"
   - Click "Create"

5. **Download Credentials**
   - Click the download icon next to your new OAuth client
   - Save the file as `credentials.json`
   - Place it in the same directory as `gmail-fetch-for-email-survey.py`

### 3. Run the Script

```powershell
python gmail-fetch-for-email-survey.py
```

**First Run:**
- The script will open your browser
- Sign in with your Google account
- Grant permissions to read Gmail
- A `token.json` file will be created (saved for future runs)

**Subsequent Runs:**
- The script uses the saved token (no browser needed)

## Usage Examples

### Fetch Unread Job Application Emails

1. Run the script
2. Select option 2: "Job application emails"
3. Choose how many emails to fetch
4. Select save format (individual files recommended)
5. Upload the files to Claude and use `@emailsurvey`

### Custom Search

The script supports Gmail search syntax:
- `is:unread` - Unread emails
- `subject:"job"` - Emails with "job" in subject
- `from:recruiter@company.com` - Emails from specific sender
- `has:attachment` - Emails with attachments
- `after:2025/1/1` - Emails after a date
- Combine: `is:unread subject:"interview" after:2025/1/1`

## Output Formats

### Individual Text Files (Recommended)
- Each email saved as separate `.txt` file
- Easy to upload to Claude one at a time
- Format: `email_YYYYMMDD_HHMMSS_001.txt`

### Combined Text File
- All emails in one file
- Good for batch processing
- Format: `emails_YYYYMMDD_HHMMSS.txt`

### JSON File
- Structured data format
- Good for programmatic processing
- Format: `emails_YYYYMMDD_HHMMSS.json`

## Using with @emailsurvey Agent

### Method 1: Upload Files
1. Run the script and save emails as text files
2. In Claude, upload the email file(s)
3. Say: `@emailsurvey analyze this email file`

### Method 2: Copy/Paste
1. Run the script and choose "Display formatted for copy/paste"
2. Copy the formatted email content
3. In Claude, say: `@emailsurvey analyze this email: [paste content]`

### Method 3: Batch Processing
1. Save all emails as combined text file
2. Upload to Claude
3. Say: `@emailsurvey analyze these emails and organize them by type`

## Troubleshooting

### "credentials.json not found"
- Make sure you downloaded the OAuth credentials from Google Cloud Console
- Place the file in the same directory as the script
- Rename it to exactly `credentials.json`

### "Access blocked: This app's request is invalid"
- Make sure you selected "Desktop app" as the application type
- Check that OAuth consent screen is configured

### "The script is not recognized"
- Make sure Python is installed: `python --version`
- Try: `python3 gmail-fetch-for-email-survey.py`

### "Module not found"
- Install dependencies: `pip install google-auth google-auth-oauthlib google-auth-httplib2 google-api-python-client`

## Security Notes

- ✅ The script only requests **read-only** access to Gmail
- ✅ Credentials are stored locally in `token.json`
- ✅ Never share `credentials.json` or `token.json` files
- ✅ Add these files to `.gitignore` if using version control

## Next Steps

After fetching emails, use the `@emailsurvey` agent to:
- Extract job application information
- Organize documentation requirements
- Track action items and deadlines
- Create structured files in your knowledge base

See: `ai-resources/prompts/utilities/email-survey-organizer.md`


