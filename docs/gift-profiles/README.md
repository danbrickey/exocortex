---
title: "Gift Recipient Profiles Directory"
author: "Dan Brickey"
last_updated: "2025-10-19"
version: "1.0.0"
category: "personal-organization"
tags: ["gift-giving", "profiles", "personal-reference"]
status: "active"
purpose: "Centralized repository for gift recipient profiles with searchable index"
---

# Gift Recipient Profiles Directory

This directory contains organized profiles for gift recipients across different relationship categories. Each profile tracks interests, preferences, sizes, and gift history to help you give thoughtful, personalized gifts year after year.

## Directory Structure

```
docs/gift-profiles/
├── README.md                    ← You are here
├── PROFILE-INDEX.md             ← Quick lookup by name/address/description
├── PROFILE-TEMPLATE.md          ← Template for creating new profiles
├── family/                      ← Immediate family members
├── extended-family/             ← Aunts, uncles, cousins, in-laws
├── friends/                     ← Close friends and social circle
├── neighbors/                   ← Neighborhood connections
├── coworkers/                   ← Work colleagues and professional contacts
└── other/                       ← Anyone else (acquaintances, service providers, etc.)
```

## How to Use This System

### Creating a New Profile

1. **Copy the template**: Use [PROFILE-TEMPLATE.md](PROFILE-TEMPLATE.md) as your starting point
2. **Choose category**: Decide which subfolder fits best (family, friends, etc.)
3. **Name the file**: Use format `FirstName-LastName.md` (e.g., `Jane-Smith.md`)
4. **Fill in details**: Add what you know now; leave blanks for later
5. **Update index**: Add entry to [PROFILE-INDEX.md](PROFILE-INDEX.md) for searchability

### Finding a Profile

**Method 1: Browse by Category**
- Navigate to the appropriate subfolder (family, friends, etc.)
- Profiles are alphabetically organized by filename

**Method 2: Search by Name/Address**
- Open [PROFILE-INDEX.md](PROFILE-INDEX.md)
- Use Ctrl+F (or Cmd+F) to search by:
  - Name
  - Address
  - Nickname/description
  - Tags (hobbies, interests, etc.)

**Method 3: Use Claude Code Search**
- Use `@` to mention the giftfinder prompt
- Ask: "Find profile for [person]" or "Show me profiles for people interested in [hobby]"
- Use Grep tool to search across all profiles: Search for keywords in interests, addresses, etc.

### Updating a Profile

1. **Open the profile** using one of the search methods above
2. **Update sections** as you learn new information:
   - Add new interests or hobbies
   - Update sizes when you find out
   - Add gift ideas to the Ideas Bank
   - Record gifts you've given in Gift History
3. **Update "Last Updated" date** in the frontmatter
4. **Update the index** if name, address, or key details changed

### Recording a Gift

After giving a gift, update two sections in the recipient's profile:

1. **Gift History** table: Add the gift with date, what it was, and their reaction
2. **Ideas Bank** table: Mark the idea as "Purchased" if it came from there, or add it to history

This prevents duplicate gifts and helps you remember what worked!

## Profile Organization Tips

### Choosing the Right Category

- **family/**: Spouse, children, parents, siblings
- **extended-family/**: Grandparents, aunts, uncles, cousins, in-laws, step-family
- **friends/**: Close friends you exchange gifts with regularly
- **neighbors/**: People in your neighborhood or community
- **coworkers/**: Work colleagues, bosses, team members
- **other/**: Service providers, acquaintances, teachers, coaches, etc.

**Note**: If someone fits multiple categories, choose where you'll most naturally look for them.

### File Naming Conventions

Use this format for easy alphabetical browsing:
- **Individual**: `FirstName-LastName.md` (e.g., `Sarah-Johnson.md`)
- **Couple**: `FirstName-and-FirstName-LastName.md` (e.g., `Tom-and-Lisa-Chen.md`)
- **Family**: `LastName-Family.md` (e.g., `Martinez-Family.md`)
- **Nickname/Known as**: Add to frontmatter tags and index, but use legal/full name for filename

### Keeping Profiles Current

**Regular Maintenance Tips**:
- After birthdays/holidays: Update gift history within a week
- During conversations: Jot down new interests or hints they drop
- Seasonal updates: Review profiles before major gift-giving seasons
- Annual cleanup: Archive profiles for people you no longer exchange gifts with

## Searchable Index

The [PROFILE-INDEX.md](PROFILE-INDEX.md) file provides quick lookup functionality. It includes:
- **Name** (with nicknames/aliases)
- **Category** (which folder)
- **Address** (for card sending or reference)
- **Key Tags** (interests, easy search terms)

**Keep the index updated** whenever you:
- Create a new profile
- Move someone to a different category
- Update their address
- Discover a significant new interest or preference

## Privacy & Security Notes

**Important**: This directory contains personal information about people you know.

- **Do NOT commit to public repositories** if this repo is or becomes public
- Consider adding `docs/gift-profiles/` to `.gitignore` if sharing this repo
- Keep size and personal details private
- Use discretion when sharing gift ideas with others

## Quick Reference

| Task | How To |
|------|--------|
| **Create new profile** | Copy [PROFILE-TEMPLATE.md](PROFILE-TEMPLATE.md) → Fill in → Save to category folder → Update index |
| **Find by name** | Open [PROFILE-INDEX.md](PROFILE-INDEX.md) → Ctrl+F → Search name |
| **Find by address** | Open [PROFILE-INDEX.md](PROFILE-INDEX.md) → Ctrl+F → Search address |
| **Find by interest** | Use Grep tool to search across all `.md` files in gift-profiles/ for keyword |
| **Record a gift** | Open profile → Add to "Gifts Given" table → Update "Last Updated" date |
| **Get gift ideas** | Use `@giftfinder` with the profile as context |
| **Browse category** | Navigate to folder (family/, friends/, etc.) → View files alphabetically |

## Example Workflow

### Scenario: Finding a Birthday Gift

1. **Open their profile** (search by name in index)
2. **Review recent changes**: Check "Last Updated" and "Notes & Insights"
3. **Check gift history**: See what you've given before and what worked
4. **Review ideas bank**: See if you've already brainstormed ideas
5. **Use @giftfinder**: Invoke the Gift Finder prompt with profile context
6. **Search for gifts**: Let @giftfinder search based on their interests and budget
7. **Purchase & record**: Buy the gift, then update "Gifts Given" table
8. **Add notes**: After they receive it, note their reaction for future reference

---

## Getting Started

**First time using this system?**

1. Start with your closest 5-10 people (immediate family, best friends)
2. Use [PROFILE-TEMPLATE.md](PROFILE-TEMPLATE.md) to create their profiles
3. Fill in what you know; leave blanks for "Unknown"
4. Add them to [PROFILE-INDEX.md](PROFILE-INDEX.md)
5. Update profiles as you learn more throughout the year

**Before the next holiday season**, you'll have a rich database of gift ideas and preferences!

---

*Managed with Gift Finder Assistant (@giftfinder)*
