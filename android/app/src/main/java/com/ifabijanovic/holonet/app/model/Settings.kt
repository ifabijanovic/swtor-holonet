package com.ifabijanovic.holonet.app.model

/**
 * Created by feb on 19/03/2017.
 */
interface Settings {
    val appEmail: String
    val categoryQueryParam: String
    val threadQueryParam: String
    val baseForumUrl: String
    val devTrackerIconUrl: String
    val devAvatarUrl: String
    val stickyIconUrl: String
    val dulfyNetUrl: String
    val requestTimeout: Int
    val localized: Map<String, LocalizedSettings>
}

data class LocalizedSettings(
        val pathPrefix: String,
        val rootCategoryId: Int,
        val devTrackerId: Int
) {}

class AppSettings: Settings {
    override val appEmail: String = "holonet.swtor@gmail.com"
    override val categoryQueryParam: String = "f"
    override val threadQueryParam: String = "t"
    override val baseForumUrl: String = "http://www.swtor.com"
    override val devTrackerIconUrl: String = "http://cdn-www.swtor.com/sites/all/files/en/coruscant/main/forums/icons/devtracker_icon.png"
    override val devAvatarUrl: String = "http://www.swtor.com/sites/all/files/avatars/BioWare.gif"
    override val stickyIconUrl: String = "http://cdn-www.swtor.com/community/images/swtor/misc/sticky.gif"
    override val dulfyNetUrl: String = "http://dulfy.net"
    override val requestTimeout: Int = 10000
    override val localized: Map<String, LocalizedSettings>

    init {
        val en = LocalizedSettings("", 3, 304)
        val fr = LocalizedSettings("fr", 4, 305)
        val de = LocalizedSettings("de", 5, 306)
        this.localized = hashMapOf("en" to en, "fr" to fr, "de" to de)
    }
}
