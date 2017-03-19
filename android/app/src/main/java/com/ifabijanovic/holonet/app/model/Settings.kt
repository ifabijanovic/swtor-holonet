package com.ifabijanovic.holonet.app.model

/**
 * Created by feb on 19/03/2017.
 */
class Settings() {
    val appEmail: String
    val categoryQueryParam: String
    val threadQueryParam: String
    val postQueryParam: String
    val pageQueryParam: String
    val devTrackerIconUrl: String
    val devAvatarUrl: String
    val stickyIconUrl: String
    val dulfyNetUrl: String
    val requestTimeout: Int
    val localized: Map<String, LocalizedSettings>

    init {
        // TODO load all settings from a config file

        this.appEmail = "holonet.swtor@gmail.com"
        this.categoryQueryParam = "f"
        this.threadQueryParam = "t"
        this.postQueryParam = "p"
        this.pageQueryParam = "page"
        this.devTrackerIconUrl = "http://cdn-www.swtor.com/sites/all/files/en/coruscant/main/forums/icons/devtracker_icon.png"
        this.devAvatarUrl = "http://www.swtor.com/sites/all/files/avatars/BioWare.gif"
        this.stickyIconUrl = "http://cdn-www.swtor.com/community/images/swtor/misc/sticky.gif"
        this.dulfyNetUrl = "http://dulfy.net"
        this.requestTimeout = 10

        val en = LocalizedSettings(3, "http://www.swtor.com/community/forumdisplay.php", "http://www.swtor.com/community/showthread.php", "http://www.swtor.com/community/devtracker.php", 304)
        val fr = LocalizedSettings(4, "http://www.swtor.com/fr/community/forumdisplay.php", "http://www.swtor.com/fr/community/showthread.php", "http://www.swtor.com/fr/community/devtracker.php?language=de", 305)
        val de = LocalizedSettings(5, "http://www.swtor.com/de/community/forumdisplay.php", "http://www.swtor.com/de/community/showthread.php", "http://www.swtor.com/de/community/devtracker.php?language=de", 306)
        this.localized = hashMapOf("en" to en, "fr" to fr, "de" to de)
    }
}

data class LocalizedSettings(
        val rootCategoryId: Int,
        val forumDisplayUrl: String,
        val threadDisplayUrl: String,
        val devTrackerUrl: String,
        val devTrackerId: Int
) {}
