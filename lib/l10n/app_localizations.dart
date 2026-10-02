import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_localizations_en.dart';
import 'app_localizations_ne.dart';

// Hand-checked equivalent of Flutter gen_l10n output. The ARB files are the
// source of truth; `flutter gen-l10n` may regenerate these classes.
abstract class AppLocalizations {
  AppLocalizations(this.localeName);

  final String localeName;

  static AppLocalizations? of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ne'),
  ];

  String get appTitle;

  String get next;

  String get language;

  String get changeLanguage;

  String get english;

  String get nepali;

  String get cancel;

  String get save;

  String get tryAgain;

  String get edit;

  String get close;

  String get offline;

  String get allSaved;

  String get upToDate;

  String get saving;

  String get backupIssue;

  String get yourBooks;

  String get booksIntroduction;

  String get startNewBook;

  String get voiceComesFirst;

  String get voiceGuideDetail;

  String get openBook;

  String get chooseChapter;

  String get recordVoice;

  String get deleteBookQuestion;

  String get deleteBook;

  String get bookDeleted;

  String get bookCouldNotBeDeleted;

  String get searchYourBooks;

  String get noBooksFound;

  String get changeBookSearch;

  String get booksUnavailable;

  String get noBooksYet;

  String get checkConnection;

  String get emptyBooksHelp;

  String get allCategories;

  String get readyFirstChapter;

  String get bookActions;

  String get editBook;

  String get today;

  String get yesterday;

  String get categoryBook;

  String get categoryMemoir;

  String get categoryTravel;

  String get categoryMilitary;

  String get categoryHeritage;

  String get categoryPhilosophy;

  String get categoryBusiness;

  String get categoryFiction;

  String get projectStatusDraft;

  String get projectStatusAssigned;

  String get projectStatusInProgress;

  String get projectStatusOnHold;

  String get projectStatusCompleted;

  String get projectStatusArchived;

  String get editBookPage;

  String get bookFormIntro;

  String get bookTitle;

  String get bookTitleHint;

  String get bookTitleRequired;

  String get bookAbout;

  String get bookAboutHint;

  String get bookKind;

  String get writingProgress;

  String get saveChanges;

  String get createMyBook;

  String get bookBackupHelp;

  String get bookTypeBiography;

  String get bookTypeMemoir;

  String get bookTypeSelfHelp;

  String get bookTypeFiction;

  String get bookTypeBusiness;

  String get bookTypeAcademic;

  String get couldNotOpenBook;

  String get untitled;

  String get bookFallback;

  String get readyShareMemory;

  String get chapterRecordingGuide;

  String get yourChapters;

  String get searchChapters;

  String get deleteChapterQuestion;

  String get deleteChapter;

  String get chapterDeleted;

  String get chapterCouldNotBeDeleted;

  String get noChaptersYet;

  String get noChaptersHelp;

  String get noChapterMatches;

  String get addChapter;

  String get planned;

  String get collecting;

  String get drafting;

  String get inReview;

  String get completed;

  String get waitingForBackup;

  String get noChaptersInBook;

  String get overall;

  String get wordCount;

  String get wordsWrittenSoFar;

  String get chapterNotFound;

  String get yourChapter;

  String get recordVoiceChapterSemantics;

  String get recordVoiceTitle;

  String get yourRecordingsAndFiles;

  String get removeSourceQuestion;

  String get onlineCopyAlsoRemoved;

  String get keep;

  String get remove;

  String get updateProgress;

  String get noRecordingsYet;

  String get noRecordingsHelp;

  String get editChapter;

  String get addAChapter;

  String get chapterFormIntro;

  String get chapterNumber;

  String get chapterNumberError;

  String get chapterTitleLabel;

  String get chapterTitleHint;

  String get chapterPrompt;

  String get chapterPromptHint;

  String get wordGoal;

  String get addThisChapter;

  String get parentBookLoading;

  String get openChapter;

  String get voiceOrFilesAdded;

  String get readyToBegin;

  String get collectingStories;

  String get writingInProgress;

  String get readyToReview;

  String get noVoiceRecording;

  String get fileOpenError;

  String get allowMicrophoneSuffix;

  String get pleaseTryAgainSuffix;

  String get couldNotSaveRecording;

  String get discardRecordingQuestion;

  String get unsavedRecordingWarning;

  String get keepRecording;

  String get discard;

  String get recordingYourVoice;

  String get tellYourStory;

  String get speakNaturally;

  String get voiceIsEasiest;

  String get startRecordingSemantics;

  String get startRecordingHint;

  String get recommended;

  String get openingMicrophone;

  String get startVoiceRecording;

  String get tapThenSpeak;

  String get otherWaysToAdd;

  String get chooseFile;

  String get recordingNow;

  String get speakAtOwnPace;

  String get savingRecording;

  String get stopAndSave;

  String get discardAndRestart;

  String get openPhoneSettings;

  String get offlineRecordingSafe;

  String get fileUnavailable;

  String get voiceRecording;

  String get savedFile;

  String get doubleTapListen;

  String get doubleTapOpen;

  String get tapToListen;

  String get removeThisItem;

  String get video;

  String get image;

  String get document;

  String get processingNotStarted;

  String get processingQueued;

  String get processingTranscribing;

  String get processingDiarizing;

  String get processingIngesting;

  String get processingReady;

  String get processingFailed;

  String get backedUp;

  String get savedOnDevice;

  String get gettingReadyBackup;

  String get pausedForConnection;

  String get backupFailed;

  String get retry;

  String get audioNotFound;

  String get listenToRecording;

  String get recordingPosition;

  String get backTenSeconds;

  String get pauseRecording;

  String get playRecording;

  String get forwardTenSeconds;

  String get playing;

  String get paused;

  String get backupStatus;

  String get needsAttention;

  String get tryAllAgain;

  String get nothingWaiting;

  String get everythingSaved;

  String get noOnlineCopyYet;

  String get backupNow;

  String get retryFailed;

  String get taskNeedsHelp;

  String get taskWaiting;

  String get taskProject;

  String get taskBook;

  String get taskChapter;

  String get taskSource;

  String get taskBackup;

  String get taskProgress;

  String get taskCreate;

  String get taskUpdate;

  String get taskDelete;

  String get taskUpload;

  String get taskDownload;

  String get noInternet;

  String get microphonePermissionNeeded;

  String get recordingStartFailed;

  String get nothingRecording;

  String get emptyRecording;

  String get sourcesReadError;

  String get savedAndBackedUpLater;

  String get recordingSavedOnDevice;

  String get sourceRemoved;

  String get backupWillRetry;

  String countWaiting(int count);

  String deleteBookBody(String name);

  String couldNotDeleteBook(String error);

  String bookSemantics(String title);

  String byAuthor(String author);

  String chaptersComplete(int completed, int total);

  String wordsOfGoal(String written, String target);

  String updatedWhen(String when);

  String daysAgo(int count);

  String monthsAgo(int count);

  String yearsAgo(int count);

  String chooseMemoryForBook(String title);

  String chapterTitle(int number);

  String deleteChapterBody(String title);

  String couldNotDeleteChapter(String error);

  String lastActive(String when);

  String percentDone(int percent);

  String wordsCount(String count);

  String overallPercent(int percent);

  String chapterSemantics(int number, String title);

  String draftVersion(int version);

  String voiceRecordingCount(int count);

  String savedItemCount(int count);

  String wordsWritten(String count);

  String waitingBackupCount(int count);

  String goalWords(String count);

  String chapterWordsProgress(int current, int target);

  String removeSourceBody(String name);

  String failureWithSuffix(String failure, String suffix);

  String recordingElapsed(String minutes, String seconds);

  String sourceSemantics(String type, String name);

  String voiceDetails(String size, String duration);

  String videoDetails(String size);

  String imageDetails(String size);

  String documentDetails(String size);

  String processingStatus(String status);

  String backingUpPercent(int percent);

  String audioLoadError(String error);

  String positionOfDuration(String position, String duration);

  String itemsNeedAttention(int count);

  String itemsWaitingBackup(int count);

  String lastBackup(String time);

  String attemptCount(int count);

}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));

  @override
  bool isSupported(Locale locale) => <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ne':
      return AppLocalizationsNe();
  }
  throw FlutterError('Unsupported locale: $locale');
}
