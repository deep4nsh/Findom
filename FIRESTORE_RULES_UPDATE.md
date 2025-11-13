# Firestore Rules Update Required

## Issue
The app was unable to save user role changes because the Firestore security rules didn't allow users to delete documents from their old role collection and create documents in their new role collection.

## What Was Fixed

### 1. Code Changes (Already Applied ✅)
- Enhanced `role_selection_screen.dart` with:
  - Loading indicator during role change
  - Better error handling and debugging
  - Success/failure feedback messages
  - Proper atomic operations using Firestore batch

### 2. Firestore Rules Update (Needs Manual Deployment)

The `firestore.rules` file has been updated to include permissions for the user type collections:

- `professionals/{userId}` - allow read (any authenticated user), write/delete (owner only)
- `students/{userId}` - allow read (any authenticated user), write/delete (owner only)
- `general_users/{userId}` - allow read (any authenticated user), write/delete (owner only)
- `companies/{companyId}` - allow read (any authenticated user), write/delete (owner only)

Additionally, rules for `followers` and `following` collections were added.

## How to Deploy the Rules

### Option 1: Firebase Console (Recommended)
1. Go to https://console.firebase.google.com
2. Select your project: **findom-124**
3. Navigate to **Firestore Database** → **Rules**
4. Copy the contents of `firestore.rules` from this project
5. Paste it into the rules editor
6. Click **Publish**

### Option 2: Firebase CLI
```bash
firebase use findom-124
firebase deploy --only firestore:rules
```

**Note:** If you encounter errors, try logging in again:
```bash
firebase logout
firebase login
firebase use findom-124
firebase deploy --only firestore:rules
```

## Testing After Deployment

1. Open the app
2. Login as a user
3. Go to Profile → Change Role
4. Select a different role (e.g., change from General to Student)
5. Click "Save"
6. You should see:
   - A loading indicator
   - "Role updated successfully" message
   - The profile screen should refresh showing the new role

## Debug Logs

The app now logs debug information when changing roles:
- Look for messages like "Changing role from..." in the Flutter console
- Any errors will be displayed with detailed messages

## What Happens When You Change Role

1. A Firestore batch operation executes:
   - Deletes user document from old collection (e.g., `general_users/userId`)
   - Creates user document in new collection (e.g., `students/userId`)
2. The profile screen refreshes to show the new role
3. The app routes you to the appropriate screen based on the new role

## Important Notes

- Role changes are permanent and immediate
- All user data is preserved during the role change
- Company role users see a different dashboard
- Other roles see the standard app shell with Feed, Jobs, and Profile tabs
