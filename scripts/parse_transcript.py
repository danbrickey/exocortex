import re
import sys

def parse_transcript(file_path):
    """Parse meeting transcript and extract structured information."""

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Configure UTF-8 output
    sys.stdout.reconfigure(encoding='utf-8')

    # Extract metadata
    date_match = re.search(r'(\w+ \d+, \d{4})', content[:200])
    date = date_match.group(1) if date_match else "Not found"

    # Extract unique speakers
    speaker_pattern = r'^([A-Za-z\s\-+*0-9]+?)(?:   \d+:\d+)'
    speakers = set(re.findall(speaker_pattern, content, re.MULTILINE))
    speakers = [s.strip() for s in speakers if s.strip() and len(s.strip()) > 2]

    print("=" * 80)
    print("MEETING METADATA")
    print("=" * 80)
    print(f"Date: {date}")
    print(f"\nAttendees ({len(set(speakers))}):")
    for speaker in sorted(set(speakers)):
        if '+12*******42' in speaker:
            print(f"  - Dan Brickey (+12*******42)")
        else:
            print(f"  - {speaker}")

    print(f"\nPurpose: BCI Data Sources Discovery Session - BCBS Provider Directory Discussion")

    # Look for decisions (keywords: decided, confirmed, lean toward, agreed)
    print("\n" + "=" * 80)
    print("DECISIONS")
    print("=" * 80)

    decision_patterns = [
        (r'Rich Tallon[^\n]*?confirms?[^\n]*?not required for[^\n]*?9115',
         'Rich Tallon confirmed BCBS Provider Directory data not required for 9115 Provider Directory API'),
        (r'Rich[^\.]*?important for business[^\.]*?use cases',
         'Rich Tallon stated BCBS Provider Directory is important for business-driven use cases'),
        (r'Rich[^\.]*?lean toward[^\.]*?put it in the foundation model',
         'Rich Tallon leaning toward including BCBS Provider Directory in foundation model'),
        (r'association does assign master IDs',
         'Rich Tallon confirmed BCBS Association assigns master IDs for practitioners, organizations, and locations'),
    ]

    # Extract specific decision quotes
    decisions = []

    # Decision 1: Not required for 9115
    if 'not required for 99115' in content or 'not necessarily' in content[:5000]:
        decisions.append("Rich Tallon: BCBS Provider Directory not required for CMS 9115 compliance")

    # Decision 2: Important for business needs
    if 'important for business' in content:
        decisions.append("Rich Tallon: BCBS Provider Directory is important for business-driven use cases and compliance regulations outside of 9115")

    # Decision 3: Lean toward foundation model
    if 'lean toward' in content and 'foundation model' in content:
        decisions.append("Rich Tallon: Leaning toward including BCBS Provider Directory data in the foundation model (can filter by plan code)")

    # Decision 4: Hold off pending scope clarity
    if 'take this back internally' in content:
        decisions.append("Vallimala Palaneeappan: Team will take back internally to understand scope before deciding on foundation model inclusion")

    for i, decision in enumerate(decisions, 1):
        print(f"{i}. {decision}")

    # Look for action items
    print("\n" + "=" * 80)
    print("ACTION ITEMS")
    print("=" * 80)

    action_items = []

    # Check for FM sharing
    if 'send it over to you' in content and 'FM' in content:
        action_items.append("Sathish Dhanasekar: Send FM (Foundation Model) documentation to Dan Brickey")

    # Check for scope clarity
    if 'take this back internally' in content and 'scope' in content:
        action_items.append("Vallimala Palaneeappan: Clarify internally what Foundation Models will be used for and scope requirements")

    # Check for Joe involvement
    if 'need Joe' in content or "Joe's help" in content:
        action_items.append("Vallimala Palaneeappan: Consult with Joe to understand if provider mastering is in scope")

    for i, item in enumerate(action_items, 1):
        print(f"{i}. {item}")

    if not action_items:
        print("No explicit action items with owners/deadlines found in transcript")

    # Look for open questions
    print("\n" + "=" * 80)
    print("OPEN QUESTIONS")
    print("=" * 80)

    open_questions = []

    # Extract specific open questions
    if 'foundation model' in content and 'unclear' in content:
        open_questions.append("Whether BCBS Provider Directory data should be loaded into Foundation Models or kept in raw/bronze layer")

    if 'mastering' in content and 'in scope' in content:
        open_questions.append("Is provider mastering in scope for the EDP project? (needs Joe's clarification)")

    if "don't really know what the FM" in content:
        open_questions.append("What will Blue Cross of Idaho use the Foundation Models for? (Dan needs clarity)")

    if 'duplicate' in content or 'duplicat' in content:
        open_questions.append("How to handle overlapping/duplicate providers between BCI and BCBS Association directory")

    if 'filter' in content and 'source' in content:
        open_questions.append("Can data be filtered by source in feed workflow to prevent certain providers from going to CMS data flow")

    for i, question in enumerate(open_questions, 1):
        print(f"{i}. {question}")

    # Key discussion points
    print("\n" + "=" * 80)
    print("KEY DISCUSSION POINTS")
    print("=" * 80)

    discussion_points = [
        "BCBS Provider Directory contains data from all Blue Cross Blue Shield plans (including BCI), providing comprehensive out-of-state provider information needed for claims processing",

        "20-30% of BCI claims are with out-of-state providers not in BCI's contracting network - BCBS Provider Directory would provide cleaner provider data than what's currently extracted from Facets claim records",

        "BCBS Association assigns master IDs (practitioner, organization, location) which simplifies provider matching across plans and reduces mastering complexity"
    ]

    for i, point in enumerate(discussion_points, 1):
        print(f"{i}. {point}")

    print("\n" + "=" * 80)

# Run the parser
if __name__ == "__main__":
    parse_transcript(r'c:\Users\danbr\github-danbrickey\edp-ai-expert-team\docs\meetings\transcripts\2025-10-16-bci-data-sources-discovery-session-5-edp.md')
