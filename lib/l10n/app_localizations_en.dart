// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get theme => 'Theme';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get defaultSystem => 'System';

  @override
  String get loading => 'Loading';

  @override
  String get error => 'Error';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get done => 'Done';

  @override
  String get clear => 'Clear';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get required => 'Required';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get textIsRequired => 'is required';

  @override
  String get textIsTooShort => 'is too short';

  @override
  String get notValidEmail => 'Not valid email';

  @override
  String get invalidPhoneNumber => 'Invalid phone number';

  @override
  String get invalidEgyptianPhoneNumber => 'Invalid Egyptian phone number. Format: 01XXXXXXXXX';

  @override
  String get newPhoneNumberError => 'You can\'t use your old phone number';

  @override
  String get validNumber => 'Please enter a valid number';

  @override
  String get atLeast18 => 'Age must be at least 18';

  @override
  String get accessKeyCannotBeEmpty => 'Access key cannot be empty';

  @override
  String get welcome => 'Welcome';

  @override
  String get enterAccessKeyToContinue => 'Enter your access key to continue';

  @override
  String get accessKey => 'Access Key';

  @override
  String get enterAccessKey => 'Enter access key';

  @override
  String get authenticate => 'Authenticate';

  @override
  String get authenticationSuccessful => 'Authentication successful';

  @override
  String get invalidAccessKey => 'Invalid access key';

  @override
  String failedToAuthenticate(String error) {
    return 'Failed to authenticate: $error';
  }

  @override
  String get chats => 'Chats';

  @override
  String get calls => 'Calls';

  @override
  String get contacts => 'Contacts';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get stories => 'Stories';

  @override
  String get users => 'Users';

  @override
  String get newUser => 'New User';

  @override
  String get myUsers => 'My Users';

  @override
  String get conversations => 'Conversations';

  @override
  String get addStory => 'Add Story';

  @override
  String get viewStory => 'View Story';

  @override
  String get storyViews => 'Story Views';

  @override
  String get storyExpired => 'This story has expired';

  @override
  String get noStoriesYet => 'No stories yet';

  @override
  String get deleteStory => 'Delete Story';

  @override
  String get deleteStoryConfirm => 'Are you sure you want to delete this story?';

  @override
  String get newChat => 'New Chat';

  @override
  String get searchChats => 'Search chats...';

  @override
  String get noChatsFound => 'No chats found';

  @override
  String get pinned => 'Pinned';

  @override
  String get unreadMessages => 'Unread Messages';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get send => 'Send';

  @override
  String get record => 'Record';

  @override
  String get uploadMedia => 'Upload Media';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get document => 'Document';

  @override
  String get audio => 'Audio';

  @override
  String get video => 'Video';

  @override
  String get location => 'Location';

  @override
  String get contactCard => 'Contact Card';

  @override
  String get sendMessageFailed => 'Failed to send message';

  @override
  String get messageCopied => 'Message copied';

  @override
  String get editMessage => 'Edit Message';

  @override
  String get deleteForEveryone => 'Delete for everyone';

  @override
  String get deleteForMe => 'Delete for me';

  @override
  String get edited => 'edited';

  @override
  String get sending => 'Sending...';

  @override
  String get sent => 'Sent';

  @override
  String get delivered => 'Delivered';

  @override
  String get seen => 'Seen';

  @override
  String get failed => 'Failed';

  @override
  String get voiceCall => 'Voice Call';

  @override
  String get videoCall => 'Video Call';

  @override
  String get missedCall => 'Missed Call';

  @override
  String get callEnded => 'Call Ended';

  @override
  String get calling => 'Calling...';

  @override
  String get incomingCall => 'Incoming Call';

  @override
  String get addContact => 'Add Contact';

  @override
  String get addNewContact => 'Add New Contact';

  @override
  String get addGroup => 'Add Group';

  @override
  String get archived => 'Archived';

  @override
  String get contactsList => 'Contacts List';

  @override
  String get noContactsFound => 'No contacts found';

  @override
  String get searchContacts => 'Search contacts...';

  @override
  String get searchUsers => 'Search Users...';

  @override
  String get searchViewers => 'Search Viewers...';

  @override
  String get tapToAddPhoto => 'Tap To Add Photo';

  @override
  String get reply => 'Reply';

  @override
  String get replyToYourStory => 'Reply To Your Story';

  @override
  String get messageDeleted => 'Message Deleted';

  @override
  String get less => 'Less';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get enterPhoneNumber => 'Enter phone number (optional)';

  @override
  String get address => 'Address';

  @override
  String get enterAddressOptional => 'Enter address (optional)';

  @override
  String get call => 'Call';

  @override
  String get chatWhatsApp => 'Chat on WhatsApp';

  @override
  String get couldNotMakeCall => 'Could not make call';

  @override
  String get couldNotOpenWhatsApp => 'Could not open WhatsApp';

  @override
  String get groupName => 'Group Name';

  @override
  String get enterGroupName => 'Enter group name';

  @override
  String get groupCreated => 'Group created';

  @override
  String get addParticipants => 'Add Participants';

  @override
  String get removeFromGroup => 'Remove from Group';

  @override
  String get groupInfo => 'Group Info';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get username => 'Username';

  @override
  String get enterUsername => 'Enter username';

  @override
  String get bio => 'Bio';

  @override
  String get enterBio => 'Enter bio';

  @override
  String get lastSeen => 'Last Seen';

  @override
  String get online => 'Online';

  @override
  String get typing => 'Typing...';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get security => 'Security';

  @override
  String get chatSettings => 'Chats Settings';

  @override
  String get privacySettings => 'Privacy Settings';

  @override
  String get customizeYourExperience => 'Customize your experience';

  @override
  String get blockedContacts => 'Blocked Contacts';

  @override
  String get unblock => 'Unblock';

  @override
  String get blockConfirm => 'Are you sure you want to block this user?';

  @override
  String get blockedSuccessfully => 'User blocked successfully';

  @override
  String get unblockedSuccessfully => 'User unblocked successfully';

  @override
  String get readReceipts => 'Read Receipts';

  @override
  String get typingIndicators => 'Typing indicators';

  @override
  String get showLastSeen => 'Show Last Seen';

  @override
  String get download => 'Download';

  @override
  String get downloading => 'Downloading...';

  @override
  String get fileNotSupported => 'This file type is not supported';

  @override
  String get openFile => 'Open File';

  @override
  String get viewImage => 'View Image';

  @override
  String get viewVideo => 'View Video';

  @override
  String get mute => 'Mute';

  @override
  String get unmute => 'Unmute';

  @override
  String get pinChat => 'Pin Chat';

  @override
  String get unpinChat => 'Unpin Chat';

  @override
  String get markAsUnread => 'Mark as unread';

  @override
  String get markAsRead => 'Mark as read';

  @override
  String get report => 'Report';

  @override
  String get searchInChat => 'Search in chat';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get forward => 'Forward';

  @override
  String get forwarded => 'Forwarded';

  @override
  String get selectMessages => 'Select messages';

  @override
  String get you => 'You';

  @override
  String get logout => 'Logout';

  @override
  String get logoutDescription => 'Sign out from your account';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get loggedOutSuccessfully => 'Logged out successfully';

  @override
  String failedToLogout(String error) {
    return 'Failed to logout: $error';
  }

  @override
  String get updateRequired => 'Update Required';

  @override
  String get updateRequiredMessage => 'A new version of the app is available. Please update to continue using the app.';

  @override
  String get latestVersion => 'Latest Version';

  @override
  String get updateNow => 'Update Now';

  @override
  String get couldNotOpenUpdateUrl => 'Could not open update URL';

  @override
  String get version => 'App Version';

  @override
  String get madeWith => 'Made By Momen & Ziad Muhammad';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get welcomeHeadline => 'Gathering friends together';

  @override
  String get getStarted => 'Get Started..';

  @override
  String get login => 'Login';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get email => 'Email';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get password => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get loggingIn => 'Logging in...';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get byLoggingInYouAgree => 'By logging in, you agree to our';

  @override
  String get termsAndConditions => 'Terms and Conditions';

  @override
  String get and => 'and';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get signup => 'Sign Up';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get name => 'Name';

  @override
  String get enterYourPhoneNumber => 'Enter your phone number';

  @override
  String get phone => 'Phone';

  @override
  String get signUpButton => 'Sign Up';

  @override
  String get signingUp => 'Signing Up...';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get signIn => 'Sign In';

  @override
  String get fillProfile => 'Fill Your Profile';

  @override
  String get completeProfileMessage => 'Complete your profile to get started';

  @override
  String get continueButton => 'Continue';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get enterYourBio => 'Tell us about yourself';

  @override
  String get searchConversations => 'Search Conversations..';

  @override
  String get messages => 'Messages';

  @override
  String totalUsers(Object count) {
    return 'Total Users ($count)';
  }

  @override
  String get createGroup => 'Create Group';

  @override
  String get newContact => 'New Contact';

  @override
  String get archive => 'Archive';

  @override
  String get myContacts => 'My Contacts';

  @override
  String get notification => 'Notification';

  @override
  String get privacySubtitle => 'Control your privacy settings';

  @override
  String get chatsSubtitle => 'Theme, wallpaper, chat history';

  @override
  String get languageSubtitle => 'Choose your language';

  @override
  String get notificationSubtitle => 'Messages, calls, and alerts';

  @override
  String get appearance => 'Appearance';

  @override
  String get systemDefault => 'System Default';

  @override
  String get chatWallpaper => 'Chat Wallpaper';

  @override
  String get defaultText => 'Default Text';

  @override
  String get chatBackup => 'Chat Backup';

  @override
  String get googleDrive => 'Google Drive';

  @override
  String get storageAndBackup => 'Storage And Backup';

  @override
  String get preferences => 'Preferences';

  @override
  String get enterIsSend => 'Enter is Send';

  @override
  String get pressEnterToSend => 'Press Enter to Send';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get clearAllChats => 'Clear All Chats';

  @override
  String get deleteAllConversationHistory => 'Delete all conversation history';

  @override
  String get deleteAllConversationHistoryConfirm => 'Are you sure you want to delete all conversation history?';

  @override
  String get themeSettings => 'Theme Settings';

  @override
  String get chooseYourPreferredTheme => 'Choose your preferred theme';

  @override
  String get brightAndClean => 'Bright and clean interface';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get easierOnEyes => 'Easier on the eyes in low light';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get matchDeviceSettings => 'Match your device settings';

  @override
  String get preview => 'Preview';

  @override
  String get colorsAndContrast => 'Colors and contrast preview';

  @override
  String get themeChangesApplyImmediately => 'Theme changes apply immediately and are saved automatically';

  @override
  String get sampleMessage => 'Sample Message';

  @override
  String get thisIsHowYourAppWillLook => 'This is how your app will look';

  @override
  String get about => 'About';

  @override
  String get aboutApp => 'About App';

  @override
  String get pleaseSelectAtLeastOneContact => 'Please Select AtLeast One Contact';

  @override
  String get groupCreatedSuccessfully => 'Group Created Successfully';

  @override
  String get pleaseEnterGroupName => 'Please enter a group name';

  @override
  String get createNewGroup => 'Create New Group';

  @override
  String get addMembersToYourGroup => 'Add members to your group';

  @override
  String get selected => 'Selected';

  @override
  String get noContactsAvailable => 'No Contacts Available';

  @override
  String get noGroupsAvailable => 'No Groups Available';

  @override
  String get noMessagesAvailable => 'No Messages Available';

  @override
  String get noCallsAvailable => 'No Calls Available';

  @override
  String get noStoriesAvailable => 'No Stories Available';

  @override
  String get noNotificationsAvailable => 'No Notifications Available';

  @override
  String get noSettingsAvailable => 'No Settings Available';

  @override
  String get noChatsAvailable => 'No Chats Available';

  @override
  String get noConversationsAvailable => 'No Conversations Available';

  @override
  String get groups => 'Groups';

  @override
  String get selectYourLanguage => 'Select Your Language';

  @override
  String get languageAppliesInstantly => 'Language applies instantly — no restart needed';

  @override
  String get unexpectedError => 'Unexpected error';

  @override
  String get work => 'Work';

  @override
  String get study => 'Study';

  @override
  String get gaming => 'Gaming';

  @override
  String get fitness => 'Fitness';

  @override
  String get creative => 'Creative';

  @override
  String get social => 'Social';

  @override
  String get step1Of2 => 'Step 1 of 2 • Group Details';

  @override
  String get requiredField => 'Required field';

  @override
  String get groupNameExample => 'e.g. Group Name';

  @override
  String get groupDescriptionHint => 'What\'s this group about?';

  @override
  String get category => 'Category';

  @override
  String get nextAddMembers => 'Next: Add Members';

  @override
  String get addMembers => 'Add Members';

  @override
  String get step2Of2 => 'Step 2 of 2 • Select group members';

  @override
  String get searchByNameOrEmail => 'Search by name or email...';

  @override
  String membersSelected(int count) {
    return '$count member(s) selected';
  }

  @override
  String groupMembers(int count) {
    return 'Group Members ($count)';
  }

  @override
  String get back => 'Back';

  @override
  String get privateGroup => 'Private Group';

  @override
  String get publicGroup => 'Public Group';

  @override
  String get onlyInvitedMembersCanJoin => 'Only invited members can join';

  @override
  String get anyoneCanDiscoverAndJoin => 'Anyone can discover and join';

  @override
  String get noUsersFound => 'No users found';

  @override
  String get tryAdjustingYourSearch => 'Try adjusting your search';

  @override
  String get description => 'Description';

  @override
  String get backToDetails => 'Back to Details';

  @override
  String get create => 'Create';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get inviteFriends => 'Invite Friends';

  @override
  String get blockedUsers => 'Blocked Users';

  @override
  String get shareInviteDescription => 'Share Invite Description';

  @override
  String get linkCopied => 'Link Copied';

  @override
  String get shareInvite => 'Share Invite';

  @override
  String get inviteProfessionalDesc => 'Invite friends and grow your network';

  @override
  String get yourInviteCode => 'Your invite code';

  @override
  String get inviteLink => 'Invite link';

  @override
  String invitedCount(Object count) {
    return 'Friends invited: $count';
  }

  @override
  String get inviteSubtitle => 'Share the app with your friends';

  @override
  String get inviteCode => 'Invite code';

  @override
  String get shareVia => 'Share via';

  @override
  String get more => 'More';

  @override
  String get copy => 'Copy';

  @override
  String get qrCode => 'QR Code';

  @override
  String get inviteShareText => 'Join me on this awesome app!';

  @override
  String get inviteSent => 'Invite sent successfully';

  @override
  String get storyFileTooLarge => 'File size must be less than 50MB';

  @override
  String get storyPickFailed => 'Failed to pick media';

  @override
  String get storyVideoLoadFailed => 'Failed to load video';

  @override
  String get storyUploadFailed => 'Upload failed';

  @override
  String get storyPosted => 'Story posted! 🎉';

  @override
  String get storyReplyPrefix => '📷 Replied to your story:';

  @override
  String get storyReplySentTitle => 'Reply sent';

  @override
  String get storyReplySentBody => 'Your message has been delivered.';

  @override
  String get storyReplySentOk => 'OK';

  @override
  String get storyLoading => 'Loading image…';

  @override
  String get storyLikes => 'likes';

  @override
  String get storyJustViewed => 'just viewed';

  @override
  String get storyAll => 'All';

  @override
  String get storyLiked => 'Liked';

  @override
  String get storyViewed => 'Viewed';

  @override
  String get storyNoViewers => 'No viewers yet';

  @override
  String get storyUploading => 'Uploading Story';

  @override
  String storyUploadPercent(Object percent) {
    return '$percent% complete';
  }

  @override
  String get storyTypeSomething => 'Type something...';

  @override
  String get storyBackground => 'Background';

  @override
  String get storyDone => 'Done';

  @override
  String get chatWallpaperTitle => 'Chat Wallpaper';

  @override
  String get chooseWallpaper => 'Choose Wallpaper';

  @override
  String get wallpaperClassic => 'Classic';

  @override
  String get wallpaperAbstractBlue => 'Abstract Blue';

  @override
  String get wallpaperGreenTexture => 'Green Texture';

  @override
  String get wallpaperYourPhoto => 'Your Photo';

  @override
  String get previewAndAdjust => 'Preview & Adjust';

  @override
  String get previewWallpaper => 'Preview Wallpaper';

  @override
  String get brightness => 'Brightness';

  @override
  String get save => 'Save';

  @override
  String get sampleHello => 'Hello 👋';

  @override
  String get sampleLooksGreat => 'Looks great!';

  @override
  String get locked => 'Locked';

  @override
  String get alertTypes => 'Alert Types';

  @override
  String get messageNotifications => 'Message Notifications';

  @override
  String get messageNotificationsDesc => 'Get notified for new messages';

  @override
  String get groupNotifications => 'Group Notifications';

  @override
  String get groupNotificationsDesc => 'Stay updated with group activities';

  @override
  String get notificationPreferences => 'Notification Preferences';

  @override
  String get showPreview => 'Show Message Preview';

  @override
  String get showPreviewDesc => 'Display message content in notifications';

  @override
  String get accountInformation => 'Account Information';

  @override
  String get userDetails => 'User Details';

  @override
  String get nameLabel => 'Name';

  @override
  String get bioLabel => 'Bio';

  @override
  String get emailLabel => 'Email';

  @override
  String get usernameLabel => 'Username';

  @override
  String get profilePhoto => 'Profile Photo';

  @override
  String get profilePhotoAction => 'What would you like to do?';

  @override
  String get change => 'Change';

  @override
  String get nameDescription => 'This is how your name will appear to other users';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get saving => 'Saving...';

  @override
  String get nameEmptyError => 'Name cannot be empty';

  @override
  String get nameUpdatedSuccess => 'Name updated successfully';

  @override
  String get bioDescription => 'Share a bit about yourself with your profile bio';

  @override
  String get yourBio => 'Your Bio';

  @override
  String get bioTip => 'Tip: Keep it short and interesting. Mention your hobbies or what makes you unique!';

  @override
  String get noStories => 'No stories';

  @override
  String get mediaComing => 'Media feature coming soon';

  @override
  String get createGroupComing => 'Create group feature coming soon';

  @override
  String groupsInCommon(int count) {
    return '$count groups in common';
  }

  @override
  String get message => 'Message';

  @override
  String get muteNotifications => 'Mute notifications';

  @override
  String get silenceAlerts => 'Silence alerts';

  @override
  String get mediaLinks => 'Media & Links';

  @override
  String get sharedFiles => 'Shared files';

  @override
  String get joined => 'Joined';

  @override
  String block(String username) {
    return 'Block $username';
  }

  @override
  String get blockDesc => 'Block this user';

  @override
  String get reportDesc => 'Report this user';

  @override
  String get blockUser => 'Block user';

  @override
  String get blockUserConfirm => 'Are you sure you want to block this user?';

  @override
  String get reportUser => 'Report user';

  @override
  String get reportUserConfirm => 'Are you sure you want to report this user?';

  @override
  String get reportReason => 'Report reason';

  @override
  String get reportReasonHint => 'Tell us why you\'re reporting this user';

  @override
  String showMore(int count) {
    return 'Show more ($count)';
  }

  @override
  String get showLess => 'Show less';

  @override
  String createGroupWith(String username) {
    return 'Create a group with $username';
  }

  @override
  String get startNewCommunity => 'Start a new community';

  @override
  String get bioUpdatedSuccess => 'Bio updated successfully';

  @override
  String get profileTapToAddBio => 'Tap to add bio';

  @override
  String get profileViewProfile => 'View Profile';

  @override
  String get profileEditProfile => 'Edit Profile';

  @override
  String get yourStory => 'Your Story';

  @override
  String get createStory => 'Create Story';

  @override
  String get optional => 'Optional';

  @override
  String get recording => 'Recording…';

  @override
  String get stop => 'Stop';

  @override
  String get image => 'Image';

  @override
  String get loadingImage => 'Loading image…';

  @override
  String get members => 'members';

  @override
  String get member => 'member';

  @override
  String get userNotFound => 'User not found';

  @override
  String get groupNotFound => 'Group not found';

  @override
  String get noStory => 'No story';

  @override
  String get err => 'Error';

  @override
  String get recordingLabel => 'Recording…';

  @override
  String get failedToLoadImage => 'Failed to load image';

  @override
  String membersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'members',
      one: 'member',
    );
    return '$count $_temp0';
  }

  @override
  String get chatAlreadyExists => 'Chat already exists with this user';

  @override
  String get networkError => 'Network error. Please check your connection';

  @override
  String get authenticationError => 'Authentication error. Please login again';

  @override
  String get failedToCreateChat => 'Failed to create chat. Please try again';

  @override
  String get groupNameRequired => 'Group name required';

  @override
  String get selectAtLeastOneMember => 'Select at least one member';

  @override
  String failedToUploadImage(String error) {
    return 'Failed to upload image: $error';
  }

  @override
  String get profileImage => 'Profile Image';

  @override
  String get groupPicture => 'Group Picture';

  @override
  String get profilePicture => 'Profile Picture';

  @override
  String get views => 'Views';

  @override
  String get likes => 'likes';

  @override
  String get all => 'All';

  @override
  String get liked => 'Liked';

  @override
  String get noViewersYet => 'No viewers yet';

  @override
  String get justViewed => 'just viewed';

  @override
  String get uploadingStory => 'Uploading Story';

  @override
  String uploadPercent(int percent) {
    return '$percent% complete';
  }

  @override
  String get typeSomething => 'Type something...';

  @override
  String get background => 'Background';

  @override
  String get noViewersFound => 'No viewers found';

  @override
  String get pdf => 'pdf';

  @override
  String get file => 'file';

  @override
  String get offline => 'offline';

  @override
  String get notificationInfo => 'Your settings are applied instantly.';

  @override
  String get groupPictureUpdated => 'Group Picture Updated';

  @override
  String get groupImageDesc => 'Make your group stand out with a picture.';

  @override
  String get admin => 'admin';

  @override
  String get media => 'Media';

  @override
  String get searchMedia => 'Search media...';

  @override
  String get mediaAll => 'All';

  @override
  String get mediaPhotos => 'Photos';

  @override
  String get mediaVideos => 'Videos';

  @override
  String get mediaAudio => 'Audio';

  @override
  String get mediaDocs => 'Docs';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get noMediaYet => 'No media yet';

  @override
  String get adjustSearchKeywords => 'Try adjusting your search keywords';

  @override
  String get mediaEmptyDescription => 'Photos, videos, audio, and documents shared\nin this conversation will appear here';

  @override
  String searchLabel(Object query) {
    return 'Search: \"$query\"';
  }

  @override
  String get createYourStory => 'Create Your Story';

  @override
  String get shareMomentWithFriends => 'Share a moment with your friends';

  @override
  String get storyUploadHint => 'Max 50MB • Photos & Videos';

  @override
  String get chooseMedia => 'Choose Media';

  @override
  String get post => 'Post';

  @override
  String uploadProgress(Object percent) {
    return '$percent% complete';
  }

  @override
  String get gender => 'Gender';

  @override
  String get confirmYourPassword => 'Confirm Your Password';

  @override
  String get bySigningUpYouAgree => 'By signing up, you agree to our';

  @override
  String get profileSettings => 'Profile Settings';

  @override
  String get loginSuccessful => 'Login successful';

  @override
  String get signupSuccessful => 'Signup successful';

  @override
  String get profileCompletedSuccessfully => 'Profile completed successfully';

  @override
  String get pleaseSelectProfileImage => 'Please select a profile image';

  @override
  String get nameIsRequired => 'Name is required';

  @override
  String get updatedSuccessfully => 'Updated Successfully';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get addCaption => 'Add caption';

  @override
  String get chatsSettings => 'Chats Settings';

  @override
  String get chatsWallpaperSubtitle => 'Change the wallpaper for your chats';

  @override
  String get mediaAndFiles => 'Media & Files';

  @override
  String get mediaEmptyTitle => 'No media yet';

  @override
  String get mediaErrorDescription => 'Failed to load media. Please try again.';

  @override
  String get mediaErrorTitle => 'Error loading media';

  @override
  String get noSharedFiles => 'No shared files';

  @override
  String get photo => 'Photo';

  @override
  String get attachment => 'Attachment';

  @override
  String get am => 'AM';

  @override
  String get pm => 'PM';

  @override
  String get storagePermissionDenied => 'Storage permission denied';

  @override
  String get downloadedSuccessfully => 'Downloaded successfully';

  @override
  String get downloadFailed => 'Download failed';

  @override
  String get now => 'now';

  @override
  String get minutesAgo => 'minutes ago';

  @override
  String get hoursAgo => 'hours ago';

  @override
  String get daysAgo => 'days ago';

  @override
  String get notificationsMuted => 'Notifications muted';

  @override
  String get videoPlayer => 'Video Player';

  @override
  String get videoPlayerComingSoon => 'Video Player Coming Soon';

  @override
  String get permissionDenied => 'Permission denied';

  @override
  String get createdAt => 'Created at';

  @override
  String get group => 'Group';

  @override
  String get editGroupName => 'Edit Group Name';

  @override
  String get editGroupDescription => 'Edit Group Description';

  @override
  String get addGroupDescription => 'Add Group Description';

  @override
  String get editGroupPicture => 'Edit Group Picture';

  @override
  String get removeMember => 'Remove Member';

  @override
  String get removeMemberConfirm => 'Are you sure you want to remove this member?';

  @override
  String get removeMemberSuccess => 'Member removed successfully';

  @override
  String get removeMemberFailed => 'Failed to remove member';

  @override
  String get owner => 'Owner';

  @override
  String get storyReplyNotifications => 'Story Reply Notifications';

  @override
  String get storyReplyNotificationsDesc => 'Receive notifications when someone replies to your story';

  @override
  String get notificationSound => 'Notification Sound';

  @override
  String get notificationSoundDesc => 'Choose the sound for your notifications';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrationDesc => 'Enable or disable vibration for notifications';

  @override
  String get messagePreview => 'Message Preview';

  @override
  String get messagePreviewDesc => 'Show a preview of the notification';

  @override
  String get inAppSound => 'In-App Sound';

  @override
  String get inAppSoundDesc => 'Play sound for incoming messages';

  @override
  String get noStoryFound => 'No story found';

  @override
  String get goBack => 'Go Back';

  @override
  String get paused => 'Paused';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get like => 'Like';

  @override
  String get unlike => 'Unlike';

  @override
  String get viewed => 'Viewed';

  @override
  String get viewers => 'Viewers';

  @override
  String get viewersSheetTitle => 'Viewers';

  @override
  String get viewersSheetDescription => 'Viewers of this story';

  @override
  String get tapToSeeWhoViewed => 'Tap to see who viewed your story';

  @override
  String get replyToStory => 'Reply to story...';

  @override
  String get voiceMessage => 'Voice Message';

  @override
  String get slideToCancel => 'Slide to cancel';

  @override
  String get releaseToCancel => 'Release to cancel';

  @override
  String get deleteMessage => 'Delete Message';

  @override
  String get deleteMessageConfirm => 'Are you sure you want to delete this message?';

  @override
  String get deleteMessageSuccess => 'Message deleted successfully';

  @override
  String get deleteMessageFailed => 'Failed to delete message';

  @override
  String get pinchToZoomTapToClose => 'Pinch to zoom  ·  Tap to close';

  @override
  String get chatInfo => 'Chat Info';

  @override
  String get minute => 'minute';

  @override
  String get hour => 'hour';

  @override
  String get day => 'day';

  @override
  String get ago => 'ago';

  @override
  String get justNow => 'just now';

  @override
  String get noViewsYet => 'No views yet';

  @override
  String addCount(Object count) {
    return 'Add ($count)';
  }

  @override
  String createCount(Object count) {
    return 'Create ($count)';
  }

  @override
  String get leaveGroup => 'Leave Group';

  @override
  String get leaveGroupConfirm => 'Are you sure you want to leave this group?';

  @override
  String get leaveGroupOwnerConfirm => 'You are the owner. Ownership will be transferred to the next member when you leave.';

  @override
  String get leaveAndTransfer => 'Leave & Transfer Ownership';

  @override
  String get createAGroupWithThisUser => 'Create a group with this user';

  @override
  String get commonGroups => 'Common Groups';

  @override
  String get emailOrPasswordIncorrect => 'Email or password incorrect';

  @override
  String get thisOperationFailed => 'This operation failed.';

  @override
  String get emailCannotBeChanged => 'Email cannot be changed';

  @override
  String get usernameCannotBeChanged => 'Username cannot be changed';

  @override
  String get couldNotLoadFile => 'Could Not Load File';

  @override
  String get brightnessDescription => 'Adjust overlay darkness to improve text readability';
}
