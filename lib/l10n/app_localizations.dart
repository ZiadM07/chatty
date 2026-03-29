import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @defaultSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get defaultSystem;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @textIsRequired.
  ///
  /// In en, this message translates to:
  /// **'is required'**
  String get textIsRequired;

  /// No description provided for @textIsTooShort.
  ///
  /// In en, this message translates to:
  /// **'is too short'**
  String get textIsTooShort;

  /// No description provided for @notValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Not valid email'**
  String get notValidEmail;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhoneNumber;

  /// No description provided for @invalidEgyptianPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid Egyptian phone number. Format: 01XXXXXXXXX'**
  String get invalidEgyptianPhoneNumber;

  /// No description provided for @newPhoneNumberError.
  ///
  /// In en, this message translates to:
  /// **'You can\'t use your old phone number'**
  String get newPhoneNumberError;

  /// No description provided for @validNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get validNumber;

  /// No description provided for @atLeast18.
  ///
  /// In en, this message translates to:
  /// **'Age must be at least 18'**
  String get atLeast18;

  /// No description provided for @accessKeyCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Access key cannot be empty'**
  String get accessKeyCannotBeEmpty;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @enterAccessKeyToContinue.
  ///
  /// In en, this message translates to:
  /// **'Enter your access key to continue'**
  String get enterAccessKeyToContinue;

  /// No description provided for @accessKey.
  ///
  /// In en, this message translates to:
  /// **'Access Key'**
  String get accessKey;

  /// No description provided for @enterAccessKey.
  ///
  /// In en, this message translates to:
  /// **'Enter access key'**
  String get enterAccessKey;

  /// No description provided for @authenticate.
  ///
  /// In en, this message translates to:
  /// **'Authenticate'**
  String get authenticate;

  /// No description provided for @authenticationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Authentication successful'**
  String get authenticationSuccessful;

  /// No description provided for @invalidAccessKey.
  ///
  /// In en, this message translates to:
  /// **'Invalid access key'**
  String get invalidAccessKey;

  /// No description provided for @failedToAuthenticate.
  ///
  /// In en, this message translates to:
  /// **'Failed to authenticate: {error}'**
  String failedToAuthenticate(String error);

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chats;

  /// No description provided for @calls.
  ///
  /// In en, this message translates to:
  /// **'Calls'**
  String get calls;

  /// No description provided for @contacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contacts;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @stories.
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get stories;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @newUser.
  ///
  /// In en, this message translates to:
  /// **'New User'**
  String get newUser;

  /// No description provided for @myUsers.
  ///
  /// In en, this message translates to:
  /// **'My Users'**
  String get myUsers;

  /// No description provided for @conversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversations;

  /// No description provided for @addStory.
  ///
  /// In en, this message translates to:
  /// **'Add Story'**
  String get addStory;

  /// No description provided for @viewStory.
  ///
  /// In en, this message translates to:
  /// **'View Story'**
  String get viewStory;

  /// No description provided for @storyViews.
  ///
  /// In en, this message translates to:
  /// **'Story Views'**
  String get storyViews;

  /// No description provided for @storyExpired.
  ///
  /// In en, this message translates to:
  /// **'This story has expired'**
  String get storyExpired;

  /// No description provided for @noStoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No stories yet'**
  String get noStoriesYet;

  /// No description provided for @deleteStory.
  ///
  /// In en, this message translates to:
  /// **'Delete Story'**
  String get deleteStory;

  /// No description provided for @deleteStoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this story?'**
  String get deleteStoryConfirm;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get newChat;

  /// No description provided for @searchChats.
  ///
  /// In en, this message translates to:
  /// **'Search chats...'**
  String get searchChats;

  /// No description provided for @noChatsFound.
  ///
  /// In en, this message translates to:
  /// **'No chats found'**
  String get noChatsFound;

  /// No description provided for @pinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get pinned;

  /// No description provided for @unreadMessages.
  ///
  /// In en, this message translates to:
  /// **'Unread Messages'**
  String get unreadMessages;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @record.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get record;

  /// No description provided for @uploadMedia.
  ///
  /// In en, this message translates to:
  /// **'Upload Media'**
  String get uploadMedia;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @document.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get document;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @contactCard.
  ///
  /// In en, this message translates to:
  /// **'Contact Card'**
  String get contactCard;

  /// No description provided for @sendMessageFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message'**
  String get sendMessageFailed;

  /// No description provided for @messageCopied.
  ///
  /// In en, this message translates to:
  /// **'Message copied'**
  String get messageCopied;

  /// No description provided for @editMessage.
  ///
  /// In en, this message translates to:
  /// **'Edit Message'**
  String get editMessage;

  /// No description provided for @deleteForEveryone.
  ///
  /// In en, this message translates to:
  /// **'Delete for everyone'**
  String get deleteForEveryone;

  /// No description provided for @deleteForMe.
  ///
  /// In en, this message translates to:
  /// **'Delete for me'**
  String get deleteForMe;

  /// No description provided for @edited.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get edited;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @seen.
  ///
  /// In en, this message translates to:
  /// **'Seen'**
  String get seen;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @voiceCall.
  ///
  /// In en, this message translates to:
  /// **'Voice Call'**
  String get voiceCall;

  /// No description provided for @videoCall.
  ///
  /// In en, this message translates to:
  /// **'Video Call'**
  String get videoCall;

  /// No description provided for @missedCall.
  ///
  /// In en, this message translates to:
  /// **'Missed Call'**
  String get missedCall;

  /// No description provided for @callEnded.
  ///
  /// In en, this message translates to:
  /// **'Call Ended'**
  String get callEnded;

  /// No description provided for @calling.
  ///
  /// In en, this message translates to:
  /// **'Calling...'**
  String get calling;

  /// No description provided for @incomingCall.
  ///
  /// In en, this message translates to:
  /// **'Incoming Call'**
  String get incomingCall;

  /// No description provided for @addContact.
  ///
  /// In en, this message translates to:
  /// **'Add Contact'**
  String get addContact;

  /// No description provided for @addNewContact.
  ///
  /// In en, this message translates to:
  /// **'Add New Contact'**
  String get addNewContact;

  /// No description provided for @addGroup.
  ///
  /// In en, this message translates to:
  /// **'Add Group'**
  String get addGroup;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @contactsList.
  ///
  /// In en, this message translates to:
  /// **'Contacts List'**
  String get contactsList;

  /// No description provided for @noContactsFound.
  ///
  /// In en, this message translates to:
  /// **'No contacts found'**
  String get noContactsFound;

  /// No description provided for @searchContacts.
  ///
  /// In en, this message translates to:
  /// **'Search contacts...'**
  String get searchContacts;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search Users...'**
  String get searchUsers;

  /// No description provided for @searchViewers.
  ///
  /// In en, this message translates to:
  /// **'Search Viewers...'**
  String get searchViewers;

  /// No description provided for @tapToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap To Add Photo'**
  String get tapToAddPhoto;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @replyToYourStory.
  ///
  /// In en, this message translates to:
  /// **'Reply To Your Story'**
  String get replyToYourStory;

  /// No description provided for @messageDeleted.
  ///
  /// In en, this message translates to:
  /// **'Message Deleted'**
  String get messageDeleted;

  /// No description provided for @less.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get less;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number (optional)'**
  String get enterPhoneNumber;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @enterAddressOptional.
  ///
  /// In en, this message translates to:
  /// **'Enter address (optional)'**
  String get enterAddressOptional;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @chatWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Chat on WhatsApp'**
  String get chatWhatsApp;

  /// No description provided for @couldNotMakeCall.
  ///
  /// In en, this message translates to:
  /// **'Could not make call'**
  String get couldNotMakeCall;

  /// No description provided for @couldNotOpenWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp'**
  String get couldNotOpenWhatsApp;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupName;

  /// No description provided for @enterGroupName.
  ///
  /// In en, this message translates to:
  /// **'Enter group name'**
  String get enterGroupName;

  /// No description provided for @groupCreated.
  ///
  /// In en, this message translates to:
  /// **'Group created'**
  String get groupCreated;

  /// No description provided for @addParticipants.
  ///
  /// In en, this message translates to:
  /// **'Add Participants'**
  String get addParticipants;

  /// No description provided for @removeFromGroup.
  ///
  /// In en, this message translates to:
  /// **'Remove from Group'**
  String get removeFromGroup;

  /// No description provided for @groupInfo.
  ///
  /// In en, this message translates to:
  /// **'Group Info'**
  String get groupInfo;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get enterUsername;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @enterBio.
  ///
  /// In en, this message translates to:
  /// **'Enter bio'**
  String get enterBio;

  /// No description provided for @lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last Seen'**
  String get lastSeen;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'Typing...'**
  String get typing;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @chatSettings.
  ///
  /// In en, this message translates to:
  /// **'Chats Settings'**
  String get chatSettings;

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy Settings'**
  String get privacySettings;

  /// No description provided for @customizeYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Customize your experience'**
  String get customizeYourExperience;

  /// No description provided for @blockedContacts.
  ///
  /// In en, this message translates to:
  /// **'Blocked Contacts'**
  String get blockedContacts;

  /// No description provided for @unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// No description provided for @blockConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to block this user?'**
  String get blockConfirm;

  /// No description provided for @blockedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'User blocked successfully'**
  String get blockedSuccessfully;

  /// No description provided for @unblockedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'User unblocked successfully'**
  String get unblockedSuccessfully;

  /// No description provided for @readReceipts.
  ///
  /// In en, this message translates to:
  /// **'Read Receipts'**
  String get readReceipts;

  /// No description provided for @typingIndicators.
  ///
  /// In en, this message translates to:
  /// **'Typing indicators'**
  String get typingIndicators;

  /// No description provided for @showLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Show Last Seen'**
  String get showLastSeen;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get downloading;

  /// No description provided for @fileNotSupported.
  ///
  /// In en, this message translates to:
  /// **'This file type is not supported'**
  String get fileNotSupported;

  /// No description provided for @openFile.
  ///
  /// In en, this message translates to:
  /// **'Open File'**
  String get openFile;

  /// No description provided for @viewImage.
  ///
  /// In en, this message translates to:
  /// **'View Image'**
  String get viewImage;

  /// No description provided for @viewVideo.
  ///
  /// In en, this message translates to:
  /// **'View Video'**
  String get viewVideo;

  /// No description provided for @mute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// No description provided for @unmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unmute;

  /// No description provided for @pinChat.
  ///
  /// In en, this message translates to:
  /// **'Pin Chat'**
  String get pinChat;

  /// No description provided for @unpinChat.
  ///
  /// In en, this message translates to:
  /// **'Unpin Chat'**
  String get unpinChat;

  /// No description provided for @markAsUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark as unread'**
  String get markAsUnread;

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markAsRead;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @searchInChat.
  ///
  /// In en, this message translates to:
  /// **'Search in chat'**
  String get searchInChat;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @forward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get forward;

  /// No description provided for @forwarded.
  ///
  /// In en, this message translates to:
  /// **'Forwarded'**
  String get forwarded;

  /// No description provided for @selectMessages.
  ///
  /// In en, this message translates to:
  /// **'Select messages'**
  String get selectMessages;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign out from your account'**
  String get logoutDescription;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @loggedOutSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get loggedOutSuccessfully;

  /// No description provided for @failedToLogout.
  ///
  /// In en, this message translates to:
  /// **'Failed to logout: {error}'**
  String failedToLogout(String error);

  /// No description provided for @updateRequired.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get updateRequired;

  /// No description provided for @updateRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'A new version of the app is available. Please update to continue using the app.'**
  String get updateRequiredMessage;

  /// No description provided for @latestVersion.
  ///
  /// In en, this message translates to:
  /// **'Latest Version'**
  String get latestVersion;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @couldNotOpenUpdateUrl.
  ///
  /// In en, this message translates to:
  /// **'Could not open update URL'**
  String get couldNotOpenUpdateUrl;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get version;

  /// No description provided for @madeWith.
  ///
  /// In en, this message translates to:
  /// **'Made By Momen & Ziad Muhammad'**
  String get madeWith;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @welcomeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Gathering friends together'**
  String get welcomeHeadline;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started..'**
  String get getStarted;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get loggingIn;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @byLoggingInYouAgree.
  ///
  /// In en, this message translates to:
  /// **'By logging in, you agree to our'**
  String get byLoggingInYouAgree;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @enterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhoneNumber;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButton;

  /// No description provided for @signingUp.
  ///
  /// In en, this message translates to:
  /// **'Signing Up...'**
  String get signingUp;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @fillProfile.
  ///
  /// In en, this message translates to:
  /// **'Fill Your Profile'**
  String get fillProfile;

  /// No description provided for @completeProfileMessage.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to get started'**
  String get completeProfileMessage;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @enterYourBio.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get enterYourBio;

  /// No description provided for @searchConversations.
  ///
  /// In en, this message translates to:
  /// **'Search Conversations..'**
  String get searchConversations;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @totalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users ({count})'**
  String totalUsers(Object count);

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get createGroup;

  /// No description provided for @newContact.
  ///
  /// In en, this message translates to:
  /// **'New Contact'**
  String get newContact;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @myContacts.
  ///
  /// In en, this message translates to:
  /// **'My Contacts'**
  String get myContacts;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @privacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Control your privacy settings'**
  String get privacySubtitle;

  /// No description provided for @chatsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Theme, wallpaper, chat history'**
  String get chatsSubtitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languageSubtitle;

  /// No description provided for @notificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Messages, calls, and alerts'**
  String get notificationSubtitle;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @chatWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Chat Wallpaper'**
  String get chatWallpaper;

  /// No description provided for @defaultText.
  ///
  /// In en, this message translates to:
  /// **'Default Text'**
  String get defaultText;

  /// No description provided for @chatBackup.
  ///
  /// In en, this message translates to:
  /// **'Chat Backup'**
  String get chatBackup;

  /// No description provided for @googleDrive.
  ///
  /// In en, this message translates to:
  /// **'Google Drive'**
  String get googleDrive;

  /// No description provided for @storageAndBackup.
  ///
  /// In en, this message translates to:
  /// **'Storage And Backup'**
  String get storageAndBackup;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @enterIsSend.
  ///
  /// In en, this message translates to:
  /// **'Enter is Send'**
  String get enterIsSend;

  /// No description provided for @pressEnterToSend.
  ///
  /// In en, this message translates to:
  /// **'Press Enter to Send'**
  String get pressEnterToSend;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @clearAllChats.
  ///
  /// In en, this message translates to:
  /// **'Clear All Chats'**
  String get clearAllChats;

  /// No description provided for @deleteAllConversationHistory.
  ///
  /// In en, this message translates to:
  /// **'Delete all conversation history'**
  String get deleteAllConversationHistory;

  /// No description provided for @deleteAllConversationHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all conversation history?'**
  String get deleteAllConversationHistoryConfirm;

  /// No description provided for @themeSettings.
  ///
  /// In en, this message translates to:
  /// **'Theme Settings'**
  String get themeSettings;

  /// No description provided for @chooseYourPreferredTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred theme'**
  String get chooseYourPreferredTheme;

  /// No description provided for @brightAndClean.
  ///
  /// In en, this message translates to:
  /// **'Bright and clean interface'**
  String get brightAndClean;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @easierOnEyes.
  ///
  /// In en, this message translates to:
  /// **'Easier on the eyes in low light'**
  String get easierOnEyes;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @matchDeviceSettings.
  ///
  /// In en, this message translates to:
  /// **'Match your device settings'**
  String get matchDeviceSettings;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @colorsAndContrast.
  ///
  /// In en, this message translates to:
  /// **'Colors and contrast preview'**
  String get colorsAndContrast;

  /// No description provided for @themeChangesApplyImmediately.
  ///
  /// In en, this message translates to:
  /// **'Theme changes apply immediately and are saved automatically'**
  String get themeChangesApplyImmediately;

  /// No description provided for @sampleMessage.
  ///
  /// In en, this message translates to:
  /// **'Sample Message'**
  String get sampleMessage;

  /// No description provided for @thisIsHowYourAppWillLook.
  ///
  /// In en, this message translates to:
  /// **'This is how your app will look'**
  String get thisIsHowYourAppWillLook;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @pleaseSelectAtLeastOneContact.
  ///
  /// In en, this message translates to:
  /// **'Please Select AtLeast One Contact'**
  String get pleaseSelectAtLeastOneContact;

  /// No description provided for @groupCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Group Created Successfully'**
  String get groupCreatedSuccessfully;

  /// No description provided for @pleaseEnterGroupName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a group name'**
  String get pleaseEnterGroupName;

  /// No description provided for @createNewGroup.
  ///
  /// In en, this message translates to:
  /// **'Create New Group'**
  String get createNewGroup;

  /// No description provided for @addMembersToYourGroup.
  ///
  /// In en, this message translates to:
  /// **'Add members to your group'**
  String get addMembersToYourGroup;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @noContactsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Contacts Available'**
  String get noContactsAvailable;

  /// No description provided for @noGroupsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Groups Available'**
  String get noGroupsAvailable;

  /// No description provided for @noMessagesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Messages Available'**
  String get noMessagesAvailable;

  /// No description provided for @noCallsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Calls Available'**
  String get noCallsAvailable;

  /// No description provided for @noStoriesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Stories Available'**
  String get noStoriesAvailable;

  /// No description provided for @noNotificationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Notifications Available'**
  String get noNotificationsAvailable;

  /// No description provided for @noSettingsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Settings Available'**
  String get noSettingsAvailable;

  /// No description provided for @noChatsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Chats Available'**
  String get noChatsAvailable;

  /// No description provided for @noConversationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Conversations Available'**
  String get noConversationsAvailable;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @selectYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Your Language'**
  String get selectYourLanguage;

  /// No description provided for @languageAppliesInstantly.
  ///
  /// In en, this message translates to:
  /// **'Language applies instantly — no restart needed'**
  String get languageAppliesInstantly;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error'**
  String get unexpectedError;

  /// No description provided for @work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// No description provided for @study.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get study;

  /// No description provided for @gaming.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get gaming;

  /// No description provided for @fitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get fitness;

  /// No description provided for @creative.
  ///
  /// In en, this message translates to:
  /// **'Creative'**
  String get creative;

  /// No description provided for @social.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get social;

  /// No description provided for @step1Of2.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 2 • Group Details'**
  String get step1Of2;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get requiredField;

  /// No description provided for @groupNameExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. Group Name'**
  String get groupNameExample;

  /// No description provided for @groupDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s this group about?'**
  String get groupDescriptionHint;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @nextAddMembers.
  ///
  /// In en, this message translates to:
  /// **'Next: Add Members'**
  String get nextAddMembers;

  /// No description provided for @addMembers.
  ///
  /// In en, this message translates to:
  /// **'Add Members'**
  String get addMembers;

  /// No description provided for @step2Of2.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 2 • Select group members'**
  String get step2Of2;

  /// No description provided for @searchByNameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email...'**
  String get searchByNameOrEmail;

  /// No description provided for @membersSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} member(s) selected'**
  String membersSelected(int count);

  /// No description provided for @groupMembers.
  ///
  /// In en, this message translates to:
  /// **'Group Members ({count})'**
  String groupMembers(int count);

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @privateGroup.
  ///
  /// In en, this message translates to:
  /// **'Private Group'**
  String get privateGroup;

  /// No description provided for @publicGroup.
  ///
  /// In en, this message translates to:
  /// **'Public Group'**
  String get publicGroup;

  /// No description provided for @onlyInvitedMembersCanJoin.
  ///
  /// In en, this message translates to:
  /// **'Only invited members can join'**
  String get onlyInvitedMembersCanJoin;

  /// No description provided for @anyoneCanDiscoverAndJoin.
  ///
  /// In en, this message translates to:
  /// **'Anyone can discover and join'**
  String get anyoneCanDiscoverAndJoin;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @tryAdjustingYourSearch.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search'**
  String get tryAdjustingYourSearch;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @backToDetails.
  ///
  /// In en, this message translates to:
  /// **'Back to Details'**
  String get backToDetails;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @inviteFriends.
  ///
  /// In en, this message translates to:
  /// **'Invite Friends'**
  String get inviteFriends;

  /// No description provided for @blockedUsers.
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get blockedUsers;

  /// No description provided for @shareInviteDescription.
  ///
  /// In en, this message translates to:
  /// **'Share Invite Description'**
  String get shareInviteDescription;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link Copied'**
  String get linkCopied;

  /// No description provided for @shareInvite.
  ///
  /// In en, this message translates to:
  /// **'Share Invite'**
  String get shareInvite;

  /// No description provided for @inviteProfessionalDesc.
  ///
  /// In en, this message translates to:
  /// **'Invite friends and grow your network'**
  String get inviteProfessionalDesc;

  /// No description provided for @yourInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Your invite code'**
  String get yourInviteCode;

  /// No description provided for @inviteLink.
  ///
  /// In en, this message translates to:
  /// **'Invite link'**
  String get inviteLink;

  /// No description provided for @invitedCount.
  ///
  /// In en, this message translates to:
  /// **'Friends invited: {count}'**
  String invitedCount(Object count);

  /// No description provided for @inviteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share the app with your friends'**
  String get inviteSubtitle;

  /// No description provided for @inviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get inviteCode;

  /// No description provided for @shareVia.
  ///
  /// In en, this message translates to:
  /// **'Share via'**
  String get shareVia;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @qrCode.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get qrCode;

  /// No description provided for @inviteShareText.
  ///
  /// In en, this message translates to:
  /// **'Join me on this awesome app!'**
  String get inviteShareText;

  /// No description provided for @inviteSent.
  ///
  /// In en, this message translates to:
  /// **'Invite sent successfully'**
  String get inviteSent;

  /// No description provided for @storyFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File size must be less than 50MB'**
  String get storyFileTooLarge;

  /// No description provided for @storyPickFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick media'**
  String get storyPickFailed;

  /// No description provided for @storyVideoLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load video'**
  String get storyVideoLoadFailed;

  /// No description provided for @storyUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get storyUploadFailed;

  /// No description provided for @storyPosted.
  ///
  /// In en, this message translates to:
  /// **'Story posted! 🎉'**
  String get storyPosted;

  /// No description provided for @storyReplyPrefix.
  ///
  /// In en, this message translates to:
  /// **'📷 Replied to your story:'**
  String get storyReplyPrefix;

  /// No description provided for @storyReplySentTitle.
  ///
  /// In en, this message translates to:
  /// **'Reply sent'**
  String get storyReplySentTitle;

  /// No description provided for @storyReplySentBody.
  ///
  /// In en, this message translates to:
  /// **'Your message has been delivered.'**
  String get storyReplySentBody;

  /// No description provided for @storyReplySentOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get storyReplySentOk;

  /// No description provided for @storyLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading image…'**
  String get storyLoading;

  /// No description provided for @storyLikes.
  ///
  /// In en, this message translates to:
  /// **'likes'**
  String get storyLikes;

  /// No description provided for @storyJustViewed.
  ///
  /// In en, this message translates to:
  /// **'just viewed'**
  String get storyJustViewed;

  /// No description provided for @storyAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get storyAll;

  /// No description provided for @storyLiked.
  ///
  /// In en, this message translates to:
  /// **'Liked'**
  String get storyLiked;

  /// No description provided for @storyViewed.
  ///
  /// In en, this message translates to:
  /// **'Viewed'**
  String get storyViewed;

  /// No description provided for @storyNoViewers.
  ///
  /// In en, this message translates to:
  /// **'No viewers yet'**
  String get storyNoViewers;

  /// No description provided for @storyUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading Story'**
  String get storyUploading;

  /// No description provided for @storyUploadPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String storyUploadPercent(Object percent);

  /// No description provided for @storyTypeSomething.
  ///
  /// In en, this message translates to:
  /// **'Type something...'**
  String get storyTypeSomething;

  /// No description provided for @storyBackground.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get storyBackground;

  /// No description provided for @storyDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get storyDone;

  /// No description provided for @chatWallpaperTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat Wallpaper'**
  String get chatWallpaperTitle;

  /// No description provided for @chooseWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Choose Wallpaper'**
  String get chooseWallpaper;

  /// No description provided for @wallpaperClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get wallpaperClassic;

  /// No description provided for @wallpaperAbstractBlue.
  ///
  /// In en, this message translates to:
  /// **'Abstract Blue'**
  String get wallpaperAbstractBlue;

  /// No description provided for @wallpaperGreenTexture.
  ///
  /// In en, this message translates to:
  /// **'Green Texture'**
  String get wallpaperGreenTexture;

  /// No description provided for @wallpaperYourPhoto.
  ///
  /// In en, this message translates to:
  /// **'Your Photo'**
  String get wallpaperYourPhoto;

  /// No description provided for @previewAndAdjust.
  ///
  /// In en, this message translates to:
  /// **'Preview & Adjust'**
  String get previewAndAdjust;

  /// No description provided for @previewWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Preview Wallpaper'**
  String get previewWallpaper;

  /// No description provided for @brightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightness;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @sampleHello.
  ///
  /// In en, this message translates to:
  /// **'Hello 👋'**
  String get sampleHello;

  /// No description provided for @sampleLooksGreat.
  ///
  /// In en, this message translates to:
  /// **'Looks great!'**
  String get sampleLooksGreat;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @alertTypes.
  ///
  /// In en, this message translates to:
  /// **'Alert Types'**
  String get alertTypes;

  /// No description provided for @messageNotifications.
  ///
  /// In en, this message translates to:
  /// **'Message Notifications'**
  String get messageNotifications;

  /// No description provided for @messageNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified for new messages'**
  String get messageNotificationsDesc;

  /// No description provided for @groupNotifications.
  ///
  /// In en, this message translates to:
  /// **'Group Notifications'**
  String get groupNotifications;

  /// No description provided for @groupNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Stay updated with group activities'**
  String get groupNotificationsDesc;

  /// No description provided for @notificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get notificationPreferences;

  /// No description provided for @showPreview.
  ///
  /// In en, this message translates to:
  /// **'Show Message Preview'**
  String get showPreview;

  /// No description provided for @showPreviewDesc.
  ///
  /// In en, this message translates to:
  /// **'Display message content in notifications'**
  String get showPreviewDesc;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @userDetails.
  ///
  /// In en, this message translates to:
  /// **'User Details'**
  String get userDetails;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @bioLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bioLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo'**
  String get profilePhoto;

  /// No description provided for @profilePhotoAction.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get profilePhotoAction;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @nameDescription.
  ///
  /// In en, this message translates to:
  /// **'This is how your name will appear to other users'**
  String get nameDescription;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @nameEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get nameEmptyError;

  /// No description provided for @nameUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Name updated successfully'**
  String get nameUpdatedSuccess;

  /// No description provided for @bioDescription.
  ///
  /// In en, this message translates to:
  /// **'Share a bit about yourself with your profile bio'**
  String get bioDescription;

  /// No description provided for @yourBio.
  ///
  /// In en, this message translates to:
  /// **'Your Bio'**
  String get yourBio;

  /// No description provided for @bioTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: Keep it short and interesting. Mention your hobbies or what makes you unique!'**
  String get bioTip;

  /// No description provided for @noStories.
  ///
  /// In en, this message translates to:
  /// **'No stories'**
  String get noStories;

  /// No description provided for @mediaComing.
  ///
  /// In en, this message translates to:
  /// **'Media feature coming soon'**
  String get mediaComing;

  /// No description provided for @createGroupComing.
  ///
  /// In en, this message translates to:
  /// **'Create group feature coming soon'**
  String get createGroupComing;

  /// No description provided for @groupsInCommon.
  ///
  /// In en, this message translates to:
  /// **'{count} groups in common'**
  String groupsInCommon(int count);

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @muteNotifications.
  ///
  /// In en, this message translates to:
  /// **'Mute notifications'**
  String get muteNotifications;

  /// No description provided for @silenceAlerts.
  ///
  /// In en, this message translates to:
  /// **'Silence alerts'**
  String get silenceAlerts;

  /// No description provided for @mediaLinks.
  ///
  /// In en, this message translates to:
  /// **'Media & Links'**
  String get mediaLinks;

  /// No description provided for @sharedFiles.
  ///
  /// In en, this message translates to:
  /// **'Shared files'**
  String get sharedFiles;

  /// No description provided for @joined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joined;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block {username}'**
  String block(String username);

  /// No description provided for @blockDesc.
  ///
  /// In en, this message translates to:
  /// **'Block this user'**
  String get blockDesc;

  /// No description provided for @reportDesc.
  ///
  /// In en, this message translates to:
  /// **'Report this user'**
  String get reportDesc;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get blockUser;

  /// No description provided for @blockUserConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to block this user?'**
  String get blockUserConfirm;

  /// No description provided for @reportUser.
  ///
  /// In en, this message translates to:
  /// **'Report user'**
  String get reportUser;

  /// No description provided for @reportUserConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to report this user?'**
  String get reportUserConfirm;

  /// No description provided for @reportReason.
  ///
  /// In en, this message translates to:
  /// **'Report reason'**
  String get reportReason;

  /// No description provided for @reportReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us why you\'re reporting this user'**
  String get reportReasonHint;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show more ({count})'**
  String showMore(int count);

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @createGroupWith.
  ///
  /// In en, this message translates to:
  /// **'Create a group with {username}'**
  String createGroupWith(String username);

  /// No description provided for @startNewCommunity.
  ///
  /// In en, this message translates to:
  /// **'Start a new community'**
  String get startNewCommunity;

  /// No description provided for @bioUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Bio updated successfully'**
  String get bioUpdatedSuccess;

  /// No description provided for @profileTapToAddBio.
  ///
  /// In en, this message translates to:
  /// **'Tap to add bio'**
  String get profileTapToAddBio;

  /// No description provided for @profileViewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get profileViewProfile;

  /// No description provided for @profileEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditProfile;

  /// No description provided for @yourStory.
  ///
  /// In en, this message translates to:
  /// **'Your Story'**
  String get yourStory;

  /// No description provided for @createStory.
  ///
  /// In en, this message translates to:
  /// **'Create Story'**
  String get createStory;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'Recording…'**
  String get recording;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @loadingImage.
  ///
  /// In en, this message translates to:
  /// **'Loading image…'**
  String get loadingImage;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'members'**
  String get members;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'member'**
  String get member;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @groupNotFound.
  ///
  /// In en, this message translates to:
  /// **'Group not found'**
  String get groupNotFound;

  /// No description provided for @noStory.
  ///
  /// In en, this message translates to:
  /// **'No story'**
  String get noStory;

  /// No description provided for @err.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get err;

  /// No description provided for @recordingLabel.
  ///
  /// In en, this message translates to:
  /// **'Recording…'**
  String get recordingLabel;

  /// No description provided for @failedToLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get failedToLoadImage;

  /// No description provided for @membersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1 {member} other {members}}'**
  String membersCount(int count);

  /// No description provided for @chatAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Chat already exists with this user'**
  String get chatAlreadyExists;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection'**
  String get networkError;

  /// No description provided for @authenticationError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error. Please login again'**
  String get authenticationError;

  /// No description provided for @failedToCreateChat.
  ///
  /// In en, this message translates to:
  /// **'Failed to create chat. Please try again'**
  String get failedToCreateChat;

  /// No description provided for @groupNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Group name required'**
  String get groupNameRequired;

  /// No description provided for @selectAtLeastOneMember.
  ///
  /// In en, this message translates to:
  /// **'Select at least one member'**
  String get selectAtLeastOneMember;

  /// No description provided for @failedToUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image: {error}'**
  String failedToUploadImage(String error);

  /// No description provided for @profileImage.
  ///
  /// In en, this message translates to:
  /// **'Profile Image'**
  String get profileImage;

  /// No description provided for @groupPicture.
  ///
  /// In en, this message translates to:
  /// **'Group Picture'**
  String get groupPicture;

  /// No description provided for @profilePicture.
  ///
  /// In en, this message translates to:
  /// **'Profile Picture'**
  String get profilePicture;

  /// No description provided for @views.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get views;

  /// No description provided for @likes.
  ///
  /// In en, this message translates to:
  /// **'likes'**
  String get likes;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @liked.
  ///
  /// In en, this message translates to:
  /// **'Liked'**
  String get liked;

  /// No description provided for @noViewersYet.
  ///
  /// In en, this message translates to:
  /// **'No viewers yet'**
  String get noViewersYet;

  /// No description provided for @justViewed.
  ///
  /// In en, this message translates to:
  /// **'just viewed'**
  String get justViewed;

  /// No description provided for @uploadingStory.
  ///
  /// In en, this message translates to:
  /// **'Uploading Story'**
  String get uploadingStory;

  /// No description provided for @uploadPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String uploadPercent(int percent);

  /// No description provided for @typeSomething.
  ///
  /// In en, this message translates to:
  /// **'Type something...'**
  String get typeSomething;

  /// No description provided for @background.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get background;

  /// No description provided for @noViewersFound.
  ///
  /// In en, this message translates to:
  /// **'No viewers found'**
  String get noViewersFound;

  /// No description provided for @pdf.
  ///
  /// In en, this message translates to:
  /// **'pdf'**
  String get pdf;

  /// No description provided for @file.
  ///
  /// In en, this message translates to:
  /// **'file'**
  String get file;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'offline'**
  String get offline;

  /// No description provided for @notificationInfo.
  ///
  /// In en, this message translates to:
  /// **'Your settings are applied instantly.'**
  String get notificationInfo;

  /// No description provided for @groupPictureUpdated.
  ///
  /// In en, this message translates to:
  /// **'Group Picture Updated'**
  String get groupPictureUpdated;

  /// No description provided for @groupImageDesc.
  ///
  /// In en, this message translates to:
  /// **'Make your group stand out with a picture.'**
  String get groupImageDesc;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'admin'**
  String get admin;

  /// No description provided for @media.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get media;

  /// No description provided for @searchMedia.
  ///
  /// In en, this message translates to:
  /// **'Search media...'**
  String get searchMedia;

  /// No description provided for @mediaAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get mediaAll;

  /// No description provided for @mediaPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get mediaPhotos;

  /// No description provided for @mediaVideos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get mediaVideos;

  /// No description provided for @mediaAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get mediaAudio;

  /// No description provided for @mediaDocs.
  ///
  /// In en, this message translates to:
  /// **'Docs'**
  String get mediaDocs;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @noMediaYet.
  ///
  /// In en, this message translates to:
  /// **'No media yet'**
  String get noMediaYet;

  /// No description provided for @adjustSearchKeywords.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search keywords'**
  String get adjustSearchKeywords;

  /// No description provided for @mediaEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Photos, videos, audio, and documents shared\nin this conversation will appear here'**
  String get mediaEmptyDescription;

  /// No description provided for @searchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search: \"{query}\"'**
  String searchLabel(Object query);

  /// No description provided for @createYourStory.
  ///
  /// In en, this message translates to:
  /// **'Create Your Story'**
  String get createYourStory;

  /// No description provided for @shareMomentWithFriends.
  ///
  /// In en, this message translates to:
  /// **'Share a moment with your friends'**
  String get shareMomentWithFriends;

  /// No description provided for @storyUploadHint.
  ///
  /// In en, this message translates to:
  /// **'Max 50MB • Photos & Videos'**
  String get storyUploadHint;

  /// No description provided for @chooseMedia.
  ///
  /// In en, this message translates to:
  /// **'Choose Media'**
  String get chooseMedia;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @uploadProgress.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String uploadProgress(Object percent);

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Your Password'**
  String get confirmYourPassword;

  /// No description provided for @bySigningUpYouAgree.
  ///
  /// In en, this message translates to:
  /// **'By signing up, you agree to our'**
  String get bySigningUpYouAgree;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileSettings;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccessful;

  /// No description provided for @signupSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Signup successful'**
  String get signupSuccessful;

  /// No description provided for @profileCompletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile completed successfully'**
  String get profileCompletedSuccessfully;

  /// No description provided for @pleaseSelectProfileImage.
  ///
  /// In en, this message translates to:
  /// **'Please select a profile image'**
  String get pleaseSelectProfileImage;

  /// No description provided for @nameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameIsRequired;

  /// No description provided for @updatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Updated Successfully'**
  String get updatedSuccessfully;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @addCaption.
  ///
  /// In en, this message translates to:
  /// **'Add caption'**
  String get addCaption;

  /// No description provided for @chatsSettings.
  ///
  /// In en, this message translates to:
  /// **'Chats Settings'**
  String get chatsSettings;

  /// No description provided for @chatsWallpaperSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change the wallpaper for your chats'**
  String get chatsWallpaperSubtitle;

  /// No description provided for @mediaAndFiles.
  ///
  /// In en, this message translates to:
  /// **'Media & Files'**
  String get mediaAndFiles;

  /// No description provided for @mediaEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No media yet'**
  String get mediaEmptyTitle;

  /// No description provided for @mediaErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'Failed to load media. Please try again.'**
  String get mediaErrorDescription;

  /// No description provided for @mediaErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error loading media'**
  String get mediaErrorTitle;

  /// No description provided for @noSharedFiles.
  ///
  /// In en, this message translates to:
  /// **'No shared files'**
  String get noSharedFiles;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @attachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get attachment;

  /// No description provided for @am.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get am;

  /// No description provided for @pm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get pm;

  /// No description provided for @storagePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Storage permission denied'**
  String get storagePermissionDenied;

  /// No description provided for @downloadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Downloaded successfully'**
  String get downloadedSuccessfully;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get downloadFailed;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get now;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'minutes ago'**
  String get minutesAgo;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'hours ago'**
  String get hoursAgo;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get daysAgo;

  /// No description provided for @notificationsMuted.
  ///
  /// In en, this message translates to:
  /// **'Notifications muted'**
  String get notificationsMuted;

  /// No description provided for @videoPlayer.
  ///
  /// In en, this message translates to:
  /// **'Video Player'**
  String get videoPlayer;

  /// No description provided for @videoPlayerComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Video Player Coming Soon'**
  String get videoPlayerComingSoon;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get permissionDenied;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get createdAt;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @editGroupName.
  ///
  /// In en, this message translates to:
  /// **'Edit Group Name'**
  String get editGroupName;

  /// No description provided for @editGroupDescription.
  ///
  /// In en, this message translates to:
  /// **'Edit Group Description'**
  String get editGroupDescription;

  /// No description provided for @addGroupDescription.
  ///
  /// In en, this message translates to:
  /// **'Add Group Description'**
  String get addGroupDescription;

  /// No description provided for @editGroupPicture.
  ///
  /// In en, this message translates to:
  /// **'Edit Group Picture'**
  String get editGroupPicture;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove Member'**
  String get removeMember;

  /// No description provided for @removeMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this member?'**
  String get removeMemberConfirm;

  /// No description provided for @removeMemberSuccess.
  ///
  /// In en, this message translates to:
  /// **'Member removed successfully'**
  String get removeMemberSuccess;

  /// No description provided for @removeMemberFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove member'**
  String get removeMemberFailed;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @storyReplyNotifications.
  ///
  /// In en, this message translates to:
  /// **'Story Reply Notifications'**
  String get storyReplyNotifications;

  /// No description provided for @storyReplyNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications when someone replies to your story'**
  String get storyReplyNotificationsDesc;

  /// No description provided for @notificationSound.
  ///
  /// In en, this message translates to:
  /// **'Notification Sound'**
  String get notificationSound;

  /// No description provided for @notificationSoundDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose the sound for your notifications'**
  String get notificationSoundDesc;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @vibrationDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable or disable vibration for notifications'**
  String get vibrationDesc;

  /// No description provided for @messagePreview.
  ///
  /// In en, this message translates to:
  /// **'Message Preview'**
  String get messagePreview;

  /// No description provided for @messagePreviewDesc.
  ///
  /// In en, this message translates to:
  /// **'Show a preview of the notification'**
  String get messagePreviewDesc;

  /// No description provided for @inAppSound.
  ///
  /// In en, this message translates to:
  /// **'In-App Sound'**
  String get inAppSound;

  /// No description provided for @inAppSoundDesc.
  ///
  /// In en, this message translates to:
  /// **'Play sound for incoming messages'**
  String get inAppSoundDesc;

  /// No description provided for @noStoryFound.
  ///
  /// In en, this message translates to:
  /// **'No story found'**
  String get noStoryFound;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// No description provided for @unlike.
  ///
  /// In en, this message translates to:
  /// **'Unlike'**
  String get unlike;

  /// No description provided for @viewed.
  ///
  /// In en, this message translates to:
  /// **'Viewed'**
  String get viewed;

  /// No description provided for @viewers.
  ///
  /// In en, this message translates to:
  /// **'Viewers'**
  String get viewers;

  /// No description provided for @viewersSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Viewers'**
  String get viewersSheetTitle;

  /// No description provided for @viewersSheetDescription.
  ///
  /// In en, this message translates to:
  /// **'Viewers of this story'**
  String get viewersSheetDescription;

  /// No description provided for @tapToSeeWhoViewed.
  ///
  /// In en, this message translates to:
  /// **'Tap to see who viewed your story'**
  String get tapToSeeWhoViewed;

  /// No description provided for @replyToStory.
  ///
  /// In en, this message translates to:
  /// **'Reply to story...'**
  String get replyToStory;

  /// No description provided for @voiceMessage.
  ///
  /// In en, this message translates to:
  /// **'Voice Message'**
  String get voiceMessage;

  /// No description provided for @slideToCancel.
  ///
  /// In en, this message translates to:
  /// **'Slide to cancel'**
  String get slideToCancel;

  /// No description provided for @releaseToCancel.
  ///
  /// In en, this message translates to:
  /// **'Release to cancel'**
  String get releaseToCancel;

  /// No description provided for @deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete Message'**
  String get deleteMessage;

  /// No description provided for @deleteMessageConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this message?'**
  String get deleteMessageConfirm;

  /// No description provided for @deleteMessageSuccess.
  ///
  /// In en, this message translates to:
  /// **'Message deleted successfully'**
  String get deleteMessageSuccess;

  /// No description provided for @deleteMessageFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete message'**
  String get deleteMessageFailed;

  /// No description provided for @pinchToZoomTapToClose.
  ///
  /// In en, this message translates to:
  /// **'Pinch to zoom  ·  Tap to close'**
  String get pinchToZoomTapToClose;

  /// No description provided for @chatInfo.
  ///
  /// In en, this message translates to:
  /// **'Chat Info'**
  String get chatInfo;

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'minute'**
  String get minute;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @ago.
  ///
  /// In en, this message translates to:
  /// **'ago'**
  String get ago;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @noViewsYet.
  ///
  /// In en, this message translates to:
  /// **'No views yet'**
  String get noViewsYet;

  /// No description provided for @addCount.
  ///
  /// In en, this message translates to:
  /// **'Add ({count})'**
  String addCount(Object count);

  /// No description provided for @createCount.
  ///
  /// In en, this message translates to:
  /// **'Create ({count})'**
  String createCount(Object count);

  /// No description provided for @leaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave Group'**
  String get leaveGroup;

  /// No description provided for @leaveGroupConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave this group?'**
  String get leaveGroupConfirm;

  /// No description provided for @leaveGroupOwnerConfirm.
  ///
  /// In en, this message translates to:
  /// **'You are the owner. Ownership will be transferred to the next member when you leave.'**
  String get leaveGroupOwnerConfirm;

  /// No description provided for @leaveAndTransfer.
  ///
  /// In en, this message translates to:
  /// **'Leave & Transfer Ownership'**
  String get leaveAndTransfer;

  /// No description provided for @createAGroupWithThisUser.
  ///
  /// In en, this message translates to:
  /// **'Create a group with this user'**
  String get createAGroupWithThisUser;

  /// No description provided for @commonGroups.
  ///
  /// In en, this message translates to:
  /// **'Common Groups'**
  String get commonGroups;

  /// No description provided for @emailOrPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Email or password incorrect'**
  String get emailOrPasswordIncorrect;

  /// No description provided for @thisOperationFailed.
  ///
  /// In en, this message translates to:
  /// **'This operation failed.'**
  String get thisOperationFailed;

  /// No description provided for @emailCannotBeChanged.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be changed'**
  String get emailCannotBeChanged;

  /// No description provided for @usernameCannotBeChanged.
  ///
  /// In en, this message translates to:
  /// **'Username cannot be changed'**
  String get usernameCannotBeChanged;

  /// No description provided for @couldNotLoadFile.
  ///
  /// In en, this message translates to:
  /// **'Could Not Load File'**
  String get couldNotLoadFile;

  /// No description provided for @brightnessDescription.
  ///
  /// In en, this message translates to:
  /// **'Adjust overlay darkness to improve text readability'**
  String get brightnessDescription;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to reset your password.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent! Check your inbox or spam folder.'**
  String get resetLinkSent;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully!'**
  String get passwordChangedSuccess;

  /// No description provided for @backTo.
  ///
  /// In en, this message translates to:
  /// **'Back to'**
  String get backTo;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email address before logging in. Check your inbox or spam folder.'**
  String get emailNotVerified;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailDescription.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to your email address. Please check your inbox (and spam folder) and tap the link to verify.'**
  String get verifyEmailDescription;

  /// No description provided for @resendVerification.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get resendVerification;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(Object seconds);

  /// No description provided for @waitingForVerification.
  ///
  /// In en, this message translates to:
  /// **'Waiting for verification...'**
  String get waitingForVerification;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @emailVerificationSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent!'**
  String get emailVerificationSent;

  /// No description provided for @emailVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send verification email.'**
  String get emailVerificationFailed;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
