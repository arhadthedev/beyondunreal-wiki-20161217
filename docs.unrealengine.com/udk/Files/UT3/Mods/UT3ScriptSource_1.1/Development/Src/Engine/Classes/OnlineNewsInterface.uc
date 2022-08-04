/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This interface provides functions for reading game specific news and announcements
 */
interface OnlineNewsInterface dependson(OnlineSubsystem);

/**
 * Reads the game specific news from the online subsystem
 *
 * @param LocalUserNum the local user the news is being read for
 *
 * @return true if the async task was successfully started, false otherwise
 */
function bool ReadGameNews(byte LocalUserNum);

/**
 * Delegate used in notifying the UI/game that the news read operation completed
 *
 * @param bWasSuccessful true if the read completed ok, false otherwise
 */
delegate OnReadGameNewsCompleted(bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that news reading has completed
 *
 * @param ReadGameNewsDelegate the delegate to use for notifications
 */
function AddReadGameNewsCompletedDelegate(delegate<OnReadGameNewsCompleted> ReadGameNewsDelegate);

/**
 * Removes the specified delegate from the notification list
 *
 * @param ReadGameNewsDelegate the delegate to use for notifications
 */
function ClearReadGameNewsCompletedDelegate(delegate<OnReadGameNewsCompleted> ReadGameNewsDelegate);

/**
 * Returns the game specific news from the cache
 *
 * @param LocalUserNum the local user the news is being read for
 *
 * @return an empty string if no news was read, otherwise the contents of the read
 */
function string GetGameNews(byte LocalUserNum);

/**
 * Reads the game specific content announcements from the online subsystem
 *
 * @param LocalUserNum the local user the request is for
 *
 * @return true if the async task was successfully started, false otherwise
 */
function bool ReadContentAnnouncements(byte LocalUserNum);

/**
 * Delegate used in notifying the UI/game that the content announcements read operation completed
 *
 * @param bWasSuccessful true if the read completed ok, false otherwise
 */
delegate OnReadContentAnnouncementsCompleted(bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that content announcements reading has completed
 *
 * @param ReadContentAnnouncementsDelegate the delegate to use for notifications
 */
function AddReadContentAnnouncementsCompletedDelegate(delegate<OnReadContentAnnouncementsCompleted> ReadContentAnnouncementsDelegate);

/**
 * Removes the specified delegate from the notification list
 *
 * @param ReadContentAnnouncementsDelegate the delegate to use for notifications
 */
function ClearReadContentAnnouncementsCompletedDelegate(delegate<OnReadContentAnnouncementsCompleted> ReadContentAnnouncementsDelegate);

/**
 * Returns the game specific content announcements from the cache
 *
 * @param LocalUserNum the local user the content announcements is being read for
 *
 * @return an empty string if no data was read, otherwise the contents of the read
 */
function string GetContentAnnouncements(byte LocalUserNum);

