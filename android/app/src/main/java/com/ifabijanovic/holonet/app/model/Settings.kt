package com.ifabijanovic.holonet.app.model

/**
 * Created by feb on 19/03/2017.
 */
class Settings {
    val appEmail: String
    val baseForumUrl: String
    val devTrackerIconUrl: String
    val devAvatarUrl: String
    val stickyIconUrl: String
    val dulfyNetUrl: String
    val requestTimeout: Int
    val localized: Map<String, LocalizedSettings>

    init {
        // TODO load all settings from a config file

        this.appEmail = "holonet.swtor@gmail.com"
        this.baseForumUrl = "http://www.swtor.com"
        this.devTrackerIconUrl = "http://cdn-www.swtor.com/sites/all/files/en/coruscant/main/forums/icons/devtracker_icon.png"
        this.devAvatarUrl = "http://www.swtor.com/sites/all/files/avatars/BioWare.gif"
        this.stickyIconUrl = "http://cdn-www.swtor.com/community/images/swtor/misc/sticky.gif"
        this.dulfyNetUrl = "http://dulfy.net"
        this.requestTimeout = 10000

        val en = LocalizedSettings("", 3, 304)
        val fr = LocalizedSettings("fr", 4, 305)
        val de = LocalizedSettings("de", 5, 306)
        this.localized = hashMapOf("en" to en, "fr" to fr, "de" to de)
    }
}

data class LocalizedSettings(
        val pathPrefix: String,
        val rootCategoryId: Int,
        val devTrackerId: Int
) {}
