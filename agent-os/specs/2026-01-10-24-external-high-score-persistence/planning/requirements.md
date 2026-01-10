# Spec Requirements: External High Score Persistence

## Initial Description

Persist high scores to Firebase Realtime Database for global leaderboards. Display top scores from all players on the high score screen. This is roadmap item 24.

## Requirements Discussion

### First Round Questions

**Q1:** Which Firebase service - Firestore or Realtime Database?
**Answer:** Firebase Realtime Database (simpler REST API).

**Q2:** SDK or REST API integration approach?
**Answer:** REST API via HTTPRequest node (no SDK - keeps it simple).

**Q3:** How should Firebase configuration be managed?
**Answer:** Commit Firebase config to repo. Deploying to GitHub Pages, so API keys are public-facing anyway. Security handled via Firebase rules.

**Q4:** Should this spec include UI/display changes for global scores?
**Answer:** No. This spec is ONLY about the persistence layer. UI/display changes are separate (item 23's territory for initials, or future work for global leaderboard display).

**Q5:** How should network errors and timeouts be handled?
**Answer:** Quick 4-second timeout, then just hide/skip showing global scores. Keep it simple.

**Q6:** What anti-cheat measures are needed?
**Answer:** Skip anti-cheat for now. Not worried about it, keep it simple.

**Q7:** How should score submissions be identified (device ID, session ID)?
**Answer:** As simple as possible - no device identifiers. Not worried about flooding.

**Q8:** Should offline scores be queued for later submission?
**Answer:** No. Just drop offline scores, don't queue them. Simple.

**Q9:** Overall design philosophy?
**Answer:** SIMPLE. The entire theme of this spec is simplicity.

### Existing Code to Reference

Based on roadmap context, the following existing features are relevant:

- **Local Score System (Item 8):** The existing score system with persistent high score storage using localStorage
- **GitHub Pages Hosting (Item 12):** Current localStorage-based personal high score persistence
- **High Score Initials (Item 23):** Related feature that handles initials entry - this spec should be compatible but separate

### Follow-up Questions

No follow-up questions needed - user was very clear about scope and simplicity requirements.

## Visual Assets

### Files Provided:

No visual assets provided.

### Visual Insights:

N/A - This is a backend/persistence feature with no UI changes in scope.

## Requirements Summary

### Functional Requirements

- Submit high scores to Firebase Realtime Database when achieved
- Retrieve global high scores from Firebase Realtime Database
- Use REST API via HTTPRequest node (no Firebase SDK)
- Store Firebase configuration in committed config file
- 4-second timeout for all network operations
- On timeout or error: silently fail and skip global score operations

### Technical Approach

- **Database:** Firebase Realtime Database (not Firestore)
- **Integration:** REST API via Godot's HTTPRequest node
- **Configuration:** Committed to repo (public API keys, security via Firebase rules)
- **Error Handling:** 4-second timeout, silent failure, no retries
- **Offline Behavior:** Drop scores (no queueing)
- **Identification:** None (no device IDs, no session tracking)
- **Anti-cheat:** None (deferred to future work if needed)

### Scope Boundaries

**In Scope:**

- Firebase project setup instructions/documentation
- Firebase Realtime Database REST API integration
- Score submission function (score, initials if available)
- Score retrieval function (top N scores)
- Configuration file for Firebase project settings
- Basic Firebase security rules (public read, public write for scores)
- 4-second network timeout handling

**Out of Scope:**

- UI/display changes for global leaderboards (separate from item 23)
- High score initials entry UI (that's item 23)
- Anti-cheat or score validation
- Device identification or rate limiting
- Offline score queueing
- Retry logic or sophisticated error handling
- Firebase Authentication
- Firestore (using Realtime Database instead)
- Firebase SDK (using REST API instead)

### Technical Considerations

- Must work with GitHub Pages deployment (client-side only)
- Firebase API keys are public; security via Firebase Database Rules
- Should integrate cleanly with existing local score system
- Should be compatible with item 23 (initials) when that's implemented
- Keep implementation minimal and maintainable
